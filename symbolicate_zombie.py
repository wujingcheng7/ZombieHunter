#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import os
import re
import subprocess
import sys
from bisect import bisect_left

class BinaryImage:
    __slots__ = ('start', 'end', 'name', 'arch', 'uuid', 'path', 'start_int', 'end_int')
    
    def __init__(self, start, end, name, arch, uuid, path):
        self.start = start
        self.end = end
        self.name = name
        self.arch = arch
        self.uuid = uuid.replace('-', '').lower()
        self.path = path
        self.start_int = int(start, 16)
        self.end_int = int(end, 16)
    
    def contains_address(self, address):
        addr_int = int(address, 16)
        return self.start_int <= addr_int <= self.end_int

class ImageManager:
    def __init__(self):
        self.images = []
        self.sorted_starts = []
    
    def add_image(self, image):
        self.images.append(image)
        # 在插入时保持start地址有序
        pos = bisect_left(self.sorted_starts, image.start_int)
        self.sorted_starts.insert(pos, image.start_int)
        self.images.sort(key=lambda x: x.start_int)
    
    def find_image(self, address):
        addr_int = int(address, 16)
        # 使用二分查找定位可能的image
        pos = bisect_left(self.sorted_starts, addr_int)
        if pos == 0:
            if addr_int < self.sorted_starts[0]:
                return None
        elif pos >= len(self.sorted_starts):
            pos = len(self.sorted_starts) - 1
        
        # 检查找到的image
        candidate = self.images[pos - 1] if pos > 0 else self.images[0]
        if candidate.contains_address(address):
            return candidate
        
        # 检查相邻的image
        for img in [self.images[pos - 1], self.images[pos]]:
            if img.contains_address(address):
                return img
        return None

def get_dwarf_uuid(dwarf_path, arch):
    """获取DWARF文件的UUID"""
    cmd = ['dwarfdump', '--arch', arch, '-u', dwarf_path]
    try:
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, text=True)
        uuid_match = re.search(r'UUID: ([0-9A-Fa-f-]+)', output)
        if uuid_match:
            return uuid_match.group(1).replace('-', '').lower()
    except subprocess.CalledProcessError as e:
        print(f"dwarfdump failed: {e}")
    return None

def symbolize_address(addr, image_manager, dsym_path):
    """符号化单个地址"""
    image = image_manager.find_image(addr)
    if not image:
        return f"{addr} [Unknown Image]"
    
    # 主应用框架使用提供的dSYM
    if '.app/' in image.path and dsym_path:
        dwarf_file = os.path.join(dsym_path, 'Contents', 'Resources', 'DWARF', image.name)
        if not os.path.exists(dwarf_file):
            dwarf_file = dsym_path  # 可能直接是dwarf文件
        
        # 验证UUID匹配
        dwarf_uuid = get_dwarf_uuid(dwarf_file, image.arch)
        if dwarf_uuid and dwarf_uuid != image.uuid:
            return f"{addr} [UUID Mismatch: {image.uuid} vs {dwarf_uuid}]"
    else:
        # 系统框架使用原始路径
        dwarf_file = image.path
        if not os.path.exists(dwarf_file):
            offset = int(addr, 16) - image.start_int
            return f"{image.name} + {hex(offset)}"
    
    # 使用atos进行符号化
    cmd = ['atos', '-arch', image.arch, '-o', dwarf_file, 
           '-l', image.start, addr]
    try:
        symbol = subprocess.check_output(cmd, stderr=subprocess.STDOUT, text=True).strip()
        return symbol if symbol else f"{image.name} + {hex(int(addr, 16) - image.start_int)}"
    except subprocess.CalledProcessError as e:
        return f"{addr} [atos error: {e}]"

def parse_stack_string(stack_str):
    """解析堆栈字符串，提取线程ID和地址列表"""
    tid_match = re.search(r'tid:(\d+)', stack_str)
    tid = tid_match.group(1) if tid_match else "unknown"
    
    stack_match = re.search(r'stack:\[([^\]]+)\]', stack_str)
    if not stack_match:
        return tid, []
    
    addresses = [addr.strip() for addr in stack_match.group(1).split(',') if addr.strip()]
    return tid, addresses

