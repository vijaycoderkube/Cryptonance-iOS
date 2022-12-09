//
//  AccountCreatedViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 28/10/22.
//

import UIKit
import SKCountryPicker
import CRNotifications
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON

class AccountCreatedViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var continueButton: UIButton?
    
    @IBOutlet weak var DOBTextFieldRightView: UIView?
    @IBOutlet weak var nationalityTextFieldRightView: UIView?
    @IBOutlet weak var DOBTextFieldBackgroundView: UIView?
    @IBOutlet weak var userNameTextFieldBackgroundView: UIView?
    @IBOutlet weak var nationalityTextFieldBackgroundView: UIView?
    
    @IBOutlet weak var DOBTextField: UITextField?
    @IBOutlet weak var userNameTextField: UITextField?
    @IBOutlet weak var nationalityTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let country = CountryManager.shared.country(withDigitCode: "+91") {
            self.nationalityTextField?.text = country.countryName
            manager.lastCountrySelected = country
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}

extension AccountCreatedViewController {
    func setUpUI() {
        
        titleLabel?.text = "ACCOUNT_CREATED".localized + "!"
        
        navigationBarWithRightButtonTransparent(isShowBackButton: true, isShowHomeButton: false)
        
        [userNameTextFieldBackgroundView, DOBTextFieldBackgroundView, nationalityTextFieldBackgroundView].forEach { (view) in
            view?.layer.borderColor = UIColor.textFieldBorderColor.cgColor
            view?.layer.borderWidth = 1
        }
        
        userNameTextField?.setRightPaddingPoints(14)
        userNameTextField?.setLeftPaddingPoints(14)
        
        DOBTextField?.setLeftPaddingPoints(14)
        DOBTextField?.rightViewMode = .always
        DOBTextField?.rightView = DOBTextFieldRightView
        
        nationalityTextField?.setLeftPaddingPoints(14)
        nationalityTextField?.rightViewMode = .always
        nationalityTextField?.rightView = nationalityTextFieldRightView
    }
}

extension AccountCreatedViewController {
    @IBAction func continueButtonAction(_ sender: Any) {
        
        if userNameTextField?.text?.trimmingLeadingAndTrailingSpaces() == "" {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "ENTER_USERNAME".localized)
            
        } else if DOBTextField?.text?.trimmingLeadingAndTrailingSpaces() == "" {
            makeToast(type: CRNotifications.error, title: "APP_TITLE".localized.capitalized, message: "SELECT_DATE_OF_BIRTH".localized)
            
        } else {
            if Connectivity.isConnectedToInternet {
                databseReference.child("user").child(Config().userData().string(key:"phoneNumber")).updateChildValues(["personalDataStored": true, "dateOfBirth" : DOBTextField?.text ?? "", "nationality" : nationalityTextField?.text ?? "", "userName" : userNameTextField?.text ?? ""])
                
                userDataObject["personalDataStored"] = true as AnyObject
                Config().saveUserData(Object: userDataObject)
                
                let viewController = StepsViewController.init(nibName: "StepsViewController", bundle: nil)
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                self.openSettingAlert()
            }
        }
    }
}

extension AccountCreatedViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == nationalityTextField {
            let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
                
                guard let self = self else { return }
                self.nationalityTextField?.text = country.countryName
            }
            return false
        }
        
        else if textField == DOBTextField{
            let viewController = DatePickerViewController()
            viewController.modalPresentationStyle = .custom
            viewController.modalTransitionStyle = .coverVertical
            viewController.pickerDelegate = self
            
            self.present(viewController, animated: true, completion: nil)
            return false
        }
        return true
    }
}

//MARK: - Date Picker Delegate
extension AccountCreatedViewController : datePickerDelegate {
    
    func setDateValue(dateValue: Date, type: Int) {
        let date = DateToString(Formatter: "dd-MM-YYYY", date: dateValue)
        self.DOBTextField?.text = date
    }
}
