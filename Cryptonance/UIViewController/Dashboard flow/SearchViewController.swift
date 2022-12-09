//
//  SearchViewController.swift
//  Cryptonance
//
//  Created by iMac on 14/11/22.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    
    let searchTableViewDataSource = SearchTableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.setDataSourceDelegate(datasourceAndDelegate: searchTableViewDataSource, tableCell: "SearchTableViewCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}

extension SearchViewController{
    
    func setUpUI() {
        self.navigationController?.navigationBar.isHidden = true
    }
}

@available(iOS 13.0, *)
extension SearchViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        print("update search results....")
        guard let searchText = searchController.searchBar.text else { return }
        searchTableViewDataSource.searchResults = searchTableViewDataSource.searchArray.filter { $0.lowercased().contains(searchText.lowercased()) }
        tableView?.reloadData()
    }
}
