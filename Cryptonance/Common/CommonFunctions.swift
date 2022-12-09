//
//  CommonFunctions.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 21/10/22.
//

import UIKit
import Foundation
import WebKit
import Alamofire
import JGProgressHUD
import CRNotifications
import SDWebImage
import ObjectiveC
import SKCountryPicker
import FirebaseDatabase
import SwiftyJSON

@available(iOS 13.0, *)
let appDelegate = UIApplication.shared.delegate as! AppDelegate
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let maxCharacters = 9 //10
var selectSocialLink : Int? //Here 2 = twitter, 0 = Google, 1 = facebook
var hud = JGProgressHUD(style: .dark)
private var AssociatedObjectHandle: UInt8 = 0
var TableObejctHandel = "TABLEVIEWHANDAL"
var maxLengths = [UITextField: Int]()
var showPassword : Bool = false
public var manager : CountryListDataSource = CountryManager.shared
var currency : String?
var dictNotification = json()
//var reference : DatabaseReference?
let databseReference = Database.database().reference()
var userDataObject = Config().userData().dictionaryObject as JSONDictionary? ?? JSONDictionary()

//MARK: - completion Handlor
typealias completionHandler = ([String : Any]) ->  Void
typealias reloadDataHandler = (Any) -> Void
public typealias CompletionObject<T> = (_ response: T) -> Void

func widthPer(per : Float) -> CGFloat{
    return  (UIScreen.main.bounds.size.width *  CGFloat(per))/100
}

func heightPer(per : Float) -> CGFloat{
    return  (UIScreen.main.bounds.size.height *  CGFloat(per))/100
}

/// Inherited from MeterialComponents for making toast message
func makeToast(type: CRNotificationType , title: String, message: String) {
    CRNotifications.showNotification(type: type, title: title.localized.capitalized, message: message.localized.capitalized, dismissDelay: 3)
}


//MARK: - Loader setup
///Shows Loader / Activity Indicator
func showLoader() {
    hud.textLabel.text = "please_wait".localized
    hud.show(in: UIApplication.shared.windows.first!)
}

///Hides Loader /  Activity Indicator
func hideLoader() {
    hud.dismiss(animated: true)
}


//MARK: - Check Internet Connectivity
///Checks Internet Connectivity
struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}


//MARK: - UITextField Setup
//TODO: For arabic
//-- Textfield Alighment set with language
//-- UITextField Alighment set with language
extension UITextField {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.autocorrectionType = .no
        
