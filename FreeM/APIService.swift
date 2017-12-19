//
//  APIService.swift
//  FreeM
//
//  Created by Sachin S P on 18/12/17.
//  Copyright © 2017 Sachin S P. All rights reserved.
//

import Foundation

class APISerive {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    static let shared = APISerive()
    
    func fetchArtist() {
        
        let url = "http://ws.audioscrobbler.com/2.0/?method=library.getartists&api_key=e901f68d50d3e41a71aaae388f0a6017&user=joanofarctan&format=json"
        
        let session = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, res, error in
            guard error == nil else { return }
            guard let data =  data else { return }
            do {
                let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                print(data)
            } catch let err{
                print(err)
            }
        })
        session.resume()
    }
    
}
