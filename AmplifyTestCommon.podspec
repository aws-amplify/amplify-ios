#
#  Be sure to run `pod spec lint AmplifyTestCommon.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "AmplifyTestCommon"
  s.version      = "1.0.0-rc.1"
  s.summary      = "Test resources used by different targets"

  s.description  = "Provides different test resources and mock methods"

  s.homepage     = "https://aws.amazon.com/amplify/"
  s.license      = 'Apache License, Version 2.0'
  s.author       = { 'Amazon Web Services' => 'amazonwebservices' }
  s.source       = { :git => 'https://github.com/aws-amplify/amplify-ios.git', :tag => s.version}

  s.platform     = :ios, '11.0'
  s.swift_version = '5.0'

  s.source_files = 'AmplifyTestCommon/**/*.swift'

  s.dependency 'Amplify', '1.0.0-rc.1'

  s.subspec 'AWSPluginsTestCommon' do |ss|
    ss.source_files = 'AmplifyPlugins/Core/AWSPluginsTestCommon/**/*.swift'
    ss.dependency 'AWSPluginsCore', '1.0.0-rc.1'
    ss.dependency 'AWSCore'
  end

end
