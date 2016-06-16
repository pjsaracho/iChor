//
//  RegisterViewController.swift
//  iChor_xcode_v2
//
//  Created by userli on 31/03/2016.
//  Copyright © 2016 ITDC. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fnameTextField: UITextField!
    @IBOutlet weak var lnameTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fnameTextField.delegate = self
        lnameTextField.delegate = self
        contactTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        password2TextField.delegate = self

        // Do any additional setup after loading the view.
    }

    @IBAction func gotologin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func registerButton(sender: UIButton) {
        if ( usernameTextField.text=="" || passwordTextField.text==""
            || fnameTextField.text==""
            || lnameTextField.text==""
            || contactTextField.text=="") {
            
            let alertController = UIAlertController(title: "Sign-up Failed", message: "Please don't leave any blank fields", preferredStyle: .Alert)
            let actionOk = UIAlertAction(title: "OK",
                style: .Default,
                handler: nil)
            
            alertController.addAction(actionOk)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else if ( passwordTextField.text != password2TextField.text ) {
            
            let alertController = UIAlertController(title: "Sign-up Failed", message: "Passwords don't Match", preferredStyle: .Alert)
            let actionOk = UIAlertAction(title: "OK",
                style: .Default,
                handler: nil)
            
            alertController.addAction(actionOk)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let url: NSURL = NSURL(string: "http://ichor.hol.es/index.php/MobileLogin/create_member")!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            let bodyData = "fname=\(fnameTextField.text!)&lname=\(lnameTextField.text!)&contact=\(contactTextField.text!)&username=\(usernameTextField.text!)&password=\(passwordTextField.text!)&password2=\(password2TextField.text!)"
            
            request.HTTPMethod = "POST"
            
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                if let HTTPResponse = response as? NSHTTPURLResponse {
                    let statusCode = HTTPResponse.statusCode
                    let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
                    print("responseString = \(responseString!)")
                    
                    if statusCode == 200 {
                        NSLog("Login SUCCESS");
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertController = UIAlertController(title: "Sign-up Failed", message: responseString, preferredStyle: .Alert)
                            let actionOk = UIAlertAction(title: "OK",
                                style: .Default,
                                handler: nil)
                            
                            alertController.addAction(actionOk)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        })
                    }
                }
                
                
            }
            task.resume()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }

}
