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
        signInBtn?.layer.cornerRadius = CGFloat(btnRadious)
        self.navigationItem.setHidesBackButton(true, animated: false)

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
    @IBAction func didTabOnSigIn(_ sender: Any) {
        let email = emailTxtField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let password  = passwordTxtField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        self.view.endEditing(true)
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
            if (error != nil){
                self.prensetAler(msg: self.handleError(error: error as! NSError))
                return;
            }
            user?.getTokenForcingRefresh(true) {idToken, err in
                
                UserDefaults.standard.setValue(idToken, forKey: "user_auth_token")
                UserDefaults.standard.setValue("", forKey: "context")
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardNavController")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = vc
                
            }
        }

    }
    
    func handleError(error:NSError) -> String{
        switch error.code {
        case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue:
            return "Invalid email"
        case FIRAuthErrorCode.errorCodeInvalidCredential.rawValue:
            return "Invalid credentials"
        case FIRAuthErrorCode.errorCodeOperationNotAllowed.rawValue:
            return "Operation not allowed"
        case FIRAuthErrorCode.errorCodeInvalidCredential.rawValue:
            return "Invalid credentials"
        case FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue:
            return "The email is already in use"
        case FIRAuthErrorCode.errorCodeUserDisabled.rawValue:
            return "User account disabled"
        case FIRAuthErrorCode.errorCodeWrongPassword.rawValue:
            return "Invalid password"
        case FIRAuthErrorCode.errorCodeUserNotFound.rawValue:
            return "User account no founded"
        case 17011:
            return "There is no user record corresponding to those credentials"
        default:
            return "External error"
        }
    }
    
    func prensetAler(msg:String) -> Void {
        
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert,animated: true, completion: nil)
    }
    
    @IBAction func didTabOnResetPassword(_ sender: Any) {
        let alertPrompt = UIAlertController(title: "Reset password", message: "Enter your email.", preferredStyle: UIAlertControllerStyle.alert)
        alertPrompt.addTextField { (emailToResetPass:UITextField) in
            emailToResetPass.placeholder = "example@domain.com"
        }
        let restablishBtn = UIAlertAction(title: "Restablish", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            self.sendEmail(email: (alertPrompt.textFields?.first?.text)!)
        }
        let cancelBtn = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in }
        alertPrompt.addAction(restablishBtn)
        alertPrompt.addAction(cancelBtn)
        self.present(alertPrompt,animated:true,completion:nil)
    }
    
    func sendEmail(email:String) -> Void {
        if(email.isEmpty){
            self.prensetAler(msg: "You didn't type an email address")
            return
        }
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.prensetAler(msg: self.handleError(error: error as NSError))
                return
            }
            let alert = UIAlertController(title: "Success", message: "Check your email.", preferredStyle: UIAlertControllerStyle.alert)
            let actionOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){ (action:UIAlertAction) in }
            alert.addAction(actionOk)
            self.present(alert, animated: true, completion: nil)
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
