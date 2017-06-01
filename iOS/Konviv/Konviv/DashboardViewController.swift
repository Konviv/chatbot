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
    
    @IBOutlet weak var addBankAccountBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btnRadious = 20
        addBankAccountBtn?.layer.cornerRadius = CGFloat(btnRadious)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTabOnAddBankAccount(_ sender: Any) {
        print("entro")
        self.configuration()
    }
    
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
        
        if(Request().IsInternetConnection()){
            self.sendRequest(request: request)
            return
        }
        
        let alert = UIAlertController(title: "Error", message: "No internet connection", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert,animated: true, completion: nil)
    }
    func sendRequest(request:NSMutableURLRequest) -> Void {
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
            UserDefaults.standard.setValue(true, forKey: "hasAccounts")
            print(UserDefaults.standard.bool(forKey: "hasAccounts"))
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardNavController")
            self.present(vc!, animated: true, completion: nil)

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
