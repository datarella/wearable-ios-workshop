//
//  InterfaceController.swift
//  Jambit WatchKit Extension
//
//  Created by Michal Lukasiewicz on 2/15/16.
//  Copyright © 2016 Datarella. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet var button: WKInterfaceButton!
    var nextNumber = "1"
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func buttonTapped() {
        print("button tapped")
        let session = WCSession.defaultSession()

        let messagePayload = ["number": nextNumber]
        
        session.sendMessage(messagePayload, replyHandler: {
            (params: [String : AnyObject]) -> Void in
                print("reply received")
            
                let number = params["number"] as! String
                self.nextNumber = number
            
                dispatch_async(dispatch_get_main_queue(),{
                    self.button.setTitle(number)
                })
            
            }) { (error) -> Void in
                print("error happened")
        }
        
    }
}
