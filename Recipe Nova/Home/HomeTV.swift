
import UIKit

extension HomeVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if addCategory{ ///if we are adding a new category, we enable the header for table
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldNib") as? TextFieldNib
    
            cell?.backgroundColor = .clear
            cell?.HomeDelegate = self
            cell?.pageIndicator = 1
            cell?.textField.placeholder = UI.EF ? "Add Category" : "اسم گروه"
            cell?.initTextField()
            DispatchQueue.main.async {
                cell?.category = CategoryStruct()
                cell?.textField.becomeFirstResponder()
            }
            
            return cell!
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if addCategory{ ///if we are adding a new category, we enable the header for table
            return 50
        }
        return 0.01
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if addCategory{ ///if we are adding a new category, we enable the header for table
            view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0,-100, 0)
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UI.CT.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsNib", for: indexPath) as? LabelsNib
        
        cell?.Label.text = UI.CT[indexPath.row].Name
        cell?.backgroundColor = UI.AC.toColor()
        cell?.SetUpArrow()
        cell?.homeDelegate = self
        cell?.textField.isHidden = true
        cell?.pageIndicator = 1
        cell?.initTextField()
        

        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? LabelsNib
        cell?.SelectCellAndDeselect()
        self.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "Recipe", sender: nil)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = EditAction(at: indexPath)
        let delete = DeleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }
    
    //MARK: - Swipe Left to Edit
    func EditAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: UI.EF ? "Edit":"ویرایش") { (action, view, completion) in

            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            let cell = self.tableView.cellForRow(at: indexPath) as? LabelsNib
            cell?.category = UI.CT[indexPath.row]
            cell?.textField.text = UI.CT[indexPath.row].Name
            cell?.textField.isHidden = false
            cell?.Label.isHidden = true
            cell?.textField.becomeFirstResponder()
            
            completion(true)
        }
        action.image = UIImage(systemName: "square.and.pencil")
        action.backgroundColor = UIColor(named: "020")
        return action
      }
    
    //MARK: - Swipe Right to Delete
    func DeleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: UI.EF ? "Delete" : "حذف") { (action, view, completion) in

            ///calling the option page to show the options
            self.optionsDelegate?.choosen(0)
            self.indexPath = indexPath.row
            self.showOptions()
            
            self.LoadingAnimation?.StartloadingAnimation(E: "", F: "")
            self.LoadingAnimation?.RemoveWithNoDelayLoadingScreen()
            completion(true)
        }
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = UIColor(named: "012")
        return action
    }
    
}
