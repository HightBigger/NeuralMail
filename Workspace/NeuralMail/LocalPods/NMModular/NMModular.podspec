Pod::Spec.new do |s|
  s.name             = 'NMModular'
  s.version          = '1.0.0'
  s.summary          = 'NeuralMail核心模块注册与服务管理框架'
  s.description      = <<-DESC
  NeuralMail项目的核心模块注册与服务管理框架，提供模块解耦、服务注册发现、配置管理等功能。
  DESC

  s.homepage         = 'https://github.com/your-org/NeuralMail'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NeuralMail Team' => 'team@neuralmail.com' }
  s.source           = { :git => '', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.static_framework = true
  
  s.source_files = 'Classes/**/*.swift'
  
end
