
import UIKit

extension CartVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if addList{ ///if we are adding a new list name
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldNib") as? TextFieldNib
    
            cell?.backgroundColor = .clear
            cell?.cartDelegate = self
            cell?.pageIndicator = 2
            cell?.textField.placeholder = UI.EF ? "List Name" : "نام لیست"
            cell?.initTextField()
            DispatchQueue.main.async {
                cell?.textField.becomeFirstResponder()
            }
            
            return cell!
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if addList{ ///if we are adding a new list name
            return 50
        }
        return 0.01
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if addList{ ///if we are adding a new list name
            view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0,-100, 0)
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.FilterList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsNib", for: indexPath) as? LabelsNib
        
        cell?.Label.text = self.FilterList.index(indexPath.row)?.Name
        cell?.backgroundColor = UI.AC.toColor()
        cell?.SetUpArrow()
        cell?.pageIndicator = 2
        cell?.initTextField()
        cell?.textField.isHidden = true
        cell?.cartDelegate=self
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? LabelsNib
        cell?.SelectCellAndDeselect()
        self.performSegue(withIdentifier: "List", sender: nil)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = DeleteAction(at: indexPath)
        let edit = EditAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }
    //MARK: - Swipe Left to Edit
    func EditAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: UI.EF ? "Edit":"ویرایش") { (action, view, completion) in
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            let cell = self.tableView.cellForRow(at: indexPath) as? LabelsNib
            cell?.cart = self.FilterList.index(indexPath.row) ?? ShoppingCart()
            cell?.textField.text = self.FilterList.index(indexPath.row)?.Name
            cell?.textField.isHidden = false
            cell?.Label.isHidden = true
            cell?.textField.becomeFirstResponder()
        }
        action.image = UIImage(systemName: "square.and.pencil")
        action.backgroundColor = UIColor(named: "020")
        return action
      }
    func DeleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: UI.EF ? "Delete":"حذف") { (action, view, completion) in
            self.indexPath = indexPath.row
            self.DeleteControl()
            completion(true)
        }
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = UIColor(named: "012")
        return action
    }
    
    
    func DeleteControl(){
        let cart = self.FilterList.index(self.indexPath) ?? ShoppingCart()
        ///remove from our coredata
        SaveLoadListHandler(list: cart).DeleteFromCoreData()
        ///remove from both source and filter list and trie
        self.Lists.remove(cart)
        self.FilterList.remove(cart)
        self.trieSearch.remove(cart.Name)
        self.ClearList(ID: cart.ID.uuidString) ///if we have saved the list into widget then remove it from widget
        
        if self.FilterList.count == 0{
            self.ShowNoView()
        }else{
            self.NoView.removeFromSuperview()
        }
            
        self.tableView.deleteRows(at: [IndexPath(row: self.indexPath, section: 0)], with: .automatic)
    }
    
    
    private func ClearList(ID:String){
        if let userDefaults = UserDefaults(suiteName: "group.iNfamousPersian.Recipe"){
            if userDefaults.string(forKey: "ID") == ID{
                userDefaults.set(nil, forKey: "List")
                userDefaults.set(nil, forKey: "ID")
                userDefaults.synchronize()
            }
        }
    }
}
