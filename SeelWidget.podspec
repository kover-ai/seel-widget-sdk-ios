#
# Be sure to run `pod lib lint SeelWidget.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SeelWidget'
  s.version          = '0.1.4'
  s.summary          = 'Seel Widget SDK for iOS provides protection services for e-commerce.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Seel Widget SDK for iOS allows merchants to integrate Seel's protection services into their mobile applications, providing a seamless experience for customers to opt-in for coverage.
                       DESC

  s.homepage         = 'https://github.com/kover-ai/seel-widget-sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '思水' => 'architray163@163.com' }
  s.source           = { :git => 'https://github.com/kover-ai/seel-widget-sdk-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_versions = ['5.0']

  s.source_files = 'SeelWidget/**/*.swift'
  # s.source_files = 'SeelWidget/UI/**/*.swift'
  
  s.resource_bundles = {
    'SeelWidget' => ['SeelWidget/Assets/**/*.{png,jpg,jpeg,svg,xcassets}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit', '~> 5.6.0'
end
