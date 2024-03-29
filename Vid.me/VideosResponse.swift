
//
//  Video.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/8/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper

class VideosResponse: APIResponse {
    var page: Page?
    var videos: [Video]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        page <- map["page"]
        videos <- map["videos"]
    }
}
