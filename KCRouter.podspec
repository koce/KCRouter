Pod::Spec.new do |s|
  s.name         = 'KCRouter'
  s.version      = '1.0.0'
  s.summary      = 'iOS Route'

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.authors      = { 'koce' => 'koce.zhao@gmail.com' }
  s.social_media_url = 'http://www.jianshu.com/u/083bd990bfe2'
  s.homepage     = 'https://github.com/koce/KCRouter'

  s.swift_version = '4.2'

  s.ios.deployment_target = '8.0'

  s.source       = { :git => 'https://github.com/koce/KCRouter.git', :tag => s.version.to_s }
  
  s.requires_arc = true
  s.source_files = ["KCRouter/KCRouter/*.swift"]
  
  s.frameworks = 'Foundation', 'UIKit'

end