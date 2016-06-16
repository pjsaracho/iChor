//
//  ProfileViewController.swift
//  iChor_xcode_v2
//
//  Created by userli on 29/03/2016.
//  Copyright © 2016 ITDC. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fnameTextField: UITextField!
    @IBOutlet weak var lnameTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var pw1tf: UITextField!
    @IBOutlet weak var pw2tf: UITextField!
    @IBOutlet weak var pw3tf: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        
        fnameTextField.delegate = self
        lnameTextField.delegate = self
        contactTextField.delegate = self
        pw1tf.delegate = self
        pw2tf.delegate = self
        pw3tf.delegate = self
        
        
        let url: NSURL = NSURL(string: "http://ichor.hol.es/index.php/Mobile/profile")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        let username = prefs.stringForKey("USERNAME")
        let bodyData = "username=\(username!)"
        
        request.HTTPMethod = "POST"
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                print("error=\(error)")
                return
            }
            _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString!)")
            
            do {
                    let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                    for object in convertedJsonIntoDict as! [AnyObject] {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.fnameTextField.text = object["fname"] as? String
                            self.lnameTextField.text = object["lname"] as? String
                            self.contactTextField.text = object["contact"] as? String
                        })
                    }
            } catch {
                print("error serializing JSON: \(error)")
            }

        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editButtonAction(sender: UIButton) {
        if (editButton.titleLabel?.text! == "Edit") {
            fnameTextField.enabled = true
            lnameTextField.enabled = true
            contactTextField.enabled = true
            editButton.setTitle("Save", forState: .Normal)
        } else {
            fnameTextField.enabled = false
            lnameTextField.enabled = false
            contactTextField.enabled = false
            editButton.setTitle("Edit", forState: .Normal)
            
            let url: NSURL = NSURL(string: "http://ichor.hol.es/index.php/MobileLogin/update/")!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let username = prefs.stringForKey("USERNAME")
            let bodyData = "username=\(username!)&fname=\(fnameTextField.text!)&lname=\(lnameTextField.text!)&contact=\(contactTextField.text!)"
            
            request.HTTPMethod = "POST"
            
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print("responseString = \(responseString!)")
                
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "", message: responseString! as String, preferredStyle: .Alert)
                    let actionOk = UIAlertAction(title: "OK",
                        style: .Default,
                        handler: nil)
                    
                    alertController.addAction(actionOk)
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
            task.resume()
        }
    }
    
    
    @IBAction func changePasswordAction(sender: UIButton) {
        let url: NSURL = NSURL(string: "http://ichor.hol.es/index.php/MobileLogin/changePW/")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username = prefs.stringForKey("USERNAME")
        let bodyData = "username=\(username!)&password=\(pw1tf.text!)&password2=\(pw2tf.text!)&password3=\(pw3tf.text!)"
        
        request.HTTPMethod = "POST"
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                print("error=\(error)")
                return
            }
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString!)")
            
            dispatch_async(dispatch_get_main_queue(), {
                let alertController = UIAlertController(title: "", message: responseString! as String, preferredStyle: .Alert)
                let actionOk = UIAlertAction(title: "OK",
                                         style: .Default,
                                         handler: nil)
            
                alertController.addAction(actionOk)
                self.presentViewController(alertController, animated: true, completion: nil)
            })
        }
        task.resume()
    }
    
    @IBAction func logoutAction(sender: UIButton) {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        
        //self.performSegueWithIdentifier("goto_login", sender: self)
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }

}
