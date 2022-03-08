//
//  staticStrings.swift
//  SignInUsingAzureAD
//
//  Created by Admin on 04/03/22.
//

import Foundation
import MSAL

struct StringValues
{
    static let kClientID = "910b7d76-a828-4486-ba41-ef7c2af35265"
    static let kGraphEndpoint = "https://graph.microsoft.com/"
    static let kAuthority = "https://login.microsoftonline.com/common"
    static let kRedirectUri = "msauth.bipp.incp.SignInUsingAzureAD://auth"
    
    static let kScopes: [String] = ["user.read"]
}
