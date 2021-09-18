

import UIKit
import CoreData

class LoadHandler: NSObject {
    
    var recipes = AVLTree<Recipes>()
    
    ///Fetch all recipes filtred by certain category
    func FetchFromCoreData(category:Categories,completion:(_ recipe:AVLTree<Recipes>)->Void){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let prediction = NSPredicate(format: "category == %@", category.ID as CVarArg)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RecipeRecord")
        request.predicate = prediction
        do{
            let result:[RecipeRecord] = try context?.fetch(request) as! [RecipeRecord]
            if result.count > 0{
                self.SplitRecipes(recipes: result.chunked(into: 200), indx: 0)
                completion(self.recipes)
            }else{
                print("No Result")
            }
        } catch{
            print("Error in Saving")
        }
    }
    
    ///Fetch all the recipes with no filtering
    func FetchFromCoreData(completion:(_ recipe:AVLTree<Recipes>)->Void){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RecipeRecord")
        do{
            let result:[RecipeRecord] = try context?.fetch(request) as! [RecipeRecord]
            if result.count > 0{
                self.SplitRecipes(recipes: result.chunked(into: 200), indx: 0)
                completion(self.recipes)
            }
        } catch{
            print("Error in Saving")
        }
    }
       
    private func SplitRecipes(recipes:[[RecipeRecord]], indx: Int){
        self.AppendRecipes(recipes: recipes[indx], indx: 0)
        if indx  < recipes.count - 1{
            self.SplitRecipes(recipes: recipes, indx: indx+1)
        }
    }
       
    private func AppendRecipes(recipes:[RecipeRecord], indx:Int){
        self.DecodejSonEvent(json: recipes[indx].recipe ?? "")
        
        if indx < recipes.count - 1{
            self.AppendRecipes(recipes: recipes, indx: indx+1)
        }
    }

    //MARK: - Decode The json event
    private func DecodejSonEvent(json:String){
        do {
            guard let data = json.data(using: .utf8) else { return  }
            let DecodedRecipe = try JSONDecoder().decode(Recipes.self, from: data)
            
            self.recipes.insert(DecodedRecipe)
        } catch { print(error) }
    }
    
}
