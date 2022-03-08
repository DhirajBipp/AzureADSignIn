//
//  AppDelegate.swift
//  SignInUsingAzureAD
//
//  Created by Admin on 03/03/22.
//

import UIKit
import MSAL
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        MSALGlobalConfig.loggerConfig.setLogCallback { (logLevel, message, containsPII) in
                
                // If PiiLoggingEnabled is set YES, this block will potentially contain sensitive information (Personally Identifiable Information), but not all messages will contain it.
                // containsPII == YES indicates if a particular message contains PII.
                // You might want to capture PII only in debug builds, or only if you take necessary actions to handle PII properly according to legal requirements of the region
                if let displayableMessage = message {
                    if (!containsPII) {
                        #if DEBUG
                        // NB! This sample uses print just for testing purposes
                        // You should only ever log to NSLog in debug mode to prevent leaking potentially sensitive information
                        print(displayableMessage)
                        #endif
                    }
                }
            }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    }

}

