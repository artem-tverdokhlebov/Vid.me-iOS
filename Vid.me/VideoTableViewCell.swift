//
//  VideoTableViewCell.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/8/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoTableViewCell: UITableViewCell {
    
    var videoID: String?
    
    @IBOutlet weak var videoPreviewView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoLikesLabel: UILabel!
    
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor
        
        return playerLayer
    }()
    
    private var player: AVPlayer?
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.color = UIColor.white
        
        return activityIndicator
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.playerLayer.removeFromSuperlayer()
        self.playerLayer.player = nil
        
        if let player = self.player {
            player.pause()
            player.replaceCurrentItem(with: nil)

            player.removeObserver(self, forKeyPath: "status")
            NotificationCenter.default.removeObserver(player, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            self.player = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.videoPreviewView.addSubview(self.activityIndicatorView)
        
        NSLayoutConstraint(item: self.activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self.videoPreviewView, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: self.activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self.videoPreviewView, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    func playVideo(videoURL: URL) {
        self.activityIndicatorView.startAnimating()
        
        if self.player == nil {
            self.player = AVPlayer(url: videoURL)
            
            self.playerLayer.player = self.player
            self.playerLayer.frame = self.videoPreviewView.bounds
            
            self.player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            if let player = self.player {
                NotificationCenter.default.addObserver(player, selector: #selector(self.stopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            }
        }
        
        self.player?.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? AVPlayer == self.player && keyPath == "status" {
            if self.player?.status == AVPlayerStatus.readyToPlay && self.player?.currentItem != nil {
                self.videoPreviewView.layer.addSublayer(self.playerLayer)
            }
        }
    }
    
    func stopVideo() {
        self.activityIndicatorView.stopAnimating()
        self.playerLayer.removeFromSuperlayer()
        
        if let player = self.player {
            player.pause()
            player.replaceCurrentItem(with: nil)
            
            player.removeObserver(self, forKeyPath: "status")
            NotificationCenter.default.removeObserver(player, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            self.player = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.playerLayer.frame = self.videoPreviewView.bounds
    }
}
