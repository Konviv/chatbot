//
//  UserAccountsViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 4/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class UserAccountsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserBankAccounts()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getUserBankAccounts() -> Void {
        let endpoint = "http://192.168.1.13:8080/api/v1/plaid/accounts";
        let url = URL(string: endpoint)!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "GET"
        let auth_token = UserDefaults.standard.string(forKey: "user_auth_token")
        request.addValue(auth_token!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print(request.allHTTPHeaderFields)
        let task = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            print("")
            print("····················································R E S P O N S E ·······················································")
            print("")
            if error != nil
            {
                print("error=\(error)")
                return
            }
            print("response = \(response!)")
            //self.handleResponse(respose: response!)
            let res = String(data: data!, encoding: String.Encoding.utf8) // the data will be converted to the string
            NSLog(res!)
            print("response = \(data!  as! NSData)")
            
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
