//
//  ViewController.swift
//  SignInUsingAzureAD
//
//  Created by Admin on 03/03/22.
//

import UIKit
import MSAL


class AuthorizationViewController: UIViewController,AzureADManagerDelegate
{
   
    

   @IBOutlet var signOutButton: UIButton!
   @IBOutlet var signInButton: UIButton!
   @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var lblToken: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AzureADManager.sharedInstance.delegate = self

        do {
            try AzureADManager.sharedInstance.initMSAL(topview: self)
        } catch let error {
            AzureADManager.sharedInstance.updateLogging(text: "Unable to create Application Context \(error)")
        }
        
        AzureADManager.sharedInstance.loadCurrentAccount()
        self.platformViewDidLoadSetup()
    }
    
    func platformViewDidLoadSetup() {
                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appCameToForeGround(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        AzureADManager.sharedInstance.loadCurrentAccount()
    }
    
    @objc func appCameToForeGround(notification: Notification) {
        AzureADManager.sharedInstance.loadCurrentAccount()
    }

    
}

