//
//  File.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/9/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation

class NewVideosViewController: VideosViewController {
    override func loadVideosData(offset: Int, completion: @escaping VideosAPIServiceCallback) {
        apiService.getVideosRequest(path: "videos/new", parameters: ["offset": offset], completion: completion)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadVideos(offset: 0)
    }
}
