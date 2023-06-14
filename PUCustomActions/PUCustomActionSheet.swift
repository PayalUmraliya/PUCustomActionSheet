//
//  PUCustomActionSheet.swift
//  PUCustomActions
//
//  Created by PM on 25/05/23.
//

import Foundation
import UIKit
public class PUActionSheet: UIView {
   
    public typealias PUSelectionClosure = (_ item: PUButtonItem?) -> Void
    public var selectionClosure: PUSelectionClosure?
    public var topCornerRadius: CGFloat = 0
    private var title: PUTitleItem?
    private var buttons: [PUButtonItem] = []
    private var duration: Double?
    private var cancelButton: PUButtonItem?

    private struct Constants {
        static let PUdivideLineHeight: CGFloat = 1
        static let PUscreenBounds = UIScreen.main.bounds
        static let PUscreenSize = UIScreen.main.bounds.size
        static let PUscreenWidth = PUscreenBounds.width
        static let PUscreenHeight = PUscreenBounds.height
        static let PUbuttonHeight: CGFloat = 48.0 * PUscreenBounds.width / 375
        static let PUtitleHeight: CGFloat = 40.0 * PUscreenBounds.width / 375
        static let PUbtnPadding: CGFloat = 5 * PUscreenBounds.width / 375
        static let PUdefaultDuration = 0.25
        static let PUmaxHeight = PUscreenHeight * 0.62
        static let paddng_bottom: CGFloat = PUTools.isIphoneX ? 34.0 : 0.0
    }
    private var actionSheetView: UIView = UIView()
    private var actionSheetHeight: CGFloat = 0

    public var actionSheetViewBackgroundColor: UIColor? = PUTools.DefaultColor.backgroundColor

    private var scrollView: UIScrollView = UIScrollView()

    public var buttonBackgroundColor: UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public convenience init(
        title: PUTitleItem?,
        buttons: [PUButtonItem],
        duration: Double?,
        cancelButton: PUButtonItem?
    ) {
        self.init(frame: Constants.PUscreenBounds)
        self.title = title
        self.buttons = buttons

        self.duration = duration ?? Constants.PUdefaultDuration
        self.cancelButton = cancelButton
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapDismiss))
        singleTap.delegate = self
        addGestureRecognizer(singleTap)
        initActionSheet()
        initUI()
    }

    func initActionSheet() {
        let btnCount = buttons.count

        var tHeight: CGFloat = 0.0
        if title != nil {
            tHeight = Constants.PUtitleHeight
        }

        var cancelHeight: CGFloat = 0.0
        if cancelButton != nil {
            cancelHeight = Constants.PUbuttonHeight + Constants.PUbtnPadding
        }

        let contentHeight = CGFloat(btnCount) * Constants.PUbuttonHeight + CGFloat(btnCount) * Constants.PUdivideLineHeight
        let height = min(contentHeight, Constants.PUmaxHeight - tHeight - cancelHeight)

        scrollView.frame = CGRect(x: 0, y: tHeight, width: Constants.PUscreenWidth, height: height)
        actionSheetView.addSubview(scrollView)

        actionSheetHeight = tHeight + height + cancelHeight + Constants.paddng_bottom

        let aFrame: CGRect = CGRect(x: 0, y: Constants.PUscreenHeight, width: Constants.PUscreenWidth, height: actionSheetHeight)
        actionSheetView.frame = aFrame
        addSubview(actionSheetView)
        duration = duration ?? (Constants.PUdefaultDuration * Double(actionSheetHeight / 216))
    }

    func initUI() {
        setTitleView()
        setButtons()
        setCancelButton()
        setExtraView()
    }
    private func setTitleView() {
        if title != nil {
          
            let titleFrame = CGRect(x: 0, y: 0, width: Constants.PUscreenWidth, height: Constants.PUtitleHeight)
            let titlelabel = UILabel(frame: titleFrame)
            titlelabel.text = title!.text
            titlelabel.textAlignment = title!.textAlignment!
            titlelabel.textColor = title!.textColor
            titlelabel.font = title!.textFont
            titlelabel.backgroundColor = title!.backgroundColor?.rawValue
            actionSheetView.addSubview(titlelabel)
        }
    }

    private func setButtons() {
        let contentHeight = CGFloat(buttons.count) * Constants.PUbuttonHeight + CGFloat(buttons.count) * Constants.PUdivideLineHeight
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Constants.PUscreenWidth, height: contentHeight))
        view.clipsToBounds = true
        scrollView.addSubview(view)
        scrollView.contentSize = CGSize(width: Constants.PUscreenWidth, height: contentHeight)

        let buttonsCount = buttons.count
        for index in 0 ..< buttonsCount {
            let item = buttons[index]
            let origin_y = Constants.PUbuttonHeight * CGFloat(index) + Constants.PUdivideLineHeight * CGFloat(index)

            let button = PUButton(type: .custom)
            button.frame = CGRect(x: 0.0, y: origin_y, width: Constants.PUscreenWidth, height: Constants.PUbuttonHeight)
            button.item = item
            button.addTarget(self, action: #selector(actionClick), for: .touchUpInside)
            view.addSubview(button)
        }
    }
    private func setExtraView() {
        guard PUTools.isIphoneX else { return }
        let frame = CGRect(x: 0, y: self.actionSheetView.bounds.size.height - Constants.paddng_bottom, width: Constants.PUscreenWidth, height: Constants.paddng_bottom)
        let extraView = UIView()
        extraView.frame = frame
        if cancelButton != nil {
            extraView.backgroundColor = cancelButton?.backgroudImageColorNormal?.rawValue
        } else {
            let bgColor = buttons.first?.backgroudImageColorNormal?.rawValue
            extraView.backgroundColor = bgColor
        }
        self.actionSheetView.addSubview(extraView)
    }

    private func setCancelButton() {
        if cancelButton != nil {
            let button = PUButton(type: .custom)
            button.frame = CGRect(x: 0, y: actionSheetView.bounds.size.height - Constants.PUbuttonHeight - Constants.paddng_bottom, width: Constants.PUscreenWidth, height: Constants.PUbuttonHeight)
            button.item = cancelButton
            button.addTarget(self, action: #selector(actionClick), for: .touchUpInside)
            actionSheetView.addSubview(button)
        }
    }
    
    private func updateTopCornerMask() {
        guard topCornerRadius > 0 else { return }
        let shape = CAShapeLayer()
        let path = UIBezierPath(roundedRect: actionSheetView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: topCornerRadius, height: topCornerRadius))
        shape.path = path.cgPath
        shape.frame = actionSheetView.bounds
        actionSheetView.layer.mask = shape
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateTopCornerMask()
    }
}
//MARK: Event
extension PUActionSheet {
    @objc func actionClick(button: PUButton) {
        dismiss()
        guard let item = button.item else { return }
        selectionClosure?(item)
    }

