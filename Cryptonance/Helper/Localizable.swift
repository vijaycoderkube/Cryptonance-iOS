
// DT :: 7 / March / 2019

import UIKit

// MARK: Localizable
public protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: XIBLocalizable
public protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}
 
extension UILabel: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get {
            return nil }
        set(key) {
             text = key?.localized
        }
    }
}

extension UILabel {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
         self.text = self.text?.localized
        if getLangCode() == arabic {
            if textAlignment == .left {
                textAlignment = .right
            }
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}

extension UIButton {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.setTitle(self.currentTitle?.localized, for: .normal)
    }
}

extension UINavigationItem: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            title = key?.localized
        }
    }
}

extension UINavigationItem  {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
         self.title = self.title?.localized
    }
}

extension UIBarItem: XIBLocalizable { // Localizes UIBarButtonItem and UITabBarItem
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            title = key?.localized
        }
    }
}

extension UIBarItem { // Localizes UIBarButtonItem and UITabBarItem
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.title = self.title?.localized
    }
}

// MARK: Special protocol to localize multiple texts in the same control
public protocol XIBMultiLocalizable {
    var xibLocKeys: String? { get set }
}

extension UISegmentedControl: XIBMultiLocalizable {
    @IBInspectable public var xibLocKeys: String? {
        get { return nil }
        set(keys) {
            guard let keys = keys?.components(separatedBy: ","), !keys.isEmpty else { return }
            for (index, title) in keys.enumerated() {
                setTitle(title.localized, forSegmentAt: index)
            }
        }
    }
}

// MARK: Special protocol to localizaze UITextField's placeholder
public protocol UITextFieldXIBLocalizable {
    var xibPlaceholderLocKey: String? { get set }
}

extension UITextField: UITextFieldXIBLocalizable {
    @IBInspectable public var xibPlaceholderLocKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized
        }
    }
}

//extension UITextField {
//
//    open override func awakeFromNib() {
//        super.awakeFromNib()
//        self.placeholder = self.placeholder?.localized
//    }
//}




