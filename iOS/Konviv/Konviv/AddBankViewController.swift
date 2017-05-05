//
//  AddBankViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 27/4/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit
import LinkKit

class AddBankViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet var buttonContainerView: UIView!
    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
     //   NotificationCenter.defaultCenter.addObserver(self, selector: #selector(AddBankViewController.(_:)), name: "PLDPlaidLinkSetupFinished", object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*button.isEnabled = false
        let linkKitBundle  = Bundle(for: PLKPlaidLinkViewController.self)
        let linkKitVersion = linkKitBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let linkKitBuild   = linkKitBundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String)!
        let linkKitName    = linkKitBundle.object(forInfoDictionaryKey: kCFBundleNameKey as String)!
        label.text         = "Swift 2 — \(linkKitName): \(linkKitVersion)+\(linkKitBuild)"
        
        let shadowColor    = UIColor(colorLiteralRed: 3/255.0, green: 49/255.0, blue: 86/255.0, alpha: 0.1)
        buttonContainerView.layer.shadowColor   = shadowColor.cgColor
        buttonContainerView.layer.shadowOffset  = CGSize(width: 0, height: -1)
        buttonContainerView.layer.shadowRadius  = 2
        buttonContainerView.layer.shadowOpacity = 1*/
        self.configuration()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configuration() {
        let linkConfiguration = PLKConfiguration(key: "ebc098404b162edaadb2b8c6c45c8f", env: .development, product: .auth)
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
       /* print("----LINKVIEWCONTROLLER-----")
        let linkConfiguration = PLKConfiguration(key: "ebc098404b162edaadb2b8c6c45c8f", env: .sandbox, product: .auth)
        linkConfiguration.clientName = "Link Demo"
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate)
        
        
        print(linkViewController)
        present(linkViewController, animated: true)    */}
    
    func handleSuccessWithToken(publicToken: String, metadata: [String : AnyObject]?) {
        print("Success token : \(publicToken)\nmetadata: \(metadata)")
    }
    
    func handleError(error: NSError, metadata: [String : AnyObject]?) {
        print("Failure error : \(error.localizedDescription)\nmetadata: \(metadata)")
    }
    
    func handleExitWithMetadata(metadata: [String : AnyObject]?) {
        print("Exit metadata: \(metadata)")
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
    
/*extension AddBankViewController : PLKPlaidLinkViewDelegate{
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
}*/


