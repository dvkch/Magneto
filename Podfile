source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

inhibit_all_warnings!
use_frameworks!

pod 'AFNetworking'
pod 'BlocksKit'
pod 'CDZPinger'
pod 'YapDatabase'
pod 'SYKit'
pod 'BlocksKit'
pod 'SYPopover'
pod 'SPLPing'
pod 'JiveAuthenticatingHTTPProtocol'
pod 'SparkInspector', :podspec => 'https://raw.githubusercontent.com/Foundry376/SparkInspectorFramework/master/SparkInspector.podspec', :configurations => ['Debug']

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end