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

  s.subspec 'oc-hunter-no-arc' do |sp|
    sp.source_files = 'oc-hunter-no-arc/*.{h,hpp,mm}'
    sp.requires_arc = false
  end

  s.subspec 'oc-hunter-arc' do |sp|
    sp.source_files = 'oc-hunter-arc/*.{h,m,c}'
    sp.requires_arc = true
  end

  s.subspec 'c-hunter' do |sp|
    sp.source_files = 'c-hunter/*.{h,c}'
  end

  s.subspec 'facebook-fishhook' do |sp|
    sp.source_files = 'facebook-fishhook/*.{h,c}'
  end

end
