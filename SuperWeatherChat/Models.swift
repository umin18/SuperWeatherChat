//
//  Models.swift
//  EarlyWarningSystem
//
//  Created by Eric Cha on 12/22/18.
//  Copyright © 2018 Eric Cha. All rights reserved.
//

import UIKit

struct UserModel {
    
    let userID : String?
    let fname : String
    let lname : String
    let email : String
    let address : String
    let phone : String
    let password : String?
    var image : UIImage?
    var latitude : Double?
    var longitude : Double?
        
}

struct Weather {
    let timezone : String
    let date : String
    let time : String
    let summary : String
    let icon : String
    let temperatureHigh : Double
    let temperatureLow : Double
}

struct Location {
    let title : String
    let mag : Int
    let coordinates : [Double]
}

struct Conversation {
    let message : String
    let receiverID : String
    let time : String
}
