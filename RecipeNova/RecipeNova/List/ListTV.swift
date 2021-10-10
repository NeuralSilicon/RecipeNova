
import UIKit
import WidgetKit

protocol ListTVOperation {
    func UpdateList(list:ShoppingCart) ///Update our list
    func ReloadTable(list:String) ///Reload our list
    func ReloadSection() ///Reload table
    func ListControl() ///delete or add
}

class ListTV: UITableViewController,ListTVOperation,UIGestureRecognizerDelegate {
    func UpdateList(list:ShoppingCart){
        ///Call cartvc to reload page
        self.delegate?.ReloadTable(list: CartStruct(Update: true, list: list))
        self.List = list
        ///Create a list by separating our ingredients or list by dot
        self.Lists=List.List.components(separatedBy: " \u{2022} ")
        ///remove the first element since it will always be empty space
        self.Lists.remove(at: 0)
        self.tableView.reloadData()
    }
    
    func ReloadSection(){
        self.tableView.reloadData()
    }
    
    func ReloadTable(list:String){

        self.List.List.append(list)
        self.List.Selected.append(false)
        self.Lists.append(list.replacingOccurrences(of: " \u{2022} ", with: ""))

        self.LoadingAnimation?.StartloadingAnimation(E: "", F: "")
        self.LoadingAnimation?.RemoveWithNoDelayLoadingScreen()
        ///Save the updated list
        SaveLoadListHandler(list: self.List).EncodeToSave(Update: true)
        ///reload our cartvc lists
        self.delegate?.ReloadTable(list: CartStruct(Update: true, list: self.List))
        ///if this list is in our widget, then update the widget
        self.SyncWWidget(AddingList: false)
        ///insert a new row to our table and reload data
        
        self.tableView.insertRows(at: [IndexPath(row: self.Lists.count - 1, section: 0)], with: .automatic)
    }
    
    
    @IBOutlet var MoreB: UIBarButtonItem!
    @IBAction func MoreButton(_ sender: UIBarButtonItem) {
        self.showOptions()
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var List = ShoppingCart()
    var Lists:[String]=[]
    let refreshControls = UIRefreshControl()
    
    var delegate:CartVCOperation?
    
    //Create a var of Message Animation
    var LoadingAnimation:MessageAnimation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Loading Animation
        self.LoadingAnimation = MessageAnimation(rect: self.tableView.frame, navigheight: self.navigationController?.navigationBar.frame.height ?? 80)
        self.LoadingAnimation?.SetLoadingAnimtion()
        self.tableView.addSubview(self.LoadingAnimation?.loadingView ?? self.view)
        self.tableView.bringSubviewToFront(self.LoadingAnimation?.loadingView ?? self.view)
        
        self.tableView.contentInset = UIEdgeInsets(top: -3, left: 0, bottom: 50, right: 0)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationItem.title = self.List.Name
        
        ///create the list by seperating the ingredients by dot
        self.Lists=List.List.components(separatedBy: " \u{2022} ")
        ///remove the first one since the first one is just an empty " " element
        self.Lists.remove(at: 0)
        
        ///check to see if we have the same amount of bool values as we have the list items if not then add the rest
        if self.Lists.count > 0 {
            for _ in  self.List.Selected.count ..< self.Lists.count{
                self.List.Selected.append(false)
            }
        }
        
        ///tableview cell registeration
        self.tableView.register(UINib(nibName: "TextFieldNib", bundle: nil), forCellReuseIdentifier: "TextFieldNib")
        self.tableView.register(UINib(nibName: "LabelWCircleSNib", bundle: nil), forCellReuseIdentifier: "LabelWCircleSNib")

        self.tableView.backgroundColor = UI.MC.toColor()
        self.tableView.separatorColor = UI.MC.toColor().withAlphaComponent(0.7)
        
        ///refresh control for tableview, its needed if our header disappeared after adding a new item and reloading a section
        refreshControls.layoutIfNeeded()
        refreshControls.tintColor = UI.WB ? UIColor.MyTheme.Seven : UIColor.MyTheme.Nine
        refreshControls.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(sender:)), name: NSNotification.Name(rawValue: "ReloadTableView"), object: nil)
        self.tableView.addSubview(refreshControls)
    }

    @objc func refresh(sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
            self.refreshControls.endRefreshing()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldNib") as? TextFieldNib
        
        cell?.delegate=self
        cell?.pageIndicator = 3
        cell?.backgroundColor = .clear
        cell?.textField.placeholder = UI.EF ? "Add New Item" : "مورد جدیدی اضافه کنید"
        cell?.initTextField()
 
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Lists.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelWCircleSNib", for: indexPath) as? LabelWCircleSNib
        
        cell?.Label.text = self.Lists[indexPath.row].replacingOccurrences(of: "\n", with: "")
        cell?.Label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        if self.List.Selected[indexPath.row]{
            cell?.SelectedCell()
        }else{
            cell?.DeSelectedCell()
        }
        
        cell?.backgroundColor = UI.AC.toColor()
        
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.List.Selected[indexPath.row]{
            self.List.Selected[indexPath.row] = false
        }else{
            self.List.Selected[indexPath.row] = true
        }
        
        ///update coredata and call cart to update as well as widget
        SaveLoadListHandler(list: self.List).EncodeToSave(Update: true)
        self.delegate?.ReloadTable(list: CartStruct(Update: true, list: self.List))
        self.SyncWWidget(AddingList:false)
        
        if let cell = tableView.cellForRow(at: indexPath){
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
                cell.transform = CGAffineTransform(translationX: 100, y: 0)
            }, completion: nil)
            UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                cell.transform = .identity
            }, completion: {_ in
                self.tableView.reloadRows(at: [indexPath], with: .none)
            })
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = DeleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func DeleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            if let range = self.List.List.range(of: (" \u{2022} " + self.Lists[indexPath.row]) ) {
               self.List.List.removeSubrange(range)
            }
            self.List.Selected.remove(at: indexPath.row)
            self.Lists.remove(at: indexPath.row)

            self.LoadingAnimation?.StartloadingAnimation(E: "", F: "")
            self.LoadingAnimation?.RemoveWithNoDelayLoadingScreen()
            
            ///update coredata and call cart to update as well as widget
            SaveLoadListHandler(list: self.List).EncodeToSave(Update: true)
            self.delegate?.ReloadTable(list: CartStruct(Update: true, list: self.List))
            self.SyncWWidget(AddingList:false)
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = UIColor(named: "012")
        return action
    }
    
    
    func SyncWWidget(AddingList:Bool){
        if let userDefaults = UserDefaults(suiteName: "group.Cooper-Kattner.RecipeNova"){
            if self.List.ID.uuidString == userDefaults.string(forKey: "ID") && AddingList == false{
                userDefaults.set(self.MakeAList(), forKey: "List")
                userDefaults.set(self.List.ID.uuidString, forKey: "ID")
                userDefaults.synchronize()
            }else if AddingList == true{
                userDefaults.set(self.MakeAList(), forKey: "List")
                userDefaults.set(self.List.ID.uuidString, forKey: "ID")
                userDefaults.synchronize()
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func MakeAList()->String{
        var text = ""
        ///if we our list count and bool counts are the same
        if self.Lists.count == self.List.Selected.count, self.Lists.count > 0{
            for i in 0..<self.List.Selected.count {
                if self.List.Selected[i] == false{
                    ///text += dot + text + space : .peaches .onion . garlic ...
                    text+=(" \u{2022} " + self.Lists[i] + " ")
                }
            }
        }
        return text
    }
    
}
