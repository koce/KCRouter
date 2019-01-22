//
//  KCRoute.swift
//  KCRouter
//
//  Created by Koce on 2019/1/4.
//  Copyright © 2019 Koce. All rights reserved.
//

import UIKit

public func KCRouteGetClass(with name: String) -> AnyClass? {
    /// 获取命名空间
    guard let clsName = Bundle.main.infoDictionary!["CFBundleExecutable"] else {
        return nil
    }
    let cls: AnyClass? = NSClassFromString((clsName as! String) + "." + name)
    return cls
}

public struct KCRouteConf {
    
    /// 注册的url
    public var url: AnyHashable
    
    /// 打开的类名
    public var openClass: AnyClass?
    
    /// 所在堆栈序号
    public var tabbarIndex: Int
    /// 任意tabbar都可显示
    private let KCDefaultTabbarIndex: Int = -999
    
    /// 是否使用模态展示
    public var isModel: Bool
    
    /// 页面是否唯一
    public var isOnly: Bool
    
    /// 是否是根页面
    public var isRoot: Bool
    
    public init(url: AnyHashable,
                to className: String,
                at index: Int? = nil,
                isModel: Bool = false,
                isOnly: Bool = false,
                isRoot: Bool = false) {
        self.url = url
        self.openClass = KCRouteGetClass(with: className)
        
        if index == nil {
            self.tabbarIndex = KCDefaultTabbarIndex
        } else {
            self.tabbarIndex = index!
        }
        
        self.isModel = isModel
        self.isOnly = isOnly
        self.isRoot = isRoot
    }
    
}

public protocol KCGotoHandler {}

extension KCGotoHandler {
    
    /// 处理跳转事件
    ///
    /// - Parameters:
    ///   - conf: 配置
    ///   - params: 跳转参数
    ///   - factory: 创建视图控制器工厂
    /// - Returns: 是否成功跳转
    public func handle(conf: KCRouteConf, params: [AnyHashable : Any], factory: KCRouteViewControllerFactory) -> Bool {
        guard let controller = factory.createViewController(conf: conf) else {
            return false
        }
        if conf.isModel {
            
        } else if conf.isRoot {
            
        } else {
            
        }
        
        return true
    }
}

public protocol KCRouteViewControllerFactory {}

extension KCRouteViewControllerFactory {
    
    /// 创建视图控制器
    ///
    /// - Parameter conf: 配置
    /// - Returns: 视图控制器
    func createViewController(conf: KCRouteConf) -> UIViewController? {
        return nil
    }
}

private struct KCDefaultFactory: KCRouteViewControllerFactory {}
private struct KCDefaultGotoHandler: KCGotoHandler {}

public struct KCRoute {
    private let conf: KCRouteConf
    private let gotoHandler: KCGotoHandler
    private let factory: KCRouteViewControllerFactory
    
    init(conf: KCRouteConf,
         gotoHandler: KCGotoHandler = KCDefaultGotoHandler(),
         factory: KCRouteViewControllerFactory = KCDefaultFactory()) {
        self.conf = conf
        self.gotoHandler = gotoHandler
        self.factory = factory
    }
    
    public func handle(_ params: [AnyHashable : Any]) -> Bool {
        return gotoHandler.handle(conf: conf, params: params, factory: factory)
    }
}
