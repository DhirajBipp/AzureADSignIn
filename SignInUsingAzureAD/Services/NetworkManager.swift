//
//  NetworkManager.swift
//  SignInUsingAzureAD
//
//  Created by Admin on 08/03/22.
//

import Foundation
class NetworkManager
{
    static let shared = NetworkManager()
    
    private init() {
        
    }
    
    func getContentWithToken() {
        
        let graphURI = getGraphEndpoint()
        let url = URL(string: graphURI)
        var request = URLRequest(url: url!)
        
        request.setValue("Bearer \(AzureADManager.sharedInstance.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                AzureADManager.sharedInstance.updateLogging(text: "Couldn't get graph result: \(error)")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                
                AzureADManager.sharedInstance.updateLogging(text: "Couldn't deserialize result JSON")
                return
            }
            
            AzureADManager.sharedInstance.updateLogging(text: "Result from Graph: \(result))")
            
            }.resume()
    }
    
    func getGraphEndpoint() -> String {
        return StringValues.kGraphEndpoint.hasSuffix("/") ? (StringValues.kGraphEndpoint + "v1.0/me/") : (StringValues.kGraphEndpoint + "/v1.0/me/");
    }

    
 

    
        

}

