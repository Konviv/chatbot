//
//  ChatViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 7/4/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit
import Messages

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextViewDelegate {
    
    var messages : [Message] = [Message()]
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTxt: UITextView!
    var context: AnyObject? = nil
    
    @IBOutlet weak var typingImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.estimatedRowHeight = 200.0 //(your estimated row height)
        chatTableView.rowHeight = UITableViewAutomaticDimension
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self.view, action: #selector(UIView.endEditing(_:))))
        self.navigationItem.setHidesBackButton(true, animated: false)
        messageTxt.layer.cornerRadius = 20
        messageTxt.textContainerInset = UIEdgeInsetsMake(5.0, 20.0, 5.0, 50.0)
        messageTxt.layer.backgroundColor = UIColor.white.cgColor
        messageTxt.layer.borderWidth = 0.5
        messageTxt.layer.borderColor = UIColor.lightGray.cgColor
        messageTxt.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.typingImg.isHidden = true
        if(UserDefaults.standard.string(forKey: "context") == ""){
            self.startChat()
            return
        }
        self.getAllMessages()
        
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        animateViewMoving(up: true, moveValue: 150)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
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
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string :messages[indexPath.row].message).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14)], context: nil)
        cell.btnLinkAccount.isHidden = true

        if(messages[indexPath.row].message == ""){
            cell.btnLinkAccount.isHidden = true
            cell.bubbleReceiveTextView.layer.isHidden = true
            cell.bubbleSendTextView.layer.isHidden = true
            cell.bubbleReceiveTextView.frame = CGRect(x: CGFloat(48.0+8.0), y: 0, width: estimatedFrame.width + 16+8, height: estimatedFrame.height-10);
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
            cell.iconChat.layer.isHidden = true
        }else{
            cell.bubbleReceiveTextView.text = messages[indexPath.row].message
            cell.bubbleReceiveTextView.frame = CGRect(x: CGFloat(48.0+8.0), y: 0, width: estimatedFrame.width + 16+8, height: estimatedFrame.height + 20);
            
            cell.iconChat.layer.isHidden = false
            cell.bubbleReceiveTextView.layer.cornerRadius = 8
            cell.bubbleReceiveTextView.layer.masksToBounds = true
            cell.bubbleReceiveTextView.isHidden=false
            cell.bubbleSendTextView.layer.isHidden = true
            cell.btnLinkAccount.isHidden = true
            
            if("link-dashboard" == messages[indexPath.row].message){
                cell.btnLinkAccount.isHidden = false
                cell.bubbleReceiveTextView.isHidden = true
                cell.btnLinkAccount.frame = CGRect(x: CGFloat(48.0+8.0), y: 0, width: estimatedFrame.width + 16+8, height: estimatedFrame.height + 20);
                cell.btnLinkAccount.layer.cornerRadius = 8
                cell.btnLinkAccount.layer.masksToBounds = true
                cell.btnLinkAccount.addTarget(self, action:#selector(self.buttonTabed), for: .touchUpInside)
            }
        }
        
        return cell
    }
    
    
    @IBAction func tabOnSendBtn(_ sender: Any) {
        var text = self.messageTxt.text!
        if (!((text.isEmpty))){
            if(text.uppercased()=="HELP"){
                self.createMessage(messageText: Constants.POSIBLE_QUESTIONS,isUser:false)
                self.reloadTable()
                self.messageTxt.text = ""
                return
            }
            let arrQuestions = Constants.POSIBLE_QUESTIONS.components(separatedBy: "\n")
            for (i,question) in arrQuestions.enumerated() {
                if(String(i+1)==text){
                    let startIndex = question.index(question.startIndex, offsetBy: 2)
                    text = question.substring(from: startIndex)
                    self.messageTxt.text = text.trimmingCharacters(in: NSCharacterSet.whitespaces)
                    break
                }
            }
            text = self.messageTxt.text.trimmingCharacters(in: .newlines)
            self.createMessage(messageText: text,isUser:true)
            self.reloadTable()
            self.sendMessage(text: text)
            self.messageTxt.text = ""
        }
    }
    func buttonTabed() -> Void {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardNavController")
        self.present(vc!, animated: true, completion: nil)

    }
    func sendMessage(text: String) -> Void {
        let request = Request().createRequest(endPoint:Constants.CHAT_SEND_MESSAGE, method: "POST")
        let dic :[String:AnyObject] = ["message" : messageTxt.text as AnyObject, "context" : UserDefaults.standard.object(forKey: "context") as AnyObject]
        let json = try? JSONSerialization.data(withJSONObject: dic)
        request.httpBody = json
        self.typingImg.isHidden = false
        self.sendRequest(request: request,isAllMessages:false)
    }
    
    func getAllMessages() -> Void {
        self.typingImg.isHidden = false
        self.sendRequest(request: Request().createRequest(endPoint: Constants.CHAT_ALL_MESSAGES, method: "GET"), isAllMessages: true)
    }
    
    func startChat() -> Void {
        self.typingImg.isHidden = false
        self.sendRequest(request: Request().createRequest(endPoint: Constants.CHAT_START, method: "POST"),isAllMessages:false)
        
    }
    
    func sendRequest(request :NSMutableURLRequest, isAllMessages:Bool) -> Void {
        if(!Request().IsInternetConnection()){
            self.presentAlert()
            return
        }
        self.typingImg.isHidden = false
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print(error)
                self.handleError(error: error, response: response!)
                return
            }
            
            self.response(response: response!, data: data!, isAllMessages:isAllMessages)
        }
        task.resume()
    }
    
    func response(response: URLResponse, data: Data, isAllMessages:Bool) -> Void {
        let res = response as? HTTPURLResponse
        if(res?.statusCode == 200){
            let jsonObject = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if(isAllMessages){
                self.allMessages(arrOfMessages: jsonObject as! [String: Any])
                return
            }
            if let dictionary = jsonObject as? [String: Any] {
                self.context = dictionary["context"] as AnyObject?
                self.createMessage(messageText: dictionary["output"] as! String,isUser: false)
                //var d = dictionary["output"]as! String
                //print(d.stringByReplacingOccurrencesOfString("\\", withString: "\\\\", options: .LiteralSearch, range: nil))
                
                if(UserDefaults.standard.string(forKey: "context") == ""){
                    self.createMessage(messageText: Constants.CHAT_WELCOME, isUser: false)
                    self.createMessage(messageText: "link-dashboard", isUser: false)
                    self.createMessage(messageText: Constants.SELECT_NUMBER, isUser: false)
                    self.createMessage(messageText: Constants.POSIBLE_QUESTIONS, isUser: false)
                }
                UserDefaults.standard.setValue(self.context, forKey: "context")
                self.reloadTable()
            }
        }
        
    }
    
    func allMessages(arrOfMessages:[String: Any]) -> Void {
        let messages = arrOfMessages["messages"] as! [[String:Any]]
        if(messages.count == 0){
            self.startChat()
            return
        }
        for msg in messages{
            self.createMessage(messageText: msg["message"] as! String, isUser: msg["sent_by_user"] as! Bool)
        }
        self.reloadTable()
    }
    
    func handleError(error: Error?, response: URLResponse?) -> Void {
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
            self.typingImg.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2)) {
                
                let numberOfSections = self.chatTableView.numberOfSections
                let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
                
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.chatTableView.scrollToRow(at: indexPath, at: .none, animated: false)
                }
            }
            /*DispatchQueue.main.async {
              self.typingImg.isHidden = true
                let numberOfSections = self.chatTableView.numberOfSections
                let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
                let size:CGSize  = self.chatTableView.contentSize
                print(size.height)
                
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    var myRect: CGRect = self.chatTableView.rectForRow(at: indexPath)
                    var point: CGPoint = self.chatTableView.contentOffset
                    point.y += myRect.origin.y
                    self.chatTableView.setContentOffset(point, animated: false)
                    //self.chatTableView.scrollToRow(at: indexPath, at: .none, animated: false)
                }
            }*/
            
        })
        
    }
    func presentAlert() -> Void {
        let alert = UIAlertController(title: "Error", message: "No internet connection", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert,animated: true, completion: nil)
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
