//
//  APIService.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/8/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class FeaturedService {
    
    func loadFeatured(offset: Int, completion: @escaping (VideosResponse?) -> ()) {
        Alamofire.request("https://api.vid.me/videos/featured", parameters: ["offset": offset]).responseObject { (response: DataResponse<VideosResponse>) in
            let videosResponse = response.result.value
            
            completion(videosResponse)
        }
    }
    
}
