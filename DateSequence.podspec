#
# Be sure to run `pod lib lint DateSequence.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DateSequence'
  s.version          = '0.1.1'
  s.summary          = 'A helper for creating infinite and bounded Date sequences.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A helper for creating infinite and bounded Date sequences. It was created to generate ISO-8601 dash-separated date strings for SQLite queries, but can also be used in most places where evenly-spaced Dates are needed. Any `Calendar.Component` can be used, but the API is designed with intervals of at least a whole day in mind.
                       DESC

  s.homepage         = 'https://github.com/quells/DateSequence'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'quells' => 'support@kaiwells.me' }
  s.source           = { :git => 'https://github.com/quells/DateSequence.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.1'

  s.source_files = 'DateSequence/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DateSequence' => ['DateSequence/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
