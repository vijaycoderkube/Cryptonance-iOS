//
//  CodeVerificationViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 27/10/22.
//

import UIKit
import CRNotifications
import Firebase
import FirebaseDatabase

class CodeVerificationViewController: UIViewController {
    
    @IBOutlet weak var resendOtpButton: UIButton!
    @IBOutlet weak var resendOtpLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    @IBOutlet weak var continueButton: UIButton?
    
    @IBOutlet weak var otpView: OTPFieldView?

    var phoneNumber : String = ""
    var dialCode : String = ""
    var otpValue : String = ""
    var timerCount : Int = 60
    var resendTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // time interval for resnd OTP timer
        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
        setupOtpView()
    }
}

extension CodeVerificationViewController{
    func setUpUI() {
        navigationBarWithRightButtonTransparent(isShowBackButton: true, isShowHomeButton: false)
        
        descriptionLabel?.text = ("PLEASE_ENTER_THE_6_DIGIT_VERIFICATION_CODE_SENT_TO".localized) + " " + (dialCode) + " " + (phoneNumber) + ". " + ("THE_CODE_IS_VALID_FOR_30MINS".localized)
    }
    
    @objc func updateTimer(){
        if(timerCount > 0) {
            timerCount = timerCount - 1
            
            hmsFrom(seconds: timerCount) { minutes, seconds in
                let minutes = getStringFrom(seconds: minutes)
                let seconds = getStringFrom(seconds: seconds)
                
                let string = "\(minutes):\(seconds)"
                let attributes = [NSAttributedString.Key.foregroundColor: UIColor.textFieldBorderColor,
                                  NSAttributedString.Key.font: themeFont(size: 14, fontname: .regular)]
                self.resendOtpLabel?.attributedText = NSAttributedString(string: string, attributes: attributes)
                self.resendOtpLabel?.textAlignment = .center
            }
        } else {
            let resentOtpText = "DIDN’T_RECEIVE_IT".localized + "RESEND".localized
            let underlineAttributedString = NSMutableAttributedString(string: resentOtpText)
            
            let resendText = (resentOtpText as NSString).range(of: "RESEND".localized)
            
            underlineAttributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: resendText)
            
            underlineAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.themeWhite, range: resendText)
            
            resendOtpLabel?.attributedText = underlineAttributedString
            self.resendOtpLabel?.textAlignment = .left
        }
    }
    
    /// This function will use for the setup ui for otpfieldview when view contoller will load
    func setupOtpView(){
        
        self.otpView?.fieldsCount = 6
        self.otpView?.displayType = .roundedCorner
        self.otpView?.cursorColor = .themeYellow
        self.otpView?.fieldSize = 52
        self.otpView?.defaultBorderColor = .textFieldBorderColor
        self.otpView?.fieldBorderWidth = 1
        self.otpView?.filledBorderColor = .themeYellow
        self.otpView?.separatorSpace = 8
        self.otpView?.defaultBackgroundColor = .clear
        self.otpView?.filledBackgroundColor = .clear
        self.otpView?.shouldAllowIntermediateEditing = true
        self.otpView?.fieldFont = themeFont(size: 16, fontname: .semiBold)
        self.otpView?.delegate = self
        self.otpView?.initializeUI()
    }
    
    func moveToNextController(){
        if (Config().userData()["identityVerified"] == true) && ((Config().userData()["wantToSell"] == true) || (Config().userData()["wantToBuy"] == true)) {
            let viewController = DashboardViewController.init(nibName: "DashboardViewController", bundle: nil)
            self.navigationController?.pushViewController(viewController, animated: false)
            
        } else if (Config().userData()["identityVerified"] == true) && (Config().userData()["wantToSell"] == false) && (Config().userData()["wantToBuy"] == false) {
            let viewController = StepsViewController.init(nibName: "StepsViewController", bundle: nil)
            self.navigationController?.pushViewController(viewController, animated: false)
            
        } else if Config().userData()["identityVerified"] == false && Config().userData()["accountCreated"] == true{
            let viewController = StepsViewController.init(nibName: "StepsViewController", bundle: nil)
            self.navigationController?.pushViewController(viewController, animated: false)
            
        }
    }
}

