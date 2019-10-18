#
# Be sure to run `pod lib lint BlockChainKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BlockChainKit'
  s.version          = '1.4.3'
  s.summary          = '💰A blockchain toolkit with Swift.'

  s.description      = <<-DESC
The BlockChainKit is a Swift library provides mnemonic generation and validation with 8 languages, and it implements `NSLinguisticTagger` to detect mnemonic language automatically that you do not need to set language 🌍.
                       DESC

  s.homepage         = 'https://github.com/ArchieR7/BlockChainKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Archie' => 'https://twitter.com/ChangArchie' }
  s.source           = { :git => 'https://github.com/ArchieR7/BlockChainKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ChangArchie'
  s.swift_version = '5.1'
  s.ios.deployment_target = '11.0'
  s.source_files = 'BlockChainKit/Classes/**/*'
  
  s.dependency 'CryptoSwift', '~> 1.0.0'
  s.dependency 'BigInt', '~> 4.0.0'
  s.dependency 'secp256k1.swift', '~> 0.1.0'
end
