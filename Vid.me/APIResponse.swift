//
//  APIResponse.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/10/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper

class APIResponse: Mappable {
    var status: Bool?
    var error: String?
    var code: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        error <- map["error"]
        code <- map["code"]
    }
}
