//
//  Reachability.swift
//  SmartStatis
//
//  Created by wu yun en on 2019/5/11.
//  Copyright © 2019 GenX Leader. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit
import SystemConfiguration.CaptiveNetwork
public let ReachabilityStatusChangedNotification = "ReachabilityStatusChangedNotification"
public enum ReachabilityType: CustomStringConvertible {
    case WWAN
    case WiFi
    public var description: String {
        switch self {
        case .WWAN: return "WWAN"
        case .WiFi: return "WiFi"
        }
    }
}

public enum ReachabilityStatus: CustomStringConvertible  {
    case Offline
    case Online(ReachabilityType)
    case Unknown
    
    public var description: String {
        switch self {
        case .Offline: return "Offline"
        case .Online(let type): return "Online (\(type))"
        case .Unknown: return "Unknown"
        }
    }
}

/*
    This class is to manage the internet connect for the device.
 */
public class Reachability {
    func connectionStatus() -> ReachabilityStatus {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = (withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return .Unknown
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .Unknown
        }
        
        return ReachabilityStatus(reachabilityFlags: flags)
    }
    
    func monitorReachabilityChanges() {
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!
        
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
            let status = ReachabilityStatus(reachabilityFlags: flags)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil, userInfo: ["Status": status.description])}, &context)
        
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }
}

extension ReachabilityStatus {
    
    public init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.connectionRequired)
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        if !connectionRequired && isReachable {
            if isWWAN {
                self = .Online(.WWAN)
            } else {
                self = .Online(.WiFi)
            }
        } else {
            self =  .Offline
        }
    }
}
