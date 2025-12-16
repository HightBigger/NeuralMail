Pod::Spec.new do |s|
  s.name             = 'NMMailModule'
  s.version          = '0.1.0'
  s.summary          = 'NeuralMail NMMailModule Module'
  s.description      = <<-DESC
                       Handles login, auto-discovery, and authentication flows.
                       DESC
  s.homepage         = 'https://github.com/neuralmail/NMMailModule'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NeuralMail Team' => 'team@neuralmail.com' }
  s.source           = { :path => '.' }
  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.0'
    
  s.resource_bundles = {
    'NMMailModule' => ['Assets/**/*']
  }
  
  s.source_files = 'Classes/**/*'
#  s.vendored_frameworks = 'Frameworks/*.framework'

  # Dependencies
  s.dependency 'NMModular'
  s.dependency 'MailCore2'
end
