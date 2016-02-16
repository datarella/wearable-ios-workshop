//
//  HeartRateController.swift
//  Jambit
//
//  Created by Michal Lukasiewicz on 2/15/16.
//  Copyright © 2016 Datarella. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class HeartRateController: WKInterfaceController, HKWorkoutSessionDelegate {

    @IBOutlet var startWorkoutButton: WKInterfaceButton!
    let healthStore = HKHealthStore()
    var workoutSession : HKWorkoutSession?
    var workoutStartDate = NSDate()
    var workoutEndDate = NSDate()
    var samples =  [HKQuantitySample]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    @IBAction func startWorkoutButtonTapped() {
        
        self.workoutSession = HKWorkoutSession(activityType: .Running, locationType: .Outdoor)
        self.workoutSession!.delegate = self        
        self.healthStore.startWorkoutSession(self.workoutSession!)
        
    }
    
    @IBAction func endWorkoutButtonTapped() {
        self.healthStore.endWorkoutSession(self.workoutSession!)
    }

    func saveWorkout() {
        let startDate = self.workoutStartDate
        let endDate = self.workoutEndDate
        let duration = endDate.timeIntervalSinceDate(startDate)
        
        let workout = HKWorkout(activityType: self.workoutSession!.activityType,
            startDate: startDate,
            endDate: endDate,
            duration: duration,
            totalEnergyBurned: nil,
            totalDistance: nil,
            metadata: nil)
        
        // save workout
        self.healthStore.saveObject(workout) {
            (success, error) in
            // add samples to saved workout
            self.healthStore.addSamples(self.samples, toWorkout: workout) {
                (success, error) in
            }
        }

        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let typesToShare = Set([HKObjectType.workoutType()])
        let typesToRead = Set([
           
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!,
            
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
            
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
            
        ])
        
        self.healthStore.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead) { (success, error) -> Void in
            print("authorization granted")
        }
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
            switch toState {
                case .Running: self.workoutDidStart(date)
                case .Ended: self.workoutDidEnd(date)
                default: print("Unexpected state \(toState)")
            }
        
    }
    
    func workoutDidStart(date : NSDate) {
        print("workout started")
        let query = self.createStreamingHeartRateQuery(date)
        self.healthStore.executeQuery(query)
    }
    
    func workoutDidEnd(date: NSDate) {
        print("Workout ended")
        self.workoutEndDate = date
        self.saveWorkout()
    }

    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        print("session can't be started")
    }

    
    func createStreamingHeartRateQuery(workoutStartDate: NSDate) -> HKQuery {
        let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: .None)
        
        let heartRateType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, anchor, error) -> Void in
        }
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.samples += samples
            guard let quantity = samples.last?.quantity else { return }
            let heartRateUnit = HKUnit(fromString: "count/min")
            print("\(quantity.doubleValueForUnit(heartRateUnit))")
            
            let session = WCSession.defaultSession()
            
            let messagePayload = ["number": "\(quantity.doubleValueForUnit(heartRateUnit))"]
            
            // here send the current value to companion iOS app
            session.sendMessage(messagePayload, replyHandler: {
                (params: [String : AnyObject]) -> Void in
                print("reply received")
                }) { (error) -> Void in
                 print("error happened")
            }
                        
            dispatch_async(dispatch_get_main_queue(),{
                
                self.startWorkoutButton.setTitle("\(quantity.doubleValueForUnit(heartRateUnit))")
                
            })

        }
        return query
    }

    
}
