source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

inhibit_all_warnings!

use_frameworks!

target 'TorrentAdder' do
	pod 'AFNetworking'
	pod 'YapDatabase'
	pod 'SYKit'
	pod 'SYPopoverController'
	pod 'SPLPing'
	pod 'JiveAuthenticatingHTTPProtocol'
	#pod 'SparkInspector', :configurations => ['Debug']
	pod 'XMLDictionary'
	pod 'hpple'
	pod "JRSwizzle"
	pod "NSDate+TimeAgo"
    pod 'Alamofire'
    pod 'Fuzi'
    pod 'BrightFutures'
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        end
    end
end
