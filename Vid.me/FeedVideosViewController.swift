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
                self.loginStackView.isHidden = true
                self.loginStackView.resignFirstResponder()
                
                self.loadVideos(offset: 0)
            } else if let error = error {
                if error.kind != .networkProblem {
                    self.showAlert(message: error.error!)
                }
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        // TODO: request to log out
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: handle UI state on user status
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
    }
}
