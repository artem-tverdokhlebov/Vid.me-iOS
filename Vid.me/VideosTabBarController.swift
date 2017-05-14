//
//  VideosTabBarController.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/14/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit

class VideosTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let videosViewController: VideosViewController? = viewController as? VideosViewController
        
        videosViewController?.playVideoInCell()
    }
}
