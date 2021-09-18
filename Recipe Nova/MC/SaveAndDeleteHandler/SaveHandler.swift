

import UIKit
import CoreData
class SavingHandler:NSObject{
    
    var recipe:Recipes
    
    init(recipe:Recipes) {
        self.recipe=recipe
    }

    //MARK: - EnCode to save or update
    func EncodeRecipeToSave(edit:Bool){
        do {
        let jsonData = try JSONEncoder().encode(self.recipe)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        if edit == false{ //New Event
            self.SaveToCoreData(recipe: jsonString)
        }else{ //Updating
            self.UpdateCoreData(recipe: jsonString)
        }

        } catch { print(error) }
    }
    
    
       
     //MARK: - SaveToCoreData
     func SaveToCoreData(recipe:String){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "RecipeRecord", in: context!)
        let records = NSManagedObject(entity: entity!, insertInto: context)
       
        records.setValue(recipe, forKey: "recipe")
        records.setValue(self.recipe.ID, forKey: "id")
        records.setValue(self.recipe.Category.ID, forKey: "category")
           do{
                try context?.save()
                print("Saved")
           }catch{
               print(error)
           }
       }
    
    
       
    //MARK: - UpdateCoreData
    func UpdateCoreData(recipe:String){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "RecipeRecord")
        let predicate = NSPredicate(format: "id == %@", self.recipe.ID as CVarArg)
        fetchRequest.predicate = predicate
        do
        {
            let record = try context?.fetch(fetchRequest)
            if record?.count == 1
            {
                (record?[0] as AnyObject).setValue(recipe, forKey: "recipe")
                do{
                    try context?.save()
                    print("Updated")
                }
                catch
                {
                    print(error)
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    
    
    //MARK: - Delete From CoreData
    func DeleteFromCoreData(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<RecipeRecord> = RecipeRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format:"id == %@", self.recipe.ID as CVarArg? ?? UUID.init() as CVarArg)
            do {
                let objects = try context!.fetch(fetchRequest)
                for object in objects {
                    context!.delete(object)
                }
                try context!.save()
            } catch{
                print("error executing fetch request: \(error)")
            }
    }
        
    
}
