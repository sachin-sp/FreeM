//
//  Extensions.swift
//  FreeM
//
//  Created by Sachin S P on 20/12/17.
//  Copyright © 2017 Sachin S P. All rights reserved.
//

import UIKit

import Foundation
import UIKit

extension UIView {
    
    
    func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        
        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        
        _ = anchor(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
    }
    
    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
    
    func setShadowWithColor(color: UIColor?, opacity: Float?, offset: CGSize?, radius: CGFloat, viewCornerRadius: CGFloat?) {
        //layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: viewCornerRadius ?? 0.0).CGPath
        layer.shadowColor = color?.cgColor ?? UIColor.black.cgColor
        layer.shadowOpacity = opacity ?? 1.0
        layer.shadowOffset = offset ?? CGSize.zero
        layer.shadowRadius = radius
    }
}

extension UIImageView {
    func profileImage(image: UIImageView) {
        
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
    }
}


extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUsingUrlString(_ urlString: String) {
        
        imageUrlString = urlString
        
        let url = URL(string: urlString)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                let imageData = NSData(data: data!)
                let imageToCache = UIImage(data: imageData as Data)
                
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                
                if imageToCache != nil {
                    imageCache.setObject(imageToCache! , forKey: urlString as AnyObject)
                }
                
                
            })
            
        }).resume()
    }
    
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    class func omnipreneurBackgroungColor() -> UIColor{
        return UIColor(red: 245, green: 238, blue: 234)
        //return UIColor.white
    }
    class func omniGreen() -> UIColor{
        return UIColor(red:33, green:145, blue:133)
    }
    class func omniYellow() -> UIColor{
        return UIColor(red:237, green:168, blue:11)
    }
    
    class func skyBlue() -> UIColor{
        return UIColor(red:92, green:212, blue:255)
    }
}

extension UINavigationBar {
    func customBar(){
        self.barTintColor = UIColor.omnipreneurBackgroungColor()
        self.isTranslucent = false
        //self.setBackgroundImage(UIImage(), for: .default)
        //self.shadowImage = UIImage()
        self.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
        self.tintColor = UIColor.black
        
    }
    
    func whiteTintBar(){
        self.barTintColor = UIColor.omnipreneurBackgroungColor()
        self.isTranslucent = false
        //self.setBackgroundImage(UIImage(), for: .default)
        //self.shadowImage = UIImage()
        self.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        self.tintColor = UIColor.white
    }
}

extension UINavigationItem {
    
    func setTitle(title:String, subtitle:String) {
        
        let one = UILabel()
        one.text = title
        one.font = UIFont.systemFont(ofSize: 17)
        one.sizeToFit()
        
        let two = UILabel()
        two.text = subtitle
        two.font = UIFont.systemFont(ofSize: 12)
        two.textAlignment = .center
        two.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        
        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        one.sizeToFit()
        two.sizeToFit()
        
        self.titleView = stackView
    }
    
    func setTitleOne(title: String, subtitle: String, titleColor: UIColor){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 480, height: 44))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        label.textAlignment = .center
        label.textColor = titleColor
        label.text = title + "\n" + subtitle
        self.titleView = label
    }
    
    func setTitleView(title: String){
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 480, height: 60))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.semibold)
        label.textAlignment = .right
        label.text = title
        self.titleView = label
    }
}

extension String {
    func localized(lang:String) ->String {
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    
    //Validate Email
    
    var isValidEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var isValidPhoneNumber: Bool{
        //let passRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z].*[a-z].*[a-z].*[a-z].*[a-z]).{8}$"
        let passRegEx = "^(?=.*[0-9]).{11}$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidPassword: Bool{
        //let passRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z].*[a-z].*[a-z].*[a-z].*[a-z]).{8}$"
        let passRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{8,24}$"
        let passTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: self)
    }
    
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIViewController {
    
    func transitionToMainViewController() {
        
        if let window = self.view.window {
            UIView.transition(with: window, duration: 0.3, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
                //window.rootViewController = HomeViewController()
            }, completion: nil)
        }
    }
    
    func transitionToLoginViewController() {
        
        if let window = self.view.window {
            UIView.transition(with: window, duration: 0.3, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
//                let splashVC = SplashScreenViewController()
//                window.rootViewController = UINavigationController(rootViewController: splashVC)
            }, completion: nil)
        }
    }
    
    func addCustomRightSwipeGesture() {
//        let rightSwipeToPopVC = UISwipeGestureRecognizer.init(target: self, action: #selector(self.actionForCustomRightSwipeGesture))
//        rightSwipeToPopVC.direction = .right
//        self.view.addGestureRecognizer(rightSwipeToPopVC)
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func actionForCustomRightSwipeGesture() {
        
        //self.navigationController?.popViewController(animated: true)
    }
}

extension NSNull {
    func length() -> Int { return 0 }
    
    func integerValue() -> Int { return 0 }
    
    func floatValue() -> Float { return 0 };
    
    open override var description: String { return "0(NSNull)" }
    
    func componentsSeparatedByString(separator: String) -> [AnyObject] { return [AnyObject]() }
    
    func objectForKey(key: AnyObject) -> AnyObject? { return nil }
    
    func boolValue() -> Bool { return false }
}

extension UIFont {
    
