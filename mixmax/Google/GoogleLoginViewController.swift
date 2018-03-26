//
//  GoogleLoginViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 2/9/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit
import GoogleSignIn
import RxCocoa

class GoogleLoginViewController : UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        view.addSubview(signInButton)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            
        } else {
            self.signInButton.isHidden = true
//            if let vc = self.slideMenuController()?.rightViewController as? MenuViewController {
//                vc.currentCloud = BehaviorRelay(value: .google)
//            }
        }
    }
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
//        UIActivityIndicatorView.stopAnimating()
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func closeLoginButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
