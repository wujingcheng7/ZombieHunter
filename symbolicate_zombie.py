#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
import sys
import json
import zipfile
import subprocess
from tempfile import TemporaryDirectory

def extract_dsym(zip_path, extract_dir):
    """解压 dsym.zip 文件"""
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_dir)
    # 查找 DWARF 文件
    for root, _, files in os.walk(extract_dir):
        for file in files:
            if file == 'Tutor':  # 修改为你的二进制名称
                return os.path.join(root, file)
    return None

def get_binary_info(binary_path):
    """获取二进制文件的架构和UUID"""
    cmd = ['dwarfdump', '--arch=all', '--uuid', binary_path]
    result = subprocess.run(cmd, capture_output=True, text=True)
    info = {'architectures': [], 'uuids': {}}
    if result.returncode == 0:
        for line in result.stdout.splitlines():
            if 'UUID:' in line:
                parts = line.split()
                arch = parts[1].strip('()')
                uuid = parts[2]
                info['architectures'].append(arch)
                info['uuids'][arch] = uuid
    return info

def symbolicating(architecture, executable, load_address, address, uuid=None):
    """符号化单个地址"""
    cmd = [
        'atos',
        '-arch', architecture,
        '-o', executable,
        '-l', load_address,
        address
    ]
    if uuid:
        cmd.extend(['--uuid', uuid])
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0 and result.stdout.strip() != address:
        return result.stdout.strip()
    return None

def parse_stack(stack_str):
    """解析堆栈字符串"""
    tid_match = re.search(r'tid:(\d+)', stack_str)
    stack_match = re.search(r'stack:\[([^\]]+)', stack_str)
    
    tid = tid_match.group(1) if tid_match else 'unknown'
    addresses = []
    if stack_match:
        addresses = [addr.strip() for addr in stack_match.group(1).split(',') if addr.strip()]
    
    return tid, addresses

def parse_binary_images(binary_images):
    """解析binaryImages字符串为字典"""
    images = {}
    # 示例格式: "0x100000000-0x1000ffff Tutor arm64 <uuid> /path/to/Tutor"
    image_re = re.compile(r'(0x[0-9a-f]+)\s*-\s*(0x[0-9a-f]+)\s+([^\s]+)\s+([^\s]+)\s+<([^>]+)>\s*(.*)')
    
    for line in binary_images:
        match = image_re.match(line)
        if match:
            start, end, name, arch, uuid, path = match.groups()
            images[name] = {
                'start': int(start, 16),
                'end': int(end, 16),
                'arch': arch,
                'uuid': uuid,
                'path': path
            }
    return images

def get_image_for_address(address, images):
    """确定地址属于哪个镜像"""
    addr_num = int(address, 16)
    for name, image in images.items():
        if addr_num >= image['start'] and addr_num <= image['end']:
            return image
    return None

def symbolicate_stack(addresses, images, binary_path, default_arch='arm64'):
    """符号化整个堆栈"""
    results = []
    for i, address in enumerate(addresses):
        image = get_image_for_address(address, images)
        if image:
            symbol = symbolicating(
                image.get('arch', default_arch),
                image.get('path', binary_path),
                hex(image['start']),
                address,
                image.get('uuid')
            )
            image_name = os.path.basename(image.get('path', ''))
        else:
            symbol = None
            image_name = 'unknown'
        
        if symbol:
            results.append(f"{i}\t{address}\t{image_name}\t{symbol}")
        else:
            results.append(f"{i}\t{address}\t{image_name}\t[unknown]")
    return '\n'.join(results)

# python3 symbolicate_zombie.py {json_path} {dsym_zip_path} {output_dir}
def process_zombie_data(json_path, dsym_zip_path, output_dir):
    """处理僵尸数据"""
    # 读取 JSON 文件
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    # 解析binaryImages
    if 'binaryImages' not in data:
        print("Error: Missing 'binaryImages' in JSON file")
        return
    
    images = parse_binary_images(data['binaryImages'])
    
    # 解压 dsym.zip
    with TemporaryDirectory() as temp_dir:
        binary_path = extract_dsym(dsym_zip_path, temp_dir)
        if not binary_path:
            print("Error: Failed to extract or find binary in dsym.zip")
            return
        
        # 获取二进制信息
        binary_info = get_binary_info(binary_path)
        print(f"Binary Info: {binary_info}")
        
        # 更新应用镜像信息
        app_name = os.path.basename(binary_path)
        if app_name in images:
            images[app_name]['path'] = binary_path
            if binary_info['uuids']:
                images[app_name]['uuid'] = binary_info['uuids'].get('arm64', '')
        
        # 解析和符号化堆栈
        zombie_tid, zombie_addresses = parse_stack(data['zombieStack'])
        dealloc_tid, dealloc_addresses = parse_stack(data['deallocStack'])
        
        zombie_symbolicated = symbolicate_stack(zombie_addresses, images, binary_path)
        dealloc_symbolicated = symbolicate_stack(dealloc_addresses, images, binary_path)
        
        # 生成输出文件
        output_path = os.path.join(output_dir, 'symbolicated_zombie.log')
        with open(output_path, 'w') as f:
            f.write(f"Zombie Class: {data['className']}\n")
            f.write(f"Zombie Object Address: {data.get('zombieObjectAddress', '0x0')}\n")
            f.write(f"Selector: {data['selectorName']}\n\n")
            
            f.write("Zombie Stack (tid: {}):\n".format(zombie_tid))
            f.write("Index\tAddress\t\tImage\t\tSymbol\n")
            f.write(zombie_symbolicated)
            f.write("\n\n")
            
            f.write("Dealloc Stack (tid: {}):\n".format(dealloc_tid))
            f.write("Index\tAddress\t\tImage\t\tSymbol\n")
            f.write(dealloc_symbolicated)
        
        print(f"Symbolicated output saved to: {output_path}")

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python symbolicate_zombie.py <json_path> <dsym_zip_path> <output_dir>")
        sys.exit(1)
    
    json_path = sys.argv[1]
    dsym_zip_path = sys.argv[2]
    output_dir = sys.argv[3]
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    process_zombie_data(json_path, dsym_zip_path, output_dir)