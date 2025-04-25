# Uncomment the next line to define a global platform for your project
platform :ios, '15.6'

target 'orkstra-driver' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for orkstra-driver
  pod 'Alamofire'
  pod 'Japx/Alamofire'
  pod 'RealmSwift'
  pod 'Unrealm'
  pod 'LanguageManager-iOS'
  pod 'SwiftyJSON'
  pod 'PKHUD'
  pod 'GoogleMaps'
  pod 'Google-Maps-iOS-Utils' # For route rendering (optional)
  
  target 'orkstra-driverTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'orkstra-driverUITests' do
    # Pods for testing
  end

end

# Fix deployment target for all pods
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
    end
  end
end
