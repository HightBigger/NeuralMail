Pod::Spec.new do |s|
  s.name         = "MailCore2"
  s.version      = "0.6.4"
  s.summary      = "MailCore2 XCFramework"
  s.description  = "Local wrapper for MailCore2 xcframework"
  s.homepage     = "http://libmailcore.com"
  s.license      = "BSD"
  s.author       = { "MailCore" => "info@libmailcore.com" }
  s.platform     = :ios, "13.0"
  
  # 指向当前目录
  s.source       = { :path => "." }
  
  s.vendored_frameworks = "MailCore.xcframework"
  
  s.libraries = "z", "iconv", "c++"
  s.frameworks = "CFNetwork", "Security"
  
  s.pod_target_xcconfig = { 
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }
end
