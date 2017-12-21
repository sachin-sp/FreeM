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
    
    func fetchTopAlbums() -> [String: Any] {
        
        var dict = [String: Any]()
       
        
        let urlString = "http://ws.audioscrobbler.com/2.0/?method=user.gettopalbums&user=rj&api_key=\(AppConstants.API.key)&format=json"
        
        let session = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: {data, res, error in
            guard error == nil else { return }
            guard let data =  data else { return }
            do {
                if let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    dict = data
                    print(data)
                }
            } catch let err{
                print(err)
            }
        })
        session.resume()
        session.resume()
        
        return dict
        
    }
    
    func fetchTopAlbumsds(completion: @escaping ([Album]?, Error?) -> ()) {
        
        var albums = [Album]()
        
        let urlString = "http://ws.audioscrobbler.com/2.0/?method=user.gettopalbums&user=rj&api_key=\(AppConstants.API.key)&format=json"
        
        let session = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: {data, res, error in
            guard error == nil else { return }
            guard let data =  data else { return }
            do {
                if let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(data)
                    if let topalbums = data["topalbums"] as? [String: Any] {
                    if let album = topalbums["album"] as? NSArray {
                        
                        for dict in album {
                            guard let dict = dict as? NSDictionary else { return }
                            let alb = Album(dictionary: dict)
                            albums.append(alb)
                        }
                    }
                }
                    completion(albums, nil)
              }
            } catch let err{
                print(err)
                completion(nil, err)
            }
        })
        session.resume()
        
        
    }
    
}

struct Album {
    var artist: Artist?
    let image: [Image]?
    
    init(dictionary: NSDictionary) {
        self.artist = Artist(mbid: "", name: "", url: "")
        if let artist = dictionary.object(forKey: "artist") as? NSDictionary {
         self.artist = Artist(mbid: artist.object(forKey: "mbid") as? String, name: artist.object(forKey: "name") as? String, url: artist.object(forKey: "url") as? String)
        }
        self.image = [Image]()
        if let images = dictionary.object(forKey: "image") as? NSArray {
           
            for img in images {
                
                let txt = (img as? NSDictionary)?.object(forKey: "#text") as? String
                let sz = (img as? NSDictionary)?.object(forKey: "size") as? String
                let i = Image(text: txt, size: sz)
                self.image?.append(i)
            }
        }
    }
}

struct Artist {
    let mbid: String?
    let name: String?
    let url: String?
    
    init(mbid: String?, name: String?, url: String?) {
        self.mbid = mbid
        self.name = name
        self.url = url
    }
}

struct Image {
   
    let text: String?
    let size: String?
    
    init(text: String?, size: String?) {
        self.text = text
        self.size = size
    }
}

/*
 {
 "@attr" =             {
 rank = 1;
 };
 artist =             {
 mbid = "f90e8b26-9e52-4669-a5c9-e28529c47894";
 name = "Snoop Dogg";
 url = "https://www.last.fm/music/Snoop+Dogg";
 };
 image =             (
 {
 "#text" = "https://lastfm-img2.akamaized.net/i/u/34s/cf3a46415a1f4e9cce0f365af8225097.png";
 size = small;
 },
 {
 "#text" = "https://lastfm-img2.akamaized.net/i/u/64s/cf3a46415a1f4e9cce0f365af8225097.png";
 size = medium;
 },
 {
 "#text" = "https://lastfm-img2.akamaized.net/i/u/174s/cf3a46415a1f4e9cce0f365af8225097.png";
 size = large;
 },
 {
 "#text" = "https://lastfm-img2.akamaized.net/i/u/300x300/cf3a46415a1f4e9cce0f365af8225097.png";
 size = extralarge;
 }
 );
 mbid = "";
 name = Doggystyle;
 playcount = 396;
 url = "https://www.last.fm/music/Snoop+Dogg/Doggystyle";
 }
 */
