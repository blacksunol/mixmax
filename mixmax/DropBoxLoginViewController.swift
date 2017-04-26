//
//  DropBoxLoginViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/26/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

import UIKit

class DropBoxLoginViewController: UIViewController {
    @IBOutlet weak var loginWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
    }
    
    private func loadWebView() {
        if let url = URL(string: "https://www.dropbox.com/oauth2/authorize?client_id=8g16zfowqmgqtmd&response_type=token&redirect_uri=http://localhost") {
            loginWebView.loadRequest(URLRequest(url: url))
        }
    }
}

extension DropBoxLoginViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let kDropBoxToken = "http://localhost/#access_token="
        let urlString = webView.request?.url?.absoluteString
        if let urlString = urlString, urlString.contains(kDropBoxToken) {
            let tokenString = urlString.replacingOccurrences(of: kDropBoxToken, with: "")
            print("token: \(tokenString)")
            UserDefaults.standard.set(tokenString, forKey: kDropBoxToken)
        }
    }
}
