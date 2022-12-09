//
//  DashboardViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 31/10/22.
//

import UIKit
import SwiftQRScanner

class DashboardViewController: UIViewController {

    @IBOutlet weak var balanceLabel: UILabel?
    
    let numberFormatter = NumberFormatter()
    var mainBalance : Double = 0
    var searchController : UISearchController?
    var searchViewController = SearchViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            searchController = UISearchController(searchResultsController: searchViewController)
            searchController?.searchBar.searchTextField.textColor = .themeWhite
            searchController?.searchBar.searchTextField.placeholderColor = .textFieldBorderColor
            searchController?.searchResultsUpdater = searchViewController
            searchController?.searchBar.tintColor = .themeYellow
            searchController?.searchBar.barStyle = .black
            searchController?.searchBar.delegate = self
            searchController?.searchBar.placeholder = "SEARCH".localized
            searchController?.searchBar.searchTextField.becomeFirstResponder()
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}

extension DashboardViewController {
    func setUpUI() {
        
        currency = "USDT"
        mainBalance = 2525.85
        
        let mainBalanceString = "\((currency ?? "") + " " + ("\(mainBalance.withCommas())"))"
        
        if let afterDecimalPoint = mainBalanceString.lastIndex(of: ".") {
            let afterEqualsTo = String("." + mainBalanceString.suffix(from: afterDecimalPoint).dropFirst())
            print(afterEqualsTo)
            
            let mainBalanceAttributedString = NSMutableAttributedString(string: mainBalanceString)
            
            let afterPointValue = (mainBalanceString as NSString).range(of: afterEqualsTo)
            mainBalanceAttributedString.addAttribute(NSAttributedString.Key.font, value: themeFont(size: 18, fontname: .regular), range: afterPointValue)
            
            let point = (mainBalanceString as NSString).range(of: ".")
            mainBalanceAttributedString.addAttribute(NSAttributedString.Key.font, value: themeFont(size: 26, fontname: .regular), range: point)
            
            balanceLabel?.attributedText = mainBalanceAttributedString
        } else {
            let mainBalanceStringWithAddedZero = mainBalanceString + ".00"
            
            let afterDecimalPoint = mainBalanceStringWithAddedZero.lastIndex(of: ".")
            let afterEqualsTo = String("." + mainBalanceStringWithAddedZero.suffix(from: afterDecimalPoint!).dropFirst())
            print(afterEqualsTo)
            
            let mainBalanceAttributedString = NSMutableAttributedString(string: mainBalanceStringWithAddedZero)
            
            let afterPointValue = (mainBalanceStringWithAddedZero as NSString).range(of: afterEqualsTo)
            mainBalanceAttributedString.addAttribute(NSAttributedString.Key.font, value: themeFont(size: 18, fontname: .regular), range: afterPointValue)     
            
            let point = (mainBalanceStringWithAddedZero as NSString).range(of: ".")
            mainBalanceAttributedString.addAttribute(NSAttributedString.Key.font, value: themeFont(size: 26, fontname: .regular), range: point)
            
            balanceLabel?.attributedText = mainBalanceAttributedString
        }
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.isHidden = false
        
        let drawerButton = UIButton()
        drawerButton.setImage(UIImage(named: "drawerIcon")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        drawerButton.addTarget(self, action: #selector(drawerButtonClickAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: drawerButton)
        
        let scannerButton = UIButton()
        scannerButton.setImage(UIImage(named: "scannerIcon")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        scannerButton.addTarget(self, action: #selector(scannerButtonClickAction), for: .touchUpInside)
        
        let searchButton = UIButton()
        searchButton.setImage(UIImage(named: "searchIcon")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonClickAction), for: .touchUpInside)
        
        let rightNavigationItem = UIBarButtonItem(customView: searchButton)
        let secondRightNavigationItem = UIBarButtonItem(customView: scannerButton)
        navigationItem.rightBarButtonItems = [secondRightNavigationItem, rightNavigationItem]
    }
}

extension DashboardViewController: QRScannerCodeDelegate {
    func qrScannerDidFail(_ controller: UIViewController, error: QRCodeError) {
        print("error:\(error.localizedDescription)")
    }
    
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        print("result:\(result)")
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
    }
}

extension DashboardViewController : UISearchBarDelegate{
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.searchController = nil
        self.view.setNeedsLayout()
    }
}

extension DashboardViewController {
    @objc func drawerButtonClickAction() {
        print("Drawer")
    }
    
    @objc func scannerButtonClickAction() {
        print("scanner")
        var configuration = QRScannerConfiguration()
        if #available(iOS 13.0, *) {
            configuration.cameraImage = UIImage(systemName: "camera.rotate.fill")
            configuration.flashOnImage = UIImage(systemName: "flashlight.off.fill")
        } else {
            // Fallback on earlier versions
        }
        
        let scanner = QRCodeScannerController(qrScannerConfiguration: configuration)
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
    
    @objc func searchButtonClickAction() {
        print("search")
        navigationItem.searchController = searchController
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.searchBar.sizeToFit()
    }
}
