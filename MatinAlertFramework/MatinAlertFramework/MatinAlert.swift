//
//  MatinAlert.swift
//  MatinAlertFramework
//
//  Created by Matin Kajabadi on 12/31/20.
//

import Foundation
import UIKit


public protocol MatinAlertDelegate: NSObjectProtocol {
    func buttonClicked(buttonKind: MatinAlert.ButtonKind)
}

private class MatinAlertDefaultStyle: NSObject {
    static let sharedInstance = MatinAlertDefaultStyle()
    private override init() { }
    var defaultAlertStyle: MatinAlert.CustomStyle?
}

open class MatinAlert: UIViewController {
    public enum ButtonKind {
        case confirm
        case cancel
    }

    public enum AlertType {
        case success
        case error
        case warning
        case info
        case predefined
        case custom(style: CustomStyle)
    }

    public struct CustomTextStyle {
        public var alignment: NSTextAlignment?
        public var bgColor: UIColor?
        public var color: UIColor?
        public var font: UIFont?
        public init() {}
    }

    public struct CustomButtonStyle {
        public var font: UIFont?
        public var bgColor: UIColor?
        public var titleColor: UIColor?
        public init() {}
    }

    public struct CustomViewStyle {
        public var color: UIColor?
        public var borderWidth: CGFloat?
        public var borderColor: UIColor?
        public var cornerRadius: CGFloat?
        public init() {}
    }

