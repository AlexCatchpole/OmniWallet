//
//  RegisterController.swift
//  OmnicoinWallet
//
//  Created by Alex Catchpole on 13/03/2015.
//  Copyright (c) 2015 Alex Catchpole. All rights reserved.
//

import UIKit
import Alamofire

class RegisterController: UIViewController,UITextFieldDelegate {

    @IBOutlet var mainContainter: UIView!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var comfirmPasswordField: UITextField!
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var activity: UIActivityIndicatorView!
    
    var shadowColour = UIColor(red: 29 / 255, green: 22 / 255, blue: 38 / 255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide activity
        activity.hidden = true
        
        //setup navbar
        self.navigationController?.navigationBar.titleTextAttributes =
        [
            NSFontAttributeName: UIFont(name: "Overpass-Reg", size: 20)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        //set up container
        mainContainter.layer.cornerRadius = 5
        
        //textboxes setup
        
        //username
        usernameField.layer.cornerRadius = 5
        usernameField.attributedPlaceholder = NSAttributedString(string: "3 - 30 CHARACTERS", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "Overpass-Reg", size: 15)!])
        
        
        passwordField.layer.cornerRadius = 5
        comfirmPasswordField.layer.cornerRadius = 5
        
        //set up login button
        registerButton.layer.cornerRadius = 5
        registerButton.layer.shadowColor = shadowColour.CGColor
        registerButton.layer.shadowOffset = CGSizeMake(0, 2)
        registerButton.layer.shadowOpacity = 1
        registerButton.layer.shadowRadius = 0

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func registerButton(sender: AnyObject) {
        register()
    }
    
    
    func register() {
        //this is where we perform our validation
        
        //prep for validation
        var usernameEntered = usernameField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //first we check if all textboxes are full
        if !usernameEntered.isEmpty && !passwordField.text.isEmpty && !comfirmPasswordField.text.isEmpty {
            //all textboxes are full
            //now we check if the text in both password fields are the same
            if passwordField.text == comfirmPasswordField.text {
                println("botth match")
                
                //encode passwords
                var encodedPassword = passwordField.text.sha512()!
                var encodedConfirmPassword = comfirmPasswordField.text.sha512()!
                //now perform call
                currentlyBusy()
                var url: NSURL = NSURL(string: "https://omnicha.in/api?method=wallet_register&username=\(usernameEntered)&password=\(encodedPassword)&passwordConfirm=\(encodedConfirmPassword)")!
                
                Alamofire.request(.GET, url)
                    .responseJSON { (_, _, JSON, _) in
                        self.noLongerBusy()
                        var info = JSON as! NSDictionary?
                        println(info)
                        var errorNum = info?["error"] as! Int?
                        if errorNum != 0 {
                            println("error")
                            var error = info?["error_info"] as! String
                            self.handleRegisterError(error)
                        }else {
                            println("success")
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        }
                        
                        
                }
                
            }else {
                println("text boxes don't match")
                displayError(4)
            }
            
        }else {
            //one or more are empty
            println("one or more textboxes are empty")
            displayError(5)
        }
    }
    
    func handleRegisterError(error: String) {
        switch error {
        case "USERNAME_TAKEN":
            println("Username taken")
            displayError(1)
            break;
        case "INVALID_PASSWORD":
            println("invalid password")
            displayError(2)
            break;
        case "INVALID_USERNAME":
            println("invalid username")
            displayError(3)
            break;
        default:
            break;
            
        }
        
    }
    
    func currentlyBusy() {
        registerButton.enabled = false
        activity.hidden = false
        activity.startAnimating()
    }
    
    func noLongerBusy() {
        registerButton.enabled = true
        activity.hidden = true
        activity.stopAnimating()
    }
    
    func displayError(option: Int) {
        switch option {
        case 1:
            noLongerBusy()
            var usernameTaken = UIAlertController(title: "Error Registering", message: "Username is already registered", preferredStyle: UIAlertControllerStyle.Alert)
            var okbutton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            usernameTaken.addAction(okbutton)
            self.presentViewController(usernameTaken, animated: true, completion: nil)
            usernameField.text = ""
            passwordField.text = ""
            comfirmPasswordField.text = ""
            break;
        case 2:
            noLongerBusy()
            var invalidPassword = UIAlertController(title: "Error Registering", message: "Password contains invalid characters", preferredStyle: UIAlertControllerStyle.Alert)
            var okbutton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            invalidPassword.addAction(okbutton)
            self.presentViewController(invalidPassword, animated: true, completion: nil)
            usernameField.text = ""
            passwordField.text = ""
            comfirmPasswordField.text = ""
            break;
        case 3:
            noLongerBusy()
            var errorr = UIAlertController(title: "Error Registering", message: "Username does not meet length requirements or contains invalid characters", preferredStyle: UIAlertControllerStyle.Alert)
            var okbutton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            errorr.addAction(okbutton)
            self.presentViewController(errorr, animated: true, completion: nil)
            usernameField.text = ""
            passwordField.text = ""
            comfirmPasswordField.text = ""
            break;
        case 4:
            noLongerBusy()
            var errorr = UIAlertController(title: "Error Registering", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.Alert)
            var okbutton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            errorr.addAction(okbutton)
            self.presentViewController(errorr, animated: true, completion: nil)
            usernameField.text = ""
            passwordField.text = ""
            comfirmPasswordField.text = ""
            break;
        case 5:
            noLongerBusy()
            var errorr = UIAlertController(title: "Error Registering", message: "One or more fields are empty", preferredStyle: UIAlertControllerStyle.Alert)
            var okbutton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            errorr.addAction(okbutton)
            self.presentViewController(errorr, animated: true, completion: nil)
            usernameField.text = ""
            passwordField.text = ""
            comfirmPasswordField.text = ""
            break;
            
        default:
            break;
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
