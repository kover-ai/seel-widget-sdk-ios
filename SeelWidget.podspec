#
# Be sure to run `pod lib lint SeelWidget.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SeelWidget'
  s.version          = '0.1.1'
  s.summary          = 'A short description of SeelWidget.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/思水/SeelWidget'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '思水' => 'architray163@163.com' }
  s.source           = { :git => 'https://github.com/思水/SeelWidget.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'SeelWidget/**/*.swift'
  # s.source_files = 'SeelWidget/UI/**/*.swift'
  
  s.resource_bundles = {
    'SeelWidget' => ['SeelWidget/Assets/**/*.{png,jpg,jpeg,svg,xcassets}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit', '~> 5.6.0'
end
