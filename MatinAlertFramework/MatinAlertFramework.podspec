
Pod::Spec.new do |spec|

  spec.name         = "MatinAlertFramework"
  spec.version      = "1.0.8"
  spec.summary      = "This is a customizable alert framework. This framework allows you to use scrollable alert with pre-setup types."
  spec.description  = "This framework allows you to use scrollable alert types such as success, error, warning and info, or even configure your own custom alert styles. Scrollable Alert"
  spec.homepage     = "https://github.com/matin-kaj/MatinAlertFramework"
  spec.license      = "MIT"
  spec.author       = { "Matin Kajabadi" => "" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/matin-kaj/MatinAlertFramework.git", :tag => "1.0.8" }
  spec.source_files = "MatinAlertFramework/**/*"
  spec.exclude_files = "MatinAlertFramework/**/*.plist"
  spec.swift_versions = "5.0"


end
