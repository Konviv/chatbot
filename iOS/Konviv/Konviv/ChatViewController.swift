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
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTxt: UITextView!
    @IBOutlet weak var typingLbl: UILabel!
    var context: AnyObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self.view, action: #selector(UIView.endEditing(_:))))
        self.navigationItem.setHidesBackButton(true, animated: false)
        messageTxt.layer.cornerRadius = 20
        messageTxt.textContainerInset = UIEdgeInsetsMake(5.0, 20.0, 5.0, 50.0)
        messageTxt.layer.backgroundColor = UIColor.white.cgColor
        messageTxt.layer.borderWidth = 0.5
        messageTxt.layer.borderColor = UIColor.lightGray.cgColor
        
        //chatTableView.rowHeight = UITableViewAutomaticDimension
        //chatTableView.estimatedRowHeight = 140
        
        /*let image = #imageLiteral(resourceName: "logo")
        let imageView = UIImageView(image: image)
        let bannerWidth = navigationController?.navigationBar.frame.width
        let bannerHeigth = navigationController?.navigationBar.frame.height
        let x = bannerWidth! / 2 - image.size.width / 2
        let y = bannerHeigth! / 2 - image.size.height / 2
        imageView.frame = CGRect(x: x, y: y, width: bannerWidth!-100, height: bannerHeigth!-100)
        navigationItem.titleView = imageView
        */
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        typingLbl.isHidden = true
        self.getAllMessages()
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
    
    func getAllMessages() -> Void {
        let endpoint = "http://192.168.1.11:8080/api/v1/chatbot/messages";
        let url = URL(string: endpoint)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        self.typingLbl.isHidden = false
        self.sendRequest(request: self.createHeaders(request: request), isAllMessages: true)
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
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string :messages[indexPath.row].message).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14)], context: nil)
        if(messages[indexPath.row].message == ""){
            cell.bubbleReceiveTextView.layer.isHidden = true
            cell.bubbleSendTextView.layer.isHidden = true
            return cell
        }
        
        tableView.rowHeight = estimatedFrame.height + 25
        cell.bubbleSendTextView.isEditable = false
        cell.bubbleReceiveTextView.isEditable = false
        
        if(messages[indexPath.row].sendByUser){
            print(messages[indexPath.row].message)
            cell.bubbleSendTextView.text = messages[indexPath.row].message
            cell.bubbleSendTextView.frame = CGRect(x: CGFloat(view.frame.width - estimatedFrame.width - 16-8-8), y: 0, width: estimatedFrame.width+16+8, height: estimatedFrame.height + 20);
            
            cell.bubbleSendTextView.layer.cornerRadius = 8
            cell.bubbleSendTextView.layer.masksToBounds = true
            cell.bubbleSendTextView.layer.isHidden = false
            cell.bubbleReceiveTextView.layer.isHidden = true
    
        }else{
            cell.bubbleReceiveTextView.text = messages[indexPath.row].message
            cell.bubbleReceiveTextView.frame = CGRect(x: CGFloat(48.0+8.0), y: 0, width: estimatedFrame.width + 16+8, height: estimatedFrame.height + 20);
            cell.bubbleReceiveTextView.layer.cornerRadius = 8
            cell.bubbleReceiveTextView.layer.masksToBounds = true
            cell.bubbleReceiveTextView.isHidden=false
            cell.bubbleSendTextView.layer.isHidden = true
            self.typingLbl.isHidden = true
        }
        
        return cell
    }
    
    
    @IBAction func tabOnSendBtn(_ sender: Any) {
        let text = self.messageTxt.text!
        if (!((text.isEmpty))){
            self.createMessage(messageText: text,isUser:true)
            //self.chatTableView.reloadData()
            self.sendMessage(text: text)
        }
    }
    
    func sendMessage(text: String) -> Void {
        let endpoint = "http://192.168.1.11:8080/api/v1/chatbot";
        let url = URL(string: endpoint)!
        let request = NSMutableURLRequest(url: url)
        let dic :[String:AnyObject] = ["message" : messageTxt.text as AnyObject, "context" : self.context!]// TODO
        let json = try? JSONSerialization.data(withJSONObject: dic)
        
        //self.chatTableView.scrollToRow(at: NSIndexPath(row: self.chatTableView.numberOfRows(inSection: 0) - 1, section: 0) as IndexPath, at: .bottom, animated: true)
        request.httpMethod = "POST"
        request.httpBody = json
        self.typingLbl.isHidden = false
        self.sendRequest(request: self.createHeaders(request: request),isAllMessages:false)
    }
    
    func startChat() -> Void {
        let endpoint = "http://192.168.1.11:8080/api/v1/chatbot/start";
        let url = URL(string: endpoint)!
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "POST"
        self.sendRequest(request: self.createHeaders(request:request),isAllMessages:false)
        
    }
    
    func createHeaders(request:NSMutableURLRequest) -> NSMutableURLRequest {
        let auth_token = UserDefaults.standard.string(forKey: "user_auth_token")
        request.addValue(auth_token!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func sendRequest(request :NSMutableURLRequest, isAllMessages:Bool) -> Void {
        self.typingLbl.isHidden = false
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print(error)
                self.handleError(error: error!, response: response!)
                return
            }
            
            self.response(response: response!, data: data!, isAllMessages:isAllMessages)
        }
        task.resume()
    }
    
    func response(response: URLResponse, data: Data, isAllMessages:Bool) -> Void {
        print(data)
        
        let jsonObject = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        if(isAllMessages){
            self.allMessages(arrOfMessages: jsonObject as! [String: Any])
            return
        }
        if let dictionary = jsonObject as? [String: Any] {
            self.context = dictionary["context"] as AnyObject? //TODO
            self.createMessage(messageText: dictionary["output"] as! String,isUser: false)
            self.reloadTable()
        }
    }
    
    func allMessages(arrOfMessages:[String: Any]) -> Void {
        let messages = arrOfMessages["messages"] as! [[String:Any]]
        print("--------M E S S A G E--------")
        print(messages)
        
        for msg in messages{
            self.createMessage(messageText: msg["message"] as! String, isUser: msg["sent_by_user"] as! Bool)
        }
        self.reloadTable()
    }
    
    func handleError(error:Error, response: URLResponse) -> Void {
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode) //todo
        }
    }
    
    func createMessage(messageText:String, isUser :Bool) -> Void {
        let message = Message()
        message.message = messageText
        message.sendByUser = isUser
        self.messages.append(message)
        
    }
    
    func reloadTable() -> Void {
        DispatchQueue.main.async(execute: {
            self.chatTableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                let numberOfSections = self.chatTableView.numberOfSections
                let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
                
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.chatTableView.scrollToRow(at: indexPath, at: .none, animated: false)
                }
            }
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
