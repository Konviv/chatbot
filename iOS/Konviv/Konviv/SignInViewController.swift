//
//  SignInViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 7/4/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        let btnRadious = 20
        //let btnBackgroundColor = UIColor(red: 36.0, green: 41.0, blue: 36.0, alpha: 1)

        signInBtn?.layer.cornerRadius = CGFloat(btnRadious)
        
        //signInBtn?.backgroundColor = btnBackgroundColor
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.title? = "Sign In"

    }
   
    @IBAction func didTabOnSigIn(_ sender: Any) {
        let email = emailTxtField.text
        let password  = passwordTxtField.text
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
            /*print("-----RESPONSE----")
            print(error)
            print(user)
            print("-------END SIGNIN-------")*/
            if (user == nil){
                self.responseUser();
                return;
            }
            user?.getTokenForcingRefresh(true) {idToken, err in
                //print("---TOKEN---")
                //print(err)
                
                UserDefaults.standard.setValue(idToken, forKey: "user_auth_token")
                //print(UserDefaults.standard.string(forKey: "user_auth_token"))
                //print(user?.email)
                //print("---END TOKEN---")
                
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Dashboard")
                self.present(vc!, animated: true)
            }
        }

    }
    
    func responseUser() {
        let alert = UIAlertController(title: "Error", message: "Invalid Credentials", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert,animated: true)
        print("INVALID CREDENDTIALS")
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
