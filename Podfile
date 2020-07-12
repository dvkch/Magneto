platform :ios, '10.0'

inhibit_all_warnings!

use_frameworks!

target 'TorrentAdder' do
    pod 'Alamofire'
    pod 'BrightFutures'
    pod 'Fuzi'
    pod 'NSDate+TimeAgo'
    pod 'SPLPing'
    pod 'SVProgressHUD'
    pod 'SYKit'
    pod 'SYPopoverController'
    pod 'TPKeyboardAvoiding'
    #pod 'SparkInspector', :configurations => ['Debug']
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
        end
    end
end
