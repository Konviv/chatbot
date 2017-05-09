//
//  ChatViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 7/4/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit
import Messages

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var messages : [Message] = []
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self.view, action: #selector(UIView.endEditing(_:))))
        self.navigationItem.setHidesBackButton(true, animated: false)        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        
        // Fetch Quote
        //let quote = quotes[indexPath.row]
        
        // Configure Cell
        
        cell.chatMessageBox?.text = messages[indexPath.row].message
        print( messages[indexPath.row].message)
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = "test"
        layout.subcaption = "test2"
        
        message.layout = layout
      //  cell.chatMessageBox.numberOfLines = 2
        
        //cell.chatMessageBox.sizeToFit()
        return cell
    }
    
    @IBAction func tabOnSendBtn(_ sender: Any) {
        let text = self.messageTxt.text
        //if (!(text != nil)){
            let message = Message()
            message.sendByUser = true
            message.message = text!
            self.messages.append(message)
            self.chatTableView.reloadData()
        //}
    }
    
    func startChat() -> Void {
        let endpoint = "http://192.168.1.8:8080/api/v1/chatbot/start";
        let url = URL(string: endpoint)!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "POST"
        let auth_token = UserDefaults.standard.string(forKey: "user_auth_token")
        request.addValue(auth_token!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil
            {
                print("error=\(error)")
                return
            }
            print("response = \(response!)")
            let res = String(data: data!, encoding: String.Encoding.utf8)
            print(res!)
            
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
