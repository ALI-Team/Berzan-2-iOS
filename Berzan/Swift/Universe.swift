//
//  Universe.swift
//  Berzan
//
//  Created by Luka Janković on 2017-12-08.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit

extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: self.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context!.clip(to: rect, mask: self.cgImage!)
        context!.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

class mainTabBarController: UITabBarController {
    
    override public func viewWillAppear(_ animated: Bool) {
        tabBar.items?.forEach({ (item) -> () in
            item.image = item.selectedImage?.imageWithColor(color1: UIColor.init(white: 0.0, alpha: 0.6)).withRenderingMode(.alwaysOriginal)
        })
        
        super.viewWillAppear(animated)
    }
}