        if getLangCode() == arabic {
            if self.textAlignment == .center {
                self.textAlignment = .center
            }
            else {
                self.textAlignment = .right
            }
        }
        else {
            if self.textAlignment == .center {
                self.textAlignment = .center
            }
            else {
                self.textAlignment = .left
            }
        }
    }
    
    @IBInspectable var placeholderColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }
    
    /// use this method while you need text from text field as there never crash and get "" alwasys string
    ///
    /// - Returns: <#return value description#>
    @objc func getText()-> String{
        if (self.text?.count)! > 0{
            return self.text!
        }else{
            return ""
        }
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        self.leftViewMode = .always
        let paddingView = UIControl(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        paddingView.addTarget(self, action: #selector(touchDown), for: [.touchUpInside])
        self.leftView = paddingView
    }
    
    @objc
    private func touchDown() {
        self.becomeFirstResponder()
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        self.rightViewMode = .always
        let paddingView = UIControl(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        paddingView.addTarget(self, action: #selector(touchDown), for: [ .touchUpInside])
        self.rightView = paddingView
    }
    
    @IBInspectable var maxLength: Int {
        get {
            guard let l = maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    
    @objc func fix(textField: UITextField) {
        if let t: String = textField.text {
            textField.text = String(t.prefix(maxLength))
        }
    }
}


//MARK: - UITextView Setup
//TODO: For arabic
//-- UITextView Alighment set with language
//-- UITextView Alighment set with language
extension UITextView {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        if getLangCode() == arabic {
            if self.textAlignment == .center {
                self.textAlignment = .center
            }
            else {
                self.textAlignment = .right
            }
        } else {
            if self.textAlignment == .center {
                self.textAlignment = .center
            }
            else {
                self.textAlignment = .left
            }
        }
    }
}


//MARK: - WKWebView setup
extension WKWebView {
    
    /// load HTML String same font like the web-view
    ///
    //// - Parameters:
    ///   - content: HTML content which we need to load in the web-view.
    ///   - baseURL: Content base url. It is optional.
    func loadHTMLStringWithMagic(content:String,baseURL:URL?) {
        
        let font = themeFont(size: 16, fontname: .medium)
        
        let modifiedFont = NSString(format:"<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize)\"></span>" as NSString ) as String
        
        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
        loadHTMLString(headerString + content, baseURL: baseURL)
    }
}


//MARK: - Date setup
extension Date {
    
    func getDateFor(days:Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())
    }
    
    func getYearFor(years:Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: years, to: Date())
    }
    
    static func generateDatesArrayBetweenTwoDates(startDate: Date, endDate: Date) -> [Date] {
        var datesArray: [Date] = [Date]()
        var startDate = startDate
        let calendar = Calendar.current
        while startDate <= endDate {
            let tempDate = self.dateFormatter().string(from: startDate)
            datesArray.append(self.dateFormatter().date(from: tempDate) ?? Date())
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        }
        return datesArray
    }
    
    static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func isMonday(dayNumber : Int) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == dayNumber
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}


/// Regex for Email Validation
func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}


func isAllowed(str: String?) -> Bool {
    let regexPattern: String = "^((?!(0))[0-9]{0,10})$"
    let predicate = NSPredicate(format:"SELF MATCHES %@", regexPattern)

    return predicate.evaluate(with: str)
}


extension String {
    /// HTML to String
    /// - Returns: Returns HTML data into String  format
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: true) else { return nil }
        guard let html = try? NSMutableAttributedString(
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else { return nil }
        return html
    }
    
    
    /// Name Validation
    var isValidName: Bool {
        let regularExpressionForName = "^(?! +$)[A-Za-zăâîșțĂÂÎȘȚ -]+$"
        let testName = NSPredicate(format:"SELF MATCHES %@", regularExpressionForName)
        return testName.evaluate(with: self)
    }
    
    
    /// Validate String with only numbers
    var isOnlyNumber: Bool {
        let regularExpressionForName = "[1-0]"
        let testName = NSPredicate(format:"SELF MATCHES %@", regularExpressionForName)
        return testName.evaluate(with: self)
    }

    
    /// Validate String with only characters
    var isOnlyCharacter: Bool {
        let regularExpressionForName = "[a-zA-Z]"
        let testName = NSPredicate(format:"SELF MATCHES %@", regularExpressionForName)
        return testName.evaluate(with: self)
    }
    
    /// Phone Number Validation
    public var validPhoneNumber : Bool {
        let types:NSTextCheckingResult.CheckingType = [.phoneNumber]
        guard let detector = try? NSDataDetector(types: types.rawValue) else { return false }
        
        if let match = detector.matches(in: self, options: [], range: NSMakeRange(0,self.count)).first?.phoneNumber {
            return match == self
        } else {
            return false
        }
    }
    
    /// give two decimal point value
    func setDecimalPoint(minimumFractionDigits : Int?, maximumFractionDigits : Int?) -> String {
        let numberFormatter:NumberFormatter = NumberFormatter.init()
        numberFormatter.decimalSeparator = "."
        numberFormatter.maximumFractionDigits = maximumFractionDigits ?? 0
        numberFormatter.minimumFractionDigits = minimumFractionDigits ?? 0
        //        numberFormatter.minimumIntegerDigits = 1
        return  numberFormatter.string(from: NSNumber.init(value: getDouble(value: self)))!
    }
    
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundedValue(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

func getDouble(value: Any?,nullValue :Double? = 0.0 ) -> Double {
    var fValue: Double = nullValue!
    if let val = value {
        if val is NSNull {
            return fValue
        }
        else {
            if val is Int {
                fValue = Double(val as! Int)
            }
            else if val is String {
                let stValue: String = val as! String
                fValue = (stValue as NSString).doubleValue
            }
            else if val is Float {
                fValue = Double(val as! Float)
            }else if val is Double {
                fValue = val as! Double
            }else{
                return fValue
            }
        }
    }
    return fValue
}

/// Regex for only Charecter Number space are allowed
func onlyCharacterNumberSpaceAllowed(string: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: #"^[0-9a-zA-Z ]*$"#, options: .anchorsMatchLines)
        if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
            return false
        }
    }
    catch {
        print("Invalid charecter enter")
    }
    return true
}

/// Regex for only Number space are allowed
func onlyNumberSpaceAllowed(string: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: #"^[0-9 ]*$"#, options: .anchorsMatchLines)
        if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
            return false
        }
    }
    catch {
        print("Invalid charecter enter")
    }
    return true
}

/// Regex for only Charecter space are allowed
func onlyCharacterAllowed(string: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: ".*[^A-Za-z].* ", options: [])
        if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
            return false
        }
    }
    catch {
        print("Invalid charecter enter")
    }
    return true
}


/// Regex to prevent of entering speacial characters
func specialCharacterNotAllowed(string: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: "'*=+[]\\|;:'\",<>/?%", options: [])
        if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
            return false
        }
    }
    catch {
        print("Invalid charecter enter")
        return false
    }
    return true
}

/// Regex for only Charecter Number space are allowed
func allowCharacterNumberSpacing(txt: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9 ].*", options: [])
        if regex.firstMatch(in: txt, options: [], range: NSMakeRange(0, txt.count)) != nil {
            return false
        }
    }
    catch {
        print("Not allow character")
    }
    return true
    
}


/// Date to String Conversion
func DateToString(Formatter:String,date:Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Formatter
    let FinalDate:String = dateFormatter.string(from: date)
    return FinalDate
}


/// Hex to UIColor
/// - Returns: pass #aaaaa hex colorcode return uicolor
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}


//MARK: - UIColor setup
extension UIColor {
    
