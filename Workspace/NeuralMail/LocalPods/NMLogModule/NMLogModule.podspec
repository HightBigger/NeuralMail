Pod::Spec.new do |s|
  s.name         = 'NMLogModule'
  s.version      = '2.0.0'
  s.author       = 'xiaoda'
  s.license      = { :type => 'MIT', :text => 'Copyright 2023' }
  s.homepage     = 'http://www.uusafe.com'
  s.summary      = 'NMLogModule'
  s.source       = { :git => '', :tag => s.version.to_s }
  s.platform     = :ios, '15.0'
  s.requires_arc = true
  s.static_framework = true
  
  s.swift_version    = '5.0'
  
  s.source_files = 'Classes/**/*'
  s.dependency 'NMLog'
  s.dependency 'NMModular'
#  s.subspec 'Interface' do |ss|
#    ss.source_files = 'Interface/**/*.{swift}'
#  end
#  
#  s.subspec 'Imp' do |ss|
#    ss.source_files = 'Impl/**/*.{h,m,swift}'
#    ss.public_header_files = 'Impl/Public/*.h'
#    ss.dependency 'CocoaLumberjack'
#    ss.dependency 'NMLogModule/Interface'
#    ss.dependency 'NMLog'
#  end
end
