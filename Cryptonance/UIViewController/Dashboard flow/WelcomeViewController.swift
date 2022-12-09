//
//  WelcomeViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 31/10/22.
//

import UIKit
import FirebaseDatabase

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var buyButton: UIButton?
    @IBOutlet weak var sellButton: UIButton?
    
    @IBOutlet weak var descriptionLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}

extension WelcomeViewController {
    func setUpUI() {
        navigationBarWithRightButtonTransparent(isShowBackButton: true, isShowHomeButton: false)
        
        [sellButton, buyButton].forEach { (view) in
            view?.layer.borderColor = UIColor.textFieldBorderColor.cgColor
            view?.layer.borderWidth = 1
        }
    }
}

extension WelcomeViewController {
    @IBAction func sellOrBuyButtonAction(_ sender: UIButton) {
        if sender.tag == 1{
            print("I want to Sell")
            sellButton?.layer.borderColor = UIColor.themeYellow.cgColor
            sellButton?.setTitleColor(.themeYellow, for: .normal)
            
            buyButton?.layer.borderColor = UIColor.textFieldBorderColor.cgColor
            buyButton?.setTitleColor(.textFieldBorderColor, for: .normal)
            
            if Connectivity.isConnectedToInternet {
                databseReference.child("user").child(Config().userData().string(key:"phoneNumber")).updateChildValues(["wantToSell" : true])
                
                userDataObject["wantToSell"] = true as AnyObject
                Config().saveUserData(Object: userDataObject)
                
                let viewController = DashboardViewController.init(nibName: "DashboardViewController", bundle: nil)
                navigationController?.pushViewController(viewController, animated: true)
            } else {
                openSettingAlert()
            }
        } else if sender.tag == 2 {
            print("I want to Buy")
            buyButton?.layer.borderColor = UIColor.themeYellow.cgColor
            buyButton?.setTitleColor(.themeYellow, for: .normal)
            
            sellButton?.layer.borderColor = UIColor.textFieldBorderColor.cgColor
            sellButton?.setTitleColor(.textFieldBorderColor, for: .normal)
            
            if Connectivity.isConnectedToInternet {
                databseReference.child("user").child(Config().userData().string(key:"phoneNumber")).updateChildValues(["wantToBuy" : true])
                
                userDataObject["wantToBuy"] = true as AnyObject
                Config().saveUserData(Object: userDataObject)
                
                let viewController = DashboardViewController.init(nibName: "DashboardViewController", bundle: nil)
                navigationController?.pushViewController(viewController, animated: true)
            } else {
                openSettingAlert()
            }
        }
    }
}