    /// color with hax string
    ///
    /// - Parameter hexString: hexString description
    convenience init(hexString:String) {
        var hexString:String = hexString.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if (hexString.hasPrefix("#")) { hexString.remove(at: hexString.startIndex) }
        
        var color:UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(displayP3Red: red, green: green, blue: blue, alpha: 1)
        //self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    static let backgroundColor = UIColor(hexString: "#1E1E1E") 
    static let themeYellow = UIColor(hexString: "#FFD60A")
    static let themeWhite = UIColor(hexString: "#F2F2F2")
    static let themeButtonFontColor = UIColor(hexString: "#141414")
    static let textFieldBorderColor = UIColor(hexString: "#707070")
    static let themeGrayColor = UIColor(hexString: "#202020")
}

//MARK: - NSLayoutConstraint setup
extension NSLayoutConstraint {
    
    /// to set constatnt by screen width %
    @IBInspectable var widthPercentage: Double {
        
        get {
            return self.constant
        }
        
        set {
            self.constant = UIScreen.main.bounds.width * newValue / 100
        }
    }
    
    /// to set constatnt by screen width %
    @IBInspectable var heightPercentage: Double {
        
        get {
            return self.constant
        }
        
        set {
            self.constant = UIScreen.main.bounds.height * newValue / 100
        }
    }
}


//MARK: - UILabel setup
extension UILabel {
    
    /// Set font  as per below name that will replace any font with this name
    ///
    ///     English Font
    ///   1. SegoeUI
    ///   2. SegoeUI-Italic
    ///   3. SegoeUI-Bold
    ///   4. SegoeUI-BoldItalic
    ///
    ///     Arabic Font
    ///    1. STV-Bold
    @IBInspectable var isApplyFont: Bool {
        get {
            return self.isApplyFont
        }
        
        set {
            self.isApplyFont = newValue
            if getLangCode() == "ar"{
                //TODO: - Applay font here for arabic
                
            }else{
                //TODO: - Change system font here
                
            }
        }
    }
}


//MARK: - UIView setup
extension UIView {
    
    @IBInspectable var roundCorner: Bool {
        
        get{
            if layer.cornerRadius == self.frame.size.width / 2
            {
                return true
            }
            return false
        }
        set {
            rounded()
        }
    }
    
    
    func roundedHeightView() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
    
    
    /// view's identifier
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    /// For load uiview with XIB
    /// - Returns: return UIView from XIB
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    /// Returns the first constraint with the given identifier, if available.
    ///
    /// - Parameter identifier: The constraint identifier.
    @objc  func selfconstraintWithIdentifier(_ identifier: String) -> NSLayoutConstraint? {
        return self.constraints.first { $0.identifier == identifier }
    }
    
    
    @objc func constraintWithIdentifier(_ identifier: String) -> NSLayoutConstraint? {
        var constraintsArray: [NSLayoutConstraint] = []
        var subviews: [UIView] = [self]
        while !subviews.isEmpty {
            constraintsArray += subviews.compactMap { $0.selfconstraintWithIdentifier(identifier) }
            subviews = subviews.flatMap { $0.subviews }
        }
        return constraintsArray.first
    }
    
    
    /// used when popup view appers
    func fadeIn(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        self.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }
    
    
    /// used when popup view disappears
    func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        self.alpha = 1.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.isHidden = true
            self.alpha = 0.0
        }, completion: completion)
    }
    
    
    ///function for converting subview's frame
    func getConvertedFrame(fromSubview subview: UIView) -> CGRect? {
        // check if `subview` is a subview of self
        guard subview.isDescendant(of: self) else {
            return nil
        }
        
        var frame = subview.frame
        if subview.superview == nil {
            return frame
        }
        
        var superview = subview.superview
        while superview != self {
            frame = superview!.convert(frame, to: superview!.superview)
            if superview!.superview == nil {
                break
            } else {
                superview = superview!.superview
            }
        }
        
        return superview!.convert(frame, to: self)
    }
    
    
    /// shadow for UIView
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
    }
    
    
    /// shadow for UIView
    func rounded() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    
    @IBInspectable var cornerRadius: CGFloat {
        
        get{
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    func dropShadowed(cornerRadius:CGFloat, corners: UIRectCorner, borderColor: UIColor, borderWidth:CGFloat, shadowColor:UIColor) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        layer.mask?.shadowPath = path.cgPath
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 8
        layer.cornerRadius = cornerRadius
        
        if corners.contains(.topLeft) || corners.contains(.topRight) {
            layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        }
        if corners.contains(.bottomLeft) || corners.contains(.bottomRight) {
            layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
        }
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.shadowPath =  nil//path.cgPath
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    var globalFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController?.view
        return self.superview?.convert(self.frame, to: rootView)
    }
    
    /// provide parent view controller of given view return first view controller from views
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}

func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
    let shapeLayer = CAShapeLayer()
    shapeLayer.strokeColor = UIColor.lightGray.cgColor
    shapeLayer.lineWidth = 2
    shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.
    let path = CGMutablePath()
    path.addLines(between: [p0, p1])
    shapeLayer.path = path
    view.layer.addSublayer(shapeLayer)
}


