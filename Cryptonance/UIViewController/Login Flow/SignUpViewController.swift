//
//  SignUpViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 27/10/22.
//

import UIKit
import SKCountryPicker
import CRNotifications
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signInLabel: UILabel?
    @IBOutlet weak var termsAndConditionLabel: FRHyperLabel?
    @IBOutlet weak var countryCodeLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    @IBOutlet weak var continueButton: UIButton?
    @IBOutlet weak var showPasswordButton: UIButton?
    @IBOutlet weak var countryCodeButton: UIButton?
    
    @IBOutlet weak var passwordTextfield: UITextField?
    @IBOutlet weak var phoneNumberTextField: UITextField?
    
    @IBOutlet weak var phoneNumberTextFieldLeftView: UIView?
    @IBOutlet weak var passwordTextfieldBackgroundView: UIView?
    @IBOutlet weak var phoneNumberTextfieldBackgroundView: UIView?
    @IBOutlet weak var passwordTextfieldRightView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let country = CountryManager.shared.country(withDigitCode: "+91") {
            self.countryCodeLabel?.text = country.dialingCode
            manager.lastCountrySelected = country
        }
    }
    // Do any additional setup after loading the view
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
        termsAndPrivacyPolicySetUp()
    }
}

extension SignUpViewController{
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
                
        let alreadyAcoountText = "ALREADY_HAVE_AN_ACCOUNT".localized + "SIGN_IN".localized
        let signInTextUnderlineAttributedString = NSMutableAttributedString(string: alreadyAcoountText)
        
        let signInText = (alreadyAcoountText as NSString).range(of: "SIGN_IN".localized)
        
        signInTextUnderlineAttributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: signInText)
        
        signInTextUnderlineAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.themeWhite, range: signInText)
        
        signInLabel?.attributedText = signInTextUnderlineAttributedString
        signInLabel?.isUserInteractionEnabled = true
//        signInLabel?.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapSignInLabel(gesture:))))
    }
    
    func termsAndPrivacyPolicySetUp() {
        let string = "BY_CONTINUING_YOU_AGREE_TO_THE".localized + "CRYPTONANCE".localized + "TERMS_AND_CONDITIONS".localized + "AND".localized + "PRIVACY_POLICY".localized
        
//        let termsAttributedString = NSAttributedString(string: string)
//        let cryptonanceText = (string as NSString).range(of: "CRYPTONANCE".localized)
//        termsAttributedString. (NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: cryptonanceText)
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.textFieldBorderColor,
                          NSAttributedString.Key.font: themeFont(size: 14, fontname: .regular)]
    
        termsAndConditionLabel?.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        let handler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            if substring == "TERMS_AND_CONDITIONS".localized {
                
                if Connectivity.isConnectedToInternet {
                    databseReference.child("cryptonance").child("terms_and_condition").getData(completion:  { error, snapshot in
                        guard error == nil else
                        {
                            print(error!.localizedDescription)
                            return;
                        }
                        if let object = snapshot?.value as? String, object != ""{
                            let appURL = URL(string: object)!
                            if UIApplication.shared.canOpenURL(appURL) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(appURL)
                                }
                            }
                        }
                    })
                } else {
                    self.openSettingAlert()
                }

            } else if substring == "PRIVACY_POLICY".localized {
                if Connectivity.isConnectedToInternet {
                    databseReference.child("cryptonance").child("privacy_policy").getData(completion:  { error, snapshot in
                        guard error == nil else
                        {
                            print(error!.localizedDescription)
                            return;
                        }
                        if let object = snapshot?.value as? String, object != ""{
                            let appURL = URL(string: object)!
                            if UIApplication.shared.canOpenURL(appURL) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(appURL)
                                }
                            }
                        }
                    })
                } else {
                    self.openSettingAlert()
                }
            }
        }
        
        termsAndConditionLabel?.setLinksForSubstrings(["TERMS_AND_CONDITIONS".localized, "PRIVACY_POLICY".localized], withLinkHandler: handler)
    }
}

extension SignUpViewController{
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
    
    @IBAction func continueButtonAction(_ sender: Any) {
        
        if phoneNumberTextField?.text?.trimmingLeadingAndTrailingSpaces() == "" {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "ENTER_PHONE_NO".localized)
            
        } else if phoneNumberTextField?.text?.count ?? 0 < 10 {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "PHONE_NO_SHOULD_BE_10_DIGIT_LONG".localized)
            
        } else {
            
            /*if phoneNumberTextField?.text == "9876543210" || phoneNumberTextField?.text == "1111111111" {
                Auth.auth().settings?.isAppVerificationDisabledForTesting = false
            } else {
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
            }*/
            
            if Connectivity.isConnectedToInternet {
                
                PhoneAuthProvider.provider()
                    .verifyPhoneNumber((countryCodeLabel?.text ?? "") + (phoneNumberTextField?.text ?? ""), uiDelegate: nil) { verificationID, error in
                        if let error = error {
                            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: error.localizedDescription)
                            return
                        } else {
                            // Sign in using the verificationID and the code sent to  the user
                            // ...
                            userDataObject["phoneNumber"]      = self.phoneNumberTextField?.text as AnyObject
                            userDataObject["authVerificationID"] = verificationID as AnyObject?
                            Config().saveUserData(Object: userDataObject)
                            
                            if #available(iOS 13.0, *) {
                                self.appDelegate().firebaseValueRemoved()
                                self.appDelegate().firebaseValueChanged()
                            } else {
                                // Fallback on earlier versions
                            }
                            
                            let viewController = CodeVerificationViewController.init(nibName: "CodeVerificationViewController", bundle: nil)
                            viewController.dialCode = self.countryCodeLabel?.text ?? ""
                            viewController.phoneNumber = self.phoneNumberTextField?.text ?? ""
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }
                    }
            } else {
                openSettingAlert()
            }
        }
    }
    
   /* @IBAction func tapSignInLabel(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: signInLabel!, targetText: "SIGN_IN".localized) {
            let viewController = SignInViewController.init(nibName: "SignInViewController", bundle: nil)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            print("Tapped none")
        }
    }*/
}
