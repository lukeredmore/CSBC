import UIKit
import Alamofire
import SwiftyJSON

class AthleticsViewController: UIViewController {
    
    var athleticsData = AthleticsData()
    let athleticsDataURL = "https://www.schedulegalaxy.com/api/v1/schools/163/activities"
    let teamAbbreviations = ["V":"Varsity","JV":"JV","7/8TH":"Modified"]
    var gameInfo : [String : String] = [:]
    var gameInfoArray : [[String : String]] = [[:]]
    var gameDates : [String?] = []
    var numberOfDates : [String:Int] = [:]
    var numberOfDatesArray : [Int] = []
    var numberOfDatesSum : [Int] = []
    var firstTimeLoaded = true
    var searchController : UISearchController!
    let requestingURL = true
    var showSearchBar = false
    
    private var originalTableViewOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Athletics"
        firstTimeLoaded = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if athleticsData.groupedArray.count < 2 {
            print("groupedArray is empty on viewWillAppear")
        } else {
            print("groupedArray has \(athleticsData.groupedArray.count) values on viewWillAppear")
        }
        if athleticsData.groupedArray == [[[:]]] {
            showSearchBar = false
            view.layoutIfNeeded()
            getAthleticsData(url: athleticsDataURL)
        } else {
            //setupTable()
        }
    }
    
    //MARK: Athletics Data Methods
    func getAthleticsData(url: String) {
        print("we are asking for data")
        let parameters = ["game_types" : ["regular_season", "scrimmage", "post_season", "event"]]
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Athletics Data Received")
                let athleticsJSON : JSON = JSON(response.result.value!)
                self.athleticsData.parseAthleticsData(json: athleticsJSON)
                //self.setupTable()
            }
        }
    }
    
    
}

class AthleticsData {
    let teamAbbreviations = ["V":"Varsity","JV":"JV","7/8TH":"Modified"]
    var gameInfo : [String : String] = [:]
    var gameInfoArray : [[String : String]] = [[:]]
    var gameDates : [String?] = []
    var numberOfDates : [String:Int] = [:]
    var numberOfDatesArray : [Int] = []
    var header = ""
    var rowHeight : [IndexPath : CGFloat] = [:]
    var numberOfDatesSum : [Int] = []
    var firstTimeLoaded = true
    let requestingURL = true
    var athleticsJSON : JSON?
    var groupedArray : [[[String:String]]] = [[[:]]]
    var modelList : [AthleticsModel] = []
    
    
    func parseAthleticsData(json : JSON) {
        modelList = []
        var dateToBeat = "\(json["data"][0]["date"])"
        var currentDate = dateToBeat
        var dateString : String = ""
        var n = 0
        print(dateToBeat)
        while n < json["data"].count {
            var homeGameList : [String] = []
            var genderList : [String] = []
            var levelList : [String] = []
            var sportList : [String] = []
            var opponentList : [String] = []
            var timeList : [String] = []
            while ((currentDate == dateToBeat) && (n < json["data"].count)) {
                let title = "\(json["data"][n]["title"])"
                var titleArray = title.components(separatedBy: " ")
//                if titleArray[0] == "POSTPONED:" {
//                    titleArray.remove(at: 0)
//                }
                titleArray.removeLast()
                titleArray.removeLast()
                if titleArray[0].contains("(") { //if each data is formatted correctly
                    if titleArray[3] == "@" {
                        homeGameList.append("@")
                    } else {
                        homeGameList.append("vs.")
                    }
                    if titleArray[0] == "(G)" {
                        genderList.append("Girl")
                    } else {
                        genderList.append("Boy")
                    }
                    levelList.append(teamAbbreviations[titleArray[1]] ?? "")
                    var sport = titleArray[2]
                    if sport == "Outdoor" {
                        sport = "Track & Field"
                    }
                    sportList.append(sport)
                    if titleArray.count == 8 {
                        opponentList.append(titleArray[4] + titleArray[5])
                    } else if titleArray.count == 9 {
                        opponentList.append(titleArray[4] + titleArray[5] + titleArray[6])
                    } else {
                        opponentList.append(titleArray[4])
                    }
                    timeList.append("\(json["data"][n]["start_time"])")
                    currentDate = "\(json["data"][n+1]["date"])"
                    dateString = "\(json["data"][n]["date"])".replacingOccurrences(of: ",", with: "")
                    let months = ["Jan":"01", "Feb":"02", "Mar":"03", "Apr":"04", "May":"05", "Jun":"06", "Jul":"07", "Aug":"08", "Sep":"09", "Oct":"10", "Nov":"11", "Dec":"12"]
                    var dateArray = dateString.components(separatedBy: " ")
                    dateArray[0] = months[dateArray[0]]!
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM dd yyyy"
                    let date = formatter.date(from: "\(dateArray[0]) \(dateArray[1]) \(dateArray[2])")
                    formatter.dateFormat = "EEEE, MMMM d"
                    dateString = formatter.string(from: date!)
                    n += 1
                }
                
            }
            dateToBeat = currentDate
            print("adding new model for \(dateString)")
            let modelToAppend = AthleticsModel(homeGame: homeGameList, gender: genderList, level: levelList, sport: sportList, opponent: opponentList, time: timeList, date: dateString)
            modelList.append(modelToAppend)
            print(modelToAppend)
        }
    }
    
}

struct AthleticsModel {
    let homeGame : [String]
    let gender : [String]
    let level : [String]
    let sport : [String]
    let opponent : [String]
    let time : [String]
    let date : String
}


let vc = AthleticsViewController()
vc.getAthleticsData(url: "https://www.schedulegalaxy.com/api/v1/schools/163/activities")
