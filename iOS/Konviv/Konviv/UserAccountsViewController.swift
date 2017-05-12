//
//  UserAccountsViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 4/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit
import Firebase
class UserAccountsViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var accountsTableView: UITableView!
        
    var bankAccounts : [Bank] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       // self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuItem")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.bankAccounts = []
        self.getUserBankAccounts()
        //self.noHasBankAccounts()
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "AccountHistory") as! AccountHistoryViewController
        vc.idAccount = self.bankAccounts[indexPath.section].accounts[indexPath.row].id
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func noHasBankAccounts() -> Void {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardWelcomeNavController")
        self.present(vc!, animated: true, completion: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        UserDefaults.standard.set(false, forKey: "hasAccounts")
    }
    
    func getUserBankAccounts() -> Void {
        self.sendRequest(request: Request().createRequest(endPoint: Constants.BANK_ACCOUNTS, method: "GET"))
    }
    
    func sendRequest(request: NSMutableURLRequest) -> Void {
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil
            {
                print("error=\(error)")
                return
            }
            if(JSONSerialization.isValidJSONObject(try!JSONSerialization.jsonObject(with: data!, options: .allowFragments))){
                self.getResponseData(data: data!)
                return
            }
            self.noHasBankAccounts()
        }
        task.resume()
    }
    func getResponseData(data:Data) -> Void {
        let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        if let dictionary = object as? [String: AnyObject] {
            let b = dictionary["banks"] as? [[String: AnyObject]]
            for banks in b! {
                let bank = Bank()
                bank.name = banks["bank_name"] as! String
                let accounts = banks["accounts"] as? [[String:AnyObject]]
                if((accounts?.count)! == 0){
                    self.noHasBankAccounts()
                    return
                }
                UserDefaults.standard.setValue(true, forKey: "hasAccounts")
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
        }
    }
    
    @IBAction func didTabOnLogout(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Landingscreen")
        AuthUserActions().signOut()
        self.present(vc!, animated: true)
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