    //tap action
    @objc func singleTapDismiss() {
        dismiss()
        selectionClosure?(nil)
    }
}

//MARK: present, dismiss
extension PUActionSheet {
    public func present() {
        if #available(iOS 13.0, *) {
            var keyWindows: UIWindow? {
                    return UIApplication.shared.connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .first(where: { $0 is UIWindowScene })
                        .flatMap({ $0 as? UIWindowScene })?.windows
                        .first(where: \.isKeyWindow)
                }
            if let keyWindow = keyWindows {
                keyWindow.addSubview(self)
            }
        } else {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        
        UIView.animate(withDuration: 0.1, animations: { [self] in
            self.actionSheetView.backgroundColor = actionSheetViewBackgroundColor
        }) { (_: Bool) in
            UIView.animate(withDuration: self.duration!) {
                self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
                self.actionSheetView.transform = CGAffineTransform(translationX: 0, y: -self.actionSheetView.frame.size.height)
            }
        }
    }

    func dismiss() {
        UIView.animate(withDuration: duration!, animations: {
            self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            self.actionSheetView.transform = .identity
        }) { (_: Bool) in
            self.removeFromSuperview()
        }
    }
}


// MARK: - UIGestureRecognizerDelegate
extension PUActionSheet: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard touch.view == actionSheetView else { return true }
        return false
    }
}