///for UITextField with dashed border style
class RectangularDashedView: UITextField {
    
    @IBInspectable var cornerRadiuss: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0
    
    var dashBorder: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
}


///for UIView with dashed border style
/*class DashedView: UIView {
    
    @IBInspectable var cornerRadiuss: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0
    
    var dashBorder: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
}

///for UIView with dashed border style
class DashedVerticalView: UIView {
    
    @IBInspectable var cornerRadiuss: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 1
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 4
    @IBInspectable var betweenDashesSpace: CGFloat = 4
    
    var dashBorder: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addDashedBorder(dashColor: .themeColor, lineWidth: 1.0)

    }
}*/

extension UIView {

    func addDashedBorder(dashColor: UIColor, lineWidth: CGFloat) {
        let shapeLayer = CAShapeLayer()
           shapeLayer.strokeColor = dashColor.cgColor
           shapeLayer.lineWidth = lineWidth
           shapeLayer.lineDashPattern = [8,5]
//           if shape == .round {
               shapeLayer.lineCap = .round
//           }
           let path = CGMutablePath()
//           if orientation == .vertical {
               path.addLines(between: [CGPoint(x: lineWidth/2, y: lineWidth/2),
                                       CGPoint(x: lineWidth/2, y: self.frame.height)])
//           }
           shapeLayer.path = path
           layer.addSublayer(shapeLayer)
    }

}

//MARK: - UIApplication setup
extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow?{
        return windows.first(where: {$0.isKeyWindow})
    }
}


//MARK: - UIViewController setup
extension UIViewController {
    
    ///  set up transparent navigation bar with custom back button and feedack button
    func navigationBarWithRightButtonTransparent(isShowBackButton: Bool, isShowHomeButton : Bool) {
        
        // set up navigation bar
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.isHidden = false
        
        // set up back button
        if isShowBackButton {
            let backButton = UIButton()
            backButton.setImage(UIImage(named: "backArrow")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
            backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }

        
        // if true then this will show back button with feedback button
        else if isShowHomeButton {
            let homeButton = UIButton()
            homeButton.setImage(UIImage(named: "home")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
            homeButton.addTarget(self, action: #selector(homeButtonAction), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: homeButton)
        }
    }
    
    
    ///  set up navigation swipe direction while changing languages
    func setSwipeDirection() {
        
        // right to left for arabic
        if getLangCode() == arabic {
            navigationController?.view.semanticContentAttribute = .forceRightToLeft
            navigationController?.navigationBar.semanticContentAttribute =  .forceRightToLeft
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            navigationController?.view.semanticContentAttribute = .forceLeftToRight
            navigationController?.navigationBar.semanticContentAttribute =  .forceLeftToRight
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
    
    /// Click event for back button
    @objc func backButtonAction() {
        if let stack = self.navigationController?.viewControllers , stack.count > 1{
            self.navigationController?.popViewController(animated: true)
        } else {
        
        }
    }
    
    ///Click event for home button
    @objc func homeButtonAction() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    
    //No Internet connection alert
    func openSettingAlert(){
        let alertController = UIAlertController (title: "INTERNET_CONNECTION_LOST".localized, message: "PLEASE_CHECK_YOUR_INTERNET_CONNECTION".localized, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "SETTINGS".localized, style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    application.openURL(phoneCallURL as URL)
                }
            }
            else {
                print("Calling functinality not support your device..")
                let alert = UIAlertController(title: "", message: "Calling functinality not support your device..", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            print("Calling functinality not support your device..")
            let alert = UIAlertController(title: "", message: "Calling functinality not support your device..", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlert(title: String? = nil, msg: String? = nil, alertOkTitle: String? = nil, okHandlor:@escaping()->Void, cancelTitle: String? = nil, showCancelButton: Bool = false) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertOkTitle, style: .default, handler: { alt in
            okHandlor()
        }))
        if showCancelButton {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { alt in }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @available(iOS 13.0, *)
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}


//MARK: - A path that consists of straight and curved line segments that you can render in your custom views.
extension UIBezierPath {
    convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGSize = .zero, topRightRadius: CGSize = .zero, bottomLeftRadius: CGSize = .zero, bottomRightRadius: CGSize = .zero){
        
        self.init()
        
        let path = CGMutablePath()
        
        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        if topLeftRadius != .zero{
            path.move(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }
        
        if topRightRadius != .zero{
            path.addLine(to: CGPoint(x: topRight.x-topRightRadius.width, y: topRight.y))
            path.addCurve(to:  CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height), control1: CGPoint(x: topRight.x, y: topRight.y), control2:CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height))
        } else {
            path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
        }
        
        if bottomRightRadius != .zero{
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y-bottomRightRadius.height))
            path.addCurve(to: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y), control1: CGPoint(x: bottomRight.x, y: bottomRight.y), control2: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y))
        } else {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
        }
        
        if bottomLeftRadius != .zero{
            path.addLine(to: CGPoint(x: bottomLeft.x+bottomLeftRadius.width, y: bottomLeft.y))
            path.addCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height), control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y), control2: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height))
        } else {
            path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
        }
        
        if topLeftRadius != .zero{
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y+topLeftRadius.height))
            path.addCurve(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y) , control1: CGPoint(x: topLeft.x, y: topLeft.y) , control2: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }
        
        path.closeSubpath()
        cgPath = path
    }
}


