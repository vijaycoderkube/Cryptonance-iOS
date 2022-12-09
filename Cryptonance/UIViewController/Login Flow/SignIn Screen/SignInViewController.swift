//
//  SignInViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 27/10/22.
//

import UIKit
import SKCountryPicker
import CRNotifications

class SignInViewController: UIViewController {
    
    @IBOutlet weak var signUpLabel: UILabel?
    @IBOutlet weak var termsAndConditionLabel: UILabel?
    @IBOutlet weak var countryCodeLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    @IBOutlet weak var signInButton: UIButton?
    @IBOutlet weak var showPasswordButton: UIButton?
    @IBOutlet weak var countryCodeButton: UIButton?
    
    @IBOutlet weak var passwordTextfield: UITextField?
    @IBOutlet weak var phoneNumberTextField: UITextField?
    
    @IBOutlet weak var phoneNumberTextFieldLeftView: UIView?
    @IBOutlet weak var passwordTextfieldBackgroundView: UIView?
    @IBOutlet weak var phoneNumberTextfieldBackgroundView: UIView?
    @IBOutlet weak var passwordTextfieldRightView: UIView?
    
    let termsConditionText = "BY_CONTINUING_YOU_AGREE_TO_THE".localized + "CRYPTONANCE".localized + "TERMS_AND_CONDITIONS".localized + "AND".localized + "PRIVACY_POLICY".localized
    let dontHaveAcoountText = "DON’T_HAVE_AN_ACCOUNT".localized + "SIGN_UP".localized
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let country = CountryManager.shared.country(withDigitCode: "+91") {
            self.countryCodeLabel?.text = country.dialingCode
            manager.lastCountrySelected = country
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}


extension SignInViewController{
    func setUpUI() {
        navigationBarWithRightButtonTransparent(isShowBackButton: true, isShowHomeButton: false)
        
        descriptionLabel?.text = "Lorem ipsum dolor sit amet, consectetur\nadipiscing elit. Enim hendrerit aliquam odio eu."
        
        [phoneNumberTextfieldBackgroundView, passwordTextfieldBackgroundView].forEach { (view) in
            view?.layer.borderColor = UIColor.textFieldBorderColor.cgColor
            view?.layer.borderWidth = 1
        }
        
        phoneNumberTextField?.setRightPaddingPoints(14)
        
        passwordTextfield?.setLeftPaddingPoints(14)
        passwordTextfield?.rightViewMode = .always
        passwordTextfield?.rightView = passwordTextfieldRightView
        
        let underlineAttributedString = NSMutableAttributedString(string: termsConditionText)
        underlineAttributedString.setColorForText("CRYPTONANCE".localized, with: .themeWhite)
        
        let termsText = (termsConditionText as NSString).range(of: "TERMS_AND_CONDITIONS".localized)
        let privacyText = (termsConditionText as NSString).range(of: "PRIVACY_POLICY".localized)
        
        underlineAttributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: termsText)
        underlineAttributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: privacyText)
        
        underlineAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.themeWhite, range: termsText)
        underlineAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.themeWhite, range: privacyText)
        
        termsAndConditionLabel?.attributedText = underlineAttributedString
        termsAndConditionLabel?.isUserInteractionEnabled = true
        termsAndConditionLabel?.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapTermsAndConditionsLabel(gesture:))))
        
        
        let signUpTextUnderlineAttributedString = NSMutableAttributedString(string: dontHaveAcoountText)
        
        let signInText = (dontHaveAcoountText as NSString).range(of: "SIGN_UP".localized)
        
        signUpTextUnderlineAttributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: signInText)
        
        signUpTextUnderlineAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.themeWhite, range: signInText)
        
        signUpLabel?.attributedText = signUpTextUnderlineAttributedString
        signUpLabel?.isUserInteractionEnabled = true
        signUpLabel?.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapSignUpLabel(gesture:))))
    }
}

extension SignInViewController{
    @IBAction func countryCodeButtonAction(_ sender: Any) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            
            guard let self = self else { return }
            self.countryCodeLabel?.text = country.dialingCode
        }
    }
    
    @IBAction func showPasswordButtonAction(_ sender: UIButton) {
        if showPassword == false{
            showPassword = true
            if #available(iOS 13.0, *) {
                sender.isSelected = true
            } else {
                // Fallback on earlier versions
            }
            passwordTextfield?.isSecureTextEntry = false
        }
        else {
            showPassword = false
            if #available(iOS 13.0, *) {
                sender.isSelected = false
            } else {
                // Fallback on earlier versions
            }
            passwordTextfield?.isSecureTextEntry = true
        }
    }
    
    @IBAction func signInButtonAction(_ sender: Any) {
        if phoneNumberTextField?.text?.trimmingLeadingAndTrailingSpaces() == "" {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "ENTER_PHONE_NO".localized)
            
        } else if phoneNumberTextField?.text?.count ?? 0 < 10 {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "PHONE_NO_SHOULD_BE_10_DIGIT_LONG".localized)
            
        } else {
            let viewController = WelcomeViewController.init(nibName: "WelcomeViewController", bundle: nil)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func tapTermsAndConditionsLabel(gesture: UITapGestureRecognizer) {
        
//        let termsRange = (text as NSString).range(of: "TERMS_AND_CONDITIONS".localized)
//        let privacyRange = (text as NSString).range(of: "PRIVACY_POLICY".localized)
        
        if gesture.didTapAttributedTextInLabel(label: termsAndConditionLabel!, targetText: "TERMS_AND_CONDITIONS".localized) {
            print("Terms of service")
        } else if gesture.didTapAttributedTextInLabel(label: termsAndConditionLabel!, targetText: "PRIVACY_POLICY".localized) {
            print("Privacy policy")
        } else {
            print("Tapped none")
        }
    }
    
    @IBAction func tapSignUpLabel(gesture: UITapGestureRecognizer) {
//        let signUpText = (text as NSString).range(of: "SIGN_UP".localized)
        
        if gesture.didTapAttributedTextInLabel(label: signUpLabel!, targetText: "SIGN_UP".localized) {
            let viewController = SignUpViewController.init(nibName: "SignUpViewController", bundle: nil)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            print("Tapped none")
        }
    }
}

