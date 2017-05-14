//
//  FeedVideosViewController.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/10/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit

class FeedVideosViewController: VideosViewController {
    @IBOutlet weak var loginStackView: UIStackView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func loadVideosData(offset: Int, completion: @escaping VideosAPIServiceCallback) {
        apiService.getVideosRequest(path: "videos/following", parameters: ["offset": offset], requiresAuth: true, completion: completion)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        apiService.authCreate(username: usernameTextField.text!, password: passwordTextField.text!) { (status, error) in
            if status {
                self.showAuthorizedViews()
                
                self.loginStackView.endEditing(true)
                
                self.loadVideos(offset: 0)
            } else if let error = error {
                switch error.kind {
                case .apiError:
                    self.showAlert(message: error.error!)
                    break
                case .networkProblem:
                    self.showNetworkProblemLabel()
                    break
                }
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        self.apiService.authDelete { (status, error) in
            if status {
                self.showLoginViews()
                
                self.videos.removeAll()
            } else if let error = error {
                switch error.kind {
                case .apiError:
                    self.showAlert(message: error.error!)
                    break
                case .networkProblem:
                    self.showNetworkProblemLabel()
                    break
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.apiService.isAuthorized() {
            self.showAuthorizedViews()
            
            self.loadVideos(offset: 0)
        } else {
            self.showLoginViews()
        }
    }
    
    private func showLoginViews() {
        self.usernameTextField.text = nil
        self.passwordTextField.text = nil
        
        self.loginStackView.alpha = 1
        
        self.tableView.alpha = 0
        self.logoutButton.alpha = 0
    }
    
    private func showAuthorizedViews() {
        self.loginStackView.alpha = 0
        
        self.tableView.alpha = 1
        self.logoutButton.alpha = 1
    }
}
