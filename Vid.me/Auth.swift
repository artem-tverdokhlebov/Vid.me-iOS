//
//  Auth.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/10/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper

class Auth: Mappable {
    var token: String?
    var expires: Date?
    var user_id: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        token <- map["token"]
        expires <- (map["expires"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        user_id <- map["user_id"]
    }
}
