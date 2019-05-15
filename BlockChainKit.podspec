#
# Be sure to run `pod lib lint BlockChainKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BlockChainKit'
  s.version          = '0.1.0'
  s.summary          = '💰A blockchain toolkit with Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The BlockChainKit is a Swift library provides mnemonic generation and validation with 8 languages, and it implements `NSLinguisticTagger` to detect mnemonic language automatically that you do not need to set language 🌍.
                       DESC

  s.homepage         = 'https://github.com/Archie/BlockChainKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Archie' => 'https://twitter.com/ChangArchie' }
  s.source           = { :git => 'https://github.com/Archie/BlockChainKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ChangArchie'

  s.ios.deployment_target = '11.0'

  s.source_files = 'BlockChainKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BlockChainKit' => ['BlockChainKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'CryptoSwift', '~> 1.0.0'
end
