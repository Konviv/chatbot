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
   
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btnRadious = 20
        registerBtn.layer.cornerRadius = CGFloat(btnRadious)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self.view, action: #selector(UIView.endEditing(_:))))
        self.navigationItem.setHidesBackButton(true, animated: false)
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
    @IBAction func EndEditing(_ sender: Any) {
        animateViewMoving(up: true, moveValue: 150)
    }
    @IBAction func BeginEditing(_ sender: Any) {
        animateViewMoving(up: false, moveValue: 150)
    }
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.2
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    @IBAction func didTabOnRegister(_ sender: Any) {
        let name = nameTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let lastname = lastNameField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let email = emailTxtField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let password = passwordTxtField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        self.view.endEditing(true)
        if (name?.isEmpty)! {
            self.prensetAlert(msg: "The name is empy")
            return
        }
        
        if(lastname?.isEmpty)! {
            self.prensetAlert(msg: "The last name is empy")
            return
        }
        
        if(email?.isEmpty)! {
           self.prensetAlert(msg: "Invalid email")
           return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!) {(user, error)in
            
            if(user == nil){
                self.prensetAlert(msg: self.handleRegisterError(error: error as! NSError))
                return
            }
            let updateRequest = user?.profileChangeRequest()
            
            updateRequest?.displayName = name! + " " + lastname!
            updateRequest?.commitChanges { error in
                if let error = error {
                    // An error happened.
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignIn")
                    self.present(vc!, animated: true)

                }
            }
        }
    }
    
    func handleRegisterError(error:NSError) -> String {
        print(error)
        switch error.code {
        case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue:
            return "Invalid email"
        case FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue:
            return "That email is already in use"
        case FIRAuthErrorCode.errorCodeWeakPassword.rawValue:
            return"The password is weak"
        default:
            return "External error"
        }
    }
    
    func prensetAlert(msg:String) -> Void {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
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
