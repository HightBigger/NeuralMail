Pod::Spec.new do |s|
  s.name         = 'NMLog'
  s.version      = '2.0.0'
  s.author       = 'xiaoda'
  s.license      = { :type => 'MIT', :text => 'Copyright 2023' }
  s.homepage     = 'http://www.uusafe.com'
  s.summary      = 'NMLog'
  s.source       = { :git => '', :tag => s.version.to_s }
  s.platform     = :ios, '15.0'
  s.requires_arc = true
  s.static_framework = true
  
  s.source_files = 'Source/**/*.{h,m}'
  s.public_header_files = 'Source/Public/*.h'
  s.dependency 'CocoaLumberjack'
  
end