    public struct CustomStyle {
        public var topHeaderView: CustomViewStyle?
        public var contentView: CustomViewStyle?
        public var topHeaderText: CustomTextStyle?
        public var contentText: CustomTextStyle?
        public var firstButton: CustomButtonStyle?
        public var secondButton: CustomButtonStyle?
        public init() {}
    }
    var buttonAction:((_ buttonKind: ButtonKind) -> Void)? = nil
    fileprivate var matinAlertView: MatinAlertView!
    fileprivate let overlayView = UIView()
    fileprivate var strongSelf: MatinAlert?
    fileprivate var alertData: MatinAlertModel?
    fileprivate var alertStyle: CustomStyle?
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = UIScreen.main.bounds
        self.view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleHeight,
            UIView.AutoresizingMask.flexibleWidth]
        self.view.backgroundColor =
            UIColor.grayScale1().withAlphaComponent(0.7)
        strongSelf = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceRotated),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }
    
    @objc private func deviceRotated() {
        dismissAlert(completion: { [weak self] in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.setupViews()
        }, animated: false)
    }
    
    public static func setDefaultStyle(customStyle: CustomStyle) {
        MatinAlertDefaultStyle.sharedInstance.defaultAlertStyle = customStyle
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func showAlert(
        withContent text: String,
        action: ((_ buttonKind: ButtonKind) -> Void)? = nil) -> MatinAlert {
        showAlert("",
                  contentText: text,
                  alertType: .info,
                  firstButtonTitle: nil, secondButtonTitle: nil)
        return self
    }
    
    open func showAlert(
        _ title: String,
        contentText: String?,
        alertType: AlertType? = nil,
        firstButtonTitle: String? = nil,
        secondButtonTitle: String? = nil,
        action: ((_ buttonKind: ButtonKind) -> Void)? = nil) -> MatinAlert {
        showAlert(
            title,
            contentText: contentText,
            alertType: alertType ?? .info,
            firstButtonTitle: firstButtonTitle,
            secondButtonTitle: secondButtonTitle)
        return self
    }
    
    private func showAlert(
        _ title: String,
        contentText: String?,
        alertType: AlertType,
        firstButtonTitle: String?,
        secondButtonTitle: String?,
        action: ((_ buttonKind: ButtonKind) -> Void)? = nil) -> Void {
        buttonAction = action
        if let window: UIWindow =
            UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            window.addSubview(view)
            window.bringSubviewToFront(view)
            view.frame = window.bounds
            let data = MatinAlertModel()
            data.topTitle = title
            data.contentText = contentText ?? ""
            data.firstButtonTitle = firstButtonTitle ?? "OK"
            data.secondButtonTitle = secondButtonTitle
            data.topTitle = title
            alertData = data
            alertStyle = getStyle(for: alertType)
            setupViews()
        }
    }
    
    private func getStyle(for alertType: AlertType ) -> CustomStyle {
        var topHeaderView = CustomViewStyle()
        var customStyle = CustomStyle()
        switch alertType {
        case .success:
            topHeaderView.color = UIColor.systemGreen
            customStyle.topHeaderView = topHeaderView
            return customStyle
        case .error:
            topHeaderView.color = UIColor.systemRed
            customStyle.topHeaderView = topHeaderView
            return customStyle
        case .warning:
            topHeaderView.color = UIColor.systemOrange
            customStyle.topHeaderView = topHeaderView
            return customStyle
        case .info:
            topHeaderView.color = UIColor.blueMain()
            customStyle.topHeaderView = topHeaderView
            return customStyle
        case .predefined:
            if let defaultAlertStyle =
                MatinAlertDefaultStyle.sharedInstance.defaultAlertStyle {
                return setDarkModeForCustomStyle(userCustomStyle: defaultAlertStyle)
            } else {
                print("MatinAlert: You need to call MatinAlert.setDefaultStyle before calling showAlert")
                return getStyle(for: .info)
            }
        case let .custom(userCustomStyle):
            return setDarkModeForCustomStyle(userCustomStyle: userCustomStyle)
        }
    }
    
    private func setDarkModeForCustomStyle(
        userCustomStyle: CustomStyle) -> CustomStyle {
        var customStyle = CustomStyle()
        customStyle = userCustomStyle
        if let contentViewBackground = customStyle.contentView?.color {
            if customStyle.contentText?.bgColor == nil {
                if customStyle.contentText == nil {
                    var contentText = CustomTextStyle()
                    contentText.bgColor = contentViewBackground
                    customStyle.contentText = contentText
                } else {
                    customStyle.contentText?.bgColor = contentViewBackground
                }
            }
        }
        return customStyle
    }
    
    private func setupViews() {
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            window.endEditing(true)
            overlayView.backgroundColor = UIColor(white: 0, alpha: 0.65)
            window.addSubview(overlayView)
            matinAlertView = MatinAlertView()
            matinAlertView.customStyle = alertStyle
            matinAlertView.data = alertData
            matinAlertView.delegate = self
            overlayView.addSubview(matinAlertView)
            overlayView.frame = window.frame
            overlayView.alpha = 0
            overlayView.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(dismissKeyboard)
                ))
            
            matinAlertView.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint =
                matinAlertView.centerXAnchor.constraint(
                    equalTo: overlayView.centerXAnchor)
            let verticalConstraint =
                matinAlertView.centerYAnchor.constraint(
                    equalTo: overlayView.centerYAnchor)
            NSLayoutConstraint.activate(
                [
                    horizontalConstraint, verticalConstraint
                ])
            matinAlertView.transform =
                CGAffineTransform.init(scaleX: 0.7, y: 0.7)
            matinAlertView.alpha = 0
            
            UIView.animate(
                withDuration: 0.65,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseOut,
                animations: { [weak self] in
                    guard let unwrappedSelf = self else { return }
                    unwrappedSelf.overlayView.alpha = 1
                    unwrappedSelf.matinAlertView.alpha = 1
                    unwrappedSelf.matinAlertView.transform =
                        CGAffineTransform.identity
                }, completion: nil)
        }
    }
    
    
    private func dismissAlert(
        completion: (() -> Void)? = nil,
        animated: Bool? = true) {
        if (animated ?? true) {
            UIView.animate(
                withDuration: 0.2,
                animations: { [weak self] in
                    guard let unwrappedSelf = self else { return }
                    unwrappedSelf.matinAlertView.transform =
                        CGAffineTransform.init(scaleX: 0.8, y: 0.8)
                    unwrappedSelf.matinAlertView.alpha = 0
                }, completion: { _ in
                    self.view.removeFromSuperview()
                    self.overlayView.removeFromSuperview()
                    if completion != nil {
                        completion!()
                    }
                }
            )
        } else {
            self.matinAlertView.alpha = 0
            self.view.removeFromSuperview()
            self.overlayView.removeFromSuperview()
            if completion != nil {
                completion!()
            }
        }
    }
    
    private func cleanUp() -> Void {
        self.matinAlertView = nil
        self.strongSelf = nil
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }
}

extension MatinAlert: MatinAlertDelegate {
    public func buttonClicked(buttonKind: ButtonKind) {
        dismissAlert()
        cleanUp()
        if buttonAction != nil {
            buttonAction!(buttonKind)
        }
    }
}

