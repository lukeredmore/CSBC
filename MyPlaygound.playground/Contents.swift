
var number : Int? = nil

if let num = number, num == 5 {
    print("right number")
} else {
    print("no")
}

if let num = number {
    if num == 5 {
    print("right number")
    }
} else {
    print("no")
}
