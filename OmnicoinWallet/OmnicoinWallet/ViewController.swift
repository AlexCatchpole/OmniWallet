//
//  ViewController.swift
//  OmnicoinWallet
//
//  Created by Alex Catchpole on 13/03/2015.
//  Copyright (c) 2015 Alex Catchpole. All rights reserved.
//

import UIKit
import CryptoSwift
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var mainView: UIView!
    @IBOutlet var secondView: UIView!
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!

    @IBOutlet var signInButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var activity: UIActivityIndicatorView!
    var sessionID: String!
    var username: String!
    
    var shadowColour = UIColor(red: 29 / 255, green: 22 / 255, blue: 38 / 255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("loaded")
        //setup boxes
        mainView.layer.cornerRadius = 5
        secondView.layer.cornerRadius = 5
        
        //setup textboxes
        usernameField.layer.cornerRadius = 5
        passwordField.layer.cornerRadius = 5
        
        //setup login button
        signInButton.layer.cornerRadius = 5
        signInButton.layer.shadowColor = shadowColour.CGColor
        signInButton.layer.shadowOffset = CGSizeMake(0, 2)
        signInButton.layer.shadowOpacity = 1
        signInButton.layer.shadowRadius = 0
        
        //setup register button
        registerButton.layer.cornerRadius = 5
        registerButton.layer.shadowColor = shadowColour.CGColor
        registerButton.layer.shadowOffset = CGSizeMake(0, 2)
        registerButton.layer.shadowOpacity = 1
        registerButton.layer.shadowRadius = 0
        
        //activity monitor
        activity.hidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    func login() {
        //prepare for api call
        
        //remove whitespace for username
        var username = usernameField.text
        var finalUsername = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //password
        var password = passwordField.text
        
        //check if username field is not empty
        if !finalUsername.isEmpty && !password.isEmpty {
            //convert password to sha512
            var encodedPassword = password.sha512()!
            var finalEncodedPassword = encodedPassword.lowercaseString
            
            //construct url
            var url: NSURL = NSURL(string: "https://omnicha.in/api?method=wallet_login&username=\(finalUsername)&password=\(finalEncodedPassword)")!
            println(url)
            
            //make call
            currentlyBusy()
            Alamofire.request(.GET, url)
                .responseJSON { (_, _, JSON, _) in
                    self.noLongerBusy()
                    var response: NSDictionary = JSON as! NSDictionary
                    println(response)
                    var error: Int = response["error"] as! Int
                    //if there is no error login!
                    if error == 0 {
                        println("login successfully")
                        var responsee = response["response"] as! NSDictionary
                        self.sessionID = responsee["session"] as! String
                        self.username = finalUsername
                        self.performSegueWithIdentifier("login", sender: self)
                    }else {
                        var errorInfo: String = response["error_info"] as! String
                        self.handleRegisterError(errorInfo)
                        
                    }
            }
            
            
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "login" {
            var vc = segue.destinationViewController as! UINavigationController
            var vcc: MainViewController = vc.topViewController as! MainViewController
            vcc.sessionID = sessionID
            vcc.username = username
            
        }
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.resignFirstResponder()
    }

    @IBAction func signInButton(sender: AnyObject) {
        login()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func currentlyBusy() {
        registerButton.enabled = false
        signInButton.enabled = false
        activity.hidden = false
        activity.startAnimating()
    }
    
    func noLongerBusy() {
        registerButton.enabled = true
        signInButton.enabled = true
        activity.hidden = true
        activity.stopAnimating()
    }
    
    func handleRegisterError(error: String) {
        switch error {
        case "BAD_LOGIN":
            displayError(1)
            break;
        case "IP_BANNED":
            displayError(2)
            break;
        default:
            break;
            
        }
        
    }
    func displayError(option: Int) {
        switch option {
        case 1:
            var noLogin = UIAlertController(title: "Error Logging In", message: "Username or password are incorrect", preferredStyle: UIAlertControllerStyle.Alert)
            var okbutton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            noLogin.addAction(okbutton)
            self.presentViewController(noLogin, animated: true, completion: nil)
            usernameField.text = ""
            passwordField.text = ""
            break;
        case 2:
            var ipBanned = UIAlertController(title: "Error Logging In", message: "Your IP is banned", preferredStyle: UIAlertControllerStyle.Alert)
            var okbutton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            ipBanned.addAction(okbutton)
            self.presentViewController(ipBanned, animated: true, completion: nil)
            usernameField.text = ""
            passwordField.text = ""
            break;
        default:
            break;
            
        }
        
    }

}

