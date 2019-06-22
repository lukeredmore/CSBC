import UIKit

func addData(model: String) {
    let filteredo : CharacterSet = CharacterSet(charactersIn: ":()1234567890")
    var titleText : String = model.components(separatedBy: filteredo).joined()
    print(titleText)
    
}

addData(model: "Girl's Varsity Lacrosse @ Norwich(4:00")
