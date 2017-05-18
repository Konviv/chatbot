//
//  SignOut.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 12/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import Foundation
import Firebase
class AuthUserActions: NSObject {
    func signOut() -> Void {
        UserDefaults.standard.set("", forKey: "user_auth_token")
        UserDefaults.standard.set(false, forKey: "hasAccounts")
        UserDefaults.standard.setValue("", forKey: "context")
        try!FIRAuth.auth()?.signOut()
    }
}
