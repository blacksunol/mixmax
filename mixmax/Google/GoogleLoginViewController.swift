//
//  GoogleLoginViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 2/9/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import AVFoundation


class GoogleLoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate  {
    
    private let scopes = [kGTLRAuthScopeDriveReadonly]
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    private let service = GTLRDriveService()
    
    var player:AVPlayer?
    
    let output = UITextView()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        // Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output);

    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            listFiles()
            print("Access token: \(user.authentication.accessToken)")
            guard let accessToken = user.authentication.accessToken else {
                return
            }
//            getFile()
      
            let headers = ["Authorization": "Bearer \(accessToken)"]
            let url = URL(string: "https://www.googleapis.com/drive/v3/files/1siQAS6GbPTvN0xNKejBlyE6VREYa8hKC?alt=media")!
            
//            let url = URL(string: "https://www.googleapis.com/drive/v2/files/1siQAS6GbPTvN0xNKejBlyE6VREYa8hKC?alt=media")!
            
//            let url =  URL(string: "https://doc-0s-34-docs.googleusercontent.com/docs/securesc/669fcdtp0silioo506rd5psg3ut8s79n/v8am2bna2m1nbbg9v4o8qbr7fdsftpp7/1521381600000/02980703435378377253/02980703435378377253/1siQAS6GbPTvN0xNKejBlyE6VREYa8hKC?e=download&gd=true")!
            let avAsset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
            let playerItem = AVPlayerItem(asset: avAsset)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
        }
    }
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
//        UIActivityIndicatorView.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

    // List up to 10 files in Drive
    func listFiles() {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 10
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
        
        
    }

    // Process the response and display output
    func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRDrive_FileList,
                                 error : NSError?) {
        
        if let error = error {
            showAlert( title: "Error", message: error.localizedDescription)
            return
        }
        
        var text = "";
        if let files = result.files, !files.isEmpty {
            text += "Files:\n"
            for file in files {
                text += "\(file.name!) (\(file.identifier!))\n"
                print("filename: \(file.name!), fileid : \(file.identifier!)")
            }
        } else {
            text += "No files found."
        }
        output.text = text
    }
    
    // Process the response and display output
    func getFileResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject file : GTLRDataObject,
                                 error : NSError?) {
        if let error = error {
            showAlert( title: "Error", message: error.localizedDescription)
            return
        }
        
    }
    
    func getFile() {
        let query = GTLRDriveQuery_FilesGet.query(withFileId: "1HCzFMnt9zBZEjGvFtTjeNPYz9fU6Ijmav6SrPT-rB7k")
        
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(getFileResultWithTicket(ticket:finishedWithObject:error:))
        )
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
}
