//
//  Page.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/8/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper

class Page: Mappable {
    var offset: Int?
    var limit: Int?
    var total: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        offset <- map["offset"]
        limit <- map["limit"]
        total <- map["total"]
    }
}
