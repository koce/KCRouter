//
//  BaseNavigationController.swift
//  KCRouter
//
//  Created by Koce on 2020/1/9.
//  Copyright © 2020 Koce. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    static let rootVC = BaseNavigationController(rootViewController: HomeViewController())

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
