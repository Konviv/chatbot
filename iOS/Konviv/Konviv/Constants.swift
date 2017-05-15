//
//  Constants.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 12/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import Foundation
struct Constants {
    static let BASE_URL = "http://192.168.1.117:8080/api/v1/"
    static let PLAID_KEY = "ebc098404b162edaadb2b8c6c45c8f"
    static let CHAT_START = "chatbot/start"
    static let CHAT_SEND_MESSAGE = "chatbot/"
    static let CHAT_ALL_MESSAGES = "chatbot/messages"
    static let BANK_ACCOUNTS = "plaid/accounts"
    static let HISTORY_BANK_ACCOUNT = "plaid/account_history/"
    static let REGISTER_BANK = "plaid/authenticate"
    static let LAST_TRANSACTION = "plaid/last_transaction"
    static let POSIBLE_QUESTIONS = "1. How much do I have in my checking account?could\n2. Can you give me a full summary of my accounts? \n3. How much did I spend on coffee this month? \n4. Can I get a total of all accounts? \n5. Can I get a total of all accounts? \n6. What was my most expensive bill? \n7. How much do I have in my savings account? \n8. What is my average spending amount? \n9. What were my last five transactions? \n10. How much did I spend today?"
    static let CHAT_WELCOME = "Wahoooo!!\nSo, what’s next? For you to put your ninja skills into use we first have to link Konviv to your banking info. You can do that here."
    static let SELECT_NUMBER = "Then you can select a number with question or you can type the question\n if you don't remeber any question you can type help"
}
