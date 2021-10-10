
import UIKit

//Init our ui and dates
var UI=UserInformation()

//UserInformation
struct UserInformation:Codable{
    var CT:[Categories]=[] //Our app categories
    var WB:Bool=false //true black, false white
    var MC:String="001" //White,DarkGray,Black - Main Colors
    var AC:String="Blue" //Accent Color
    var EF:Bool = true //true English , false Farsi
    var QA:Int = -1 //App Quick Action: 0 Open Event, 0 Open Task, 1 Open Search, 2 Open Convert
}


//Recipe
struct Recipes:Codable,Comparable,Equatable{
    var Name:String=""
    var Ingredients:String=""
    var Direction:String=""
    var Category:Categories=Categories()
    var Images:[Data]=[]
    var ID:UUID=UUID.init()
    
    static func ==(lhs:Recipes,rhs:Recipes)->Bool{
        return lhs.Name == rhs.Name || lhs.ID == rhs.ID
    }
    static func < (lhs:Recipes,rhs:Recipes)->Bool{
        return lhs.Name < rhs.Name
    }
}


//Categories
struct Categories:Codable,Comparable,Equatable{
    var Name:String=""
    var ID:UUID=UUID.init()
    
    static func ==(lhs:Categories,rhs:Categories)->Bool{
        return lhs.Name == rhs.Name || lhs.ID == rhs.ID
    }
    static func < (lhs:Categories,rhs:Categories)->Bool{
        return lhs.Name < rhs.Name
    }
}


//Lists
struct ShoppingCart:Codable,Comparable,Equatable{
    var Name:String=""
    var List:String=""
    var Selected:[Bool]=[]
    var ID:UUID=UUID.init()
    
    static func ==(lhs:ShoppingCart,rhs:ShoppingCart)->Bool{
        return lhs.Name == rhs.Name || lhs.ID == rhs.ID
    }
    static func < (lhs:ShoppingCart,rhs:ShoppingCart)->Bool{
        return lhs.Name < rhs.Name
    }
}


struct CategoryStruct {
    var category=Categories()
    var editing=false
}

struct CartStruct {
    var Update:Bool=false
    var list=ShoppingCart()
}
