//
//  Request.swift
//  mixmax
//
//  Created by Apple on 4/30/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

protocol Request {
    
    var url: String { get set }
    var method: Method { get set }
    var path: String { get set}
    
    var request: URLRequest? { get set }
    
}

enum Method : String {
    
    case get = "GET"
    case post = "POST"
}

extension Request {
    
    var request: URLRequest? {
        
        let url = URL(string: self.url)
        var request = URLRequest(url: url!)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}
