//
//  UserAccountsViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 4/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class UserAccountsViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var accountsTableView: UITableView!
        
    var bankAccounts : [Bank] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       // self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuItem")
        self.getUserBankAccounts()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.bankAccounts.count
    }
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.bankAccounts[section].name
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.bankAccounts[section].accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItem", for: indexPath) as! UserAccountsTableViewCell
        cell.accountName.text = self.bankAccounts[indexPath.section].accounts[indexPath.row].name
        let amount = self.bankAccounts[indexPath.section].accounts[indexPath.row].balances["current"] as? NSNumber
        
        cell.amount.text = amount != nil ? "$\(String(describing: amount!))" : "$0"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.bankAccounts[indexPath.section].accounts[indexPath.row].id)
    }
    
    func getUserBankAccounts() -> Void {
        let endpoint = "http://192.168.1.8:8080/api/v1/plaid/accounts";
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
            let res = String(data: data!, encoding: String.Encoding.utf8)
            print(res!)
            self.getResponseData(data: data!)
        }
        task.resume()
    }
    func getResponseData(data:Data) -> Void {
        //do{
            let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let b = dictionary["banks"] as? [[String: AnyObject]]
                
                for banks in b! {
                    
                    let bank = Bank()
                    bank.name = banks["bank_name"] as! String
                    let accounts = banks["accounts"] as? [[String:AnyObject]]
                    
                    for account in accounts!{
                        
                        let ac = Account()
                        ac.id = account["id"] as! String
                        ac.name = account["name"] as! String
                        ac.balances = account["balances"] as! [String:Any]
                        bank.accounts.append(ac)
                    }
                    self.bankAccounts.append(bank)
                }
                DispatchQueue.main.async(execute: {
                    self.accountsTableView.reloadData()
                })
       //     }
       // }catch let myJSONError {
          //  print(myJSONError)
       // }
        }
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
