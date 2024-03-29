//
//  NewService.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/9/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import SystemConfiguration

struct APIServiceError: Error {
    enum ErrorKind {
        case networkProblem
        case apiError
    }
    
    let error: String?
    let kind: ErrorKind
}

typealias VideosAPIServiceCallback = (VideosResponse?, APIServiceError?) -> ()
typealias AuthAPIServiceCallback = (Bool, APIServiceError?) -> ()

fileprivate let baseURL: String = "https://api.vid.me/"
fileprivate let APIKey: String = "EOYbVSnef0ZYN0nppVnaJR53zLIbFcvB"

fileprivate let userTokenKey = "userToken"
fileprivate let userExpiresKey = "userExpires"
fileprivate let userIDKey = "userID"

class APIService {
    lazy private var authHeader: HTTPHeaders = {
        return ["Authorization": "Basic " + Data((APIKey + ":").utf8).base64EncodedString()]
    }()
    
    lazy private var userDefaults: UserDefaults = UserDefaults.standard
    
    func authCreate(username: String, password: String, completion: @escaping AuthAPIServiceCallback) {
        guard self.isInternetAvailable() else {
            completion(false, APIServiceError(error: nil, kind: .networkProblem))
            
            return
        }
        
        let userObject: Parameters = [
            "username": username,
            "password": password,
            "nocookie": true
        ]
        
        Alamofire.request(baseURL + "auth/create", method: .post, parameters: userObject, encoding: URLEncoding.default, headers: self.authHeader).responseObject { (response: DataResponse<AuthResponse>) in
            if let response = response.result.value {
                if let status = response.status, status {
                    self.userDefaults.set(response.auth?.token, forKey: userTokenKey)
                    self.userDefaults.set(response.auth?.expires?.timeIntervalSince1970, forKey: userExpiresKey)
                    self.userDefaults.set(response.auth?.user_id, forKey: userIDKey)
                    
                    completion(true, nil)
                } else {
                    completion(false, APIServiceError(error: response.error, kind: .apiError))
                }
            } else {
                completion(false, APIServiceError(error: nil, kind: .apiError))
            }
        }
    }
    
    func authDelete(completion: @escaping AuthAPIServiceCallback) {
        guard self.isInternetAvailable() else {
            completion(false, APIServiceError(error: nil, kind: .networkProblem))
            
            return
        }
        
        guard let userToken = self.userToken() else {
            completion(true, nil)
            
            return
        }
        
        Alamofire.request(baseURL + "auth/delete", method: .post, headers: ["AccessToken": userToken]).responseObject { (response: DataResponse<AuthResponse>) in
            if let response = response.result.value {
                if let status = response.status, status {
                    self.userDefaults.set(nil, forKey: userTokenKey)
                    self.userDefaults.set(nil, forKey: userExpiresKey)
                    self.userDefaults.set(nil, forKey: userIDKey)
                    
                    completion(true, nil)
                } else {
                    completion(false, APIServiceError(error: response.error, kind: .apiError))
                }
            } else {
                completion(false, APIServiceError(error: nil, kind: .apiError))
            }
        }
    }
    
    func getVideosRequest(path: String, parameters: Parameters, requiresAuth: Bool = false, completion: @escaping VideosAPIServiceCallback) {
        guard isInternetAvailable() else {
            completion(nil, APIServiceError(error: nil, kind: .networkProblem))
            
            return
        }
        
        var headers: HTTPHeaders? = nil
        
        if requiresAuth, let userToken = self.userToken() {
            headers = ["AccessToken": userToken]
        }
        
        Alamofire.request(baseURL + path, method: .get, parameters: parameters, headers: headers).responseObject { (response: DataResponse<VideosResponse>) in
            if let response = response.result.value {
                if let status = response.status, status {
                    completion(response, nil)
                } else {
                    completion(nil, APIServiceError(error: response.error, kind: .apiError))
                }
            } else {
                completion(nil, APIServiceError(error: nil, kind: .apiError))
            }
        }
    }
    
    private func userToken() -> String? {
        let expireDate = self.userDefaults.double(forKey: userExpiresKey)
        
        guard let userToken = self.userDefaults.string(forKey: userTokenKey), expireDate != 0.0 else {
            return nil
        }
        
        if Date().timeIntervalSince1970 < expireDate {
            return userToken
        } else {
            self.userDefaults.set(nil, forKey: userTokenKey)
            self.userDefaults.set(nil, forKey: userExpiresKey)
            self.userDefaults.set(nil, forKey: userIDKey)
            
            return nil
        }
    }
    
    func isAuthorized() -> Bool {
        return self.userToken() != nil
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
