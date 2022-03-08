//
//  extension.swift
//  SignInUsingAzureAD
//
//  Created by Admin on 04/03/22.
//

import Foundation
import MSAL
extension AuthorizationViewController
{
    
    // MARK: Initialization

    @IBAction func callGraphAPI(_ sender: UIButton) {
        AzureADManager.sharedInstance.callGraphAPI()
    }
         
    @IBAction func signOutButtonPressed(_ sender: Any) {
        
        guard let applicationContext = AzureADManager.sharedInstance.applicationContext else { return }
        
        guard let account = AzureADManager.sharedInstance.currentAccount else { return }
        
        do {
            
            /**
             Removes all tokens from the cache for this application for the provided account
             
             - account:    The account to remove from the cache
             */
            
            let signoutParameters = MSALSignoutParameters(webviewParameters: AzureADManager.sharedInstance.webViewParamaters!)
            signoutParameters.signoutFromBrowser = false
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    AzureADManager.sharedInstance.updateLogging(text: "Couldn't sign out account with error: \(error)")
                    return
                }
                
                AzureADManager.sharedInstance.updateLogging(text: "Sign out completed successfully")
                AzureADManager.sharedInstance.accessToken = ""
                self.updateCurrentAccount(account: nil, token: "")
            })
            
        }
    }
  
    
    
    func updateSignOutButtonStatus(status: Bool?) {
        if Thread.isMainThread {
            self.signOutButton.isEnabled = status ?? false
            self.signInButton.isEnabled = !(status ?? true)
            
        } else {
            DispatchQueue.main.async {
                self.signOutButton.isEnabled = status ?? false
                self.signInButton.isEnabled = !(status ?? true)
            }
        }
    }
    func updateAccountLabel() {
        
        guard let currentAccount = AzureADManager.sharedInstance.currentAccount else {
            self.usernameLabel.text = "Signed out"
            return
        }
        
        self.usernameLabel.text = currentAccount.username
    }
    
    func updateCurrentAccount(account: MSALAccount?, token: String) {
        AzureADManager.sharedInstance.currentAccount = account
        self.updateAccountLabel()
        self.updateSignOutButtonStatus(status: account != nil)
        self.lblToken.text = token
    }


    }