extension Array where Element: Equatable {
    
    @discardableResult mutating func remove(object: Element) -> Bool {
        if let index = firstIndex(of: object) {
            self.remove(at: index)
            return true
        }
        return false
    }
    
    @discardableResult mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
        if let index = self.index(where: { (element) -> Bool in
            return predicate(element)
        }) {
            self.remove(at: index)
            return true
        }
        return false
    }
}

/// Class with defult reload data option
///  `reloadDataHandler` this data handler we used
///  please use `reloadData` anywhere in the function
class RefreshView : UIView {
    var reloadData : reloadDataHandler?
}


class ProductDetailsView : UIView {
    var reqestKey : String?
}

class ShapeImageView: UIImageView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override var image : UIImage?{
        set {
             updateHeight(newvalue: newValue!)
            super.image  =
            imageCutInOtherImageShape(image: newValue!, cutMask: UIImage(named: "shapeImage")!, imgVW: self,height: updateHeight(newvalue: newValue!))
        }
        get {
            self.contentMode = .scaleToFill
            if (super.image != nil){
                
                return imageCutInOtherImageShape(image: super.image!, cutMask: UIImage(named: "shapeImage")!, imgVW: self,height: updateHeight(newvalue: super.image!))
            }
            return super.image
            //            return super.image!
        }
    }
}

func imageCutInOtherImageShape(image:UIImage,cutMask:UIImage, imgVW: UIImageView) -> UIImage {
    let size = imgVW.frame.size
    let rect =  CGRect(origin: CGPoint(x:0,y:0), size: size)
    UIGraphicsBeginImageContext(size)
    image.draw(in: rect)
    cutMask.draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage ?? UIImage()
}

func imageCutInOtherImageShape(image:UIImage,cutMask:UIImage, imgVW: UIImageView , height : CGFloat) -> UIImage {
    var size = imgVW.frame.size
    size.height = height
    let rect =  CGRect(origin: CGPoint(x:0,y:0), size: size)
    UIGraphicsBeginImageContext(size)
    image.draw(in: rect)
    cutMask.draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage ?? UIImage()
}


/// Bottom RoundView for bottom top 2 coronor round and shadow on View
class BottomRoundView : UIView {
    
    override func awakeFromNib() {
        self.cornerRadius = 15
        [self].forEach {(view) in
            view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            view.dropShadow(color: UIColor.gray, opacity: 1, offSet: CGSize(width: 0, height: 2), radius: 5)
        }
    }
}


//MARK: - Dictionary setup
extension Dictionary {
    
