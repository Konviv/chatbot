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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        print(self.bank.transactions[indexPath.row].name)
        cell.lblDate.text = String(describing: self.bank.transactions[indexPath.row].date)
        cell.textViewDescription.text = self.bank.transactions[indexPath.row].name
        return cell
    }
    
    // MARK: - Request
    
    func getAccountHistory() -> Void {
        let endpoint = "http://192.168.1.11:8080/api/v1/plaid/account_history/\(self.idAccount)";
        let url = URL(string: endpoint)!
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "GET"
        self.sendRequest(request: self.createHeaders(request: request))
    }
    
    func createHeaders(request:NSMutableURLRequest) -> NSMutableURLRequest {
        let auth_token = UserDefaults.standard.string(forKey: "user_auth_token")
        request.addValue(auth_token!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func sendRequest(request :NSMutableURLRequest) -> Void {
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil
            {
                // self.handleError(error: error!, response: response!)
                return
            }
            self.response(response: response!, data: data!)
        }
        task.resume()
    }
    
    func response(response: URLResponse, data: Data) -> Void {
        
        let jsonObject = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        if let dictionary = jsonObject as? [String: AnyObject] {
            self.bank.name = dictionary["bank"] as! String
            let transactions :[[String:AnyObject]] = dictionary["account"]!["transactions"] as! [[String : AnyObject]]
            
            for transaction in transactions {
                let tran = Transaction()
                tran.amount = transaction["amount"] as! Double
                tran.date = transaction["date"] as! String
                tran.name = transaction["name"] as! String
                self.bank.transactions.append(tran)
            }
            DispatchQueue.main.async {
                self.accountHistoryTableView.reloadData()
            }
        }
    }
    
    func handleError(error:Error, response: URLResponse) -> Void {
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode) //todo
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
