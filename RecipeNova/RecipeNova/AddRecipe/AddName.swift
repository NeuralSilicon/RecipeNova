
import UIKit

class AddName: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet var textField:UITextFieldWithBorders!
    
    @IBAction func TextFieldEditiing(_ sender: UITextFieldWithBorders) {
        if textField.text?.isEmpty == false{
            self.doneB.isEnabled = true
            let results = self.trieSearch.collections(startWith: self.textField.text?.trimmingCharacters(in:CharacterSet.whitespaces) ?? "")
            self.filter = AVLTree<Recipes>()
            results.forEach { (names) in
                self.AllRecipes.root?.traversePreOrder(visit: { (R) in
                    if names == R.Name{
                        self.filter.insert(R)
                    }
                })
            }
            self.tableView.reloadData()
        }else{
            self.doneB.isEnabled = false
            self.filter = AVLTree<Recipes>()
            self.tableView.reloadData()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        return true
    }
    
    
    @IBOutlet var closeB: UIBarButtonItem!
    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var doneB: UIBarButtonItem!
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        saving.NewRecipe.Name = self.textField.text ?? ""
        self.delegate?.ReloadTable()
        self.dismiss(animated: true, completion: nil)
    }
    
    var trieSearch = Trie<String>()
    var filter = AVLTree<Recipes>()
    var AllRecipes = AVLTree<Recipes>()
    var delegate:AddVCOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///load all the recipes
        LoadHandler().FetchFromCoreData(category: saving.NewRecipe.Category) { (recipe) in

            recipe.root?.traversePreOrder(visit: { (RC) in
                self.AllRecipes.insert(RC)
                self.filter.insert(RC)
                self.trieSearch.insert(RC.Name)
            })
            
            self.tableView.reloadData()
        }
        
        self.setUpPage()
    }
    
    func setUpPage(){

        self.navigationItem.title = UI.EF ? "Name" : "اسم"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .bold)]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UI.AC.toColor().darker
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UI.AC.toColor().darker
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        
        self.tableView.backgroundColor = UI.AC.toColor()
        self.tableView.separatorColor = UI.MC.toColor()
        self.view.backgroundColor = UI.MC.toColor()
        
        self.tableView.register(UINib(nibName: "LabelsNib", bundle: nil), forCellReuseIdentifier: "LabelsNib")

        self.textField.delegate = self
        
        self.textField.placeholder = UI.EF ? "Recipe Name" : "نام دستور"
        self.textField.placeholderColor = UI.WB ? .lightGray : .darkGray
        self.textField.textColor = UI.WB ? .white : .black
        self.textField.tintColor = UI.AC.toColor()
        self.textField.keyboardAppearance = UI.WB ? .dark : .light
        self.textField.textAlignment = UI.EF ? .left : .right
        
        self.textField.borderColor = UI.WB ? .black : .white
        self.textField.borderWidth = 2
        self.textField.bottomBorder = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsets(top: -40, left: 0, bottom: 0, right: 0)
        
        self.textField.becomeFirstResponder()
        
        if saving.NewRecipe.Name != ""{
            self.textField.text = saving.NewRecipe.Name
        }
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsNib", for: indexPath) as? LabelsNib
        cell?.Label.text = self.filter.index(indexPath.row)?.Name
        cell?.backgroundColor = UI.AC.toColor().darker
        cell?.textField.isEnabled = false
        cell?.Label.textColor = .white
        
        var image = UIImage(systemName: "arrow.up.square.fill")
        image = image?.withRenderingMode(.alwaysTemplate)
        let checkmark  = UIImageView(frame:CGRect(x:0, y:0, width:23, height:20))
        checkmark.image = image
        checkmark.tintColor = .white
        cell?.accessoryView = checkmark
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? LabelsNib
        cell?.SelectCellAndDeselect()
        cell?.backgroundColor = .clear
        self.textField.text = self.filter.index(indexPath.row)?.Name
        
        self.filter = AVLTree<Recipes>()
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.4) {
            cell.alpha = 1.0
        }
    }
    
    
    
}