    class func omniBoldLargeFont() -> UIFont{
        if UserDefaults.standard.isCurrentDeviceIphone(){
            return UIFont.boldSystemFont(ofSize: 17)
        } else {
            return UIFont.boldSystemFont(ofSize: 25)
        }
    }
    class func omniLargeFont() -> UIFont{
        if UserDefaults.standard.isCurrentDeviceIphone(){
            return UIFont.systemFont(ofSize: 17)
        } else {
            return UIFont.boldSystemFont(ofSize: 25)
        }
    }
    class func omniMediumFont() -> UIFont{
        if UserDefaults.standard.isCurrentDeviceIphone(){
            return UIFont.systemFont(ofSize: 15)
        } else {
            return UIFont.systemFont(ofSize: 23)
        }
    }
    class func omniBoldMediumFont() -> UIFont{
        if UserDefaults.standard.isCurrentDeviceIphone(){
            return UIFont.boldSystemFont(ofSize: 15)
        } else {
            return UIFont.boldSystemFont(ofSize: 23)
        }
    }
    class func omniSmallFont() -> UIFont{
        if UserDefaults.standard.isCurrentDeviceIphone(){
            return UIFont.systemFont(ofSize: 13)
        } else {
            return UIFont.systemFont(ofSize: 21)
        }
    }
}

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)! as NSData        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)! as NSData  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! as NSData }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)! as NSData  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! as NSData }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)! as NSData  }
}

extension Dictionary
{
    func filteredDictionary(_ isIncluded: (Key, Value) -> Bool)  -> Dictionary<Key, Value>
    {
        return self.filter(isIncluded).toDictionary(byTransforming: { $0 })
    }
}

extension Array
{
    func toDictionary<H:Hashable, T>(byTransforming transformer: (Element) -> (H, T)) -> Dictionary<H, T>
    {
        var result = Dictionary<H,T>()
        self.forEach({ element in
            let (key,value) = transformer(element)
            result[key] = value
        })
        return result
    }
}

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    public func fixedOrientation() -> UIImage {
        if imageOrientation == UIImageOrientation.up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi/2)
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat.pi/2)
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }
        
        switch imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil,
                                       width: Int(size.width),
                                       height: Int(size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent,
                                       bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
    }
}

extension UIImage {
    func image(withRotation radians: CGFloat) -> UIImage {
        let cgImage = self.cgImage!
        let LARGEST_SIZE = CGFloat(max(self.size.width, self.size.height))
        let context = CGContext.init(data: nil, width:Int(LARGEST_SIZE), height:Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!
        
        var drawRect = CGRect.zero
        drawRect.size = self.size
        let drawOrigin = CGPoint(x: (LARGEST_SIZE - self.size.width) * 0.5,y: (LARGEST_SIZE - self.size.height) * 0.5)
        drawRect.origin = drawOrigin
        var tf = CGAffineTransform.identity
        tf = tf.translatedBy(x: LARGEST_SIZE * 0.5, y: LARGEST_SIZE * 0.5)
        tf = tf.rotated(by: CGFloat(radians))
        tf = tf.translatedBy(x: LARGEST_SIZE * -0.5, y: LARGEST_SIZE * -0.5)
        context.concatenate(tf)
        context.draw(cgImage, in: drawRect)
        var rotatedImage = context.makeImage()!
        
        drawRect = drawRect.applying(tf)
        
        rotatedImage = rotatedImage.cropping(to: drawRect)!
        let resultImage = UIImage(cgImage: rotatedImage)
        return resultImage
        
        
    }
}

extension UserDefaults {
    enum UserDefaultsKeys: String {
        case userDevice
        case isLoggedIn
        case userLanguage
        case isSocialLogin
        case isUserProfileSaved
        case isMenteeProfile
    }
    
    enum CurrentDevice: String {
        case iPhone
        case iPad
    }
    
    func setCurrentDevice(device: String){
        if device == CurrentDevice.iPad.rawValue{
            set(false, forKey: UserDefaultsKeys.userDevice.rawValue)
            synchronize()
        } else {
            set(true, forKey: UserDefaultsKeys.userDevice.rawValue)
            synchronize()
        }
    }
    
    func isCurrentDeviceIphone() -> Bool {
        let isPhone = value(forKey: UserDefaultsKeys.userDevice.rawValue) as? Bool
        return isPhone!
    }
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    func setLanguageToEnglish(_ value: Bool) {
        set(value, forKey: UserDefaultsKeys.userLanguage.rawValue)
        synchronize()
    }
    
    func isLanguageEnglish() -> Bool{
        return bool(forKey: UserDefaultsKeys.userLanguage.rawValue)
    }
    
    func setIsSocilaLogin(value: Bool){
        set(value, forKey: UserDefaultsKeys.isSocialLogin.rawValue)
        synchronize()
    }
    
    func isSocialLogin() -> Bool{
        return bool(forKey: UserDefaultsKeys.isSocialLogin.rawValue)
    }
    
    func isUserProfileSave() -> Bool{
        return bool(forKey: UserDefaultsKeys.isUserProfileSaved.rawValue)
    }
    
    func setIsMenteeProfile(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isMenteeProfile.rawValue)
        synchronize()
    }
    
    func isMenteeProfile() -> Bool {
        return bool(forKey: UserDefaultsKeys.isMenteeProfile.rawValue)
    }
    
    func clearUserDefaults(){
        removeObject(forKey: "Profile_Image_Date")
        removeObject(forKey: "User_Full_Name")
        removeObject(forKey: "Creation_Time")
        removeObject(forKey: "DOB")
        
        synchronize()
    }
}

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
