
import UIKit

extension HomeVC{
        
    
    func DeleteControl(Choice:Int){
        if Choice==2{ ///Delete Category Only
            UI.CT.remove(at: self.indexPath)
        }else{ ///Delete category and recipes
            self.DeleteRecipes(IndexPath: self.indexPath)
            UI.CT.remove(at: self.indexPath)
        }
            
        ///If our categories are empty then show no category image and label
        if UI.CT.count == 0{
            self.ShowNoView()
        }else{
            self.NoView.removeFromSuperview()
        }

        ///remove that cell from our tableview
        self.tableView.deleteRows(at: [IndexPath(row: self.indexPath, section: 0)], with: .automatic)
    }
    
    private func DeleteRecipes(IndexPath:Int){
        /*
         Init our Savinghanlder object
         Load every recipe under the selected category
         for every recipe in our feteched recipes
         remove recipes one by one
         */
        let SH = SavingHandler(recipe: Recipes())
        LoadHandler().FetchFromCoreData(category: UI.CT[IndexPath]) { (recipes) in
            recipes.root?.traversePreOrder(visit: { (recipe) in
                SH.recipe = recipe
                SH.DeleteFromCoreData()
            })
        }
    }
    
}
