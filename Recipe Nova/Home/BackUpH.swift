
import UIKit
import CoreData

extension HomeVC{
        
    private func FetchBackUpFromCoreData(completion:(_ done:Bool)->Void){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BackUp")
            do{
                let result:[BackUp] = try context?.fetch(request) as! [BackUp]
                if result.count > 0{
                    for recipe in result{
                        self.DecodejSonRecipe(json: recipe.recipe!)
                    }
                    completion(true)
                }else{
                    completion(true)
                  //No Back up
                }
        }catch{
            completion(false)
            print("Error in Loading")
        }
    }
    
    
    private func DecodejSonRecipe(json:String){
        do {
            guard let data = json.data(using: .utf8) else { return  }
            let DecodedEvent = try JSONDecoder().decode(Recipes.self, from: data)
            //delete it from our backup database
            self.DeleteFromBackUpCoreData(id: DecodedEvent.ID)
        } catch { print(error) }
    }
    
    //MARK: - Delete From Backup CoreData
    func DeleteFromBackUpCoreData(id:UUID){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BackUp> = BackUp.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format:"id == %@", id as CVarArg? ?? UUID.init() as CVarArg)
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

