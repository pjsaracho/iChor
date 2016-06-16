//
//  RequestViewController.swift
//  iChor_xcode_v2
//
//  Created by userli on 29/03/2016.
//  Copyright © 2016 ITDC. All rights reserved.
//

import UIKit
import MapKit

class RequestViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var bloodtypeField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var contactField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var currentAnnotation: MKPointAnnotation?
    var dropPin: MKPointAnnotation?
    var latitude: Double!
    var longitude: Double!
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username:String = prefs.stringForKey("USERNAME")! as String
        let url: NSURL = NSURL(string: "http://ichor.hol.es/index.php/Mobile/create")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        let bodyData = "username=\(username)&name=\(nameField.text!)&bloodtype=\(bloodtypeField.text!)&bloodamount=\(amountField.text!)&date=\(dateField.text!)&contact=\(contactField.text!)&lat=\(latitude)&lon=\(longitude)"
        print(bodyData)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            if let HTTPResponse = response as? NSHTTPURLResponse {
                let statusCode = HTTPResponse.statusCode
                
                if statusCode == 200 {
                }
            }
            
            _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        
        nameField.delegate = self
        bloodtypeField.delegate = self
        amountField.delegate = self
        dateField.delegate = self
        contactField.delegate = self
        mapView.delegate = self
        
        let ITDC = CLLocationCoordinate2DMake(14.633464472083569, 121.03418581014398)
        
        let mapSpan = MKCoordinateSpanMake(0.125,0.125)
        let mapRegion = MKCoordinateRegion(center: ITDC, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RequestViewController.didTapMap(_:)))
        singleTap.delegate = self
        self.mapView.addGestureRecognizer(singleTap)
    }
    
    func didTapMap(gestureReconizer: UITapGestureRecognizer) {
        let touchLocation = gestureReconizer.locationInView(mapView)
        let locationCoordinate = mapView.convertPoint(touchLocation,toCoordinateFromView: mapView)
        latitude = locationCoordinate.latitude
        longitude = locationCoordinate.longitude
        
        if mapView.annotations.count != 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            let dropPin = Location()
            dropPin.coordinate = locationCoordinate
            dropPin.title = ""
            dropPin.info = ""
            self.mapView.addAnnotation(dropPin)
        })
    }
    
    @IBAction func dateAction(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(RequestViewController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        //dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        //dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateFormat = "yyyy-MM-dd"        
        dateField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }

}
