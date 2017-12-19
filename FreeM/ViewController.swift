//
//  ViewController.swift
//  FreeM
//
//  Created by Sachin S P on 18/12/17.
//  Copyright © 2017 Sachin S P. All rights reserved.
//

import UIKit
import CryptoSwift

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
       _ = getSessionKeyFor("s4chin_", andPassword: "error501!")
        
    }
    
    func getSessionKeyFor(_ username: String, andPassword passsword: String) -> String {
        
        var sesseionKey = ""
        
        let username = username
        let password = passsword
        let apiKey = "602df7e5efb15841e1b49624afa6bd32"
        let apiSecret = "9c8f33f22a3723df96f63c7db16045d2"
        
        let apiSignature = "api_key\(apiKey)methodauth.getMobileSessionpassword\(password)username\(username)\(apiSecret)"
        
        let md5Sig = apiSignature.md5()
        
        let url = AppConstants.AppUrl.BASE_URL
        
        let urlParameter = "method=auth.getMobileSession&api_key=\(apiKey)&password=\(password)&username=\(username)&api_sig=\(md5Sig)"
        
        let urlr = URL(string: url + urlParameter + "&format=json")
        
        var request = URLRequest(url: urlr!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared.dataTask(with: request, completionHandler: {data, res, error in
           guard error == nil else { return }
            guard let data =  data else { return }
            do {
                
                if let data = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    
                    if let _session = data["session"] as? [String: Any] {
                        
                        if let _key = _session["key"] as? String {
                            sesseionKey = _key
                        }
                    }
                }
                
                
            } catch let err{
                print(err)
            }
        })
        session.resume()
        
        return sesseionKey
        
    }
    

}

