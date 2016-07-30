Pod::Spec.new do |s|
  s.name           = 'CommunityLibrary'
  s.homepage       = 'https://github.com/IamVisual/CommunityLibrary.git'
  s.version        = '0.1.0'
  s.source         = { :git => 'https://github.com/IamVisual/CommunityLibrary.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.source_files = 'CommunityLibrary/**/*.{h,m}'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aleksandr Vnukov' => 'aleksandr.vnukov.jos@gmail.com' }
  s.requires_arc   = true
  s.summary          = 'ARC and GCD Compatible Reachability Class for iOS and macOS.'

end
