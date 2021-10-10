
import UIKit
import WidgetKit

protocol CartVCOperation {
    func ReloadTable(list:CartStruct) ///In case we needed to reload our lists due to update or add
    func ReloadTable() ///simply reload the table and disable the header
    func DeleteControl() ///delete list which is called from list or option page
}

class CartVC: UIViewController,UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,CartVCOperation,UIGestureRecognizerDelegate {
    
    func ReloadTable() {
        self.addList = false ///disable header
        self.tableView.reloadData()
    }
    
    func ReloadTable(list:CartStruct) {
        ///if our list was updated
        if list.Update{
            
            ///find the name in our avltree and remove it from tries to add the new name
            self.FilterList.root?.traversePreOrder(visit: { (cart) in
                if cart.ID == list.list.ID{
                    self.trieSearch.remove(cart.Name)
                }
            })
            
            ///update our list and filter avltree and tries
            self.Lists.updateValue(list.list)
            self.FilterList.updateValue(list.list)
            self.trieSearch.insert(list.list.Name)
            
            guard let index = self.FilterList.indexOf(list.list) else{
                return
            }
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.addList = false ///disable the header
            }
        
        }else{
            
            ///if a list was added, insert into our avltree
            self.Lists.insert(list.list)
            self.FilterList.insert(list.list)
            self.trieSearch.insert(list.list.Name)
            self.addList = false ///disable the header
            
            self.NoView.removeFromSuperview()
            
            guard let index = self.FilterList.indexOf(list.list) else{
                return
            }
            self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var AddB: UIBarButtonItem!
    @IBAction func AddButton(_ sender: UIBarButtonItem) {
        if !addList{
            self.addList = true
            self.tableView.reloadData()
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    var trieSearch = Trie<String>()
    var Lists=AVLTree<ShoppingCart>()
    var FilterList=AVLTree<ShoppingCart>()
    let controller = UISearchController(searchResultsController: nil)

    ///add new category
    lazy var addList:Bool=false
    
    //Show No Category
    let NoView = UIView()
    let Label = UILabel()
    let Image = UIImageView(image: UIImage(systemName: "cart.fill"))
    
    ///options page
    var optionsDelegate:ChoosenOp?
    var indexPath:Int=0
    
    //init Options
     lazy var optionsVC: OptionsVC = {
         // Load Storyboard
         let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
         // Instantiate View Controller
         var viewController = storyboard.instantiateViewController(withIdentifier: "OptionsVC") as! OptionsVC
         self.optionsDelegate = viewController
         viewController.delegateCart = self
         return viewController
     }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Label.setWB(W: .black, B: .white)
        NoView.backgroundColor = .clear
        Image.tintColor = UI.WB ? .white : .black
        SetUpNoView()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationItem.title = UI.EF ? "Cart":"سبد"
        
        self.view.backgroundColor = UI.MC.toColor()
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = UI.MC.toColor().withAlphaComponent(0.7)
        self.tableView.contentInset = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        ///our table registeration
        self.tableView.register(UINib(nibName: "LabelsNib", bundle: nil), forCellReuseIdentifier: "LabelsNib")
        self.tableView.register(UINib(nibName: "TextFieldNib", bundle: nil), forCellReuseIdentifier: "TextFieldNib")
        
        self.SetUpSearchController()
        
        ///load categories from coredata
        SaveLoadListHandler(list: ShoppingCart()).FetchFromCoreData { (list) in
            list.root?.traversePreOrder(visit: { (cart) in
                self.Lists.insert(cart)
                self.FilterList.insert(cart)
                self.trieSearch.insert(cart.Name)
            })
        }
        
        ///if we have no list then show no cart image
        if FilterList.count == 0{
            self.ShowNoView()
        }else{
            self.NoView.removeFromSuperview()
        }
        
        ///Quick action was called
        self.QuickAction()

    }
    
    //MARK: - Quick Action
    private func QuickAction(){
        if UI.QA == 1{
            UI.QA = -1
            if !addList{
                self.addList = true
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: - SearchController
    func SetUpSearchController(){
        
        controller.delegate = self
        controller.searchBar.delegate = self
        controller.searchResultsUpdater = self
        
        controller.hidesNavigationBarDuringPresentation = false
        controller.obscuresBackgroundDuringPresentation = false
        
        controller.searchBar.placeholder = UI.EF ? "Search Lists" : "جستجو در لیست خرید"
        controller.searchBar.tintColor = UIColor.MyTheme.Seven

        controller.searchBar.isTranslucent = false
        controller.searchBar.barStyle = .black
        controller.searchBar.keyboardAppearance = UI.WB ? .dark : .light
        
        controller.automaticallyShowsScopeBar = true
        controller.searchBar.searchTextField.backgroundColor = UI.WB ? UIColor.MyTheme.Nine : UIColor.MyTheme.Eight
        controller.searchBar.searchTextField.tintColor = UI.AC.toColor()
        controller.searchBar.searchTextField.textColor = .white
         
        definesPresentationContext = true
        self.navigationItem.searchController = controller
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive{
            if controller.searchBar.text?.isEmpty == false{
                
                ///look for prefix in our tries
                let result = self.trieSearch.collections(startWith: searchController.searchBar.text?.trimmingCharacters(in:CharacterSet.whitespaces) ?? "")
                
                ///remove all lists from filter tree
                self.FilterList = AVLTree<ShoppingCart>()
                
                ///for all the founded match names then look into our source lists and insert them into our filter list
                result.forEach { (names) in
                    self.Lists.root?.traversePreOrder(visit: { (cart) in
                        if cart.Name == names{
                            self.FilterList.insert(cart)
                        }
                    })
                }
                
                self.tableView.reloadData()
            }else{
                
                self.FilterList = AVLTree<ShoppingCart>()
                self.tableView.reloadData()
            }
        }else{
            ///remove all lists from filter tree
            self.FilterList = AVLTree<ShoppingCart>()
            ///insert back into our filter tree from source
            self.Lists.root?.traversePreOrder(visit: { (cart) in
                self.FilterList.insert(cart)
            })
            
            self.tableView.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "List"{
            let vc = segue.destination as? ListTV
            if let indx = self.tableView.indexPathForSelectedRow{
                vc?.List = self.FilterList.index(indx.row) ?? ShoppingCart()
            }
            vc?.delegate=self
        }
    }
    
    
    //Show No View
    private func SetUpNoView(){
        NoView.backgroundColor = .clear
        NoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        NoView.alpha = 0.0
           
        Label.setWB(W: .black, B: .white)
        Label.textAlignment = .center
        Label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        Label.text = UI.EF ? "Tap + to add a list.":"برای افزودن لیست ، روی + ضربه بزنید."
        Label.frame.size = CGSize(width: 250, height: 100)
        
        Label.frame.origin = CGPoint(x: self.NoView.frame.midX - 130 , y:self.NoView.frame.midY - 250)
        Image.frame = CGRect(x: self.NoView.frame.midX - 30, y: Label.frame.origin.y + 50
            , width: 50, height: 100)

        Image.contentMode = .scaleAspectFit
        Image.image = Image.image?.withRenderingMode(.alwaysTemplate)
        Image.tintColor = UI.WB ? .white : .black
        self.NoView.addSubview(Label)
        self.NoView.addSubview(Image)
        
    }
    
    func ShowNoView(){
        self.tableView.addSubview(self.NoView)
        UIView.animate(withDuration: 0.5) {
            self.NoView.alpha = 1.0
        }
    }
    
    
    //MARK: - Options
    @objc func showOptions(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "OptionsVC") as! OptionsVC
        self.optionsDelegate = viewController
        viewController.delegateCart = self
        
        viewController.modalPresentationStyle = .overFullScreen
        viewController.view.backgroundColor = .clear
            
        viewController.choosen(1)
            
        self.present(viewController, animated: true, completion: nil)
    }
    
}