    /// convert dictionary to json string
    ///
    /// - Returns: return value description
    func convertToJSonString() -> String {
        do {
            let dataJSon = try JSONSerialization.data(withJSONObject: self as AnyObject, options: JSONSerialization.WritingOptions.prettyPrinted)
            let st: NSString = NSString.init(data: dataJSon, encoding: String.Encoding.utf8.rawValue)!
            return st as String
        } catch let error as NSError { print(error) }
        return ""
    }
    
    
    /// check given key have value or not
    ///
    /// - Parameter stKey: pass key what you want check
    /// - Returns: true if exist
    func isKeyNull(_ stKey: String) -> Bool {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] { return val is NSNull ? true : false }
        return true
    }
    
    
    
    /// handal carsh when null valu or key not found
    ///
    /// - Parameter stKey: pass the key of object
    /// - Returns: blank string or value if exist
    func valueForKeyString(_ stKey: String) -> String {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return ""
            }else if (val as? NSNumber) != nil {
                return  val.stringValue
                
            }else if (val as? String) != nil {
                return val as! String
            }else{
                return ""
            }
        }
        return ""
    }
    
    ///expaned function of null value
    func valueForKeyString(_ stKey: String,nullvalue:String) -> String {
        return  self.valueForKeyWithNullString(Key: stKey, NullReplaceValue: nullvalue)
    }
    
    /// Update dic with other Dictionary
    ///
    /// - Parameter other: add second Dictionary which one you want to add
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
    
    /// USE TO GET VALUE FOR KEY if key not found or null then replace with the string
    ///
    /// - Parameters:
    ///   - stKey: pass key of dic
    ///   - NullReplaceValue: set value what you want retun if that key is nill
    /// - Returns: retun key value if exist or return null replace value
    func valueForKeyWithNullString(Key stKey: String,NullReplaceValue:String) -> String {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return NullReplaceValue
            } else{
                if (val as? NSNumber) != nil {
                    return  val.stringValue
                }else{
                    return val as! String == "" ? NullReplaceValue : val as! String
                }
            }
        }
        return NullReplaceValue
    }
    
    func valuForKeyWithNullWithPlaseString(Key stKey: String,NullReplaceValue:String) -> String {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return NullReplaceValue
            } else{
                if (val as? NSNumber) != nil {
                    if Int(truncating: val as! NSNumber) > 0{
                        return  "+" + val.stringValue
                    }
                }else{
                    if Int(val as! String) ?? 0 > 0{
                        return val as! String == "" ? NullReplaceValue : "+" + (val as! String)
                    }else{
                        return val as! String == "" ? NullReplaceValue : val as! String
                    }
                }
            }
        }
        return NullReplaceValue
    }
    
    func valuForKeyArray(_ stKey: String) -> Array<Any> {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return []
            } else if val is NSArray{
                return val as! Array<Any>
            } else if val is String{
                return [val] as Array<Any>
            }else {
                return val as! Array<Any>
            }
        }
        return []
    }
    
    /// dic
    /// - Parameter stKey: <#stKey description#>
    func valuForKeyDic(_ stKey: String) -> JSONDictionary {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return JSONDictionary()
            } else if ((val as? JSONDictionary) != nil){
                return val as! JSONDictionary
            }
        }
        return JSONDictionary()
    }
    
    
    
    /// This is function for convert dicticonery to xml string also check log for other type of string i only handal 2 or 3 type of stct
    ///
    /// - Returns: return xml string
    func createXML()-> String{
        
        var xml = ""
        for k in self.keys {
            
            if let str = self[k] as? String{
                xml.append("<\(k as! String)>")
                xml.append(str)
                xml.append("</\(k as! String)>")
                
            }else if let dic =  self[k] as? Dictionary{
                xml.append("<\(k as! String)>")
                xml.append(dic.createXML())
                xml.append("</\(k as! String)>")
                
            }else if let array : NSArray =  self[k] as? NSArray{
                for i in 0..<array.count {
                    xml.append("<\(k as! String)>")
                    if let dic =  array[i] as? Dictionary{
                        xml.append(dic.createXML())
                    }else if let str = array[i]  as? String{
                        xml.append(str)
                    }else{
                        fatalError("[XML]  associated with \(self[k] as Any) not any type!")
                    }
                    xml.append("</\(k as! String)>")
                    
                }
            }else if let dic =  self[k] as? NSDictionary{
                xml.append("<\(k as! String)>")
                
                let newdic = dic as! Dictionary<String,Any>
                xml.append(newdic.createXML())
                xml.append("</\(k as! String)>")
                
            }
            else{
                fatalError("[XML]  associated with \(self[k] as Any) not any type!")
            }
        }
        
        return xml
    }
    
    func valueForKeyInt( _ any:String) -> Int {
        return valueForKeyInt(any,nullValue: 0)
    }
    func valueForKeyInt( _ any:String,nullValue :Int) -> Int {
        var iValue: Int = 0
        let dict: JSONDictionary = self as! JSONDictionary
        if let val = dict[any] {
            if val is NSNull {
                return 0
            }
            else {
                if val is Int {
                    iValue = val as! Int
                }
                else if val is Double {
                    iValue = Int(val as! Double)
                }
                else if val is String {
                    let stValue: String = val as! String
                    iValue = (stValue as NSString).integerValue
                }
                else if val is Float {
                    iValue = Int(val as! Float)
                }else{
                    let error = NSError(domain:any,
                                        code: 100,
                                        userInfo:dict)
                }
            }
        }
        return iValue
    }
}


//MARK: - UICollectionView setup
extension UICollectionView{
    
    func setDataSourceDelegate (datasourceAndDelegate : NSObject , collectionCell: String? = ""){
        datasourceAndDelegate.CollectionView = self
        if let datasource = datasourceAndDelegate as? UICollectionViewDataSource{
            self.dataSource = datasource
        }
        
        if let delegate = datasourceAndDelegate as? UICollectionViewDelegate{
            self.delegate = delegate
        }
        
        if collectionCell != "" {
            self.register(UINib(nibName: collectionCell!, bundle: nil), forCellWithReuseIdentifier: collectionCell!)
        }
    }
    
    func getDataSourceandDeleget() -> NSObject{
        return self.dataSource as! NSObject
    }
}


//MARK: - UITableView setup
extension UITableView{
    
    func setDataSourceDelegate (datasourceAndDelegate : NSObject , tableCell: String? = ""){
        datasourceAndDelegate.TableView = self
        if let datasource = datasourceAndDelegate as? UITableViewDataSource{
            self.dataSource = datasource
        }
        
        if let delegate = datasourceAndDelegate as? UITableViewDelegate{
            self.delegate = delegate
        }
        
        if tableCell != "" {
            self.register(UINib(nibName: tableCell!, bundle: nil), forCellReuseIdentifier: tableCell!)
        }
    }
    
    func getDataSourceandDeleget() -> NSObject{
        return self.dataSource as! NSObject
    }
}

class ScaledHeightImageView: UIImageView {
    
    override var intrinsicContentSize: CGSize {
        
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
            
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
            
            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        
        return CGSize(width: -1.0, height: -1.0)
    }
    
}


//MARK: - UIImageView setup
extension UIImageView{
    
