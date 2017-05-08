
//
//  Video.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/8/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper

class VideosResponse: Mappable {
    var status: Bool?
    var page: Page?
    var videos: [Video]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        page <- map["page"]
        videos <- map["videos"]
    }
}