class PUButton: UIButton {
    /// item
    public var item: PUButtonItem? {
        willSet { updateButton(newValue) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func updateButton(_ item: PUButtonItem?) {
        guard let newItem = item else { return }
      
        let strs = newItem.title?.components(separatedBy: "\n")
        if strs?.count ?? 0 > 1
        {
            let attrString = NSMutableAttributedString(string: strs?[0] ?? "",
                                                       attributes: [
                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                        NSAttributedString.Key.foregroundColor :newItem.titleColor?.rawValue ?? PUButtonTitleColor.default
                                                                   ]);
            attrString.append(NSMutableAttributedString(string: "\n\(strs?[1] ?? "")",
                                                        attributes: [
                                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                            NSAttributedString.Key.foregroundColor :newItem.subtitleColor?.rawValue ?? PUButtonTitleColor.custom(.gray)
                                                                    ]));
            setAttributedTitle(attrString, for: .normal)
        }
        else
        {
            setTitle(newItem.title, for: .normal)
            setTitleColor(newItem.titleColor?.rawValue, for: .normal)
            titleLabel?.font = item?.titleFont
        }
        
       
        titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        titleLabel?.textAlignment = .center
        let noramlColor = newItem.backgroudImageColorNormal?.rawValue ?? PUTools.DefaultColor.normalColor
        let highlightColor = newItem.backgroudImageColorHighlight?.rawValue ?? PUTools.DefaultColor.highlightColor

        setBackgroundImage(PUTools.imageWithColor(color: noramlColor, size: bounds.size), for: .normal)
        setBackgroundImage(PUTools.imageWithColor(color: highlightColor, size: bounds.size), for: .highlighted)
    }
}
public enum PUButtonTitleColor {
   
    case `default`
    case blue
    case danger
    case custom(UIColor)
}

extension PUButtonTitleColor: RawRepresentable {
    public typealias RawValue = UIColor

    public init?(rawValue: UIColor) {
        switch rawValue {
        case UIColor(red: 0.000, green: 0.000, blue: 0.004, alpha: 1.00): self = .default
        case UIColor(red: 0.082, green: 0.494, blue: 0.984, alpha: 1.00): self = .blue
        case UIColor.red: self = .danger
        case let color: self = .custom(color)
        }
    }

    public var rawValue: UIColor {
        switch self {
        case .default: return UIColor(red: 0.000, green: 0.000, blue: 0.004, alpha: 1.00)
        case .blue: return UIColor(red: 0.082, green: 0.494, blue: 0.984, alpha: 1.00)
        case .danger: return UIColor.red
        case let .custom(customColor): return customColor
        }
    }
}
public struct PUButtonItem {
    public var title: String?
    public var titleColor: PUButtonTitleColor? = .default
    public var subtitleColor: PUButtonTitleColor? = .default
    public var titleFont: UIFont? = .systemFont(ofSize: 16.0)
    public var buttonType: PUButtonType?
    public var backgroudImageColorNormal: PUButtonTitleColor? = .custom(PUTools.DefaultColor.normalColor)
    public var backgroudImageColorHighlight: PUButtonTitleColor? = .custom(PUTools.DefaultColor.highlightColor)

    public init(title: String?,
                titleColor: PUButtonTitleColor? = .default,
                subtitleColor: PUButtonTitleColor? = .custom(UIColor.gray),
                titleFont: UIFont? = .systemFont(ofSize: 16.0),
                buttonType: PUButtonType?,
                backgroudImageColorNormal: PUButtonTitleColor? = .custom(PUTools.DefaultColor.normalColor),
                backgroudImageColorHighlight: PUButtonTitleColor? = .custom(PUTools.DefaultColor.highlightColor)) {
        self.title = title
        self.subtitleColor = subtitleColor
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.buttonType = buttonType
        self.backgroudImageColorNormal = backgroudImageColorNormal
        self.backgroudImageColorHighlight = backgroudImageColorHighlight
    }
}
public enum PUButtonType {
    case `default`(index: Int)
    case cancel
}
public struct PUTools {
    public struct DefaultColor {
        public static let backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.941, alpha: 0.90).withAlphaComponent(0.9)
        public static let normalColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.80)
        public static let highlightColor = UIColor(red: 0.780, green: 0.733, blue: 0.745, alpha: 0.80)
    }
    
    static var isIphoneX: Bool {
        if #available(iOS 11.0, *) {
            var keyWindow: UIWindow? {
                    return UIApplication.shared.connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .first(where: { $0 is UIWindowScene })
                        .flatMap({ $0 as? UIWindowScene })?.windows
                        .first(where: \.isKeyWindow)
                }
            return keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        } else {
            return false
        }
    }
    
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
public struct PUTitleItem {
    public var text: String?
    public var textColor: UIColor?
    public var textFont: UIFont? = .systemFont(ofSize: 14.0)
    public var textAlignment: NSTextAlignment? = .center
    public var backgroundColor: PUButtonTitleColor? = .custom(UIColor.clear)

    public init(title: String?,
                titleColor: UIColor? = PUButtonTitleColor.default.rawValue,
                titleFont: UIFont? = .systemFont(ofSize: 14.0),
                textAlignment: NSTextAlignment? = .center,
                backgroundColor: PUButtonTitleColor? = .custom(UIColor.white.withAlphaComponent(0.5 ))
    ) {
        self.text = title
        self.textColor = titleColor
        self.textFont = titleFont
        self.textAlignment = textAlignment
        self.backgroundColor = backgroundColor ?? .custom(UIColor.clear)
    }
}
