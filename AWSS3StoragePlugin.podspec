#
#  Be sure to run `pod spec lint AWSS3StoragePlugin.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = 'AWSS3StoragePlugin'
  s.version      = '0.0.1'
  s.summary      = 'Amazon Web Services Amplify for iOS.'

  s.description  = 'AWS Amplify for iOS provides a declarative library for application development using cloud services'
  
  s.homepage     = 'http://aws.amazon.com/mobile/sdk'
  s.license      = 'Apache License, Version 2.0'
  s.author       = { 'Amazon Web Services' => 'amazonwebservices' }
  s.platform     = :ios, '11.0'
  s.source       = { :git => 'https://github.com/aws-amplify/amplify-ios.git', :tag => s.version}
  
  s.requires_arc = true 
  s.dependency 'Amplify', '0.0.1'
  s.dependency 'AWSS3', '2.11.1'
  s.dependency 'AWSMobileClient', '2.11.1'
  s.source_files = 'AWSPlugins/AWSS3StoragePlugin/**/*.swift'

end
