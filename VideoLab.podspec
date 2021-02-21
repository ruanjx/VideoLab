Pod::Spec.new do |s|
  s.name             = 'VideoLab'
  s.version          = '0.0.1'
  s.summary          = 'High-performance video editing and effects framework base on AVFoundation and Metal.'
  s.description      = <<-DESC
  High-performance and flexible video editing and effects framework, based on AVFoundation and Metal. Data structure consistent with After Effects.
                       DESC

  s.homepage         = 'https://github.com/ruanjx/VideoLab'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bear' => 'ruanjingxiong@gmail.com' }
  s.source           = { :git => 'https://github.com/ruanjx/VideoLab.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = "5"

  s.source_files = 'VideoLab/**/*.{swift,h,m,metal}'
  s.resources    = 'VideoLab/VideoLab.bundle'

end
