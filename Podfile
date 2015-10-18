source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

inhibit_all_warnings!

pod 'AFNetworking'
pod 'BlocksKit'
pod 'YapDatabase'
pod 'SYKit'
pod 'BlocksKit'
pod 'SYPopover'
pod 'SPLPing'
pod 'JiveAuthenticatingHTTPProtocol'
pod 'SparkInspector', :configurations => ['Debug']

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end