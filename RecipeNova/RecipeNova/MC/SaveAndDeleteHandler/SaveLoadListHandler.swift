
import UIKit
import CoreData

class SaveLoadListHandler:NSObject{
    
    var shoppingcart:ShoppingCart
    private var list:String
    private var Lists=AVLTree<ShoppingCart>()
    
    init(list:ShoppingCart) {
        self.shoppingcart=list
        self.list=""
    }
    
    ///Fetch all the lists from our coredata
    func FetchFromCoreData(completion:(_ list:AVLTree<ShoppingCart>)->Void){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        do{
            let result:[Cart] = try context?.fetch(request) as! [Cart]
            if result.count > 0{
                for lists in result{
                    self.DecodejSonEvent(json: lists.list ?? "")
                }
                completion(self.Lists)
            }else{
                print("No Result")
            }
        } catch{
            print("Error in Saving")
        }
    }
    
    //MARK: - Decode The json event
    private func DecodejSonEvent(json:String){
        do {
            guard let data = json.data(using: .utf8) else { return  }
            let DecodedList = try JSONDecoder().decode(ShoppingCart.self, from: data)
            self.Lists.insert(DecodedList)
        } catch { print(error) }
    }
    
    
    //MARK: - EnCode to save or update
    func EncodeToSave(Update:Bool){
        do {
            let jsonData = try JSONEncoder().encode(self.shoppingcart)
            self.list = String(data: jsonData, encoding: .utf8)!
            if Update{
                self.UpdateCoreData()
            }else{
                self.SaveToCoreData()
            }
        } catch { print(error) }
    }
       
    
    
    //MARK: - SaveToCoreData
    func SaveToCoreData(){
        if !CheckDuplicateCoreData(id: self.shoppingcart.ID){
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Cart", in: context!)
            let records = NSManagedObject(entity: entity!, insertInto: context)
           
            records.setValue(self.list, forKey: "list")
            records.setValue(self.shoppingcart.ID, forKey: "id")
            do{
                try context?.save()
                print("Saved")
            }catch{
                print("CoreData Error")
            }
        }else{
            self.UpdateCoreData()
        }
    }
    
    private func CheckDuplicateCoreData(id:UUID)->Bool{
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Cart")
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        do
        {
            let record = try context?.fetch(fetchRequest)
            if record?.count == 1
            {
                return true
            }
        }
        catch
        {
            print(error)
        }
        return false
    }
    
       
    //MARK: - UpdateCoreData
    func UpdateCoreData(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Cart")
        let predicate = NSPredicate(format: "id == %@", self.shoppingcart.ID as CVarArg)
        fetchRequest.predicate = predicate
        do
        {
            let record = try context?.fetch(fetchRequest)
            if record?.count == 1
            {
                (record?[0] as AnyObject).setValue(self.list, forKey: "List")
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
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format:"id == %@", self.shoppingcart.ID as CVarArg? ?? UUID.init() as CVarArg)
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