private class MatinAlertView: UIView {
    fileprivate weak var delegate: MatinAlertDelegate?
    private var contentTableView = MatinAlertContentTableView()
    private let mainBoxWidth = CGFloat(300)
    private var topBoxHeight = CGFloat(50)
    private var bottomBoxHeight = CGFloat(45)
    private lazy var deviceHeight = UIScreen.main.bounds.size.height
    private lazy var deviceWidth = UIScreen.main.bounds.size.width
    private lazy var maxContentHeight = UIDevice.current.orientation.isLandscape
        ? deviceHeight - (deviceHeight / 2)
        : deviceHeight - deviceWidth
    private var contentHeight = CGFloat(50)
    
    fileprivate var customStyle: MatinAlert.CustomStyle? {
        didSet {
            if let topHeaderView = customStyle?.topHeaderView {
                if let color = topHeaderView.color {
                    topBoxView.backgroundColor = color
                }
                if let borderWidth = topHeaderView.borderWidth {
                    topBoxView.layer.borderWidth = borderWidth
                }
                if let borderColor = topHeaderView.borderColor {
                    topBoxView.layer.borderColor = borderColor.cgColor
                    
                }
                if let cornerRadius = topHeaderView.cornerRadius {
                    topBoxView.layer.cornerRadius = cornerRadius
                }
            }
            
            if let contentView = customStyle?.contentView {
                if let color = contentView.color {
                    mainBoxView.backgroundColor = color
                }
                if let borderWidth = contentView.borderWidth {
                    mainBoxView.layer.borderWidth = borderWidth
                }
                if let borderColor = contentView.borderColor {
                    mainBoxView.layer.borderColor = borderColor.cgColor
                    
                }
                if let cornerRadius = contentView.cornerRadius {
                    mainBoxView.layer.cornerRadius = cornerRadius
                }
            }
            
            if let firstButtonStyle = customStyle?.firstButton {
                if let font = firstButtonStyle.font {
                    firstButton.titleLabel?.font = font
                }
                if let bgColor = firstButtonStyle.bgColor {
                    firstButton.backgroundColor = bgColor
                }
                if let titleColor = firstButtonStyle.titleColor {
                    firstButton.setTitleColor(titleColor, for: .normal)
                }
            }
            
            if let secondButtonStyle = customStyle?.secondButton {
                if let font = secondButtonStyle.font {
                    secondButton.titleLabel?.font = font
                }
                if let bgColor = secondButtonStyle.bgColor {
                    secondButton.backgroundColor = bgColor
                }
                if let titleColor = secondButtonStyle.titleColor {
                    secondButton.setTitleColor(titleColor, for: .normal)
                }
            }
        }
    }
    
