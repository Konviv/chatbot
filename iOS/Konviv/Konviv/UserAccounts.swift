//
//  UserAccounts.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 8/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import Foundation
class Bank: NSObject {
    var name:String = ""
    var accounts:[Account] = []
    var transactions: [Transaction] = []
}
class Account: NSObject{
    var id:String = ""
    var name:String = ""
    var balances:[String:Any] = [:]
}
