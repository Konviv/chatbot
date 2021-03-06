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
    
    var messages : [Message] = []
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var messageTxt: UITextView!
    var context: AnyObject? = nil
    var isHelp:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.estimatedRowHeight = 200.0
        chatTableView.rowHeight = UITableViewAutomaticDimension
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self.view, action: #selector(UIView.endEditing(_:))))
        self.navigationItem.setHidesBackButton(true, animated: false)
        messageTxt.layer.cornerRadius = 20
        messageTxt.textContainerInset = UIEdgeInsetsMake(12.0, 20.0, 5.0, 50.0)
        messageTxt.layer.backgroundColor = UIColor.white.cgColor
        messageTxt.layer.borderWidth = 0.5
        messageTxt.layer.borderColor = UIColor.lightGray.cgColor
        messageTxt.delegate = self
        let m1 = Message()
        m1.message = ""
        messages.append(m1)
        messages.append(m1)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
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
        animateViewMoving(up: true, moveValue: 170)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(up: false, moveValue: 170)
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
        if(messages[indexPath.row].message != ""){
            tableView.rowHeight = 100
        }
        if(indexPath.row == 0 || indexPath.row == 1){
            cell.btnLinkAccount.isHidden = true
            cell.bubbleReceiveTextView.layer.isHidden = true
            cell.bubbleSendTextView.layer.isHidden = true
            cell.iconChat.isHidden = true
            tableView.rowHeight = 50
            cell.bubbleReceiveTextView.text = messages[indexPath.row].message
            cell.bubbleReceiveTextView.frame = CGRect(x: CGFloat(40.0), y: 0, width: estimatedFrame.width + 30+10, height: estimatedFrame.height + 20);
            return cell
        }
        
        tableView.rowHeight = estimatedFrame.height + 25
        cell.bubbleSendTextView.isEditable = false
        cell.bubbleReceiveTextView.isEditable = false
        cell.bubbleSendTextView.textContainerInset.left = 6
        cell.bubbleSendTextView.textContainerInset.right = 6
        cell.bubbleReceiveTextView.textContainerInset.left = 9
        
        if(messages[indexPath.row].sendByUser){
            cell.bubbleSendTextView.text = messages[indexPath.row].message
           cell.bubbleSendTextView.frame = CGRect(x: CGFloat(view.frame.width - estimatedFrame.width - 16-18-8), y: 0, width: estimatedFrame.width+30+10, height: estimatedFrame.height + 20);
            
            cell.bubbleSendTextView.layer.cornerRadius = 8
            cell.bubbleSendTextView.layer.masksToBounds = true
            cell.bubbleSendTextView.layer.isHidden = false
            cell.bubbleReceiveTextView.layer.isHidden = true
            cell.iconChat.layer.isHidden = true
        }else{
            cell.bubbleReceiveTextView.text = messages[indexPath.row].message
            cell.bubbleReceiveTextView.frame = CGRect(x: CGFloat(40.0), y: 0, width: estimatedFrame.width + 30+10, height: estimatedFrame.height + 20);
            
            cell.iconChat.layer.isHidden = false
            cell.bubbleReceiveTextView.layer.cornerRadius = 8
            cell.bubbleReceiveTextView.layer.masksToBounds = true
            cell.bubbleReceiveTextView.isHidden=false
            cell.bubbleSendTextView.layer.isHidden = true
            cell.btnLinkAccount.isHidden = true
            
            if("link-dashboard" == messages[indexPath.row].message){
                cell.btnLinkAccount.isHidden = false
                cell.bubbleReceiveTextView.isHidden = true
                cell.btnLinkAccount.frame = CGRect(x: CGFloat(40.0), y: 0, width: estimatedFrame.width + 16+8, height: estimatedFrame.height + 20);
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
                self.isHelp = true
                text = "could you"
            }
            text = self.compareTextByAValidQuestion(text: text)
            self.createMessage(messageText: text ,isUser:true)
            self.reloadTable()
            self.sendMessage(text: text)
            self.messageTxt.text = ""
        }
    }
    
    func compareTextByAValidQuestion(text:String) -> String {
        var arrQuestions = UserDefaults.standard.string(forKey:"questions")?.components(separatedBy: "\n")
        
        if(arrQuestions != nil){
            arrQuestions?.removeFirst()
            for (i,question) in (arrQuestions?.enumerated())! {
                if(String(i+1)==text){
                    let startIndex = question.index(question.startIndex, offsetBy: 2)
                    self.messageTxt.text = text.trimmingCharacters(in: NSCharacterSet.whitespaces)
                    return question.substring(from: startIndex)
                }
            }
        }
        return text
    }
    
    func buttonTabed() -> Void {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardNavController")
        self.present(vc!, animated: true, completion: nil)

    }
    func sendMessage(text: String) -> Void {
        let request = Request().createRequest(endPoint:Constants.CHAT_SEND_MESSAGE, method: "POST")
        let dic :[String:AnyObject] = ["message" : text as AnyObject, "context" : UserDefaults.standard.object(forKey: "context") as AnyObject]
        let json = try? JSONSerialization.data(withJSONObject: dic)
        request.httpBody = json
        self.sendRequest(request: request,isAllMessages:false)
    }
    
    func getAllMessages() -> Void {
        self.sendRequest(request: Request().createRequest(endPoint: Constants.CHAT_ALL_MESSAGES, method: "GET"), isAllMessages: true)
    }
    
    func startChat() -> Void {
        self.sendRequest(request: Request().createRequest(endPoint: Constants.CHAT_START, method: "POST"),isAllMessages:false)
        
    }
    
    func sendRequest(request :NSMutableURLRequest, isAllMessages:Bool) -> Void {
        if(!Request().IsInternetConnection()){
            self.presentAlert()
            return
        }
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print(error)
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                }
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
                let messageResponse = (dictionary["output"] as! String).replacingOccurrences(of: "\\n", with: "\n" )
                self.createMessage(messageText: messageResponse,isUser: false)
                self.reloadTable()
                if(self.isHelp){
                    let pos =  messageResponse.index(messageResponse.startIndex, offsetBy: ((messageResponse.components(separatedBy: "\n").first)?.characters.count)! )
                    UserDefaults.standard.set(messageResponse.substring(from: pos), forKey: "questions")
                    self.isHelp = false
                }
                if(UserDefaults.standard.string(forKey: "context") == ""){
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1600))  {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1600))  {
                            self.createMessage(messageText: Constants.CHAT_WELCOME, isUser: false)
                            self.reloadTable()
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1600))  {
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1600))  {
                                    self.createMessage(messageText: "link-dashboard", isUser: false)
                                    self.reloadTable()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000))  {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000))  {
                                            self.createMessage(messageText: Constants.SELECT_NUMBER, isUser: false)
                                            UserDefaults.standard.setValue(self.context, forKey: "context")
                                            self.reloadTable()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5000))  {
                                                self.isHelp = true
                                                self.sendMessage(text: "could you")
                                                
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    return
                }
                UserDefaults.standard.setValue(self.context, forKey: "context")
                self.reloadTable()
            }//
        }
        
    }
    
    func allMessages(arrOfMessages:[String: Any]) -> Void {
        let messages = arrOfMessages["messages"] as! [[String:Any]]
        if(messages.count == 0){
            self.startChat()
            return
        }
        for msg in messages{
            self.createMessage(messageText: (msg["message"] as! String).replacingOccurrences(of: "\\n", with: "\n" ), isUser: msg["sent_by_user"] as! Bool)
        }
        self.reloadTable()
    }
    
    func handleError(error: Error?, response: URLResponse?) -> Void {
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
        }
    }
    
    func createMessage(messageText:String, isUser :Bool) -> Void {
        let message = Message()
        message.message = messageText == "could you" ? "Help" : messageText
        message.sendByUser = isUser
        self.messages.append(message)
        
    }
    
    func reloadTable() -> Void {

        DispatchQueue.main.async(execute: {
            self.chatTableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                
                let numberOfSections = self.chatTableView.numberOfSections
                let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
                
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.chatTableView.scrollToRow(at: indexPath, at: .none, animated: false)

                }
            }
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
