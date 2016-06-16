//
//  Location.swift
//  iChor_xcode_v2
//
//  Created by userli on 31/03/2016.
//  Copyright © 2016 ITDC. All rights reserved.
//

import MapKit
import UIKit

class Location: NSObject, MKAnnotation {
    //private var _coordinate: CLLocationCoordinate2D
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var id: String
    
    override init() {
        self.title = ""
        self.coordinate = CLLocationCoordinate2DMake(0,0)
        self.info = ""
        self.id = ""
    }
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, id: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.id = id
        
        super.init()
    }

}
