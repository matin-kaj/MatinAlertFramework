
Pod::Spec.new do |spec|

  spec.name         = "MatinAlertFramework"
  spec.version      = "1.0.2"
  spec.summary      = "This is a customizable alert framework."
  spec.description  = "This framework allows you to use existing scrollable alert types such as success, error, warning and info, or you can configure your own custom alert style. Scrollable Alert"
  spec.homepage     = "https://github.com/matin-kaj/MatinAlertFramework"
  spec.license      = "MIT"
  spec.author       = { "Matin Kajabadi" => "" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/matin-kaj/MatinAlertFramework.git", :tag => "1.0.2" }
  spec.source_files = "MatinAlertFramework/**/*"
  spec.exclude_files = "MatinAlertFramework/**/*.plist"
  spec.swift_versions = "5.0"


end
