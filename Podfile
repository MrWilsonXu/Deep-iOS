platform :ios, '9.0'
inhibit_all_warnings!

target 'TEST' do
  use_frameworks!
  pod 'RxSwift', '4.0.0'
  pod 'RxCocoa', '4.0.0'

  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '4.0'
          end
      end
  end
  
end