Pod::Spec.new do |s|

  s.name          = "ZombieHunter"
  s.version       = "0.0.1"
  s.summary       = "iOS find Zombie object, support both C/OC"

  s.description   = <<-DESC
   中文:
   找到iOS中的僵尸对象(aka.野指针)，让其尽早暴露
                   DESC

  s.homepage      = "https://github.com/wujingcheng7/ZombieHunter"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "wujc" => "love@jingchengwu.cn" }
  s.platform      = :ios, "8.0"
  s.frameworks    = 'Foundation'
  s.source        = { :git => "https://github.com/wujingcheng7/ZombieHunter.git", :tag => "#{s.version}" }

  s.requires_arc  = true
  s.libraries    = 'c++'
  s.pod_target_xcconfig = {
      'CLANG_CXX_LIBRARY' => 'libc++'
  }

  s.subspec 'all-in-one' do |sp|
    sp.source_files = 'all-in-one/*.{h,m,mm}'
    sp.requires_arc = true
    sp.frameworks   = 'Foundation'
  end

  s.subspec 'c-hunter' do |sp|
    sp.source_files = 'c-hunter/*.{h,c,mm}'
    sp.requires_arc = true
    sp.frameworks   = 'Foundation'
  end
  
  s.subspec 'oc-hunter-no-arc' do |sp|
    sp.source_files = 'oc-hunter-no-arc/*.{h,hpp,mm}'
    sp.requires_arc = false
    sp.frameworks   = 'Foundation'
    sp.libraries    = 'c++'
  end

  s.subspec 'oc-hunter-arc' do |sp|
    sp.source_files = 'oc-hunter-arc/*.{h,m,c}'
    sp.requires_arc = true
    sp.frameworks   = 'Foundation'
  end

  s.subspec 'facebook-fishhook' do |sp|
    sp.source_files = 'facebook-fishhook/*.{h,c}'
    sp.requires_arc = false
  end

end
