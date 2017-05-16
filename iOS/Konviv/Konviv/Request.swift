//
//  Request.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 12/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import Foundation
class Request: NSObject {
    let BASE_URL = Constants.BASE_URL
    
    func createHeaders(request:NSMutableURLRequest) -> NSMutableURLRequest {
        let auth_token = UserDefaults.standard.string(forKey: "user_auth_token")
        request.addValue(auth_token!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Accept-Language", forHTTPHeaderField: "es-ES")
        
        return request
    }
    
    func createRequest(endPoint:String, method:String) -> NSMutableURLRequest {
        let endPoint = "\(BASE_URL)\(endPoint)"
        let url = URL(string: endPoint)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        return self.createHeaders(request: request)
    }
    
    func IsInternetConnection() -> Bool {
        return currentReachabilityStatus == .reachableViaWiFi || currentReachabilityStatus == .reachableViaWiFi ? true : false
    }
    
}
