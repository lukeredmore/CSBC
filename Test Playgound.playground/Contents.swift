import Foundation
import SwiftyJSON

let jstr = """
[{"title":"International Student Orientation","date":"2019-09-03","time":"All Day","schools":"Seton Catholic Central"},{"title":"SCC First Day of Classes","date":"2019-09-04","time":"All Day","schools":"Seton Catholic Central"},{"title":"Modified Fall Sports Start","date":"2019-09-04","time":"All Day","schools":"Seton Catholic Central"},{"title":"Dutch Bulb Fundraiser for 7 & 8th Grade Starts","date":"2019-09-06","time":"All Day","schools":"Seton Catholic Central"},{"title":"Board Meeting","date":"2019-09-09","time":"6:30 PM","schools":""},{"title":"Scrip Orders Due","date":"2019-09-10","time":"All Day","schools":"Seton Catholic Central"},{"title":"Board Meeting","date":"2019-09-10","time":"6:30 PM - 8:00 PM","schools":""},{"title":"Board Meeting","date":"2019-09-10","time":"6:30 PM - 8:00 PM","schools":""},{"title":"Faculty Meeting","date":"2019-09-11","time":"3:00 PM - 4:00 PM","schools":"Seton Catholic Central"},{"title":"Welcome Back Activity Night Grades 9-12","date":"2019-09-13","time":"8:00 PM - 10:00 PM","schools":"Seton Catholic Central"},{"title":"ACT","date":"2019-09-14","time":"All Day","schools":"Seton Catholic Central"},{"title":"7/8th Bottle Drive","date":"2019-09-14","time":"9:00 AM - 10:00 AM","schools":"Seton Catholic Central"},{"title":"Welcome Back Picnic & Dedication","date":"2019-09-15","time":"11:00 AM - 4:30 PM","schools":"Seton Catholic Central"},{"title":"Opening Mass","date":"2019-09-17","time":"12:40 PM - 1:45 PM","schools":"Seton Catholic Central"},{"title":"Senior Class Parent Meeting","date":"2019-09-18","time":"6:00 PM - 7:00 PM","schools":"Seton Catholic Central"},{"title":"Add/Drop Deadline","date":"2019-09-20","time":"All Day","schools":"Seton Catholic Central"},{"title":"Dutch Bulb Fundraiser for 7 & 8th Grade Ends","date":"2019-09-23","time":"All Day","schools":"Seton Catholic Central"},{"title":"Curriculum Night","date":"2019-09-25","time":"6:30 PM - 9:00 PM","schools":"Seton Catholic Central"},{"title":"Enjoy the City Fundraiser for 7 & 8th Grade Starts","date":"2019-09-26","time":"All Day","schools":"Seton Catholic Central"},{"title":"Homecoming Game","date":"2019-09-27","time":"4:30 PM - 7:00 PM","schools":"Seton Catholic Central"},{"title":"Senior Class Bottle Drive","date":"2019-09-28","time":"10:00 AM - 12:00 PM","schools":"Seton Catholic Central"},{"title":"Homecoming Dance","date":"2019-09-28","time":"7:30 PM - 10:00 PM","schools":"Seton Catholic Central"},{"title":"Construction Career Day","date":"2019-10-02","time":"All Day","schools":"Seton Catholic Central"},{"title":"SAT","date":"2019-10-05","time":"All Day","schools":"Seton Catholic Central"},{"title":"7/8th Bottle Drive","date":"2019-10-05","time":"9:00 AM - 10:00 AM","schools":"Seton Catholic Central"},{"title":"Blessing of the Animals","date":"2019-10-06","time":"1:00 PM - 2:00 PM","schools":"Seton Catholic Central"},{"title":"Board Meeting","date":"2019-10-08","time":"All Day","schools":"Seton Catholic Central"},{"title":"Scrip Orders Due","date":"2019-10-08","time":"All Day","schools":"Seton Catholic Central"},{"title":"Mass","date":"2019-10-08","time":"12:40 PM - 1:40 PM","schools":"Seton Catholic Central"},{"title":"Board Meeting","date":"2019-10-08","time":"6:30 PM - 8:00 PM","schools":""},{"title":"Fall Fundraiser Assembly","date":"2019-10-09","time":"All Day","schools":"Seton Catholic Central"},{"title":"AP Order Deadline","date":"2019-10-09","time":"All Day","schools":"Seton Catholic Central"},{"title":"Faculty Meeting","date":"2019-10-09","time":"3:00 PM - 4:00 PM","schools":"Seton Catholic Central"},{"title":"PPP Meeting","date":"2019-10-09","time":"6:30 PM - 8:00 PM","schools":"Seton Catholic Central"},{"title":"Teen Traffic Safety Day","date":"2019-10-10","time":"All Day","schools":"Seton Catholic Central"},{"title":"8th Grade Hayride","date":"2019-10-10","time":"6:45 PM - 8:00 PM","schools":"Seton Catholic Central"},{"title":"Faculty In-Service Day","date":"2019-10-11","time":"All Day","schools":"Seton Catholic Central"},{"title":"Columbus Day Holiday","date":"2019-10-14","time":"All Day","schools":"Seton Catholic Central"},{"title":"Board Meeting","date":"2019-10-14","time":"6:30 PM","schools":""},{"title":"Enjoy the City Fundraiser for 7 & 8th Grade Ends","date":"2019-10-15","time":"All Day","schools":"Seton Catholic Central"},{"title":"PSAT for Juniors","date":"2019-10-16","time":"All Day","schools":"Seton Catholic Central"},{"title":"Speaker: Steven Hill \" Speak Sobriety\"","date":"2019-10-18","time":"All Day","schools":"Seton Catholic Central"},{"title":"Senior Class Bottle Drive","date":"2019-10-19","time":"10:00 AM - 12:00 PM","schools":"Seton Catholic Central"},{"title":"Little Mermaid","date":"2019-10-24","time":"7:00 PM - 9:00 PM","schools":"Seton Catholic Central"},{"title":"Little Mermaid","date":"2019-10-25","time":"7:00 PM - 9:00 PM","schools":"Seton Catholic Central"},{"title":"Little Mermaid","date":"2019-10-26","time":"7:00 PM - 9:00 PM","schools":"Seton Catholic Central"},{"title":"Little Mermaid","date":"2019-10-27","time":"3:00 PM - 5:00 PM","schools":"Seton Catholic Central"},{"title":"Make Up Picture Day","date":"2019-10-30","time":"All Day","schools":"Seton Catholic Central"}]
"""

struct EventsModel: Codable, Hashable, Comparable {
    
    let event : String
    let date : DateComponents
    let time : String?
    let schools : String?
    
    static func < (lhs : EventsModel, rhs : EventsModel) -> Bool {
        return lhs.date.day! < rhs.date.day!
    }
}

func parseJSON(str: String) -> [EventsModel] {
    let eventsModelSet : Set<EventsModel>?
    let json = JSON
    for event in json {
        let dateInts = event["date"].components(separatedBy: "-")
        let eventToInsert = EventsModel(
            title: event["title"],
            date: DateComponents(year: dateInts[0], month: dateInts[1], day: dateInts[2])
        )
    }
}
