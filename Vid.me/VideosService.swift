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

protocol VideosService {
    func loadVideos(offset: Int, completion: @escaping APIServiceResponse)
}

class FeaturedVideosService: APIService, VideosService {
    func loadVideos(offset: Int, completion: @escaping APIServiceResponse) {
        getRequest(path: "videos/featured", parameters: ["offset": offset], completion: completion)
    }
}

class NewVideosService: APIService, VideosService {
    func loadVideos(offset: Int, completion: @escaping APIServiceResponse) {
        getRequest(path: "videos/new", parameters: ["offset": offset], completion: completion)
    }
}
