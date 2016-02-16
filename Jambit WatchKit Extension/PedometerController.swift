//
//  PedometerController.swift
//  Jambit
//
//  Created by Michal Lukasiewicz on 2/15/16.
//  Copyright © 2016 Datarella. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

class PedometerController: WKInterfaceController {

    let pedometer = CMPedometer()
    
    
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    @IBOutlet var stepsLabel: WKInterfaceLabel!
    @IBOutlet var ascendedLabel: WKInterfaceLabel!
    @IBOutlet var descendedLabel: WKInterfaceLabel!
    @IBOutlet var paceLabel: WKInterfaceLabel!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let date = NSDate(timeIntervalSinceNow: -(60 * 60 * 24))
        self.pedometer.startPedometerUpdatesFromDate(date) {
            (pedometerData, error) -> Void in
            print("data received")
            if let data = pedometerData {
                dispatch_async(dispatch_get_main_queue(),{
                    self.updateLabelsWithData(data)
                })
            }
        }
        
    }
    
    private func updateLabelsWithData(pedometerData: CMPedometerData) {
        let steps = pedometerData.numberOfSteps.floatValue
        let distance = pedometerData.distance?.floatValue
        let floorsAscended = pedometerData.floorsAscended?.doubleValue
        let floorsDescended = pedometerData.floorsDescended?.doubleValue
        let pace = pedometerData.currentPace?.doubleValue
        
        self.stepsLabel.setText("steps = \(steps)")
        if let distance = distance {
            self.distanceLabel.setText("distance = \(distance)")
        }
        if let floorsAscended = floorsAscended {
            self.ascendedLabel.setText("ascended = \(floorsAscended)")
        }
        if let floorsDescended = floorsDescended {
            self.descendedLabel.setText("descended = \(floorsDescended)")
        }
        if let pace = pace {
            self.paceLabel.setText("pace = \(pace)")
        }
    }


    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
