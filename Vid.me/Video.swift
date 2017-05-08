//
//  Video.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/8/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper

class Video: Mappable {
    var video_id: String?
    
    var title: String?
    var description: String?
    
    var likes_count: Int?
    var complete_url: String?
    
    var width: Int?
    var height: Int?
    
    var thumbnail_url: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        video_id <- map["video_id"]
        
        title <- map["title"]
        description <- map["description"]
        
        likes_count <- map["likes_count"]
        
        complete_url <- map["complete_url"]
        
        width <- map["width"]
        height <- map["height"]
        
        thumbnail_url <- map["thumbnail_url"]
    }
}
