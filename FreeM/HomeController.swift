//
//  HomeController.swift
//  FreeM
//
//  Created by Sachin S P on 20/12/17.
//  Copyright © 2017 Sachin S P. All rights reserved.
//

import UIKit

class HomeController: UICollectionViewController {

    var album = [Album]()
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Albums"
        collectionView?.register(AnnotatedPhotoCell.self, forCellWithReuseIdentifier: "AnnotatedPhotoCell")
        collectionView?.backgroundColor = .white
        fetchTopAlbums()
        refresh.addTarget(self, action: #selector(refresher), for: .valueChanged)
        collectionView?.addSubview(refresh)
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
        // Set the PinterestLayout delegate
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
    }
    
    func fetchTopAlbums() {
        APISerive.shared.fetchTopAlbums { (album , error) in
            
            if error == nil {
                self.album = album!
            } else {
                print(error!)
            }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    @objc func refresher() {
        fetchTopAlbums()
        refresh.endRefreshing()
    }

}

extension HomeController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.album.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath)
        if let annotateCell = cell as? AnnotatedPhotoCell {
            //annotateCell.photo = photos[indexPath.item]
            annotateCell.photo = album[indexPath.item].image?.last
        }
        return cell
    }
}

//MARK: - PINTEREST LAYOUT DELEGATE
extension HomeController : PinterestLayoutDelegate {
    
    // 1. Returns the photo height
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        //return photos[indexPath.item].image.size.height
        
        return 200
    }
    
}
    

class AnnotatedPhotoCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    var photo: Image? {
        didSet {

            if let imageUrl = photo?.text {
                if !imageUrl.isEmpty {
                 imageView.loadImageUsingUrlString(imageUrl)
                }
            }
        }
    }
    
    lazy var containerView: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var imageView: CustomImageView = {
        let iv = CustomImageView()
        return iv
    }()
    
    func setupView() {
        containerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        imageView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
        
    }
    
}
