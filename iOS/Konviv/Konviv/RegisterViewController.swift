//
//  RegisterViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 7/4/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit
import Firebase
class RegisterViewController: UIViewController {
   
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = false;
        self.navigationController?.title = "Register"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func didTabOnRegister(_ sender: Any) {
        let email = emailTxtField.text
        let password = passwordTxtField.text
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!) {(user, error)in
            print(user)
            print(error)
            if(user == nil){
                let alert = UIAlertController(title: "Error", message: "", preferredStyle: .actionSheet)
                let okAction = UIAlertAction(title: "OK", style: .default) { action in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                self.present(alert,animated: true)
                return
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignIn")
            self.present(vc!, animated: true)

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
