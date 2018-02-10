//
//  LoginViewController.swift
//  MAD
//
//  Created by David McAllister on 2/3/18.
//  Copyright © 2018 Eric C. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, DownloadProtocol {
    
    @IBOutlet weak var incorrectCredentialsLabel: UILabel!
    
    func itemsDownloaded(items: NSArray, from: String) {
        //print("Items downloaded")
        //self.loginButton.titleLabel?.text = "Login"
        self.loginButton.setTitle("Login", for: UIControlState.normal)
        if (String(describing: items.firstObject) == "failed") {
            //print("Login Failed")
            userNameField.text = ""
            passwordField.text = ""
            self.incorrectCredentialsLabel.alpha = 1.0
            
        } else {
            let user = items.firstObject
            switch user {
            case is UserModel:
                let userCasted = user as! UserModel
                UserDefaults.standard.set(self.userNameField.text,forKey: "id")
                UserDefaults.standard.set(self.passwordField.text,forKey: "credential")

                print("puppy")
                print(UserDefaults.standard.object(forKey: "id"))
                if UserDefaults.standard.object(forKey: "FirstLogin") == nil
                {
                    //print("dog")
                    UserDefaults.standard.set("false", forKey: "FirstLogin")
                    self.performSegue(withIdentifier: "LoginToIntro", sender: self)
                    
                }
                else
                {
                    //print(UserDefaults.standard.object(forKey: "FirstLogin"))
                    self.performSegue(withIdentifier: "LoginToTabs", sender: self)
                    
                }
            default:
                userNameField.text = ""
                passwordField.text = ""
                print("Login Failed!")
                self.incorrectCredentialsLabel.alpha = 1.0

            }
        }
    }
    
    @IBOutlet weak var slideUpView: UIView!
    var timer: Timer = Timer()
    var counter: Int = 0
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var libraryBackdrop: UIImageView!
    @IBOutlet weak var fadeOutView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backBlurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.incorrectCredentialsLabel.alpha = 0.0
        self.userNameField.layer.cornerRadius = 12
        self.passwordField.layer.cornerRadius = 12
        self.userNameField.layer.masksToBounds = true
        self.passwordField.layer.masksToBounds = true
        self.iconImage.layer.cornerRadius = 12
        self.iconImage.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 12
        loginButton.layer.masksToBounds = true
        let heightConstraint = NSLayoutConstraint(item: self.slideUpView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0)
        self.slideUpView.addConstraints([heightConstraint])
        // Do any additional setup after loading the view.
        //timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(LoginViewController.action), userInfo: nil,  repeats: true)
        //let blurEffect = UIBlurEffect(style: .ExtraLight)
        //blurView.animateWithDuration(1.5) {
            //self.blurView.effect = blurEffect
        //}
        
        /*
        testView = UIVisualEffectView()
        // Put it somewhere, give it a frame...
        UIView.animate(withDuration: 0.5) {
            (self.testView as? UIVisualEffectView)?.effect = UIBlurEffect(style: .dark)
        }
        */
        
        //UserDefaults.standard.set(userCasted.ID,forKey: "id")
        if let userID = UserDefaults.standard.object(forKey: "id")
        {
        print("id: ")
        //print(userID)
            let idAsString = String(describing: userID)
        
            print(idAsString)

        let userCredential = UserDefaults.standard.object(forKey: "credential")
        
        if(idAsString.count > 2 && String(describing: userCredential).count > 2)
        {
            
            //print("Username: " + idAsString)
            //print("Password: " + String(describing: userCredential!))
            self.loginButton.setTitle("Logging in...", for: UIControlState.normal)
            //self.loginButton.titleLabel?.text = "Logging in..."
            let login = UserLoginVerify()
            login.delegate = self
            self.userNameField.text = idAsString
            self.passwordField.text = String(describing: userCredential!)
            login.verifyLogin(schoolID: idAsString, password: String(describing: userCredential!))
            
            }
        else{
            self.userNameField.text = ""
            self.passwordField.text = ""
        }
        }
        
        backBlurView.alpha = 0.4
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = self.backgroundImage.frame
        backgroundImage.addSubview(effectView)
        effectView.alpha = 0
        self.iconImage.alpha = 0
        self.userNameField.alpha = 0.0
        self.passwordField.alpha = 0.0
        self.loginButton.alpha = 0.0
        UIView.animate(withDuration: 0.9) {
            effectView.alpha = 1.0
        }
        
        UIView.animate(withDuration: 1.4) {
            self.backgroundImage.alpha = 0.2
            self.fadeOutView.alpha = 0.8
            self.iconImage.alpha = 1.0
            self.userNameField.alpha = 1.0
            self.passwordField.alpha = 1.0
            self.loginButton.alpha = 1.0
        }
        
        
    }
    
    /*
    @objc func action()
    {
        
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Submit(_ sender: Any)
    {
        self.loginButton.setTitle("Logging in...", for: UIControlState.normal)
        self.loginButton.titleLabel?.text = "Logging in..."
        let login = UserLoginVerify()
        login.delegate = self
        login.verifyLogin(schoolID: userNameField.text!, password: passwordField.text!)
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