    fileprivate var data: MatinAlertModel? {
        didSet {
            if let topTitle = data?.topTitle {
                topHeaderTitleLabel.text = topTitle
                if topTitle.isBlank {
                    topBoxHeight = CGFloat(0)
                    var contentText = MatinAlert.CustomTextStyle()
                    contentText.alignment = .center
                    contentTableView.customTextStyle = contentText
                }
            }
            if let firstButtonTitle = data?.firstButtonTitle {
                firstButton.alpha = 1
                firstButton.setTitle(firstButtonTitle, for: .normal)
            } else {
                firstButton.alpha = 0
            }
            if let secondButtonTitle = data?.secondButtonTitle {
                secondButton.alpha = 1
                secondButton.setTitle(secondButtonTitle, for: .normal)
            } else {
                secondButton.alpha = 0
            }
            setupViews()
            if let contentText = data?.contentText {
                contentTableView.content = contentText
            }
            if let contextTextStyle = customStyle?.contentText {
                contentTableView.customTextStyle = contextTextStyle
            }
        }
    }
    
    
    private let mainBoxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    private let topBoxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.blueMain()
        return view
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.grayScale2()
        return view
    }()
    
    private let topHeaderTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notice"
        label.numberOfLines = 2
        label.textColor = .white
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        return label
    }()
    
    private let firstButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.systemBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.setTitle("Ok", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        button.setTitleColor(UIColor.grayScale3(), for: .normal)
        button.addTarget(
            self,
            action: #selector(firstButtonClicked),
            for: .touchUpInside)
        return button
    }()
    
    private let secondButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.systemBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.setTitleColor(UIColor.grayScale3(), for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
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
        layer.cornerRadius = 5
        applyPlainShadow()
        backgroundColor = UIColor.grayScale3().withAlphaComponent(0.7)
    }
    
    private func setupViews() {
        if let contentText = data?.contentText {
            let estimatedHeight =
                estimateFrameForText(contentText, width: 200).height
            contentHeight = estimatedHeight < contentHeight
                ? contentHeight
                : (estimatedHeight > maxContentHeight)
                ? maxContentHeight
                : estimatedHeight
        }
        addSubview(mainBoxView)
        mainBoxView.addSubview(topBoxView)
        mainBoxView.addSubview(contentTableView)
        mainBoxView.addSubview(bottomView)
        topBoxView.addSubview(topHeaderTitleLabel)
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
        
        _ = topHeaderTitleLabel.anchor(
            topBoxView.topAnchor,
            left: topBoxView.leftAnchor,
            bottom: topBoxView.bottomAnchor,
            right: topBoxView.rightAnchor)
        
        _ = contentTableView.anchor(
            topBoxView.bottomAnchor,
            left: mainBoxView.leftAnchor,
            bottom: bottomView.topAnchor,
            right: mainBoxView.rightAnchor,
            topConstant: 15,
            leftConstant: 25,
            rightConstant: 25,
            heightConstant: contentHeight + 45
        )
        
        _ = bottomView.anchor(
            contentTableView.bottomAnchor,
            left: mainBoxView.leftAnchor,
            bottom: mainBoxView.bottomAnchor,
            right: mainBoxView.rightAnchor,
            heightConstant: bottomBoxHeight)
        
        if let secondButtonTitleLabel = secondButton.titleLabel,
           let secondButtonText = secondButtonTitleLabel.text {
            if !secondButtonText.isBlank {
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
        } else {
            _ = firstButton.anchor(
                bottomView.topAnchor,
                left: bottomView.leftAnchor,
                bottom: bottomView.bottomAnchor,
                right: bottomView.rightAnchor,
                topConstant: 0.5)
        }
    }
    
    @objc private func firstButtonClicked() {
        invalidateIntrinsicContentSize()
        delegate?.buttonClicked(buttonKind: .confirm)
    }
    
    @objc private func secondButtonClicked() {
        invalidateIntrinsicContentSize()
        delegate?.buttonClicked(buttonKind: .cancel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


fileprivate class MatinAlertModel: NSObject {
    var topTitle: String = "Notice"
    var contentText: String = ""
    var firstButtonTitle: String = "Ok"
    var secondButtonTitle: String? = nil
}

fileprivate class MatinAlertContentCell: UITableViewCell {
    lazy private var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor.label
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(name: "Avenir Next", size: 15)
        return label
    }()
    
    fileprivate func configure(
        with data: MatinAlertModel,
        textStyle: MatinAlert.CustomTextStyle?) {
        contentLabel.text = data.contentText
        if let alignment = textStyle?.alignment {
            contentLabel.textAlignment = alignment
        }
        if let color = textStyle?.color {
            contentLabel.textColor = color
        }
        if let font = textStyle?.font {
            contentLabel.font = font
        }
        if let font = textStyle?.font {
            contentLabel.font = font
        }
    }
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() -> Void {
        contentView.addSubview(contentLabel)
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 8),
            contentLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 8),
            contentLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -8),
            contentLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -8),
        ])
    }
}

fileprivate class MatinAlertContentTableView:
    UITableView,
    UITableViewDelegate,
    UITableViewDataSource {
    private let tableViewCellId = "tableViewCellId"
    fileprivate var customTextStyle: MatinAlert.CustomTextStyle? {
        didSet {
            if let bgColor = customTextStyle?.bgColor {
                self.backgroundColor = bgColor
            }
            reloadData()
        }
    }
    fileprivate var content: String? {
        didSet {
            reloadData()
        }
    }
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        delegate = self
        dataSource = self
        allowsSelection = false
        bounces = false
        register(
        MatinAlertContentCell.self,
        forCellReuseIdentifier: tableViewCellId)
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 44
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(
        in tableView: UITableView)
    -> Int { 1 }
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int)
    -> Int {1}
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: tableViewCellId,
                for: indexPath)
            as! MatinAlertContentCell
        let data = MatinAlertModel()
        data.contentText = content ?? ""
        if let bgColor = customTextStyle?.bgColor {
            cell.contentView.backgroundColor = bgColor
        }
        cell.configure(with: data, textStyle: customTextStyle)
        return cell
    }
}
