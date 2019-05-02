//
//  UIAlertControllerExtensions.swift
//  thecareportal
//
//  Created by Jayesh on 30/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit

extension UIAlertController{
    func showAlertController(viewcontroller : UIViewController,title : String,message : String,buttons : [String],type : UIAlertController.Style,completionBlock : @escaping ((Int,String) -> ())){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: type)
        for (index,btn) in buttons.enumerated(){
          alertController.addAction(UIAlertAction(title: btn, style: .default, handler: { (action) in
                completionBlock(index,btn)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        }))
        viewcontroller.present(alertController, animated: true, completion: nil)
    }
}