    open func updateHeight(){
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
            
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
            self.selfconstraintWithIdentifier("ImageHeight")?.constant = scaledHeight-1
        }
    }
    open func updateHeight(newvalue : UIImage)-> CGFloat{
        
        let myImageWidth = newvalue.size.width
        let myImageHeight = newvalue.size.height
        let myViewWidth = self.frame.size.width
        
        let ratio = myViewWidth/myImageWidth
        let scaledHeight = myImageHeight * ratio
        self.selfconstraintWithIdentifier("ImageHeight")?.constant = scaledHeight-1
        return scaledHeight-1
    }
    
    func getImage(url: String) {
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        if url != "" {
            self.sd_setImage(with: URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage:UIImage(named: "app-logo"), options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
            
                if error == nil {
                    self.image = image
                    self.updateHeight()
//                    self.backgroundColor = image?.averageColor
//                    print("success")
                }else {
                   print("false")
                }
            })
        }
    }
    
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

func timeInterval(timeAgo:String ,dateFormate:String? = "yyyy-MM-dd'T'HH:mm:ss") -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int ) {
    let df = DateFormatter()
    
    df.dateFormat = dateFormate
    var dateWithTime = df.date(from: timeAgo) ?? Date()
    let hoursAdd = TimeInterval(5.hours)
    let minutesAdd = TimeInterval(30.minutes)
    dateWithTime.addTimeInterval(hoursAdd)
    dateWithTime.addTimeInterval(minutesAdd)
    
    let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to:dateWithTime )
    
    var years = 0
    var months = 0
    var days = 0
    var hours = 0
    var minutes = 0
    var seconds = 0
    
    if let year = interval.year, year > 0 {
        years = year == 1 ? year : year
    }
    if let month = interval.month, month > 0 {
        months = month == 1 ? month : month
    }
    if let day = interval.day, day > 0 {
        days = day == 1 ? day : day
    }
    if let hour = interval.hour, hour > 0 {
        hours = hour == 1 ? hour : hour
    }
    if let minute = interval.minute, minute > 0 {
        minutes = minute == 1 ? minute : minute
    }
    if let second = interval.second, second > 0 {
        seconds = second == 1 ? second : second
    }
    return (year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
}

func checkTimeAgo(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> String {
    
    //    if (second != 0) && (minute == 0 && hour == 0 && day == 0 && month == 0 && year == 0) {
    //        return "\(second) " + "seconds ago"
    //    }
    if (second != 0) && (minute == 0 && hour == 0 && day == 0 && month == 0 && year == 0) {
        return "right now".localized
    }
    else if ((second != 0 && minute != 0) && (hour == 0 && day == 0 && month == 0 && year == 0)) {
        return "\(minute) "+"M".localized
        //        +", \(second) "+"seconds ago"
    }
    else if ((hour != 0) && (day == 0 && month == 0 && year == 0)) {
        return "\(hour)"+"H".localized + " : \(minute)"+"M".localized + " : \(second)"+"S".localized
    }
    else if ((day != 0) && (month == 0 && year == 0)) {
        return "\(day) "+"D".localized + " : \(hour) "+"H".localized + " : \(minute)"+"M".localized + ", \(second)"+"S".localized
    }
    else if ((month != 0) && (year == 0)) {
        return "\(month) "+"Month".localized + " : \(day) "+"D".localized
    }
    else if ((year != 0)) {
        return "\(year) "+"Year".localized + " : \(month) "+"M".localized
    }
    return "right now".localized
}
//ADD Date specific value
extension Int {
    
    var seconds: Int {
        return self
    }
    
    var minutes: Int {
        return self.seconds * 60
    }
    
    var hours: Int {
        return self.minutes * 60
    }
    
    var days: Int {
        return self.hours * 24
    }
    
    var weeks: Int {
        return self.days * 7
    }
    
    var months: Int {
        return self.weeks * 4
    }
    
    var years: Int {
        return self.months * 12
    }
}


/// Typealias for UIBarButtonItem closure.
typealias UIBarButtonItemTargetClosure = (UIBarButtonItem) -> ()

class UIBarButtonItemClosureWrapper: NSObject {
    let closure: UIBarButtonItemTargetClosure
    init(_ closure: @escaping UIBarButtonItemTargetClosure) {
        self.closure = closure
    }
}

extension UIBarButtonItem {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIBarButtonItemTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIBarButtonItemClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIBarButtonItemClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    convenience init(title: String?, style: UIBarButtonItem.Style, closure: @escaping UIBarButtonItemTargetClosure) {
        self.init(title: title, style: style, target: nil, action: nil)
        targetClosure = closure
        action = #selector(UIBarButtonItem.closureAction)
    }
    
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
}


extension UIControl {
    
    func block_setAction(block: @escaping BlockButtonActionBlock) {
        objc_setAssociatedObject(self, &ActionBlockKey, ActionBlockWrapper(block: block), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(block_handleAction), for: .touchUpInside)
    }
    
    @objc func block_handleAction() {
        let wrapper = objc_getAssociatedObject(self, &ActionBlockKey) as! ActionBlockWrapper
        wrapper.block(self)
    }
}

var ActionBlockKey: UInt8 = 0

// a type for our action block closure
typealias BlockButtonActionBlock = (_ sender: UIControl) -> Void

class ActionBlockWrapper : NSObject {
    var block : BlockButtonActionBlock
    init(block: @escaping BlockButtonActionBlock) {
        self.block = block
    }
}


extension UIStackView {
    
    /// Remove all added subview from stackview
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        for v in removedSubviews {
            if v.superview != nil {
                NSLayoutConstraint.deactivate(v.constraints)
                v.removeFromSuperview()
            }
        }
    }
}

