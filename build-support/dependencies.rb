# Version definitions
$AMPLIFY_VERSION = '1.0.2'
$AWS_SDK_VERSION = '2.13.4'

# http://guides.cocoapods.org/using/the-podfile.html#specifying-pod-versions
def optimistic_version(pod_version)
  "~> #{pod_version}"
end

# GitHub tag name for Amplify releases
def release_tag
  "v#{$AMPLIFY_VERSION}"
end

# Include common tooling
def include_build_tools!
  pod 'SwiftFormat/CLI'
  pod 'SwiftLint'
end

# Include common test dependencies
def include_test_utilities!
  pod 'CwlPreconditionTesting',
    git: 'https://github.com/mattgallagher/CwlPreconditionTesting.git',
    tag: '1.2.0'
  pod 'CwlCatchException',
    git: 'https://github.com/mattgallagher/CwlCatchException.git',
    tag: '1.2.0'
end
