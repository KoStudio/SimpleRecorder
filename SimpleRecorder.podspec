#
# Be sure to run `pod lib lint SimpleRecorder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SimpleRecorder'
  s.version          = '1.0.1'
  s.summary          = 'A simple recorder with Record And Play Functions.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A Recorder with Record and Play functions. Also you can show a recording view to show on screen.
                       DESC

  s.homepage         = 'https://github.com/KoStudio/SimpleRecorder'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'KoStudio' => '44663768@163.com' }
  s.source           = { :git => 'https://github.com/KoStudio/SimpleRecorder.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SimpleRecorder/Classes/**/*'
  
  s.resource_bundles = {
    'SimpleRecorder' => ['SimpleRecorder/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
