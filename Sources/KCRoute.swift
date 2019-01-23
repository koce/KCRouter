//
//  KCRoute.swift
//  KCRouter
//
//  Created by Koce on 2019/1/4.
//  Copyright © 2019 Koce. All rights reserved.
//

import UIKit

public typealias KCGotoParams = [AnyHashable : Any]

public protocol KCRouteCompatible {
    func setIdentifier(_ identifier: AnyHashable)
    func getIdentifier() -> AnyHashable?
    func setParams(_ params: KCGotoParams?)
    func getParams() -> KCGotoParams?
}

public struct KCRouteConf {
    
    /// 注册的url
    public var url: AnyHashable
    
    /// 打开的类名
    public var openClass: AnyClass?
    
    /// 所在堆栈序号，nil表示任意堆栈都可以
    public var tabbarIndex: Int?
    
    /// 是否使用Present展示
    public var isPresent: Bool
    
    /// push是否隐藏底部tabBar
    public var hidesBottomBarWhenPushed: Bool
    
    /// 页面是否唯一
    public var isOnly: Bool
    
    /// 是否是根页面
    public var isRoot: Bool
    
    /// 初始化
    ///
    /// - Parameters:
    ///   - url: 注册的url
    ///   - className: 控制器名称
    ///   - index: 所在堆栈序号，nil表示任意堆栈都可以
    ///   - isPresent: 是否使用Present展示，默认为false
    ///   - hideBottom: push是否隐藏底部tabBar，默认为true
    ///   - isOnly: 是否唯一，默认为false
    ///   - isRoot: 是否是根页面，默认为false
    public init(url: AnyHashable,
                to className: String,
                at index: Int? = nil,
                isPresent: Bool = false,
                hideBottom: Bool = true,
                isOnly: Bool = false,
                isRoot: Bool = false) {
        self.url = url
        self.openClass = KCRouteGetClass(with: className)
        
        self.tabbarIndex = index
        
        self.isPresent = isPresent
        self.hidesBottomBarWhenPushed = hideBottom
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
    public func handle(conf: KCRouteConf,
                       params: KCGotoParams?,
                       factory: KCRouteViewControllerFactory) -> Bool {
        
        if conf.isPresent {
            return handlePresent(conf: conf, params: params, factory: factory)
        } else {
            return handlePush(conf: conf, params: params, factory: factory)
        }
    }
    
    /// 处理Presnet事件
    ///
    /// - Parameters:
    ///   - conf: 配置
    ///   - params: 跳转参数
    ///   - factory: 创建视图控制器工厂
    /// - Returns: 是否成功跳转
    public func handlePresent(conf: KCRouteConf,
                              params: KCGotoParams?,
                              factory: KCRouteViewControllerFactory) -> Bool {
        guard let tabBarController = factory.getTabBarController(),
            let controller = factory.createViewController(conf: conf, params: params) else {
            return false
        }
        
        if let presented = tabBarController.presentedViewController {
            if let navi = presented as? UINavigationController {
                return pushViewController(controller, conf: conf, in: navi)
            } else {
                presented.dismiss(animated: true, completion: nil)
            }
        }
        
        let navi = factory.createNavigationController(rootViewController: controller)
        tabBarController.present(navi, animated: true, completion: nil)
        return true
    }
    
    /// 处理Push事件
    ///
    /// - Parameters:
    ///   - conf: 配置
    ///   - params: 跳转参数
    ///   - factory: 创建视图控制器工厂
    /// - Returns: 是否成功跳转
    public func handlePush(conf: KCRouteConf,
                           params: KCGotoParams?,
                           factory: KCRouteViewControllerFactory) -> Bool {
        guard let tabBarController = factory.getTabBarController(),
            let controller = factory.createViewController(conf: conf, params: params) else {
                return false
        }
        
        let toIndex = conf.tabbarIndex
        var toNavigationController: UINavigationController?
        if toIndex != nil {
            if let controllers = tabBarController.viewControllers {
                if controllers.count > toIndex! {
                    toNavigationController = controllers[toIndex!] as? UINavigationController
                }
            }
        } else if let viewController = tabBarController.selectedViewController {
            toNavigationController = viewController as? UINavigationController
        }
        
        if toNavigationController != nil {
            return pushViewController(controller, conf: conf, in: toNavigationController!)
        }
        return false
    }
    
    /// push视图控制器
    ///
    /// - Parameters:
    ///   - controller: 要Push的视图控制器
    ///   - conf: 配置
    ///   - navigation: 导航控制器
    /// - Returns: 是否成功跳转
    public func pushViewController(_ controller: UIViewController,
                                   conf: KCRouteConf,
                                   in navigation: UINavigationController) -> Bool {
        navigation.pushViewController(controller, animated: true)
        return true
    }
}

public protocol KCRouteViewControllerFactory {
    func getTabBarController() -> UITabBarController?
    func createNavigationController(rootViewController: UIViewController) -> UINavigationController
    func createViewController(conf: KCRouteConf, params: KCGotoParams?) -> UIViewController?
}

extension KCRouteViewControllerFactory {
    
    /// 获取堆栈
    ///
    /// - Returns: 堆栈
    public func getTabBarController() -> UITabBarController? {
        if let keyWindow = UIApplication.shared.keyWindow,
            let rootController = keyWindow.rootViewController {
            return rootController as? UITabBarController
        }
        return nil
    }
    
    /// 创建导航控制器
    ///
    /// - Parameter rootViewController: 导航控制器的根视图控制器
    /// - Returns: 导航控制器
    public func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        return UINavigationController(rootViewController: rootViewController)
    }
    
    /// 创建视图控制器
    ///
    /// - Parameters:
    ///   - conf: 配置
    ///   - params: 跳转参数
    /// - Returns: 视图控制器
    public func createViewController(conf: KCRouteConf, params: KCGotoParams?) -> UIViewController? {
        guard let openClass = conf.openClass,
            let controllerClass = openClass as? UIViewController.Type else {
            return nil
        }
        
        let controller = controllerClass.init(nibName: nil, bundle: nil)
        controller.hidesBottomBarWhenPushed = conf.hidesBottomBarWhenPushed
        
        if let routeCompatible = controller as? KCRouteCompatible {
            routeCompatible.setIdentifier(conf.url)
            routeCompatible.setParams(params)
        }
        return controller
    }
}

private struct KCDefaultGotoHandler: KCGotoHandler {}
private struct KCDefaultFactory: KCRouteViewControllerFactory {}

public struct KCRoute {
    public var conf: KCRouteConf
    public var gotoHandler: KCGotoHandler
    public var factory: KCRouteViewControllerFactory
    
    public init(conf: KCRouteConf,
                gotoHandler: KCGotoHandler? = nil,
                factory: KCRouteViewControllerFactory? = nil) {
        self.conf = conf
        
        if gotoHandler != nil {
            self.gotoHandler = gotoHandler!
        } else {
            self.gotoHandler = KCDefaultGotoHandler()
        }
        
        if factory != nil {
            self.factory = factory!
        } else {
            self.factory = KCDefaultFactory()
        }
    }
    
    public func handle(_ params: KCGotoParams?) -> Bool {
        return gotoHandler.handle(conf: conf, params: params, factory: factory)
    }
}


///  根据类名获取类型
///
/// - Parameter name: 类名
/// - Returns: 类型
public func KCRouteGetClass(with name: String) -> AnyClass? {
    /// 获取命名空间
    guard let clsName = Bundle.main.infoDictionary!["CFBundleExecutable"] else {
        return nil
    }
    let cls: AnyClass? = NSClassFromString((clsName as! String) + "." + name)
    return cls
}