func removeNilValues<K,V>(dict:Dictionary<K,V?>) -> Dictionary<K,V> {
    
    return dict.reduce(into: Dictionary<K,V>()) { (currentResult, currentKV) in
        
        if let val = currentKV.value {
            if ((val as? NSNull) != nil){
                
            }else{
                currentResult.updateValue(val, forKey: currentKV.key)
            }
            
        }
    }
}

extension Dictionary {

    func nullKeyRemoval() -> [AnyHashable: Any] {
        var dict: [AnyHashable: Any] = self
        
        let keysToRemove = dict.keys.filter { dict[$0] is NSNull }
        let keysToCheck = dict.keys.filter({ dict[$0] is Dictionary })
        let keysToArrayCheck = dict.keys.filter({ dict[$0] is [Any] })
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }
        for key in keysToCheck {
            if let valueDict = dict[key] as? [AnyHashable: Any] {
                dict.updateValue(valueDict.nullKeyRemoval(), forKey: key)
            }
        }
        for key in keysToArrayCheck {
            if var arrayDict = dict[key] as? [Any] {
                for i in  0..<arrayDict.count {
                    if let dictObj = arrayDict[i] as? JSONDictionary {
                        arrayDict[i] = dictObj.nullKeyRemoval()
                    }
                }
                dict.updateValue(arrayDict, forKey: key)
            }
        }
        return dict
    }
}

extension UIImage {
    
    func fixOrientation() -> UIImage {
        if (imageOrientation == .up) { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func scale(to newSize: CGSize) -> UIImage? {
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

/**
 - This is for setup Constraint equeal to the super view constraint
 - Parameter view:
 /// ads
 */
func setequalSuperView(_ view:UIView){
    view.translatesAutoresizingMaskIntoConstraints = false
    let attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .right, .left]
    if (view.superview != nil) {
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(item: view, attribute: $0, relatedBy: .equal, toItem: view.superview, attribute: $0, multiplier: 1, constant: 0)
        })
    }
}


/*class DashedLineView : UIView {
    var perDashLength: CGFloat = 5.0
    var spaceBetweenDash: CGFloat = 5.0
    var dashColor: UIColor = UIColor.placeHolderColor
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let  path = UIBezierPath()
        if height > width {
            let  p0 = CGPoint(x: self.bounds.midX, y: self.bounds.minY)
            path.move(to: p0)
            
            let  p1 = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
            path.addLine(to: p1)
            path.lineWidth = width
            
        } else {
            let  p0 = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
            path.move(to: p0)
            
            let  p1 = CGPoint(x: self.bounds.maxX, y: self.bounds.midY)
            path.addLine(to: p1)
            path.lineWidth = height
        }
        
        let  dashes: [ CGFloat ] = [ perDashLength, spaceBetweenDash ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)
        
        path.lineCapStyle = .butt
        dashColor.set()
        path.stroke()
    }
    
    private var width : CGFloat {
        return self.bounds.width
    }
    
    private var height : CGFloat {
        return self.bounds.height
    }
}*/


extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}


extension NSObject {
    
    var CollectionView: UICollectionView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? UICollectionView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var TableView: UITableView? {
        get {
            return objc_getAssociatedObject(self, &TableObejctHandel) as? UITableView
        }
        set {
            objc_setAssociatedObject(self, &TableObejctHandel, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension NSMutableAttributedString {
    
//    var fontSize : CGFloat { return 15 }
    var boldFont : UIFont { return themeFont(size: 14, fontname: .bold) }
    var normalFont:UIFont { return themeFont(size: 14, fontname: .regular)}
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes : [NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func blackHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
}


extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, targetText: String) -> Bool {
        guard let attributedString = label.attributedText, let lblText = label.text else { return false }
        let targetRange = (lblText as NSString).range(of: targetText)
        //IMPORTANT label correct font for NSTextStorage needed
        let mutableAttribString = NSMutableAttributedString(attributedString: attributedString)
        mutableAttribString.addAttributes(
            [NSAttributedString.Key.font: label.font ?? UIFont.smallSystemFontSize],
            range: NSRange(location: 0, length: attributedString.length)
        )
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: mutableAttribString)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y:
            locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

func hmsFrom(seconds: Int, completion: @escaping ( _ minutes: Int, _ seconds: Int)->()) {
    completion((seconds % 3600) / 60, (seconds % 3600) % 60)
}

func getStringFrom(seconds: Int) -> String {
    return seconds < 10 ? "0\(seconds)" : "\(seconds)"
}
