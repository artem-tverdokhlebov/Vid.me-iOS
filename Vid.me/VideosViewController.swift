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
import AVKit
import AVFoundation

class VideosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkProblemLabel: UILabel!
    
    let apiService: APIService = APIService()
    
    var page: Page?
    var videos: [Video] = [Video]()
    
    var isLoading: Bool = false
    
    var previousVideoPlayingCell: VideoTableViewCell? = nil
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    var bottomRefreshView: UIView = {
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 80))
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(activityIndicatorView)
        
        NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        
        activityIndicatorView.startAnimating()
        
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "videoItemCell")
        
        self.tableView.addSubview(self.refreshControl)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.previousVideoPlayingCell?.stopVideo()
        self.previousVideoPlayingCell = nil
    }
    
    func loadVideosData(offset: Int, completion: @escaping VideosAPIServiceCallback) {
        completion(nil, nil)
    }
    
    func loadVideos(offset: Int) {
        isLoading = true
        
        self.loadVideosData(offset: offset) { (videosResponse, error) in
            if let response = videosResponse {
                if let status = response.status, status {
                    if let videos = response.videos {
                        if offset == 0 {
                            self.videos = [Video]()
                        }
                        
                        self.videos.append(contentsOf: videos)
                        
                        self.tableView.reloadData()
                    }
                    
                    if let page = response.page {
                        self.page = page
                    }
                    
                    self.isLoading = false
                }
            } else if let error = error {
                switch error.kind {
                case .apiError:
                    self.showAlert(message: error.error)
                    break
                case .networkProblem:
                    self.showNetworkProblemLabel()
                    break
                }
            }
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            if self.tableView.tableFooterView != nil {
                self.tableView.tableFooterView = nil
            }
            
            if self.videos.count > 0 && offset == 0 {
                self.playVideoAt(indexPath: IndexPath(item: 0, section: 0))
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadVideos(offset: 0)
    }
    
    func showNetworkProblemLabel() {
        self.networkProblemLabel.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.networkProblemLabel.alpha = 1
        }) { (finished) in
            UIView.animate(withDuration: 0.2, delay: 2.0, options: [], animations: {
                self.networkProblemLabel.alpha = 0
            }) { (finished) in
                self.networkProblemLabel.isHidden = true
            }
        }
    }
    
    func showAlert(message: String?) {
        let alertController = UIAlertController(title: "Error", message: message ?? "Unknown error", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard videos.count > indexPath.row, let imageURL = videos[indexPath.row].thumbnail_url else {
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
            if self.apiService.isInternetAvailable() {
                cell.videoPreviewView.sd_setImage(with: imageURL) { (image, error, cacheType, url) in
                    if cacheType == .none {
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                        
                        cell.layoutSubviews()
                    }
                }
            } else {
                let cacheKey: String? = SDWebImageManager.shared().cacheKey(for: imageURL)
                cell.videoPreviewView.image = SDImageCache.shared().imageFromCache(forKey: cacheKey)
            }
        }
        
        cell.videoID = videos[index].video_id
        
        cell.videoTitleLabel.text = videos[index].title
        cell.videoLikesLabel.text = "\(videos[index].likes_count ?? 0) likes"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        self.previousVideoPlayingCell?.stopVideo()
        
        if let completeURL = self.videos[indexPath.row].complete_url, let videoURL = URL(string: completeURL) {
            if self.apiService.isInternetAvailable() {
                let player = AVPlayer(url: videoURL)
                
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                playerViewController.modalTransitionStyle = .flipHorizontal
                
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            } else {
                self.showNetworkProblemLabel()
            }
        }
    }
    
    func playVideoInCenterCell() {
        let centerPoint = CGPoint(x: self.tableView.frame.width / 2, y: self.tableView.contentOffset.y + (self.tableView.frame.height / 2))
        
        let indexPath = self.tableView.indexPathForRow(at: centerPoint)
        
        if let indexPath = indexPath {
            self.playVideoAt(indexPath: indexPath)
        }
    }
    
    func playVideoInCell() {
        if self.tableView.contentOffset.y == 0 {
            self.playVideoAt(indexPath: IndexPath(item: 0, section: 0))
        } else if Int(self.tableView.contentOffset.y) >= Int(self.tableView.contentSize.height - self.tableView.frame.size.height) {
            let totalRows = tableView.numberOfRows(inSection: 0)
            self.playVideoAt(indexPath: IndexPath(row: totalRows - 1, section: 0))
        } else {
            self.playVideoInCenterCell()
        }
    }
    
    func playVideoAt(indexPath: IndexPath) {
        if let videoCell = self.tableView.cellForRow(at: indexPath) as? VideoTableViewCell {
            if self.previousVideoPlayingCell != nil {
                guard self.previousVideoPlayingCell?.videoID != videoCell.videoID else {
                    return
                }
                
                self.previousVideoPlayingCell?.stopVideo()
                self.previousVideoPlayingCell = nil
            }
            
            if let completeURL = self.videos[indexPath.row].complete_url, let videoURL = URL(string: completeURL) {
                if self.apiService.isInternetAvailable() {
                    videoCell.playVideo(videoURL: videoURL)
                    
                    self.previousVideoPlayingCell = videoCell
                } else {
                    self.showNetworkProblemLabel()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if (offsetY > contentHeight - scrollViewHeight || (Int(offsetY + scrollViewHeight) == Int(contentHeight + scrollView.contentInset.bottom))) && !isLoading {
            if let videosOffset = self.page?.offset, let videosLimit = self.page?.limit, let videosTotal = page?.total, (videosOffset + videosLimit) < videosTotal {
                self.tableView.tableFooterView = self.bottomRefreshView
                
                self.loadVideos(offset: videosOffset + videosLimit)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.playVideoInCell()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.playVideoInCell()
    }
}
