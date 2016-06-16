//
//  LoginViewController.swift
//  iChor_xcode_v2
//
//  Created by userli on 31/03/2016.
//  Copyright © 2016 ITDC. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(sender: UIButton) {
        if ( usernameTextField.text=="" || passwordTextField.text=="" ) {
            
            let alertController = UIAlertController(title: "Sign-in Failed", message: "Enter Username Password", preferredStyle: .Alert)
            let actionOk = UIAlertAction(title: "OK",
                style: .Default,
                handler: nil)
            
            alertController.addAction(actionOk)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let url: NSURL = NSURL(string: "http://ichor.hol.es/index.php/MobileLogin/validate_credentials")!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            let bodyData = "username=\(usernameTextField.text!)&password=\(passwordTextField.text!)"

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
                    
                    if statusCode == 200  && responseString! != ("Incorrect Username and Password"){
                        NSLog("Login SUCCESS");
                        
                        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        prefs.setObject(self.usernameTextField.text, forKey: "USERNAME")
                        prefs.setInteger(1, forKey: "ISLOGGEDIN")
                        prefs.synchronize()
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertController = UIAlertController(title: "Sign-in Failed", message: responseString, preferredStyle: .Alert)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }

}
