//
//  SearchTableViewDataSource.swift
//  Cryptonance
//
//  Created by iMac on 14/11/22.
//

import UIKit

class SearchTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    //define variables
    var searchArray = ["Kenil", "Sagar", "Kamo", "Brijesh", "Vijay", "Nilesh", "Ashraf", "Akshay", "Irshad", "Dhruv", "Raihan", "Abdul", "Mahesh", "Naveen Tester", "Rushabh", "Sushil", "Meet", "Yagnik", "Karan", "SaiKiran"] {
        didSet {
            self.TableView?.reloadData()
        }
    }
    var searchResults = [String]()
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        
        let object = searchResults[indexPath.row]
        tableViewCell.titleLabel?.text = object
        
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
