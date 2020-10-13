# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'voice-translator' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for voice-translator

    pod 'Firebase/Analytics'
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'Firebase/Firestore'
    pod 'GoogleSignIn'
    pod 'AuthLibrary', :git => 'https://github.com/googleapis/google-auth-library-swift.git'
    pod 'Firebase/Messaging'
    pod 'googleapis', :path => '.'
    pod 'Firebase/DynamicLinks'
    pod 'Firebase/Crashlytics'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
