# MatinAlertFramework
<div id="readme" class="Box md js-code-block-container Box--responsive">
     
**MatinAlertFramework** is an open source library making it easy to create customizable **auto-scrollable** alert pop up for iOS. 
##
<img src="https://i.ibb.co/zfLFyNg/1.png" />
<img src="https://i.ibb.co/1vhFDxP/2.png" />
<br />
<img src="https://i.ibb.co/JskwYXk/4.png" />
<img src="https://i.ibb.co/6JHbmby/3.png" />

<br />
<img src="https://i.ibb.co/2qsymh1/6.png" />
<br />
<h3>Custom style</h3>
<img src="https://i.ibb.co/H4vvYmK/5.png" />

<h3>Video example</h3>
https://player.vimeo.com/video/506645136




#### Requirements
- Requires iOS 13 or later.

## License
See the [License](https://github.com/matin-kaj/MatinAlertFramework/blob/main/LICENSE). You are free to make changes and use this library in either personal or commercial projects. Attribution is not required, but highly appreciated. A little "Thanks!" (or something to that affect) is always welcome!


## Installation
#### Swift Package Manager
Add `https://github.com/matin-kaj/MatinAlertFramework` as a dependency to your Package.swift file or select `File -> Swift Packages -> Add Package Dependency...` in Xcode.

#### CocoaPods
The easiest way to install MatinAlertFramework is to use [CocoaPods](https://cocoapods.org/pods/MatinAlertFramework). 
 Simply add the following line to your Podfile:

```bash
 pod 'MatinAlertFramework'
```

## Usages

```swift
import MatinAlertFramework
```
#### Simple alert
```swift
# displays the content with an OK button
MatinAlert().display(withContent: "Please make sure to do something!") 
```
#### Alert message with title
```swift
# displays the content with an OK button with a blue header along with a title.
MatinAlert().display("Notice", contentText: "Please make sure to do something!")
```
#### Alert message with title and warning alert type
```swift
# displays the content with an OK button and with orange warning header along with a title.
MatinAlert().display("Warning", contentText: "Please make sure to do something!", alertType: .warning)
```
#### Alert message with title and warning alert type and first button title
```swift
# displays the content with an Okay button title with an orange warning header along with a title.
MatinAlert().display("Warning", contentText: "Please make sure to do something!", alertType: .warning, firstButtonTitle: "Okay")
```

#### Alert message with title and warning alert type and first and second button titles
```swift
# displays the content with `Yes` and `No` as a title of first and second buttons with an orange warning header along with a title.
MatinAlert().display(
            "Warning",
            contentText: "Are you sure you want to do something!",
            alertType: .warning,
            firstButtonTitle: "Yes",
            secondButtonTitle: "No")
```
#### Alert message with title and warning alert type and first and second button titles and on button tapped closure
```swift
# displays the content with `Yes` and `No` as a title of first and second buttons with an orange warning header along with a title.
# and receive on tap button's event 
MatinAlert().display(
            "Warning",
            contentText: "Are you sure you want to do something!",
            alertType: .warning,
            firstButtonTitle: "Yes",
            secondButtonTitle: "No") { (tappedButton) in
              // callback when button is tapped. 
              switch(tappedButton) {
                case .confirm:
                 // the first button clicked
                 MatinAlert().display(withContent: "You rock!")
                case .cancel:
                 // the second button clicked
                 MatinAlert().display(withContent: "You still rock!")
              }
            }
```

#### Alert message with custom styles 
```swift
# configures custom styles and displays the content 
var customStyle = MatinAlert.CustomStyle()
var topHeaderViewStyle = MatinAlert.CustomViewStyle()
var topHeaderTextStyle = MatinAlert.CustomTextStyle()
var buttonStyle = MatinAlert.CustomButtonStyle()
let buttonFont = UIFont(name: "Menlo-Bold", size: 16)
        
# set custom style for top header view
topHeaderViewStyle.color = UIColor.systemIndigo
topHeaderViewStyle.borderColor = UIColor.systemGray
customStyle.topHeaderView = topHeaderViewStyle
        
# set custom style for top header title
topHeaderTextStyle.color = UIColor.white
topHeaderTextStyle.alignment = .left
customStyle.topHeaderText = topHeaderTextStyle
                
# set custom styles for the first button
buttonStyle.bgColor = UIColor.systemRed
buttonStyle.font = buttonFont
buttonStyle.titleColor = UIColor.white
customStyle.firstButton = buttonStyle
        
# set custom styles for the second button
buttonStyle.titleColor = UIColor.white
buttonStyle.bgColor = UIColor.systemTeal
buttonStyle.font = buttonFont
customStyle.secondButton = buttonStyle
        
MatinAlert().display(
            "Custom Styles",
            contentText: "You are seeing customized alert message. Do you like it?",
            alertType: .custom(style: customStyle),
            firstButtonTitle: "Yes",
            secondButtonTitle: "No")

```

#### Alert message with persistent styles 
```swift
# configures custom styles and sets it as a default style. The alert will use this style throughout the app
var customStyle = MatinAlert.CustomStyle()
var topHeaderViewStyle = MatinAlert.CustomViewStyle()
var topHeaderTextStyle = MatinAlert.CustomTextStyle()
var buttonStyle = MatinAlert.CustomButtonStyle()
let buttonFont = UIFont(name: "Menlo-Bold", size: 16)
        
# set custom style for top header view
topHeaderViewStyle.color = UIColor.systemIndigo
topHeaderViewStyle.borderColor = UIColor.systemGray
customStyle.topHeaderView = topHeaderViewStyle
        
# set custom style for top header title
topHeaderTextStyle.color = UIColor.white
topHeaderTextStyle.alignment = .left
customStyle.topHeaderText = topHeaderTextStyle
                
# set custom styles for the first button
buttonStyle.bgColor = UIColor.systemRed
buttonStyle.font = buttonFont
buttonStyle.titleColor = UIColor.white
customStyle.firstButton = buttonStyle
        
# set custom styles for the second button
buttonStyle.titleColor = UIColor.white
buttonStyle.bgColor = UIColor.systemTeal
buttonStyle.font = buttonFont
customStyle.secondButton = buttonStyle

# you can configure your custom style once then alert will always use the same style
MatinAlert.setDefaultStyle(customStyle: customStyle)

MatinAlert().display("predefined Styles", contentText: "You are seeing a predefined alert message.", alertType: .predefined)

```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


## License
[MIT](https://choosealicense.com/licenses/mit/)     
</div>
