//
//  AthleticsCalendarManager.swift
//  CSBC
//
//  Created by Luke Redmore on 12/31/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import EventKitUI
import MapKit

class AthleticsCalendarManager {
    private static var eventStore = EKEventStore()
    
    // Request access to the Calendar
    private static func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    // Generate an event which will be then added to the calendar
    private static func generateAthleticCalendarEvent(event: AthleticsModel) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = event.toString().components(separatedBy: " on ")[0]
        newEvent.location = newEvent.title.contains(" vs. ") ? "Seton Catholic Central" : event.title.components(separatedBy: " @ ")[1]
        newEvent.startDate = event.realDate
        newEvent.endDate = event.realDate.addingTimeInterval(5400)
        let alarm = EKAlarm(relativeOffset: TimeInterval(7200))
        newEvent.addAlarm(alarm)
        return newEvent
    }
    
    // Show event kit ui to add event to calendar
    static func presentCalendarModalToAddAthleticEvent(event: AthleticsModel, completion : @escaping (Bool) -> Void) {
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized:
            presentEditCalendarModal(event: event)
            completion(true)
        case .notDetermined:
            requestAccess { (accessGranted, error) in
                if accessGranted { self.presentEditCalendarModal(event: event) }
                completion(accessGranted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    // Present edit event calendar modal
    private static func presentEditCalendarModal(event: AthleticsModel) {
        let event = generateAthleticCalendarEvent(event: event)
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(eventModalVC, animated: true)
        }
    }
}

extension EKEventEditViewController : EKEventEditViewDelegate {
    open override func viewDidLoad() {
        self.editViewDelegate = self
    }
    public func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}
