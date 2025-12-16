Pod::Spec.new do |s|
  s.name             = 'NMDataModule'
  s.version          = '0.1.0'
  s.summary          = 'NeuralMail Data Layer'
  s.description      = <<-DESC
                       Data implementation, Core Data stack, and API clients.
                       DESC
  s.homepage         = 'https://github.com/neuralmail/NMData'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NeuralMail Team' => 'team@neuralmail.com' }
  s.source           = { :path => '.' }
  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.0'
  
  s.source_files = 'Classes/**/*'
  
  # Dependencies
  s.dependency 'GRDB.swift/SQLCipher'
  s.dependency 'SQLCipher', '~> 4.0'
  s.dependency 'NMModular'

end
