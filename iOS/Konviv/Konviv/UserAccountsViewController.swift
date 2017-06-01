//
//  UserAccountsViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 4/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit
import LinkKit
import Firebase
class UserAccountsViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var accountsTableView: UITableView!
    @IBOutlet weak var lblLastTransaction: UILabel!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var bankAccounts : [Bank] = []
    var amount = ""
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(_ animated: Bool) {
        print(UserDefaults.standard.bool(forKey: "hasAccounts"))
        self.getLastTransaction()
        self.getUserBankAccounts()
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
        if((amount as! Double) < 0){
            cell.amount.textColor = UIColor.red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AccountHistory") as! AccountHistoryViewController
        vc.idAccount = self.bankAccounts[indexPath.section].accounts[indexPath.row].id
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func noHasBankAccounts() -> Void {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardWelcomeNavController")
       
        DispatchQueue.main.async(execute: {
            self.present(vc!, animated: false, completion: nil)
        })

        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.window?.rootViewController = vc
        UserDefaults.standard.set(false, forKey: "hasAccounts")
    }
    //MARK: - GET BANKS ACCOUNTS
    func getUserBankAccounts() -> Void {
        self.bankAccounts = []
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.sendRequest(request: Request().createRequest(endPoint: Constants.BANK_ACCOUNTS, method: "GET"))
    }
    
    func sendRequest(request: NSMutableURLRequest) -> Void {
        if(!Request().IsInternetConnection()){
            self.presentAlert()
            return
        }
        
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
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
    }
    //MARK: - GET LAST TRANSACTION
    
    func getLastTransaction() -> Void {
        if(!Request().IsInternetConnection()){
            self.presentAlert()
            return
        }
        let request = Request().createRequest(endPoint: Constants.LAST_TRANSACTION, method: "GET")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil
            {
                print("error=\(error)")
                return
            }
            DispatchQueue.main.async {
               self.lblLastTransaction.text = String(data: data!, encoding: .utf8)!.replacingOccurrences(of: "\"", with: "")
                var amount  = String(data: data!, encoding: .utf8)!.replacingOccurrences(of: "\"", with: "")
                amount  = amount.replacingOccurrences(of: "$", with: "")
                if(Double(amount)! < Double(0)){
                    self.lblLastTransaction.textColor = UIColor(red: 217.0, green: 0.11, blue: 0.3, alpha: 1.0)
                }
            }
        }
        task.resume()
    }
    
    @IBAction func didTabOnLogout(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Landingscreen")
        AuthUserActions().signOut()
        self.present(vc!, animated: true)
    }
    @IBAction func didTabOnAddBank(_ sender: Any) {
        configuration()
    }
    
    func presentAlert() -> Void {
        let alert = UIAlertController(title: "Error", message: "No internet connection", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert,animated: true, completion: nil)
    }
    
    // MARK: -  PLAID DELEGATE
    func configuration() {
        let linkConfiguration = PLKConfiguration(key: Constants.PLAID_KEY, env: .development, product: .auth)
        linkConfiguration.clientName = "Konviv"
        PLKPlaidLink.setup(with: linkConfiguration) { (success, error) in
            if (success) {
                // Handle success here, e.g. by posting a notification
                NSLog("Plaid Link setup was successful")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PLDPlaidLinkSetupFinished"), object: self)
                self.presentPlaidLinkWithCustomConfiguration()
                
            }
            else if let error = error {
                NSLog("Unable to setup Plaid Link due to: \(error.localizedDescription)")
                self.presentAlert()
            }
            else {
                NSLog("Unable to setup Plaid Link")
            }
        }
    }
    
    func presentPlaidLinkWithCustomConfiguration() {
        let linkConfiguration = PLKConfiguration(key: Constants.PLAID_KEY, env: .development, product: .auth)
        linkConfiguration.clientName = "Link Demo"
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate)
        present(linkViewController, animated: true)
    }
    
    func handleSuccessWithToken(publicToken: String, metadata: [String : AnyObject]?) {
        let inst  =  metadata?["institution"] as AnyObject
        let instName = self.getValue(anyVal: inst["name"] as Any)
        let id = self.getValue(anyVal: inst["type"] as Any)
        if (!(instName == "" && id == "")) {
            self.sendInfoAccount(token: publicToken,id: id, institution: instName)
        }
    }
    
    func getValue(anyVal : Any) -> String{
        guard let b = anyVal as? String
            else {
                print("Error") // Was not a string
                return ""
        }
        return b
    }
    
    func handleError(error: NSError, metadata: [String : AnyObject]?) {
        print("Failure error : \(error.localizedDescription)\nmetadata: \(metadata)")
    }
    
    func handleExitWithMetadata(metadata: [String : AnyObject]?) {
        print("Exit metadata: \(metadata)")
    }
    
    func sendInfoAccount(token: String, id : String, institution: String ) -> Void {
        let dictionary : [String:Any] =
            ["item":
                [
                    "public_token":token,
                    "institution":
                        [
                            "id":id,
                            "name":institution
                    ]
                ]
        ]
        let request: NSMutableURLRequest = Request().createRequest(endPoint: Constants.REGISTER_BANK, method: "POST")
        let json = try? JSONSerialization.data(withJSONObject: dictionary)
        request.httpBody = json
        self.sendPlaidRequest(request: request)
    }
    func sendPlaidRequest(request:NSMutableURLRequest) -> Void {
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            self.handleResponse(respose: response!)
        }
        task.resume()
        
    }
    func handleResponse(respose: URLResponse) -> Void {
        let res = respose as? HTTPURLResponse
        let status = res?.statusCode
        
        if (status! >= 200 && status! < 300) {
            self.getUserBankAccounts()
            self.getLastTransaction()
        }else if(status! >= 400) {
            if let user = FIRAuth.auth()?.currentUser {
                
                user.getTokenForcingRefresh(true, completion: { (val:String?, err: Error?) in
                    if(err != nil){
                        UserDefaults.standard.setValue("user_auth_token", forKey: val!)
                    }
                })
                let alert = UIAlertController(title: "Konviv", message: "The transaction was unsuccessful, please try again", preferredStyle: UIAlertControllerStyle.alert)
                let actionOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(actionOk)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.didTabOnLogout(Any)
            }
            
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

extension UserAccountsViewController : PLKPlaidLinkViewDelegate{
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            NSLog("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            self.handleSuccessWithToken(publicToken: publicToken, metadata: metadata as [String : AnyObject]?)
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
                self.handleError(error: error as NSError, metadata: metadata as [String : AnyObject]?)
            }
            else {
                NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
                self.handleExitWithMetadata(metadata: metadata as [String : AnyObject]?)
            }
        }
    }
    
}
