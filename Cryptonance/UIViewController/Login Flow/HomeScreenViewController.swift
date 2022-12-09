//
//  HomeScreenViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 27/10/22.
//

import UIKit

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton?
    @IBOutlet weak var signInButton: UIButton?
    
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}


extension HomeScreenViewController{
    func setUpUI() {
        descriptionLabel?.text = "Lorem ipsum dolor sit amet, consectetur\nadipiscing elit. Enim hendrerit aliquam odio eu."
        
        let string = NSMutableAttributedString(string: ("GET_FREE".localized) + "\n" + ("CRYPTOCURRENCY".localized) + "\n" + ("FOR_GETTING".localized) + "\n" + ("STARTED".localized))
        string.setColorForText("CRYPTOCURRENCY".localized, with: UIColor.themeYellow)
        titleLabel?.attributedText = string
    }
}

extension HomeScreenViewController{
    @IBAction func createAccountButtonAction(_ sender: Any) {
        let viewController = SignUpViewController.init(nibName: "SignUpViewController", bundle: nil)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func signInButtonAction(_ sender: Any) {
        let viewController = SignInViewController.init(nibName: "SignInViewController", bundle: nil)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
