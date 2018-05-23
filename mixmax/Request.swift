//
//  Request.swift
//  mixmax
//
//  Created by Apple on 4/30/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation


enum Method : String {
    
    case get = "GET"
    case post = "POST"
}

struct Request {
    
    var request: URLRequest
    
    init(url: String, method: Method, token: String?) {
        
        let requestUrl = URL(string: url)
        request = URLRequest(url: requestUrl!)
        if let token = token {
            
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
    }

    func requestSession(completionHandler: @escaping (Data?, URLResponse?, Error?) -> (Void)) {

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                completionHandler(data, response, error)
            }
        }
        
        task.resume()
    }

    mutating func setParamenter(path: String) {
        
        let jsonDictionary = ["path": path]
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        request.httpBody = jsonData
    }
}