def symbolize_stack(addresses, image_manager, dsym_path, stack_name, progress_offset, total_addresses):
    """符号化整个堆栈并显示进度"""
    symbolized = []
    for i, addr in enumerate(addresses):
        # 更新进度
        current_count = progress_offset + i + 1
        progress = int((current_count / total_addresses) * 100)
        sys.stdout.write(f"\r[{progress}%] Symbolicating {stack_name} ({current_count}/{total_addresses})")
        sys.stdout.flush()
        
        symbolized.append(symbolize_address(addr, image_manager, dsym_path))
    
    return symbolized

def main():
    # 解析命令行参数
    parser = argparse.ArgumentParser(description='Symbolicate zombie crash logs')
    parser.add_argument('path_to_json', help='Path to input JSON file')
    parser.add_argument('path_to_dsym', help='Path to dSYM file or directory')
    parser.add_argument('output_dir', help='Output directory for zombie.log')
    args = parser.parse_args()
    
    # 确保输出目录存在
    os.makedirs(args.output_dir, exist_ok=True)
    output_file = os.path.join(args.output_dir, 'zombie.log')
    
    print("[10%] Loading JSON file...")
    try:
        with open(args.path_to_json) as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading JSON file: {e}")
        sys.exit(1)
    
    print("[20%] Parsing binary images...")
    image_manager = ImageManager()
    for image_str in data['binaryImages']:
        # 解析二进制映像字符串
        pattern = r'^(0x[0-9a-fA-F]+)\s*-\s*(0x[0-9a-fA-F]+)\s+([^\s]+)\s+(\w+)\s+<([^>]+)>\s+(.*)$'
        match = re.match(pattern, image_str.strip())
        if match:
            img = BinaryImage(
                start=match.group(1),
                end=match.group(2),
                name=match.group(3),
                arch=match.group(4),
                uuid=match.group(5),
                path=match.group(6)
            )
            image_manager.add_image(img)
    
    if not image_manager.images:
        print("Warning: No valid binary images found in JSON")
    
    # 解析堆栈地址
    print("[30%] Parsing stack addresses...")
    zombie_tid, zombie_addresses = parse_stack_string(data['zombieStack'])
    dealloc_tid, dealloc_addresses = parse_stack_string(data['deallocStack'])
    total_addresses = len(zombie_addresses) + len(dealloc_addresses)
    
    if total_addresses == 0:
        print("Warning: No stack addresses found in JSON")
    
    # 符号化僵尸堆栈
    print("\n[40%] Symbolicating zombie stack...")
    zombie_symbols = symbolize_stack(
        zombie_addresses, image_manager, args.path_to_dsym,
        "zombie", 0, total_addresses
    )
    
    # 符号化释放堆栈
    print("\n[70%] Symbolicating dealloc stack...")
    dealloc_symbols = symbolize_stack(
        dealloc_addresses, image_manager, args.path_to_dsym,
        "dealloc", len(zombie_addresses), total_addresses
    )
    
    # 写入输出文件
    print("\n[90%] Writing zombie.log file...")
    with open(output_file, 'w') as f:
        f.write(f"ClassName: {data.get('className', 'Unknown')}\n")
        f.write(f"ZombieObjectAddress: {data.get('zombieObjectAddress', '0x0')}\n")
        f.write(f"SelectorName: {data.get('selectorName', 'Unknown')}\n\n")
        
        f.write("ZombieStack:\n")
        f.write(f"tid: {zombie_tid}\n")
        for i, (addr, symbol) in enumerate(zip(zombie_addresses, zombie_symbols)):
            f.write(f"[{i}] {addr} -> {symbol}\n")
        
        f.write("\nDeallocStack:\n")
        f.write(f"tid: {dealloc_tid}\n")
        for i, (addr, symbol) in enumerate(zip(dealloc_addresses, dealloc_symbols)):
            f.write(f"[{i}] {addr} -> {symbol}\n")
    
    print(f"\n[100%] Symbolication complete. Results saved to {output_file}")

if __name__ == "__main__":
    main()