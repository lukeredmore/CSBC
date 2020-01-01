//
//  EventsCalendarManager.swift
//  CSBC
//
//  Created by Luke Redmore on 1/1/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import EventKitUI
import MapKit

class EventsCalendarManager {
    private static var eventStore = EKEventStore()
    
    // Request access to the Calendar
    private static func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    // Generate an event which will be then added to the calendar
    private static func generateEventsCalendarEvent(event: EventsModel) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = event.event
        newEvent.location = event.schools
        if event.allDay {
            newEvent.isAllDay = true
        }
        newEvent.startDate = event.realDate
        newEvent.endDate = event.realDate.addingTimeInterval(3600)
        let alarm = EKAlarm(relativeOffset: TimeInterval(7200))
        newEvent.addAlarm(alarm)
        return newEvent
    }
    
    // Show event kit ui to add event to calendar
    static func presentCalendarModalToAddEvent(event: EventsModel, completion : @escaping (Bool) -> Void) {
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
    private static func presentEditCalendarModal(event: EventsModel) {
        let event = generateEventsCalendarEvent(event: event)
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(eventModalVC, animated: true)
        }
    }
}


