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
    
    /// 设置路由id
    ///
    /// - Parameter identifier: 路由id
    func setIdentifier(_ identifier: AnyHashable)
    
    /// 获取路由id
    ///
    /// - Returns: 路由id
    func getIdentifier() -> AnyHashable?
    
    /// 设置跳转参数
    ///
    /// - Parameter params: 参数
    func setParams(_ params: KCGotoParams?)
    
    /// 获取跳转参数
    ///
    /// - Returns: 跳转参数
    func getParams() -> KCGotoParams?
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


public struct KCRouteConf {
    
    /// 注册的url
    public var url: AnyHashable
    
    /// 打开的类名
    public var openClass: AnyClass?
    
    /// 所在堆栈序号，nil表示任意堆栈都可以
    public var tabbarIndex: Int?
    
    /// 是否使用Present展示
    public var isPresent: Bool
    
    /// present样式
    public var presentationStyle: UIModalPresentationStyle
    
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
    ///   - presentStyle: present样式，默认为fullScreen
    ///   - hideBottom: push是否隐藏底部tabBar，默认为true
    ///   - isOnly: 是否唯一，默认为false
    ///   - isRoot: 是否是根页面，默认为false
    public init(url: AnyHashable,
                to className: String,
                at index: Int? = nil,
                isPresent: Bool = false,
                presentStyle: UIModalPresentationStyle = .fullScreen,
                hideBottom: Bool = true,
                isOnly: Bool = false,
                isRoot: Bool = false)
    {
        self.url = url
        self.openClass = KCRouteGetClass(with: className)
        
        self.tabbarIndex = index
        
        self.isPresent = isPresent
        self.presentationStyle = presentStyle
        
        self.hidesBottomBarWhenPushed = hideBottom
        self.isOnly = isOnly
        self.isRoot = isRoot
    }
    
}

public protocol KCGotoHandler {
    
    /// 处理跳转事件
    ///
    /// - Parameters:
    ///   - conf: 配置
    ///   - params: 跳转参数
    ///   - factory: 创建视图控制器工厂
    /// - Returns: 是否成功跳转
    func handle(conf: KCRouteConf,
                params: KCGotoParams?,
                factory: KCRouteViewControllerFactory) -> Bool
    
    /// 处理Presnet事件
    ///
    /// - Parameters:
    ///   - conf: 配置
    ///   - params: 跳转参数
    ///   - factory: 创建视图控制器工厂
    /// - Returns: 是否成功跳转
    func handlePresent(conf: KCRouteConf,
                       params: KCGotoParams?,
                       factory: KCRouteViewControllerFactory) -> Bool
    
    /// 处理Push事件
    ///
    /// - Parameters:
    ///   - conf: 配置
    ///   - params: 跳转参数
    ///   - factory: 创建视图控制器工厂
    /// - Returns: 是否成功跳转
    func handlePush(conf: KCRouteConf,
                    params: KCGotoParams?,
                    factory: KCRouteViewControllerFactory) -> Bool
    
    /// Push视图控制器
    ///
    /// - Parameters:
    ///   - controller: 要Push的视图控制器
    ///   - conf: 配置
    ///   - navigation: 导航控制器
    /// - Returns: 是否成功跳转
    func pushViewController(_ controller: UIViewController,
                            conf: KCRouteConf,
                            in navigation: UINavigationController) -> Bool
    
    /// Pop到目的视图控制器
    ///
    /// - Parameters:
    ///   - controller: 目的视图控制器
    ///   - navigation: 要Pop的 navigationController
    /// - Returns: 是否Pop成功
    func popToViewController(_ controller: UIViewController,
                             in navigation: UINavigationController) -> Bool
}

extension KCGotoHandler {
    
    /// 处理跳转事件
    public func handle(conf: KCRouteConf,
                       params: KCGotoParams?,
                       factory: KCRouteViewControllerFactory) -> Bool
    {
        if conf.isPresent {
            return handlePresent(conf: conf, params: params, factory: factory)
        } else {
            return handlePush(conf: conf, params: params, factory: factory)
        }
    }
    
