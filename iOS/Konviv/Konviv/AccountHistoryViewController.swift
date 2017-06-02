//
//  AccountHistoryViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 10/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class AccountHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var idAccount:String = ""
    var bank = Bank()
    @IBOutlet weak var accountHistoryTableView: UITableView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        bank.accounts = []
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.getAccountHistory()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bank.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryItemTableViewCell
        cell.lblAmount.text = "$\(String(self.bank.transactions[indexPath.row].amount))"
        if(self.bank.transactions[indexPath.row].amount < 0){
            cell.lblAmount.textColor = UIColor.red
        }
        cell.lblDate.text = String(describing: self.bank.transactions[indexPath.row].date)
        cell.textViewDescription.text = self.bank.transactions[indexPath.row].name
        return cell
    }
    
    // MARK: - Request
    
    func getAccountHistory() -> Void {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        self.sendRequest(request: Request().createRequest(endPoint: "\(Constants.HISTORY_BANK_ACCOUNT)\(self.idAccount)", method: "GET"))
    }
    
    func sendRequest(request :NSMutableURLRequest) -> Void {
        if(!Request().IsInternetConnection()){
            self.presentAlert(message: "No internet connection")
            return
        }
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil
            {
                return
            }
            self.response(response: response!, data: data!)
        }
        task.resume()
    }
    
    func response(response: URLResponse, data: Data) -> Void {
        do{
            print()
            let jsonObject = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if(JSONSerialization.isValidJSONObject(jsonObject)){
                
                if let dictionary = jsonObject as? [String: AnyObject] {
                    self.bank.name = dictionary["bank"] as! String
                    let transactions :[[String:AnyObject]] = dictionary["account"]!["transactions"] as! [[String : AnyObject]]
        
                    if(JSONSerialization.isValidJSONObject(transactions) && transactions.count > 0){
                        self.getResponseData(transactions: transactions)
                        return
                    }else{
                        self.presentAlert(message: "This account doesn't have history.")
                    }
                }
            }
            self.presentAlert(message: "This information is not enable yet, please try later.")
        }catch{
            presentAlert(message: "Something was wrong.")
        }
    }
    
    func getResponseData(transactions:[[String : AnyObject]]) -> Void {
        for transaction in transactions {
            let tran = Transaction()
            tran.amount = transaction["amount"] as! Double
            tran.date = transaction["date"] as! String
            tran.name = transaction["name"] as! String
            self.bank.transactions.append(tran)
        }
        DispatchQueue.main.async {
            self.accountHistoryTableView.reloadData()
            self.activityIndicator.stopAnimating()
        }

    }
    
    func presentAlert(message:String) -> Void {
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let actionOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){ (action:UIAlertAction) in
       _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(actionOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleError(error:Error, response: URLResponse) -> Void {
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
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
