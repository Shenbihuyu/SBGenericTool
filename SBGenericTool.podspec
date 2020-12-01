#
# Be sure to run `pod lib lint SBGenericTool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SBGenericTool'
  s.version          = '0.1.6.4'
  s.summary          = '神笔互娱 开发通用工具.'
  s.swift_version    = '5.0'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Shenbihuyu/SBGenericTool.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shenbihuyu' => 'support@shenbihuyu.com' }
  s.source           = { :git => 'https://github.com/Shenbihuyu/SBGenericTool.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SBGenericTool/Classes/**/*'
  
  s.ios.deployment_target = '10.0'
   s.resource_bundles = {
     'SBGenericTool' => ['SBGenericTool/Assets/*']
   }

  # s.public_header_files = 'Pod/Classes/**/*'
  # s.frameworks = 'UIKit', 'MapKit'
#  s.dependency 'SnapKit'
  s.requires_arc  = true
end
