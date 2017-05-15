//
//  ToolsViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 7/4/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class ToolsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTabOnScore(_ sender: Any) {
        let alertPrompt = UIAlertController(title: "Score", message: "760", preferredStyle: UIAlertControllerStyle.alert)
        let btn = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in }
        alertPrompt.addAction(btn)
        //alertPrompt.addAction(btn)
        self.present(alertPrompt,animated:true,completion:nil)
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
