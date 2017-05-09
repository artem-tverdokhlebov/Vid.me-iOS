//
//  FeaturedTableViewController.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/8/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class FeaturedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let featuredService: FeaturedService = FeaturedService()
    
    var page: Page?
    var videos: [Video] = [Video]()
    
    var isLoading: Bool = false
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(self.refreshControl)
        
        loadVideos(offset: 0)
    }
    
    private func loadVideos(offset: Int) {
        isLoading = true
        featuredService.loadFeatured(offset: offset) { (videosResponse) in
            if let newVideos = videosResponse?.videos {
                self.videos.append(contentsOf: newVideos)
                
                self.tableView.reloadData()
            }
            
            if let page = videosResponse?.page {
                self.page = page
            }
            
            self.isLoading = false
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        videos = [Video]()
        loadVideos(offset: 0)
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let imageURL = videos[indexPath.row].thumbnail_url else {
            return 200.0
        }
        
        let cacheKey: String? = SDWebImageManager.shared().cacheKey(for: URL(string: imageURL))
        let image: UIImage? = SDImageCache.shared().imageFromCache(forKey: cacheKey)
        
        let screenWidth = UIScreen.main.bounds.width
        let bottomPanelHeight: CGFloat = 40.0
        
        if let image = image {
            return ((screenWidth * image.size.height) / image.size.width) + bottomPanelHeight
        } else {
            return 200.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VideoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "videoItemCell", for: indexPath) as! VideoTableViewCell
        
        let index = indexPath.row
        
        cell.videoPreviewView.sd_setShowActivityIndicatorView(true)
        cell.videoPreviewView.sd_setIndicatorStyle(.gray)
        
        if let imagePath = videos[indexPath.row].thumbnail_url, let imageURL = URL(string: imagePath) {
            cell.videoPreviewView.sd_setImage(with: imageURL) { (image, error, cacheType, url) in
                if cacheType == .none {
                    UIView.performWithoutAnimation {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
        
        cell.videoTitleLabel.text = videos[index].title
        cell.videoLikesLabel.text = "\(videos[index].likes_count ?? 0) likes"
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height && !isLoading {
            if let videosOffset = page?.offset, let videosLimit = page?.limit {
                loadVideos(offset: videosOffset + videosLimit)
            }
        }
    }
}
