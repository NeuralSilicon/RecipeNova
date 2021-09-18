import UIKit

extension RecipesVC{

    func DeleteControl(){
        self.recipes.remove(trackRecipe)
        self.filterRecipes.remove(trackRecipe)
              
        if self.filterRecipes.count == 0{
            self.ShowNoView()
        }else{
            self.NoView.removeFromSuperview()
        }
              
        self.limit-=1
        self.collectionView.deleteItems(at: [trackIndex])
            
        ///update core data
        SavingHandler(recipe: trackRecipe).DeleteFromCoreData()
    }
    
}
