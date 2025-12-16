Pod::Spec.new do |s|
  s.name             = 'NMNetworkModule'
  s.version          = '0.1.0'
  s.summary          = 'NeuralMail Networking Layer'
  s.description      = <<-DESC
                       Networking abstraction and protocol implementations (EAS/IMAP) for NeuralMail.
                       DESC
  s.homepage         = 'https://github.com/neuralmail/NMNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NeuralMail Team' => 'team@neuralmail.com' }
  s.source           = { :path => '.' }
  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.0'
  
  s.static_framework = true
  
  s.source_files = 'Classes/**/*'
  
  # Dependencies
  s.dependency 'NMKit'
  s.dependency 'NMModular'
  s.dependency 'Alamofire'
end
