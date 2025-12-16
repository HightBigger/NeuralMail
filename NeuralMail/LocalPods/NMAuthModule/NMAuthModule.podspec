Pod::Spec.new do |s|
  s.name             = 'NMAuthModule'
  s.version          = '0.1.0'
  s.summary          = 'NeuralMail Authentication Module'
  s.description      = <<-DESC
                       Handles login, auto-discovery, and authentication flows.
                       DESC
  s.homepage         = 'https://github.com/neuralmail/NMAuth'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NeuralMail Team' => 'team@neuralmail.com' }
  s.source           = { :path => '.' }
  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.0'
    
  s.resource_bundles = {
    'NMAuthModule' => ['Assets/**/*']
  }
  
  s.source_files = 'Classes/**/*'

  # Dependencies
  s.dependency 'NMKit'
  s.dependency 'SnapKit'
  s.dependency 'NMModular'
  s.dependency 'KeychainAccess'
  
end
