//
//  DemoViewController.swift
//  iDoc
//
//  Created by Broccoli on 15/10/30.
//  Copyright © 2015年 iue. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//       QRCodeManager().startScan(self)
        self.present(QRCodeViewController(completion: { (codeInfo) -> Void in
            print(codeInfo)
        }), animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    /** 二维码 生成
    *  https://github.com/reesun1130/SYQRCodeDemo
    */
}
