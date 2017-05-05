//
//  UserAccountsViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 4/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class UserAccountsViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var sections = [String]()
    
    var items = [["5"]]
    var amounts : [[String:AnyObject]] = [[:]]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuItem")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getUserBankAccounts()
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items[section].count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItem", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        //cell.LabelAmount?.text = self.amounts[indexPath.section][indexPath.row]
        return cell
    }
    func getUserBankAccounts() -> Void {
        let endpoint = "http://192.168.1.9:8080/api/v1/plaid/accounts";
        let url = URL(string: endpoint)!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "GET"
        let auth_token = UserDefaults.standard.string(forKey: "user_auth_token")
        request.addValue(auth_token!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil
            {
                print("error=\(error)")
                return
            }
            print("response = \(response!)")
            //self.handleResponse(respose: response!)
            let res = String(data: data!, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(res!)
            do{
                let object = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                if let dictionary = object as? [String: AnyObject] {
                    let b = dictionary["banks"] as? [[String: AnyObject]]
                    //   self.numberOfSections = (b?.count)!
                    self.items.removeAll()
                    for banks in b! {
                        self.sections.append(banks["bank_name"] as! String)
                        let accounts = banks["accounts"] as? [[String:AnyObject]]
                        var arr :[String]=[]
                        var acountAmount :[[String:AnyObject]]=[[:]]
                        for account in accounts!{
                            arr.append(account["name"] as! String)
                            var balances = account["balances"] as? [String: AnyObject]
                            acountAmount.append(balances!)
                        }
                        self.items.append(arr)
                        //self.amounts.append(acountAmount)
                    }
                }
                self.tableView.reloadData()
            }catch let myJSONError {
                print(myJSONError)
            }
        }
        task.resume()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
