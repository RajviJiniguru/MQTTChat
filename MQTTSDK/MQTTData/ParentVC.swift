//
//  ParentVC.swift
//  thecareportal
//
//  Created by Jayesh on 24/10/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit

public class ParentVC: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:ThemeManager.shared.currentTheme().commonColor]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func syncDatatoServer(){
        if WSManager.isConnectedNetwork(){
         //   HCProgressHUD.startLoading(onView: self.view)
            DBManager.sharedInstance().copySlaveDatabse()
            DBManager.sharedInstance().generateZipFile(successCompletionHandler: { (response) in
               // HCProgressHUD.stopLoading(fromView: self.view)
                print(response)
            }, messageCallBackHandler: { (msg) in
              //  HCProgressHUD.stopLoading(fromView: self.view)
                print(msg)
            }) { (error) in
              //  HCProgressHUD.stopLoading(fromView: self.view)
                print(error)
            }
        }
    }
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
// MARK:- IBAction Methods
extension ParentVC{
    
    @IBAction func onclickBack(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onclickMenu(_ sender : UIButton){
//        let revealController: SWRevealViewController = self.revealViewController()
//        revealController.revealToggle(animated: true)
    }

}
