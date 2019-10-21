# Uncomment the next line to define a global platform for your project
platform :ios, "11.0"

AWS_SDK_VERSION = "2.11.1"

target "Amplify" do
  # Comment the next line if you"re not using Swift and don"t want to use dynamic frameworks
  use_frameworks!

  # Tools for Amplify
  pod "SwiftFormat/CLI"
  pod "SwiftLint"

  target "AmplifyTestCommon" do
    inherit! :search_paths
    pod "CwlPreconditionTesting", :git => "https://github.com/mattgallagher/CwlPreconditionTesting.git", :tag => "1.2.0"
    pod "CwlCatchException", :git => "https://github.com/mattgallagher/CwlCatchException.git", :tag => "1.2.0"
  end

  target "AmplifyTests" do
    inherit! :search_paths
    pod "SQLite.swift", "~> 0.12.0"
    pod "CwlPreconditionTesting", :git => "https://github.com/mattgallagher/CwlPreconditionTesting.git", :tag => "1.2.0"
    pod "CwlCatchException", :git => "https://github.com/mattgallagher/CwlCatchException.git", :tag => "1.2.0"
  end

  target "AmplifyFunctionalTests" do
    inherit! :search_paths
    pod "CwlPreconditionTesting", :git => "https://github.com/mattgallagher/CwlPreconditionTesting.git", :tag => "1.2.0"
    pod "CwlCatchException", :git => "https://github.com/mattgallagher/CwlCatchException.git", :tag => "1.2.0"
  end

end

target "AWSAppSyncLocalDataStorePlugin" do
  use_frameworks!

  pod "SQLite.swift", "~> 0.12.0"

  target "AWSAppSyncLocalDataStorePluginTests" do
    inherit! :search_paths
  end
end

target "AWSS3StoragePlugin" do
  use_frameworks!

  pod "AWSS3", "~> #{AWS_SDK_VERSION}"
  pod "AWSMobileClient", "~> #{AWS_SDK_VERSION}"

  target "AWSS3StoragePluginTests" do
    inherit! :search_paths
    pod "AWSS3", "~> #{AWS_SDK_VERSION}"
    pod "AWSMobileClient", "~> #{AWS_SDK_VERSION}"
    pod "CwlPreconditionTesting", :git => "https://github.com/mattgallagher/CwlPreconditionTesting.git", :tag => "1.2.0"
    pod "CwlCatchException", :git => "https://github.com/mattgallagher/CwlCatchException.git", :tag => "1.2.0"
  end

end

target "AmplifyTestApp" do
  use_frameworks!
  pod "AWSS3", "~> #{AWS_SDK_VERSION}"

  target "AWSS3StoragePluginIntegrationTests" do
    inherit! :search_paths
    pod "AWSS3", "~> #{AWS_SDK_VERSION}"
    pod "AWSMobileClient", "~> #{AWS_SDK_VERSION}"
    pod "CwlPreconditionTesting", :git => "https://github.com/mattgallagher/CwlPreconditionTesting.git", :tag => "1.2.0"
    pod "CwlCatchException", :git => "https://github.com/mattgallagher/CwlCatchException.git", :tag => "1.2.0"
  end
end
