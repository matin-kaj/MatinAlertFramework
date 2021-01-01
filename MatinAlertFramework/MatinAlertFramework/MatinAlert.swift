//
//  MatinAlert.swift
//  MatinAlertFramework
//
//  Created by Matin Kajabadi on 12/31/20.
//

import Foundation
import UIKit


/** The MatinAlertDelegate protocol. Used to receive life cycle events. */
@objc public protocol MatinAlertDelegate: NSObjectProtocol {
    @objc optional func firstButtonClicked(for view: MatinAlertView)
    @objc optional func secondButtonClicked(for view: MatinAlertView)
    @objc optional func textfieldChanged(for view: MatinAlertView, text: String?)
}

open class MatinAlert: UIViewController {
    var matinAlertView: MatinAlertView!
    let blackView = UIView()
    var alertModel: AlertModel? {
        didSet {
            setupViews()
            setupKeyboardObservers()
        }
    }
    var firstButtonClicked: ((_ view: MatinAlertView?) -> Void)?
    var secondButtonClicked: ((_ view: MatinAlertView?) -> Void)?
    var textFieldChanged: ((_ view: MatinAlertView?, _ text: String) -> Void)?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =
            UIColor.grayScale1().withAlphaComponent(0.7)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        guard  let keyboardFrame =
                (notification.userInfo?[
                    UIResponder.keyboardFrameEndUserInfoKey
                ]
                as AnyObject).cgRectValue,
               let keyboardDuration =
                (notification.userInfo?[
                    UIResponder.keyboardAnimationDurationUserInfoKey
                ]
                as AnyObject).doubleValue else { return }
        
        if self.blackView.frame.origin.y == 0 {
            var pushUp = keyboardFrame.height -
                ((blackView.frame.height - matinAlertView.frame.height) / 2)
            UIView.animate(withDuration: keyboardDuration,
                           animations: { [weak self] in
                            guard let unwrappedSelf = self else { return }
                            pushUp += 5
                            if pushUp > 0 {
                                unwrappedSelf
                                    .blackView
                                    .frame
                                    .origin
                                    .y -= pushUp
                                unwrappedSelf
                                    .view
                                    .layoutIfNeeded()
                            }
                           }
            )
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        guard  let keyboardFrame =
                (notification.userInfo?[
                    UIResponder.keyboardFrameEndUserInfoKey
                ]
                as AnyObject).cgRectValue,
               let keyboardDuration =
                (notification.userInfo?[
                    UIResponder.keyboardAnimationDurationUserInfoKey
                ]
                as AnyObject).doubleValue else { return }
        if self.blackView.frame.origin.y != 0 {
            var pushDown = keyboardFrame.height -
                (
                    (blackView.frame.height -
                        matinAlertView.frame.height) / 2
                )
            UIView.animate(withDuration: keyboardDuration,
                           animations: { [weak self] in
                            guard let unwrappedSelf = self else { return }
                            pushDown += 5
                            if pushDown > 0 {
                                unwrappedSelf.blackView.frame.origin.y += pushDown
                                unwrappedSelf.view.layoutIfNeeded()
                            }
                           })
        }
    }
    
    @objc override func dismissKeyboard(gesture: UIGestureRecognizer) {
        matinAlertView.textField.resignFirstResponder()
    }
    
