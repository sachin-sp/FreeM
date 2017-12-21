//
//  HomeController.swift
//  FreeM
//
//  Created by Sachin S P on 20/12/17.
//  Copyright © 2017 Sachin S P. All rights reserved.
//

import UIKit

class HomeController: UITableViewController {

    var album = [Album]()
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        fetchTopAlbums()
        refresh.addTarget(self, action: #selector(refresher), for: .valueChanged)
        tableView.addSubview(refresh)
        
    }
    
    func fetchTopAlbums() {
        APISerive.shared.fetchTopAlbumsds { (album , error) in
            
            if error == nil {
                self.album = album!
                print(album!)
            } else {
                print(error!)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refresher() {
        fetchTopAlbums()
        refresh.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.album.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = self.album[indexPath.row].artist?.name
        return cell
    }
    

}
