//
//  KCRouter.swift
//  KCRouter
//
//  Created by Koce on 2019/1/4.
//  Copyright © 2019 Koce. All rights reserved.
//

import Foundation

open class KCRouter {
    public static let shared = KCRouter()
    private init() {}
    
    private var routes = [AnyHashable : KCRoute]()
    
    public func map(url: AnyHashable, route: KCRoute) {
        routes[url] = route
    }
    
    public func map(url: AnyHashable, to controller: String) {
        let conf = KCRouteConf(url: url, to: controller)
        let route = KCRoute(conf: conf)
        map(url: url, route: route)
    }
    
    public func map(url: AnyHashable,
                    to controller: String,
                    factory: KCRouteViewControllerFactory) {
        let conf = KCRouteConf(url: url, to: controller)
        let route = KCRoute(conf: conf, factory: factory)
        map(url: url, route: route)
    }
    
    public func map(url: AnyHashable,
                    to controller: String,
                    gotoHandler: KCGotoHandler) {
        let conf = KCRouteConf(url: url, to: controller)
        let route = KCRoute(conf: conf, gotoHandler: gotoHandler)
        map(url: url, route: route)
    }
    
    public func map(url: AnyHashable,
                    to controller: String,
                    gotoHandler: KCGotoHandler,
                    factory: KCRouteViewControllerFactory) {
        let conf = KCRouteConf(url: url, to: controller)
        let route = KCRoute(conf: conf, gotoHandler: gotoHandler, factory: factory)
        map(url: url, route: route)
    }
    
    
    @discardableResult
    public func open(url: AnyHashable) -> Bool {
        return open(url: url, params: nil)
    }
    
    public func open(url: AnyHashable, params: KCGotoParams?) -> Bool {
        if let route = routes[url] {
            return route.handle(params)
        }
        return false
    }
}