extension CodeVerificationViewController{
    @IBAction func continueButtonAction(_ sender: Any) {
        if otpValue.count < 6 {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "ENTER_VERIFICATION_CODE".localized)
        } else {
            if Connectivity.isConnectedToInternet {
                let phoneNumber = Config().userData().string(key:"phoneNumber")
                databseReference.child("user").child(phoneNumber).getData(completion:  { error, snapshot in
                    guard error == nil else
                    {
                        print(error!.localizedDescription)
                        return;
                    }
                    
                    let object = snapshot?.value as? JSONDictionary
                    
                    if ((object?.keys.contains(phoneNumber)) != nil) {
                        userDataObject["accountCreated"] = object?["accountCreated"]?.boolValue as AnyObject
                        userDataObject["personalDataStored"] = object?["personalDataStored"]?.boolValue as AnyObject
                        userDataObject["identityVerified"] = object?["identityVerified"]?.boolValue as AnyObject
                        userDataObject["wantToBuy"] = object?["wantToBuy"]?.boolValue as AnyObject
                        userDataObject["wantToSell"] = object?["wantToSell"]?.boolValue as AnyObject
                        
                        Config().saveUserData(Object: userDataObject)
                        self.moveToNextController()
                    } else {
                        
                        let credential = PhoneAuthProvider.provider().credential(
                            withVerificationID: Config().userData().string(key:"authVerificationID"),
                            verificationCode: self.otpValue
                        )
                        
                        Auth.auth().signIn(with: credential) { authResult, error in
                            if let error = error {
                                makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: error.localizedDescription)
                                return
                            } else {
                                
                                let userID = Auth.auth().currentUser?.uid
                                databseReference.child("user").child(phoneNumber).setValue(["userId": userID ?? "", "accountCreated": true, "personalDataStored" : false, "identityVerified" : false, "address" : "", "city" : "", "dateOfBirth" : "", "nationality" : "", "panNumber" : "", "pinCode" : "", "userName" : "", "wantToBuy" : false, "wantToSell" : false])
                                userDataObject["accountCreated"] = true as AnyObject
                                userDataObject["personalDataStored"] = false as AnyObject
                                userDataObject["identityVerified"] = false as AnyObject
                                
                                Config().saveUserData(Object: userDataObject)
                                self.moveToNextController()
                            }
                        }
                    }
                })
            } else {
                openSettingAlert()
            }
        }
    }
    
    @IBAction func resendOtpButtonAction(_ sender: Any) {
        print("working")
       /* if Config().userData().string(key:"phoneNumber") == "9876543210" || Config().userData().string(key:"phoneNumber") == "1111111111" {
            Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        } else {
            Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        }*/
        
        if Connectivity.isConnectedToInternet {
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        PhoneAuthProvider.provider()
            .verifyPhoneNumber((self.dialCode) + (self.phoneNumber), uiDelegate: nil) { verificationID, error in
                if let error = error {
                    makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: error.localizedDescription)
                    return
                } else {
                    // Sign in using the verificationID and the code sent to  the user
                    // ...
                    self.timerCount = 60
                    self.updateTimer()
                }
            }
        } else {
            openSettingAlert()
        }
    }
}

extension CodeVerificationViewController : OTPFieldViewDelegate{
    
    /// Inherited from OTPFieldViewDelegate
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool{
        return true
    }
    
    /// Inherited from OTPFieldViewDelegate
    func enteredOTP(otp otpString : String){
        otpValue = otpString
    }
    
    /// Inherited from OTPFieldViewDelegate
    func hasEnteredAllOTP(hasEnteredAll hasEntered : Bool) -> Bool {
        print("Has entered all OTP?")
        return false
    }
}
