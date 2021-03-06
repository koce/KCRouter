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
    
    public func map(url: AnyHashable,
                    conf: KCRouteConf,
                    gotoHandler: KCGotoHandler? = nil,
                    factory: KCRouteViewControllerFactory? = nil)
    {
        let route = KCRoute(conf: conf, gotoHandler: gotoHandler, factory: factory)
        map(url: url, route: route)
    }
    
    public func map(url: AnyHashable, to controller: String)
    {
        let conf = KCRouteConf(url: url, to: controller)
        map(url: url, conf: conf)
    }
    
    public func map(url: AnyHashable,
                    to controller: String,
                    gotoHandler: KCGotoHandler? = nil,
                    factory: KCRouteViewControllerFactory? = nil)
    {
        let conf = KCRouteConf(url: url, to: controller)
        map(url: url, conf: conf, gotoHandler: gotoHandler, factory: factory)
    }
    
    @discardableResult
    public func open(url: AnyHashable) -> Bool {
        return open(url: url, params: nil)
    }
    
    @discardableResult
    public func open(url: AnyHashable, params: KCGotoParams?) -> Bool {
        if let route = routes[url] {
            return route.handle(params)
        }
        return false
    }
}
