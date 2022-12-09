//
//  StepsViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 28/10/22.
//

import UIKit
import FirebaseDatabase

class StepsViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView?
    
    @IBOutlet weak var identityVerificationCheckImageView: UIImageView?
    @IBOutlet weak var accountCreatedCheckImageView: UIImageView?
    @IBOutlet weak var personalDetailsCheckImageView: UIImageView?
    @IBOutlet weak var bannerImageView: UIImageView?
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var underVerifyLabel: UILabel?
     
    @IBOutlet weak var continueButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}

extension StepsViewController{
    func setUpUI() {
        navigationController?.navigationBar.isHidden = true
        titleLabel?.text = "JUST_TWO_MORE_STEPS".localized
        
        if (Config().userData()["accountCreated"].boolValue == true) && (Config().userData()["personalDataStored"].boolValue == false) && (Config().userData()["identityVerified"].boolValue == false)  {
            
            self.accountCreatedCheckImageView?.image = UIImage(named: "checked")
            self.personalDetailsCheckImageView?.image = UIImage(named: "unchecked")
            self.identityVerificationCheckImageView?.isHidden = false
            self.underVerifyLabel?.isHidden = true

        } else if (Config().userData()["accountCreated"].boolValue == true) && (Config().userData()["personalDataStored"].boolValue == true) && (Config().userData()["identityVerified"].boolValue == false) {
            
            self.accountCreatedCheckImageView?.image = UIImage(named: "checked")
            self.personalDetailsCheckImageView?.image = UIImage(named: "checked")
            self.identityVerificationCheckImageView?.isHidden = false
            self.underVerifyLabel?.isHidden = true
            
        } else if (Config().userData()["accountCreated"].boolValue == true) && (Config().userData()["personalDataStored"].boolValue == true) && (Config().userData()["identityVerified"].boolValue == true) {
            
            self.accountCreatedCheckImageView?.image = UIImage(named: "checked")
            self.personalDetailsCheckImageView?.image = UIImage(named: "checked")
            self.identityVerificationCheckImageView?.isHidden = true
            self.underVerifyLabel?.isHidden = false
            titleLabel?.text = "THANKS_FOR_UPDATE_YOUR_DETAILS".localized
        }
    }
}

extension StepsViewController{
    @IBAction func continueButtonAction(_ sender: Any) {
        
        if (Config().userData()["accountCreated"].boolValue == true) && (Config().userData()["personalDataStored"].boolValue == false) && (Config().userData()["identityVerified"].boolValue == false)  {
            
            let viewController = AccountCreatedViewController.init(nibName: "AccountCreatedViewController", bundle: nil)
            navigationController?.pushViewController(viewController, animated: true)

        } else if (Config().userData()["accountCreated"].boolValue == true) && (Config().userData()["personalDataStored"].boolValue == true) && (Config().userData()["identityVerified"].boolValue == false) {
            
            let viewController = IdentityVerificationViewController.init(nibName: "IdentityVerificationViewController", bundle: nil)
            navigationController?.pushViewController(viewController, animated: true)
            
        } else if (Config().userData()["accountCreated"].boolValue == true) && (Config().userData()["personalDataStored"].boolValue == true) && (Config().userData()["identityVerified"].boolValue == true) {
            
            let viewController = WelcomeViewController.init(nibName: "WelcomeViewController", bundle: nil)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
