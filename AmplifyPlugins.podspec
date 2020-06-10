#
#  Be sure to run `pod spec lint AWSS3StoragePlugin.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  AMPLIFY_VERSION = '1.0.1'
  AWS_SDK_VERSION = '~> 2.13.4'

  s.name         = 'AmplifyPlugins'
  s.version      = AMPLIFY_VERSION
  s.summary      = 'Amazon Web Services Amplify for iOS.'

  s.description  = 'AWS Amplify for iOS provides a declarative library for application development using cloud services'

  s.homepage     = 'https://github.com/aws-amplify/amplify-ios'
  s.license      = 'Apache License, Version 2.0'
  s.author       = { 'Amazon Web Services' => 'amazonwebservices' }
  s.source       = { :git => 'https://github.com/aws-amplify/amplify-ios.git', :tag => "v#{s.version}" }

  s.platform = :ios, '11.0'
  s.swift_version = '5.0'

  s.dependency 'AWSPluginsCore', AMPLIFY_VERSION

  # This is technically redundant, but adding it here allows Xcode to find it
  # during initial indexing and prevent build errors after a fresh install
  s.dependency 'AWSCore', AWS_SDK_VERSION

  s.subspec 'AWSAPIPlugin' do |ss|
    ss.source_files = 'AmplifyPlugins/API/AWSAPICategoryPlugin/**/*.swift'
    ss.dependency 'ReachabilitySwift', '~> 5.0.0'
    ss.dependency 'AppSyncRealTimeClient', "~> 1.1.0"
  end

  s.subspec 'AWSCognitoAuthPlugin' do |ss|
    ss.source_files = 'AmplifyPlugins/Auth/AWSCognitoAuthPlugin/**/*.swift'
    ss.dependency 'AWSMobileClient', AWS_SDK_VERSION

    # This is technically redundant, but adding it here allows Xcode to find it
    # during initial indexing and prevent build errors after a fresh install
    s.dependency 'AWSAuthCore', AWS_SDK_VERSION

  end

  s.subspec 'AWSDataStorePlugin' do |ss|
    ss.source_files = 'AmplifyPlugins/DataStore/AWSDataStoreCategoryPlugin/**/*.swift'
    ss.dependency 'SQLite.swift', '~> 0.12.0'
  end

  s.subspec 'AWSPinpointAnalyticsPlugin' do |ss|
    ss.source_files = 'AmplifyPlugins/Analytics/AWSPinpointAnalyticsPlugin/**/*.swift'
    ss.dependency 'AWSPinpoint', AWS_SDK_VERSION
  end

  s.subspec 'AWSS3StoragePlugin' do |ss|
    ss.source_files = 'AmplifyPlugins/Storage/AWSS3StoragePlugin/**/*.swift'
    ss.dependency 'AWSS3', AWS_SDK_VERSION
  end

end
