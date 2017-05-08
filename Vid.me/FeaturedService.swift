//
//  APIService.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/8/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import Alamofire

class FeaturedService {
    
    func loadFeatured(completion: @escaping ([VideosResponse]?) -> ()) {
        Alamofire.request("https://api.vid.me/videos/featured").responseJSON { response in
            
        }
    }
    
}
