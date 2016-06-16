//
//  ViewController.swift
//  iChor_xcode_v2
//
//  Created by userli on 29/03/2016.
//  Copyright © 2016 ITDC. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var currentAnnotation: MKPointAnnotation?
    var dropPin: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadMap() {
        self.mapView.delegate = self
        let ITDC = CLLocationCoordinate2DMake(14.633464472083569, 121.03418581014398)
        
        let mapSpan = MKCoordinateSpanMake(0.125,0.125)
        let mapRegion = MKCoordinateRegion(center: ITDC, span: mapSpan)
        self.mapView.setRegion(mapRegion, animated: true)
        
        let url: NSURL = NSURL(string: "http://ichor.hol.es/index.php/mobile/map")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString!)")
            
            do {
                let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                for object in convertedJsonIntoDict as! [AnyObject] {
                    let lat  = (object["lat"]! as! NSString).doubleValue
                    let lon = (object["lon"]! as! NSString).doubleValue
                    let markers = CLLocationCoordinate2DMake(lat,lon)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        let dropPin = Location()
                        dropPin.coordinate = markers
                        dropPin.title = "Blood Request for: \(object["name"] as! String)  \n Blood Type: \(object["bloodtype"] as! String)"
                        dropPin.info = "\(object["bloodamount"] as! String) bags  \n until \(object["date"] as! String) \n call \(object["contact"] as! String)"
                        dropPin.id = "\(object["reqID"] as! String)"
                        self.mapView.addAnnotation(dropPin)
                    })
                }
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        
        loadMap()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Location"
        
        if annotation.isKindOfClass(Location.self) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }

        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Location
        let placeName = location.title
        let placeInfo = location.info
        let placeID = location.id
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        ac.addAction(UIAlertAction(title: "DELETE", style: .Default, handler: {(alert: UIAlertAction!) in
            
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let username:String = prefs.stringForKey("USERNAME")! as String
            let url: NSURL = NSURL(string: "http://ichor.hol.es/index.php/Mobile/delete")!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            let bodyData = "reqID=\(placeID)&username=\(username)"
            
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
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertController = UIAlertController(title: "Notice:", message: responseString, preferredStyle: .Alert)
                            let actionOk = UIAlertAction(title: "OK",
                                style: .Default,
                                handler: {(alert: UIAlertAction!) in
                                    let allAnnotations = self.mapView.annotations
                                    self.mapView.removeAnnotations(allAnnotations)
                                    self.loadMap()
                                })
                            
                            alertController.addAction(actionOk)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        })
                    }
                }
                
                
            }
            
            task.resume()
        }))
        
        presentViewController(ac, animated: true, completion: nil)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

