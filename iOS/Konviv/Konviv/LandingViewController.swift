//
//  LandingViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 24/4/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    @IBOutlet weak var signInTab1: UIButton?
    @IBOutlet weak var registerTab1: UIButton?
    @IBOutlet weak var signInTab2: UIButton?
    @IBOutlet weak var registerTab2: UIButton?
    @IBOutlet weak var signInTab3: UIButton?
    @IBOutlet weak var registerTab3: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        let btnRadious = 20
        let btnBackgroundColor = UIColor(white:1, alpha:0.2)
        
        signInTab1?.layer.cornerRadius = CGFloat(btnRadious)
        signInTab2?.layer.cornerRadius = CGFloat(btnRadious)
        signInTab3?.layer.cornerRadius = CGFloat(btnRadious)
        
        registerTab1?.layer.cornerRadius = CGFloat(btnRadious)
        registerTab2?.layer.cornerRadius = CGFloat(btnRadious)
        registerTab3?.layer.cornerRadius = CGFloat(btnRadious)
        
        signInTab1?.backgroundColor = btnBackgroundColor
        signInTab2?.backgroundColor = btnBackgroundColor
        signInTab3?.backgroundColor = btnBackgroundColor
        
        registerTab1?.backgroundColor = btnBackgroundColor
        registerTab2?.backgroundColor = btnBackgroundColor
        registerTab3?.backgroundColor = btnBackgroundColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
