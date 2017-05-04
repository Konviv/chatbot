//
//  DashboardViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 7/4/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit
import LinkKit
import Firebase
class DashboardViewController: UIViewController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //   NotificationCenter.defaultCenter.addObserver(self, selector: #selector(AddBankViewController.(_:)), name: "PLDPlaidLinkSetupFinished", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*-*-*-*-*-*-*-*-*TOKEN*-*-*-*-*-*-*-*-*")
        print(UserDefaults.standard.string(forKey: "user_auth_token"))

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTabOnAddBankAccount(_ sender: Any) {
        self.configuration()
    }
    
    func configuration() {
        let linkConfiguration = PLKConfiguration(key: "ebc098404b162edaadb2b8c6c45c8f", env: .sandbox, product: .auth)
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
            }
            else {
                NSLog("Unable to setup Plaid Link")
            }
        }
    }
    
    func presentPlaidLinkWithCustomConfiguration() {
        print("----LINKVIEWCONTROLLER-----")
        let linkConfiguration = PLKConfiguration(key: "ebc098404b162edaadb2b8c6c45c8f", env: .sandbox, product: .auth)
        linkConfiguration.clientName = "Link Demo"
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate)
        present(linkViewController, animated: true)
    }
    
    func handleSuccessWithToken(publicToken: String, metadata: [String : AnyObject]?) {
       //var data = try? JSONSerialization.jsonObject(with: metadata?["institution"], options: [])
        let inst  =  metadata?["institution"] as AnyObject
        let instName = self.getValue(anyVal: inst["name"] as Any)
        let id = self.getValue(anyVal: inst["type"] as Any)
        if (!(instName == "" && id == "")) {
            if (self.sendInfoAccount(token: publicToken,id: id, institution: instName)){
            
            }
            return
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
    
    func sendInfoAccount(token: String, id : String, institution: String ) -> Bool {
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
        let json = try? JSONSerialization.data(withJSONObject: dictionary)
        
        print("-----------------------------R E Q U E S T-------------------------------")
        let convertedString = String(data: json!, encoding: String.Encoding.utf8) // the data will be converted to the string
        NSLog(convertedString!)
        print(json as! NSData)
        let endpoint = "http://192.168.1.13:8080/api/v1/plaid/authenticate";
        let url = URL(string: endpoint)!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = json
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
            self.handleResponse(respose: response!)
            let res = String(data: data!, encoding: String.Encoding.utf8) // the data will be converted to the string
            NSLog(res!)
            print("response = \(data!  as! NSData)")
            
            }
        task.resume()
        
        return false
    }
    
    func handleResponse(respose: URLResponse) -> Void {
        let res = respose as? HTTPURLResponse
        let status = res?.statusCode
        
        if (status! >= 200 && status! < 300) {
            
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
    @IBAction func didTabOnLogout(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Landingscreen")
        UserDefaults.standard.set("", forKey: "user_auth_token")
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

extension DashboardViewController : PLKPlaidLinkViewDelegate{
   
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
