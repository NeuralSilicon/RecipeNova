
import UIKit
import CoreData

extension HomeVC{

    func saveCategory(){
        self.activity.startAnimating()
        
        // create categories
        let breakfast = Categories(Name: "Breakfast", ID: UUID.init())
        let lunch = Categories(Name: "Lunch", ID: UUID.init())
        let dinner = Categories(Name: "Dinner", ID: UUID.init())
        let dessert = Categories(Name: "Dessert", ID: UUID.init())
        categories.append(contentsOf: [breakfast, lunch, dinner, dessert])
        UI.CT.append(contentsOf: [breakfast, lunch, dinner, dessert])
        
        //read json files
        for (i, j) in ["Breakfast","Lunch","Dinner","Dessert"].enumerated(){
            readJson(name: j,category: i)
        }
        
        //save preference
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        appdelegate?.EncodeUI()
        
        //adding to userdefault so we don't have to add these recipes again
        UserDefaults.standard.setValue(true, forKey: "InitialPage")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 0.5) {
                self.initialPage.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
            } completion: { _ in
                self.initialPage.removeFromSuperview()
                self.ReloadHomePage()
            }
        }
    }
    
    
    private func readJson(name:String, category:Int){
        if let url = Bundle.main.url(forResource: name, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url, options: .alwaysMapped)
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
          
                if let rootArray = jsonData as? [[String : String]] {
         
                    for element in rootArray{
                        var recipe = Recipes()
                        recipe.ID = UUID.init()
                        recipe.Category = categories[category]
                        recipe.Name = element["Name"]!
                        if let img = UIImage(named: element["Image"]!)?.jpegData(compressionQuality: 0.3){
                            recipe.Images.append(img)
                        }
                        recipe.Ingredients = element["Ingredients"]!.replacingOccurrences(of: "^", with: " \u{2022} ").replacingOccurrences(of: "$", with: "\n")
                        recipe.Direction = element["Direction"]!.replacingOccurrences(of: "$", with: "\n")
                        saveRecipe(recipes: recipe)
                    }
                }
            } catch {
                print("error:\(error)")
            }
        }
        
    }
    
    private func saveRecipe(recipes:Recipes){
        // save to coredata
        let SR = SavingHandler(recipe: recipes)
        SR.EncodeRecipeToSave(edit: false)
    }
    
}
