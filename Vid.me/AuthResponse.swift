//
//  AuthResponse.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/10/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthResponse: APIResponse {
    var auth: Auth?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        auth <- map["auth"]
    }
}
