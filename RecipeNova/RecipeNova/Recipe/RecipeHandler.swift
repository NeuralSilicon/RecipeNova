
import UIKit

extension RecipeVC{
    
    ///handle options
    func RecipeControl(choice:Int){
        switch choice {
        case 0:///editing recipe
            saving.NewRecipe = self.recipe
            saving.Editing = true
            self.performSegue(withIdentifier: "Add", sender: nil)
        case 1: ///sharing the recipe
            let textShare = [ self.recipe.Name, ("\n" + self.recipe.Ingredients), ("\n" + self.recipe.Direction)]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        case 2: ///add ingredients to cart
            ///create array of bool values for the same amount of ingredients
            var selected:[Bool]=[]
            if self.recipe.Ingredients != ""{
                let count = self.recipe.Ingredients.components(separatedBy: " \u{2022} ").count - 2
                if count > 0 {
                    for _ in 0...self.recipe.Ingredients.components(separatedBy: " \u{2022} ").count - 2{
                        selected.append(false)
                    }
                }
            }
            
            self.LoadingAnimation?.StartloadingAnimation(E: "", F: "")
            self.LoadingAnimation?.RemoveWithNoDelayLoadingScreen()
            
            ///saving to coredata
            SaveLoadListHandler(list: ShoppingCart(Name: self.recipe.Name, List: self.recipe.Ingredients, Selected: selected, ID: UUID.init())).EncodeToSave(Update: false)
        default:
            break
        }
    }
    
    
    func DeleteControl(){
        self.LoadingAnimation?.StartloadingAnimation(E: "", F: "")
        self.LoadingAnimation?.RemoveWithNoDelayLoadingScreen()
        ///delete the recipe from coredata
        SavingHandler(recipe: self.recipe).DeleteFromCoreData()
        ///call back delegate to remove it from recipes page
        self.delegate?.RemoveRecipe(recipe: self.recipe)
        ///if recipe was opened from search page then we need to remove it from there too
        if self.Search{
            self.delegateSearch?.RemoveRecipe(recipe: self.recipe)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}
