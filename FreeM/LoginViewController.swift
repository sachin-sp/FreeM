//
//  LoginViewController.swift
//  FreeM
//
//  Created by Sachin S P on 20/12/17.
//  Copyright © 2017 Sachin S P. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let reuseIdentifierLogin = "LoginCell"


class LoginViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, LoginCellDelegate {

    lazy var pageController: UIPageControl = {
        let pgc = UIPageControl()
        pgc.numberOfPages = 4
        pgc.pageIndicatorTintColor = .red
        pgc.currentPageIndicatorTintColor = UIColor.purple
        return pgc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.isPagingEnabled = true
        navigationItem.titleView = pageController
        self.collectionView!.register(InitialTourCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(LoginCell.self, forCellWithReuseIdentifier: reuseIdentifierLogin)
    }
    
    func didLoginActionPerformedFor(_ username: String?, andPassword password: String?) {
        
        guard let username = username, let _ = password else { return }
        
       _ = getSessionKeyFor("s4chin_", andPassword: "error501!")
        let defaults = UserDefaults.standard
        
        defaults.set(username, forKey: "USER_NAME")
        defaults.synchronize()
        
        let layout = PinterestLayout()
        
        navigationController?.pushViewController(HomeController(collectionViewLayout: layout), animated: true)
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InitialTourCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierLogin, for: indexPath) as! LoginCell
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width , height: view.frame.height - 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == collectionView {
            
            let indexPath = collectionView?.indexPathsForVisibleItems
            let index = indexPath?.first?.item
            pageController.currentPage = index!
        }
        
    }
    
    //MARK: Login
    
    func getSessionKeyFor(_ username: String, andPassword passsword: String) -> String {
        
        var sesseionKey = ""
        
        let username = username
        let password = passsword
        
        let apiSignature = "api_key\(AppConstants.API.key)methodauth.getMobileSessionpassword\(password)username\(username)\(AppConstants.API.secret)"
        
        let md5Sig = apiSignature.md5()
        
        let url = AppConstants.AppUrl.BASE_URL
        
        let urlParameter = "method=auth.getMobileSession&api_key=\(AppConstants.API.key)&password=\(password)&username=\(username)&api_sig=\(md5Sig)"
        
        let urlr = URL(string: url + urlParameter + "&format=json")
        
        var request = URLRequest(url: urlr!)
        request.httpMethod = "POST"
        
        let session = URLSession.shared.dataTask(with: request, completionHandler: {data, res, error in
            guard error == nil else { return }
            guard let data =  data else { return }
            do {
                
                if let data = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    print(data)
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

class InitialTourCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView: UIView = {
       let iv = UIView()
       iv.backgroundColor = .red
       return iv
    }()
    
    func setupView() {
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(imageView)
    }
}

protocol LoginCellDelegate: class {
    func didLoginActionPerformedFor(_ username: String?, andPassword password: String?)
}

class LoginCell: UICollectionViewCell, UITextFieldDelegate {
    
    weak var delegate: LoginCellDelegate?
    var username: String?
    var password: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.placeholder = "Username"
        return tf
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.placeholder = "Password"
        return tf
    }()
    
    lazy var loginButton: UIButton = {
        let bt = UIButton(type: UIButtonType.system)
        bt.setTitle("Login", for: .normal)
        bt.clipsToBounds = true
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .white
        return bt
    }()
    
    @objc func loginAction() {
        delegate?.didLoginActionPerformedFor(username, andPassword: password)
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        
        if textField == usernameTextField {
            username = textField.text
        } else {
            password = textField.text
        }
    }
    
    func setupView() {
        backgroundColor = UIColor(red: 188, green: 209, blue: 242)
        usernameTextField.frame = CGRect(x: 30, y: 150, width: frame.width - 60, height: 40)
        passwordTextField.frame = CGRect(x: 30, y: 150 + 40 + 8, width: frame.width - 60, height: 40)
        loginButton.frame = CGRect(x: 60, y: 150 + 40 + 8 + 40 + 8, width: frame.width - 120, height: 50)
        addSubview(usernameTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        usernameTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: UIControlEvents.editingChanged)
    }
}


