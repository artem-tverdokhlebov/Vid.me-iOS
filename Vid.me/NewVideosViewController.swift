//
//  File.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/9/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation

class NewVideosViewController: VideosViewController {
    override var dataService: VideosService? {
        get {
            return NewVideosService()
        }
        set {}
    }
}
