Pod::Spec.new do |s|
  s.name             = 'NMKit'
  s.version          = '0.1.0'
  s.summary          = 'NeuralMail Foundation Kit'
  s.description      = <<-DESC
                       Core extensions, utilities, and base classes for NeuralMail.
                       DESC
  s.homepage         = 'https://github.com/neuralmail/NMKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NeuralMail Team' => 'team@neuralmail.com' }
  s.source           = { :path => '.' }
  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.0'
  s.source_files = 'Classes/**/*'
  
  s.resource_bundles = {
    'NMKit' => ['Assets/**/*']
  }
  
  s.static_framework = true
  
  # Dependencies
  s.dependency 'SnapKit'
  s.dependency 'NMModular'
  s.dependency 'IQKeyboardManager'
  s.dependency 'FDFullscreenPopGesture'
end
