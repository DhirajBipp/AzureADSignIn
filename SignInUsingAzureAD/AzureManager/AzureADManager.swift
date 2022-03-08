//
//  AzureADExtension.swift
//  SignInUsingAzureAD
//
//  Created by Admin on 07/03/22.
//

import Foundation
import MSAL

protocol AzureADManagerDelegate
{
    func updateCurrentAccount(account: MSALAccount?, token: String)
    func updateSignOutButtonStatus(status: Bool?)
}

class AzureADManager
{
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    var delegate : AzureADManagerDelegate?
    var currentAccount: MSALAccount?
    
    static let sharedInstance = AzureADManager()
    
    typealias AccountCompletion = (MSALAccount?) -> Void
    
    // MARK: Intilise MSAL

    func initMSAL(topview: UIViewController) throws {
         
         guard let authorityURL = URL(string: StringValues.kAuthority) else {
             self.updateLogging(text: "Unable to create authority URL")
             return
         }
         
         let authority = try MSALAADAuthority(url: authorityURL)
         
         let msalConfiguration = MSALPublicClientApplicationConfig(clientId: StringValues.kClientID,
                                                                   redirectUri: StringValues.kRedirectUri,
                                                                   authority: authority)
         self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
         self.initWebViewParams(topview: topview)
     }
     
     func initWebViewParams(topview: UIViewController) {
         self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: topview)
     }
    
    // MARK: invoke the authorization flow

     func callGraphAPI() {
        
        self.loadCurrentAccount { (account) in
            
            guard let currentAccount = account else {
                self.acquireTokenInteractively()
                return
            }
            
            self.acquireTokenSilently(currentAccount)
        }
    }
    
    func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: StringValues.kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            self.updateLogging(text: "Access token is \(self.accessToken)")
            self.delegate?.updateCurrentAccount(account: result.account, token: "Access token is : " + self.accessToken)
            NetworkManager.shared.getContentWithToken()
            
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: StringValues.kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            self.updateLogging(text: "Refreshed Access token is \(self.accessToken)")
            self.delegate?.updateSignOutButtonStatus(status: true)
            
            NetworkManager.shared.getContentWithToken()
        }
    }
    
    
    func loadCurrentAccount(completion: AccountCompletion? = nil) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
 
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.updateLogging(text: "Couldn't query current account with error: \(error)")
                return
            }
            
            if let currentAccount = currentAccount {
                
                self.updateLogging(text: "Found a signed in account \(String(describing: currentAccount.username)). Updating data for that account...")
                
                
                self.delegate?.updateCurrentAccount(account: currentAccount, token: self.accessToken)
                
                if let completion = completion {
                    completion(self.currentAccount)
                }
                
                return
            }
            
            self.updateLogging(text: "Account signed out. Updating UX")
            self.accessToken = ""
            self.delegate?.updateCurrentAccount(account: nil, token: "")
            
            if let completion = completion {
                completion(nil)
            }
        })
    }
    func updateLogging(text : String) {
        
        print("\(text)")

    }
}
