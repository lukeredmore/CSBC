platform :ios, '15.0'

target 'CSBC' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  project 'CSBC', 'DebugFirebase' => :debug

  # Pods for CSBC

  pod 'GoogleSignIn'
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'
  pod 'SwiftyJSON'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
