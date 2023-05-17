platform :ios, '14.0'

inhibit_all_warnings!

use_frameworks!

target 'TorrentAdder' do
    pod 'Alamofire'
    pod 'BrightFutures'
    pod 'Fuzi'
    pod 'GBPing'
    pod 'SYKit'
    pod 'TPKeyboardAvoiding'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
            config.build_settings.delete 'ARCHS'
        end
    end
end
