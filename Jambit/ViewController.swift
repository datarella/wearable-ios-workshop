//
//  ViewController.swift
//  Jambit
//
//  Created by Michal Lukasiewicz on 2/15/16.
//  Copyright © 2016 Datarella. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = "empty"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("did receive message inside ViewController")
        
        let number = message["number"] as! String
        //let nextNumber = Int(number)! + 1
        
        dispatch_async(dispatch_get_main_queue(),{
            self.label.text = number
        })
     
     //   replyHandler(["number": String(nextNumber)])
        
    }


}

