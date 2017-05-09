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
    
    var messages : [Message] = [Message()]
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    var context: AnyObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self.view, action: #selector(UIView.endEditing(_:))))
        self.navigationItem.setHidesBackButton(true, animated: false)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.startChat()
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
        // Configure Cell
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string :messages[indexPath.row].message).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 18)], context: nil)
        if(messages[indexPath.row].message == ""){
            cell.bubbleReceiveTextView.layer.isHidden = true
            cell.bubbleSendTextView.layer.isHidden = true
            return cell
        }
        tableView.rowHeight = estimatedFrame.height + 15
        if(messages[indexPath.row].sendByUser){
    
            cell.bubbleSendTextView.text = messages[indexPath.row].message
            cell.bubbleSendTextView.frame = CGRect(x: CGFloat(view.frame.width - estimatedFrame.width - 50), y: 0, width: estimatedFrame.width + 10, height:estimatedFrame.height + 10);
            cell.bubbleSendTextView.layer.cornerRadius = 8
            cell.bubbleSendTextView.layer.masksToBounds = true
            cell.bubbleSendTextView.layer.isHidden = false
            cell.bubbleReceiveTextView.layer.isHidden = true
    
        }else{
            cell.bubbleReceiveTextView.text = messages[indexPath.row].message
            cell.bubbleReceiveTextView.frame = CGRect(x: CGFloat(48.0 + 8.0), y: 0, width: estimatedFrame.width + 10, height: estimatedFrame.height + 10);
            cell.bubbleReceiveTextView.layer.cornerRadius = 8
            cell.bubbleReceiveTextView.layer.masksToBounds = true
            cell.bubbleReceiveTextView.isHidden=false
            cell.bubbleSendTextView.layer.isHidden = true
        }
        
        //self.chatTableView.scrollToRow(at: NSIndexPath(row: messages.count-1, section: 0) as IndexPath, at: .bottom, animated: true)
        
        return cell
    }
    
    
    @IBAction func tabOnSendBtn(_ sender: Any) {
        let text = self.messageTxt.text
        if (!((text?.isEmpty)!)){
            let message = Message()
            message.sendByUser = true
            message.message = text!
            messages.append(message)
            self.sendMessage(text: text!)
        }
    }
    
    func sendMessage(text: String) -> Void {
        let endpoint = "http://192.168.1.9:8080/api/v1/chatbot";
        let url = URL(string: endpoint)!
        let request = NSMutableURLRequest(url: url)
        let dic :[String:AnyObject] = ["message" : messageTxt.text as AnyObject, "context" : self.context!]// TODO
        let json = try? JSONSerialization.data(withJSONObject: dic)
        //let convertedString = String(data: json!, encoding: String.Encoding.utf8) // the data will be converted to the string
        //NSLog(convertedString!)
        //print(json as! NSData)
        
        request.httpMethod = "POST"
        request.httpBody = json
        self.sendRequest(request: self.createHeaders(request: request))
    }
    
    func startChat() -> Void {
        let endpoint = "http://192.168.1.9:8080/api/v1/chatbot/start";
        let url = URL(string: endpoint)!
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "POST"
        self.sendRequest(request: self.createHeaders(request:request))
    }
    
    func createHeaders(request:NSMutableURLRequest) -> NSMutableURLRequest {
        let auth_token = UserDefaults.standard.string(forKey: "user_auth_token")
        request.addValue(auth_token!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func sendRequest(request :NSMutableURLRequest) -> Void {
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil
            {
                self.handleError(error: error!, response: response!)
                return
            }
            self.response(response: response!, data: data!)
        }
        task.resume()
    }
    
    func response(response: URLResponse, data: Data) -> Void {
        print("response = \(response)")
        let res = String(data: data, encoding: String.Encoding.utf8)
        print(res!)
        
        let jsonObject = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        if let dictionary = jsonObject as? [String: Any] {
            print(dictionary["context"])
            self.context = dictionary["context"] as AnyObject? //TODO
            self.createMessage(dictionary: dictionary)
        }
    }
    
    func handleError(error:Error, response: URLResponse) -> Void {
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
        }
    }
    
    func createMessage(dictionary:[String:Any]) -> Void {
        let message = Message()
        message.message = dictionary["output"] as! String
        message.sendByUser = false
        self.messages.append(message)
        
        DispatchQueue.main.async(execute: {
            self.chatTableView.reloadData()
        })
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
