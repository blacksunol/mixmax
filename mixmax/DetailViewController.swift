//
//  DetailViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/23/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var loginWebView: UIWebView!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
//        let url = URL(string: "https://www.dropbox.com/oauth2/authorize?client_id=8g16zfowqmgqtmd&response_type=token&redirect_uri=http://localhost")!
//        loginWebView.loadRequest(URLRequest(url: url))
        
        let url = URL(string: "https://api.dropboxapi.com/2/files/list_folder")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("Bearer mMH65aBfKgUAAAAAAAAP_8-AaIY53nvfnvwvs_cuniv9yKJjJ-IUokS0QQXnA_1c", forHTTPHeaderField: "Authorization")
        let jsonDictionary = ["path": ""]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error  {
                print(error.localizedDescription)
            } else {
                let json = try?  JSON(data: data!)
                guard let jsonArray = json?["entries"].array else {
                    return
                }
                var items = [Item]()
                for jsonItem in jsonArray {
                    let item = Item()
                    item.name = jsonItem["name"].string ?? ""
                    items.append(item)
                }
                print("number of items: \(items.count)")
            }
        }
        task.resume()
        
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let string = webView.request?.url?.absoluteString
        print("url: \(string)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

