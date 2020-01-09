//
//  KCNavigatorMaps.swift
//  KCTools
//
//  Created by Koce on 2019/4/30.
//  Copyright © 2019 Koce. All rights reserved.
//

import UIKit

struct RouteFactory: KCRouteViewControllerFactory {
    
    func getRootViewController() -> UIViewController? {
        return BaseNavigationController.rootVC
    }
    
    func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        return BaseNavigationController(rootViewController: rootViewController)
    }
}

class KCRouterManager {
    enum RouterUrl: String {
        case Home
        case Setting
    }
    
    static func setUp() {
        map(.Home, to: "HomeViewController", isPresent: false, isOnly: true)
        map(.Setting, to: "SettingViewController", isPresent: true, isOnly: true)
    }
    
    static func map(_ url: RouterUrl, to controller: String, isPresent: Bool) {
        map(url, to: controller, isPresent: false, isOnly: false)
    }
    
    static func map(_ url: RouterUrl, to controller: String, isPresent: Bool, isOnly: Bool) {
        let conf = KCRouteConf(url: url.rawValue, to: controller, isPresent: isPresent, isOnly: isOnly)
        KCRouter.shared.map(url: url.rawValue, conf: conf, factory: RouteFactory())
    }
    
    @discardableResult
    static func open(_ url: RouterUrl) -> Bool {
        return KCRouter.shared.open(url: url.rawValue)
    }
    
    @discardableResult
    static func open(_ url: RouterUrl, extraParams extra: [AnyHashable : Any]?) -> Bool {
        return KCRouter.shared.open(url: url.rawValue, params: extra)
    }
}

