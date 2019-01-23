//
//  KCRouter.swift
//  KCRouter
//
//  Created by Koce on 2019/1/4.
//  Copyright © 2019 Koce. All rights reserved.
//

import Foundation

public class KCRouter {
    public static let shared = KCRouter()
    private init() {}
    
    private var routes = [AnyHashable : KCRoute]()
    
    public func map(url: AnyHashable, route: KCRoute) {
        routes[url] = route
    }
    
    public func map(url: AnyHashable, to controller: String) {
        let conf = KCRouteConf(url: url, to: controller)
        routes[url] = KCRoute(conf: conf)
    }
    
    @discardableResult
    public func open(url: AnyHashable) -> Bool {
        if let route = routes[url] {
            return route.handle(nil)
        }
        return false
    }
}
