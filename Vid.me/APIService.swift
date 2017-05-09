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

enum APIServiceError: Error {
    case noInternetConnection
}

typealias APIServiceResponse = (VideosResponse?, APIServiceError?) -> ()

class APIService {
    let baseURL = "https://api.vid.me/"
    
    func getRequest(path: String, parameters: Parameters, completion: @escaping APIServiceResponse) {
        guard isInternetAvailable() else {
            completion(nil, .noInternetConnection)
            
            return
        }
        
        Alamofire.request(baseURL + path, method: .get, parameters: parameters).responseObject { (response: DataResponse<VideosResponse>) in
            let videosResponse = response.result.value
            
            completion(videosResponse, nil)
        }
    }
    
    func isInternetAvailable() -> Bool
    {
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
