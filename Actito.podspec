Pod::Spec.new do |spec|
  spec.name               = "Actito"
  spec.version            = "5.0.0-beta.2"
  spec.summary            = "Actito Library for iOS apps"
  spec.description        = <<-DESC
The Actito iOS Library implements the power of smart notifications, location services, contextual marketing and powerful loyalty solutions provided by the Actito platform in iOS applications.

For documentation please refer to: https://developers.actito.com
For support please use: mobile@actito.com
                            DESC
  spec.homepage           = "https://actito.com"
  spec.documentation_url  = "https://developers.actito.com"
  spec.license            = { :type => "MIT", :file => 'Actito/LICENSE' }
  spec.author             = { "Actito" => "mobile@actito.com" }
  spec.source             = { :http => "https://cdn-mobile.actito.com/libs/ios/#{spec.version}/cocoapods.zip" }
  spec.swift_version      = "6.0"

  # Supported deployment targets
  spec.ios.deployment_target  = "13.0"

  # Subspecs

  spec.subspec 'ActitoKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoKit.xcframework"
    subspec.dependency 'Actito/ActitoUtilitiesKit'
  end

  spec.subspec 'ActitoAssetsKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoAssetsKit.xcframework"
    subspec.dependency 'Actito/ActitoUtilitiesKit'
  end

  spec.subspec 'ActitoGeoKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoGeoKit.xcframework"
    subspec.dependency 'Actito/ActitoUtilitiesKit'
  end

  spec.subspec 'ActitoInAppMessagingKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoInAppMessagingKit.xcframework"
    subspec.dependency 'Actito/ActitoUtilitiesKit'
  end

  spec.subspec 'ActitoInboxKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoInboxKit.xcframework"
    subspec.dependency 'Actito/ActitoUtilitiesKit'
  end

  spec.subspec 'ActitoLoyaltyKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoLoyaltyKit.xcframework"
    subspec.dependency 'Actito/ActitoUtilitiesKit'
  end

  spec.subspec 'ActitoNotificationServiceExtensionKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoNotificationServiceExtensionKit.xcframework"
  end

  spec.subspec 'ActitoPushKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoPushKit.xcframework"
    subspec.dependency 'Actito/ActitoUtilitiesKit'
  end

  spec.subspec 'ActitoPushUIKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoPushUIKit.xcframework"
    subspec.dependency 'Actito/ActitoUtilitiesKit'
  end

  spec.subspec 'ActitoUserInboxKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoUserInboxKit.xcframework"
    subspec.dependency 'Actito/ActitoUtilitiesKit'
  end

  spec.subspec 'ActitoUtilitiesKit' do |subspec|
    subspec.vendored_frameworks = "Actito/ActitoUtilitiesKit.xcframework"
  end

end
