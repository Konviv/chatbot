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
    static let HISTORY_BANK_ACCOUNT = "account_history/"
    static let REGISTER_BANK = "plaid/authenticate"
    static let LAST_TRANSACTION = "last_transaction"
}