    /// 处理Presnet事件
    public func handlePresent(conf: KCRouteConf,
                              params: KCGotoParams?,
                              factory: KCRouteViewControllerFactory) -> Bool
    {
        guard let rootController = factory.getRootViewController(),
            let controller = factory.createViewController(conf: conf, params: params) else {
            return false
        }
        
        if let presented = rootController.presentedViewController {
            if let navi = presented as? UINavigationController {
                return pushViewController(controller, conf: conf, in: navi)
            } else {
                presented.dismiss(animated: true, completion: nil)
            }
        }
        
        let navi = factory.createNavigationController(rootViewController: controller)
        navi.modalPresentationStyle = conf.presentationStyle
        rootController.present(navi, animated: true, completion: nil)
        return true
    }
    
    /// 处理Push事件
    public func handlePush(conf: KCRouteConf,
                           params: KCGotoParams?,
                           factory: KCRouteViewControllerFactory) -> Bool
    {
        guard let rootController = factory.getRootViewController(),
            let controller = factory.createViewController(conf: conf, params: params) else {
                return false
        }
        
        var toNavigationController: UINavigationController?
        
        if let tabBarController = rootController as? UITabBarController {
            
            if let toIndex = conf.tabbarIndex,
                let controllers = tabBarController.viewControllers {  //需要切换tab
                
                if controllers.count > toIndex { //可以切换
                    tabBarController.selectedIndex = toIndex
                    toNavigationController = controllers[toIndex] as? UINavigationController
                }
            } else if let viewController = tabBarController.selectedViewController {
                toNavigationController = viewController as? UINavigationController
            }
            
        } else if let navigationController = rootController as? UINavigationController {
            toNavigationController = navigationController
        }
        
        if toNavigationController != nil {
            return pushViewController(controller, conf: conf, in: toNavigationController!)
        }
        return false
    }
    
    /// Push视图控制器
    public func pushViewController(_ controller: UIViewController,
                                   conf: KCRouteConf,
                                   in navigation: UINavigationController) -> Bool
    {
        if conf.isOnly, popToViewController(controller, in: navigation)  {  //页面唯一
            return true
        }
        navigation.pushViewController(controller, animated: true)
        return true
    }
    
    /// Pop到目的视图控制器
    public func popToViewController(_ controller: UIViewController,
                                    in navigation: UINavigationController) -> Bool
    {
        guard let compatibleController = controller as? KCRouteCompatible,
            let identifier = compatibleController.getIdentifier() else {
            return false
        }
        
        var viewControllers = [UIViewController]()
        for viewController in navigation.viewControllers {
            if let compatible = viewController as? KCRouteCompatible  {
                if identifier == compatible.getIdentifier() {
                    //重设参数
                    let params = compatibleController.getParams()
                    compatible.setParams(params)
                    viewControllers.append(viewController)
                    
                    navigation.setViewControllers(viewControllers, animated: true)
                    return true
                }
            }
            viewControllers.append(viewController)
        }
        return false
    }
}

public protocol KCRouteViewControllerFactory {
    
    /// 获取页面根控制器
    /// Notice: 根控制器必须为 UITabbarController 或 UINavagationController
    /// ‼️建议自己实现‼️
    ///
    /// - Returns: UIViewController
    func getRootViewController() -> UIViewController?
    
    /// 创建导航控制器
    ///
    /// - Parameter rootViewController: 导航控制器的根视图控制器
    /// - Returns: 导航控制器
    func createNavigationController(rootViewController: UIViewController) -> UINavigationController
    
    /// 创建视图控制器
    ///
    /// - Parameters:
    ///   - conf: 配置
    ///   - params: 跳转参数
    /// - Returns: 视图控制器
    func createViewController(conf: KCRouteConf, params: KCGotoParams?) -> UIViewController?
}

extension KCRouteViewControllerFactory {
    
    /// 获取页面根控制器
    public func getRootViewController() -> UIViewController? {
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.rootViewController
        }
        return nil
    }
    
    /// 创建导航控制器
    public func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        return UINavigationController(rootViewController: rootViewController)
    }
    
    /// 创建视图控制器
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
                factory: KCRouteViewControllerFactory? = nil)
    {
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