    func setupViews() {
        guard let _ = alertModel else { return }
        
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            window.endEditing(true)
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.6)
            blackView.tag = 99999
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            blackView.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(dismissKeyboard)
                ))
            
            matinAlertView = MatinAlertView()
            matinAlertView.delegate = self
            matinAlertView.alertModel = alertModel
            blackView.addSubview(matinAlertView)
            
            matinAlertView.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint =
                matinAlertView.centerXAnchor.constraint(
                    equalTo: blackView.centerXAnchor)
            let verticalConstraint =
                matinAlertView.centerYAnchor.constraint(
                    equalTo: blackView.centerYAnchor)
            NSLayoutConstraint.activate(
                [
                    horizontalConstraint, verticalConstraint
                ])
            matinAlertView.tag = 55555
            matinAlertView.transform =
                CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            matinAlertView.alpha = 0
            
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseOut,
                animations: { [weak self] in
                    guard let unwrappedSelf = self else { return }
                    unwrappedSelf.blackView.alpha = 1
                    unwrappedSelf.matinAlertView.alpha = 1
                    unwrappedSelf.matinAlertView.transform =
                        CGAffineTransform.identity
                }, completion: nil)
        }
    }
    
    func dismissViews() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
        if let window = UIApplication.shared.windows.filter(
            {$0.isKeyWindow}).first {
            for view in window.subviews {
                if view.tag == 55555 || view.tag == 99999 {
                    UIView.animate(
                        withDuration: 0.6,
                        animations: { [weak self] in
                            guard let unwrappedSelf = self else { return }
                            unwrappedSelf.blackView.alpha = 0
                            view.removeFromSuperview()
                        }
                    ) { [weak self] (_) in
                        guard let unwrappedSelf = self else { return }
                        unwrappedSelf.matinAlertView.alertModel = nil
                        unwrappedSelf.matinAlertView = nil
                        unwrappedSelf.alertModel = nil
                        unwrappedSelf.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension MatinAlert: MatinAlertDelegate {
    public func textfieldChanged(
        for view: MatinAlertView,
        text: String?) {
        if text != nil {
            textFieldChanged?(view, text!)
        }
    }
    
    public func firstButtonClicked(for view: MatinAlertView) {
        firstButtonClicked(for: view)
    }
    
    public func secondButtonClicked(for view: MatinAlertView) {
        secondButtonClicked(for: view)
    }
}


public struct AlertModel {
    var topBoxViewColor: UIColor?
    var topTitle: String?
    var topTitleColor: UIColor?
    var topTitleFont: UIFont?
    
    var title: String?
    var titleColor: UIColor?
    var titleFont: UIFont?
    var titleTextAlignment: NSTextAlignment?
    
    var contentTextViewText: String?
    var contentTextViewColor: UIColor?
    var contentTextViewFont: UIFont?
    var contentTextViewAttributed: NSAttributedString?
    
    var subTitle: String?
    var subTitleColor: UIColor?
    var subTitleFont: UIFont?
    var subTitleTextAlignment: NSTextAlignment?
    
    var firstButtonText: String?
    var firstButtonBackgroundColor: UIColor?
    var firstButtonTextColor: UIColor?
    var firstButtonFont: UIFont?
    
    var secondButtonText: String?
    var secondButtonBackgroundColor: UIColor?
    var secondButtonTextColor: UIColor?
    var secondButtonFont: UIFont?
    
    var textFieldTitle: String?
    var textFieldTitleColor: UIColor?
    var textFieldTitleFont: UIFont?
    var textFieldTitleTextAlignment: NSTextAlignment?
    
    var hasTextField: Bool?
    var textFieldPlaceHolder: String?
    var textFieldKeyboardType: UIKeyboardType?
    
    var textFieldTitleInvisible: Bool?
    var textFieldInvisible: Bool?
    var textFieldText: String?
    
    init(
        topBoxViewColor: UIColor? = nil,
        topTitle: String? = nil,
        topTitleColor: UIColor? = nil,
        topTitleFont: UIFont? = nil,
        title: String? = nil,
        titleColor: UIColor? = nil,
        titleFont: UIFont? = nil,
        titleTextAlignment: NSTextAlignment? = nil,
        contentTextViewText: String? = nil,
        contentTextViewColor: UIColor? = nil,
        contentTextViewFont: UIFont? = nil,
        contentTextViewAttributed: NSAttributedString? = nil,
        subTitle: String? = nil,
        subTitleColor: UIColor? = nil,
        subTitleFont: UIFont? = nil,
        subTitleTextAlignment: NSTextAlignment? = nil,
        firstButtonText: String? = nil,
        firstButtonBackgroundColor: UIColor? = nil,
        firstButtonTextColor: UIColor? = nil,
        firstButtonFont: UIFont? = nil,
        secondButtonText: String? = nil,
        secondButtonBackgroundColor: UIColor? = nil,
        secondButtonTextColor: UIColor? = nil,
        secondButtonFont: UIFont? = nil,
        textFieldTitle: String? = nil,
        textFieldTitleColor: UIColor? = nil,
        textFieldTitleFont: UIFont? = nil,
        textFieldTitleTextAlignment: NSTextAlignment? = nil,
        hasTextField: Bool? = nil,
        textFieldPlaceHolder: String? = nil,
        textFieldKeyboardType: UIKeyboardType? = nil,
        textFieldTitleInvisible: Bool? = nil,
        textFieldInvisible: Bool? = nil,
        textFieldText: String? = nil) {
        self.topBoxViewColor = topBoxViewColor
        self.topTitle = topTitle
        self.topTitleColor = topTitleColor
        self.topTitleFont = topTitleFont
        self.title = title
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.titleTextAlignment = titleTextAlignment
        self.contentTextViewText = contentTextViewText
        self.contentTextViewColor = contentTextViewColor
        self.contentTextViewFont = contentTextViewFont
        self.contentTextViewAttributed = contentTextViewAttributed
        self.subTitle = subTitle
        self.subTitleColor = subTitleColor
        self.subTitleFont = subTitleFont
        self.subTitleTextAlignment = subTitleTextAlignment
        self.firstButtonText = firstButtonText
        self.firstButtonBackgroundColor = firstButtonBackgroundColor
        self.firstButtonTextColor = firstButtonTextColor
        self.firstButtonFont = firstButtonFont
        self.secondButtonText = secondButtonText
        self.secondButtonBackgroundColor = secondButtonBackgroundColor
        self.secondButtonTextColor = secondButtonTextColor
        self.secondButtonFont = secondButtonFont
        self.textFieldTitle = textFieldTitle
        self.textFieldTitleColor = textFieldTitleColor
        self.textFieldTitleFont = textFieldTitleFont
        self.textFieldTitleTextAlignment = textFieldTitleTextAlignment
        self.hasTextField = hasTextField
        self.textFieldPlaceHolder = textFieldPlaceHolder
        self.textFieldKeyboardType = textFieldKeyboardType
        self.textFieldTitleInvisible = textFieldTitleInvisible
        self.textFieldInvisible = textFieldInvisible
        self.textFieldText = textFieldText
    }
}

public class MatinAlertView: UIView {
    
    weak var delegate: MatinAlertDelegate?
    let mainBoxWidth = CGFloat(280)
    var topBoxHeight = CGFloat(50)
    var bottomBoxHeight = CGFloat(45)
    var titleHeight = CGFloat(0.05)
    var titleTopMargin = CGFloat(0)
    var contentHeight = CGFloat(0.05)
    var contentTopMargin = CGFloat(0.05)
    var subTitleHeight = CGFloat(0.05)
    var subTitleTopMargin = CGFloat(0)
    var textFieldTitleHeight = CGFloat(0.05)
    var textFieldHeight = CGFloat(0.05)
    var textFieldTopMargin = CGFloat(0.05)
    var textFieldTitleInvisible = true
    var textFieldInvisible = true
    
    public override var intrinsicContentSize: CGSize {
        if textFieldTitleInvisible {
            textFieldTitleHeight = CGFloat(0.05)
            textFieldTitleLabel.alpha = 0
        } else {
            textFieldTitleHeight = CGFloat(35)
            textFieldTitleLabel.alpha = 1
        }
        if textFieldInvisible {
            textFieldHeight = CGFloat(0.05)
            textField.alpha = 0
        } else {
            textFieldHeight = CGFloat(35)
            textField.alpha = 1
        }
        var height = topBoxHeight +
            titleHeight +
            contentTopMargin +
            contentHeight +
            subTitleHeight +
            textFieldTitleHeight +
            textFieldTopMargin +
            textFieldHeight +
            bottomBoxHeight
        // Make sure height does not go over the main view height
        if let parentView = superview {
            let maximumHeight = parentView.frame.height - 130
            height = height > maximumHeight ? maximumHeight : height
        }
        height = height < 170 ? CGFloat(160) : height
        return CGSize(width: mainBoxWidth, height: height)
    }
    
    var alertModel: AlertModel? {
        didSet {
            if let textFieldTitleInvisible =
                alertModel?.textFieldTitleInvisible {
                self.textFieldTitleInvisible =
                    textFieldTitleInvisible
            }
            if let textFieldInvisible =
                alertModel?.textFieldInvisible {
                self.textFieldInvisible =
                    textFieldInvisible
            }
            if let topBoxViewColor =
                alertModel?.topBoxViewColor {
                topBoxView.backgroundColor = topBoxViewColor
            }
            if let topTitle =
                alertModel?.topTitle,
               !topTitle.isBlank {
                topBoxTitleLabel.text = topTitle
            }
            if let topTitleColor =
                alertModel?.topTitleColor {
                topBoxTitleLabel.textColor = topTitleColor
            }
            if let topTitleFont =
                alertModel?.topTitleFont {
                topBoxTitleLabel.font = topTitleFont
            }
            if let title =
                alertModel?.title,
               !title.isBlank {
                titleLabel.text = title
                titleLabel.alpha = 1
                titleHeight =
                    estimateFrameForText(title, width: 160).height
                titleHeight = titleHeight < 25
                    ? 25
                    : titleHeight
                print(titleHeight)
            }
            if let titleColor = alertModel?.titleColor {
                titleLabel.textColor = titleColor
            }
            if let titleFont = alertModel?.titleFont {
                titleLabel.font = titleFont
            }
            if let titleTextAlignment = alertModel?.titleTextAlignment {
                titleLabel.textAlignment = titleTextAlignment
            }
            if let contentTextViewText =
                alertModel?.contentTextViewText,
               !contentTextViewText.isBlank {
                contentTextView.alpha = 1
                contentTextView.text = contentTextViewText
                let width = contentTextViewText.count > 80 &&
                    contentTextViewText.count < 130
                    ? CGFloat(220)
                    : CGFloat(160)
                let height =
                    estimateFrameForText(
                        contentTextViewText,
                        width: width).height
                contentTopMargin = 15
                contentHeight = height < 30 ? 30 : height
            }
            if let contentTextViewColor =
                alertModel?.contentTextViewColor {
                contentTextView.textColor = contentTextViewColor
            }
            if let contentTextViewFont =
                alertModel?.contentTextViewFont {
                contentTextView.font = contentTextViewFont
            }
            if let contentTextViewAttributed =
                alertModel?.contentTextViewAttributed {
                contentTextView.attributedText = contentTextViewAttributed
            }
            if let subTitle = alertModel?.subTitle, !subTitle.isBlank {
                subTitleLabel.text = subTitle
                subTitleLabel.alpha = 1
                subTitleHeight =
                    estimateFrameForText(subTitle, width: 160).height
            }
            if let subTitleColor = alertModel?.subTitleColor {
                subTitleLabel.textColor = subTitleColor
            }
            if let subTitleFont = alertModel?.subTitleFont {
                subTitleLabel.font = subTitleFont
            }
            if let subTitleTextAlignment =
                alertModel?.subTitleTextAlignment {
                subTitleLabel.textAlignment =
                    subTitleTextAlignment
            }
            if let textFieldTitle =
                alertModel?.textFieldTitle,
               !textFieldTitle.isBlank {
                textFieldTitleLabel.alpha = 1
                textFieldTitleLabel.text = textFieldTitle
                let height =
                    estimateFrameForText(textFieldTitle, width: 160).height
                textFieldTitleHeight = height < 35 ? 35 : height
            }
            if let textFieldTitleColor =
                alertModel?.textFieldTitleColor {
                textFieldTitleLabel.textColor = textFieldTitleColor
            }
            if let textFieldTitleFont =
                alertModel?.textFieldTitleFont {
                textFieldTitleLabel.font = textFieldTitleFont
            }
            if let textFieldTitleTextAlignment =
                alertModel?.textFieldTitleTextAlignment {
                textFieldTitleLabel.textAlignment =
                    textFieldTitleTextAlignment
            }
            if let textFieldPlaceHolder =
                alertModel?.textFieldPlaceHolder {
                textField.placeholder = textFieldPlaceHolder
            }
            if let textFieldText =
                alertModel?.textFieldText {
                textField.text = textFieldText
            }
            if let textFieldKeyboardType =
                alertModel?.textFieldKeyboardType {
                textField.keyboardType = textFieldKeyboardType
            }
            if let hasTextField =
                alertModel?.hasTextField, hasTextField {
                textFieldHeight = 35
            }
            if let firstButtonText =
                alertModel?.firstButtonText, !firstButtonText.isBlank {
                firstButton.alpha = 1
                firstButton.setTitle(firstButtonText, for: .normal)
            } else {
                firstButton.alpha = 0
            }
            if let firstButtonTextColor =
                alertModel?.firstButtonTextColor {
                firstButton.setTitleColor(firstButtonTextColor, for: .normal)
            }
            if let firstButtonFont =
                alertModel?.firstButtonFont {
                firstButton.titleLabel?.font = firstButtonFont
            }
            if let firstButtonBackgroundColor =
                alertModel?.firstButtonBackgroundColor {
                firstButton.backgroundColor =
                    firstButtonBackgroundColor
            }
            if let topTitleFont = alertModel?.topTitleFont {
                topBoxTitleLabel.font = topTitleFont
            }
            if let secondButtonText =
                alertModel?.secondButtonText, !secondButtonText.isBlank {
                firstButton.alpha = 1
                secondButton.alpha = 1
                secondButton.setTitle(secondButtonText, for: .normal)
            } else {
                secondButton.alpha = 0
            }
            if let secondButtonTextColor =
                alertModel?.secondButtonTextColor {
                secondButton.setTitleColor(secondButtonTextColor, for: .normal)
            }
            if let secondButtonFont =
                alertModel?.secondButtonFont {
                secondButton.titleLabel?.font = secondButtonFont
            }
            if let secondButtonBackgroundColor =
                alertModel?.secondButtonBackgroundColor {
                secondButton.backgroundColor =
                    secondButtonBackgroundColor
            }
            if contentHeight < 1 && subTitleHeight < 1 && titleHeight < 40 {
                titleTopMargin = CGFloat(15)
            }
            if contentHeight < 1 && titleHeight < 1 && subTitleHeight < 40 {
                subTitleTopMargin = CGFloat(15)
            }
            setupViews()
        }
    }
    
    var title: String?
    
    let mainBoxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let topBoxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.blueMain()
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.grayScale2()
        return view
    }()
    
    let topBoxTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notice"
        label.numberOfLines = 2
        label.textColor = .white
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        return label
    }()
    
    let contentTextView: UITextView = {
        let tv = UITextView()
        tv.text = ""
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.textColor = UIColor.grayScale5()
        tv.backgroundColor = .clear
        tv.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        tv.font = UIFont(name: "Avenir Next", size: 14)
        return tv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.grayScale5()
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        label.font = UIFont(name: "Avenir Next", size: 14)
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.grayScale4()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "Avenir Next", size: 14)
        return label
    }()
    
    let textFieldTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.grayScale4()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.numberOfLines = 0
        label.alpha = 1
        label.font = UIFont(name: "Avenir Next", size: 14)
        return label
    }()
    
    let textField: LeftPaddedTextField = {
        let textField = LeftPaddedTextField()
        let placeHolderText = "Please enter"
        textField.textColor = UIColor.blueMain()
        if let font = UIFont(name: "Avenir Next", size: 16.0) {
            textField.font = font
        }
        if let placeHolderFont =
            UIFont(name: "AvenirNext-Regular", size: 16.0) {
            textField.backgroundColor = UIColor.grayScale1()
            textField.attributedPlaceholder =
                NSAttributedString(
                    string: placeHolderText,
                    attributes:
                        [
                            NSAttributedString.Key.foregroundColor:
                                UIColor.grayMain(),
                            NSAttributedString.Key.font: placeHolderFont
                        ]
                )
        }
        textField.addTarget(
            self,
            action: #selector(handleTextfieldChanged(_:)),
            for: .editingChanged)
        textField.layer.borderColor = UIColor.grayScale2().cgColor
        textField.layer.borderWidth = 0.8
        textField.alpha = 1
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let firstButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.setTitle("Ok", for: .normal)
        button.setTitleColor(UIColor.blueMain(), for: .normal)
        button.addTarget(
            self,
            action: #selector(firstButtonClicked),
            for: .touchUpInside)
        return button
    }()
    
    let secondButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.setTitle("No", for: .normal)
        button.setTitleColor(UIColor.grayScale4(), for: .normal)
        button.addTarget(
            self,
            action: #selector(secondButtonClicked),
            for: .touchUpInside)
        return button
    }()
    
    fileprivate func estimateFrameForText(
        _ text: String, width: CGFloat
    ) -> CGRect {
        let size = CGSize(width: width, height: 1000)
        let options =
            NSStringDrawingOptions.usesFontLeading
            .union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(
            with: size,
            options: options,
            attributes:
                [
                    NSAttributedString.Key.font:
                        UIFont.systemFont(ofSize: 16)
                ],
            context: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 3
        self.applyPlainShadow()
        backgroundColor = UIColor.grayScale3().withAlphaComponent(0.7)
    }
    
    func setupViews() {
        guard let _ = alertModel else { return }
        addSubview(mainBoxView)
        
        mainBoxView.addSubview(topBoxView)
        mainBoxView.addSubview(contentView)
        mainBoxView.addSubview(bottomView)
        
        topBoxView.addSubview(topBoxTitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentTextView)
        contentView.addSubview(contentTextView)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(textFieldTitleLabel)
        if let hasTextField = alertModel?.hasTextField, hasTextField {
            contentView.addSubview(textField)
        }
        
        bottomView.addSubview(firstButton)
        bottomView.addSubview(secondButton)
        
        _ = mainBoxView.anchor(
            topAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor,
            widthConstant: mainBoxWidth)
        
        _ = topBoxView.anchor(
            mainBoxView.topAnchor,
            left: mainBoxView.leftAnchor,
            right: mainBoxView.rightAnchor,
            heightConstant: topBoxHeight)
        
        _ = topBoxTitleLabel.anchor(
            topBoxView.topAnchor,
            left: topBoxView.leftAnchor,
            bottom: topBoxView.bottomAnchor,
            right: topBoxView.rightAnchor)
        
        _ = contentView.anchor(
            topBoxView.bottomAnchor,
            left: mainBoxView.leftAnchor,
            bottom: bottomView.topAnchor,
            right: mainBoxView.rightAnchor)
        
        _ = titleLabel.anchor(
            contentView.topAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            topConstant: titleTopMargin,
            leftConstant: 20,
            rightConstant: 20,
            heightConstant: titleHeight)
        
        _ = contentTextView.anchor(
            titleLabel.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            topConstant: contentTopMargin,
            leftConstant: 20,
            rightConstant: 20,
            heightConstant: contentHeight)
        
        _ = subTitleLabel.anchor(
            contentTextView.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            topConstant: subTitleTopMargin,
            leftConstant: 20,
            rightConstant: 20,
            heightConstant: subTitleHeight)
        
        _ = textFieldTitleLabel.anchor(
            subTitleLabel.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            leftConstant: 20,
            rightConstant: 20,
            heightConstant: textFieldTitleHeight)
        
        
        if let hasTextField =
            alertModel?.hasTextField,
           hasTextField {
            if let textFieldTitle =
                alertModel?.textFieldTitle,
               textFieldTitle.isBlank {
                textFieldTopMargin = 10
            }
            _ = textField.anchor(
                textFieldTitleLabel.bottomAnchor,
                left: contentView.leftAnchor,
                right: contentView.rightAnchor,
                topConstant: textFieldTopMargin,
                leftConstant: 20,
                rightConstant: 20,
                heightConstant: textFieldHeight)
        }
        
        _ = bottomView.anchor(
            left: mainBoxView.leftAnchor,
            bottom: mainBoxView.bottomAnchor,
            right: mainBoxView.rightAnchor,
            heightConstant: bottomBoxHeight)
        
        if let secondButtonText =
            alertModel?.secondButtonText,
           !secondButtonText.isBlank {
            _ = firstButton.anchor(
                bottomView.topAnchor,
                left: bottomView.leftAnchor,
                bottom: bottomView.bottomAnchor,
                right: bottomView.centerXAnchor,
                topConstant: 0.5)
            
            _ = secondButton.anchor(
                bottomView.topAnchor,
                left: firstButton.rightAnchor,
                bottom: bottomView.bottomAnchor,
                right: bottomView.rightAnchor,
                topConstant: 0.5,
                leftConstant: 0.5)
            
        } else {
            _ = firstButton.anchor(
                bottomView.topAnchor,
                left: bottomView.leftAnchor,
                bottom: bottomView.bottomAnchor,
                right: bottomView.rightAnchor,
                topConstant: 0.5)
        }
    }
    
    @objc func firstButtonClicked() {
        delegate?.firstButtonClicked?(for: self)
    }
    
    @objc func secondButtonClicked() {
        invalidateIntrinsicContentSize()
        delegate?.secondButtonClicked?(for: self)
    }
    
    @objc func handleTextfieldChanged (_ textField: UITextField) {
        delegate?.textfieldChanged?(for: self, text: textField.text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
