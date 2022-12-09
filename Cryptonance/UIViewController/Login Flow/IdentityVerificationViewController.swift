//
//  IdentityVerificationViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 28/10/22.
//

import UIKit
import CRNotifications
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON

class IdentityVerificationViewController: UIViewController {
    
    @IBOutlet weak var verifyNowButton: UIButton?
    
    @IBOutlet weak var addressTextFieldBackgroundView: UIView?
    @IBOutlet weak var cityTextFieldBackgroundView: UIView?
    @IBOutlet weak var pinCodeTextFieldBackgroundView: UIView?
    @IBOutlet weak var panNumberTextFieldBackgroundView: UIView?
    
    @IBOutlet weak var addressTextField: UITextField?
    @IBOutlet weak var cityTextField: UITextField?
    @IBOutlet weak var pinCodeTextField: UITextField?
    @IBOutlet weak var panNumberTextField: UITextField?
    
    let acceptableCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}

extension IdentityVerificationViewController {
    func setUpUI() {
        navigationBarWithRightButtonTransparent(isShowBackButton: true, isShowHomeButton: false)
        
        [addressTextFieldBackgroundView, cityTextFieldBackgroundView, pinCodeTextFieldBackgroundView, panNumberTextFieldBackgroundView].forEach { (view) in
            view?.layer.borderColor = UIColor.textFieldBorderColor.cgColor
            view?.layer.borderWidth = 1
        }
        
        [addressTextField, cityTextField, pinCodeTextField, panNumberTextField].forEach { (view) in
            view?.setRightPaddingPoints(14)
            view?.setLeftPaddingPoints(14)
        }
    }
}

extension IdentityVerificationViewController {
    @IBAction func verifyNowButtonAction(_ sender: Any) {
        if addressTextField?.text?.trimmingLeadingAndTrailingSpaces() == "" {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "ENTER_ADDRESS".localized)
            
        } else if cityTextField?.text?.trimmingLeadingAndTrailingSpaces() == "" {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "ENTER_CITY".localized)
            
        } else if pinCodeTextField?.text?.trimmingLeadingAndTrailingSpaces() == "" {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "ENTER_PINCODE".localized)
            
        } else if panNumberTextField?.text?.trimmingLeadingAndTrailingSpaces() == "" {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "ENTER_PAN_NO".localized)
            
        } else {
            if Connectivity.isConnectedToInternet {
                databseReference.child("user").child(Config().userData().string(key:"phoneNumber")).updateChildValues(["identityVerified" : true, "address" : addressTextField?.text ?? "", "city" : cityTextField?.text ?? "", "panNumber" : panNumberTextField?.text ?? "", "pinCode" : pinCodeTextField?.text ?? ""])
                
                userDataObject["identityVerified"] = true as AnyObject
                Config().saveUserData(Object: userDataObject)
                
                let viewController = StepsViewController.init(nibName: "StepsViewController", bundle: nil)
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                openSettingAlert()
            }
        }
    }
}

extension IdentityVerificationViewController : UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == panNumberTextField {
            let characterSet = NSCharacterSet(charactersIn: acceptableCharacters).inverted
            let filtered = string.components(separatedBy: characterSet).joined(separator: "").uppercased()
            return (string == filtered)
        }
        return false
    }
}
