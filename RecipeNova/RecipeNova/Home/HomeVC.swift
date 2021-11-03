
import UIKit
import CoreData
import UserNotifications


enum Segues:String{
    case Theme="Theme"
    case Setting="Setting"
}

protocol HomeVCOperation {
    func PerformSegue(type:Segues) ///perfom segue
    func ApplyTheme() ///apply theme
    func ReloadCategories(new category:Bool) ///reload categories
    func DeleteControl(Choice:Int) ///delete categories and recipes
}

class HomeVC: UIViewController,HomeVCOperation,UNUserNotificationCenterDelegate {
    
    //MARK:-Protocols
    func ReloadCategories(new category: Bool) {
        ///if category was added
        if category{
            self.addCategory = false
            self.NoView.removeFromSuperview()
            self.tableView.insertRows(at: [IndexPath(row: UI.CT.count - 1, section: 0)], with: .automatic)
        }else{
            self.addCategory = false
            self.tableView.reloadData()
        }
    }
    
    func ApplyTheme() {
        Label.setWB(W: .black, B: .white)
        NoView.backgroundColor = .clear
        Image.tintColor = UI.WB ? .white : .black
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UI.AC.toColor().darker
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UI.AC.toColor().darker
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        
        self.view.backgroundColor = UI.MC.toColor()
        self.tableView.separatorColor = UI.MC.toColor().withAlphaComponent(0.7)
        self.tableView.backgroundColor = .clear
        
        self.tableView.reloadData()
        self.MenuDelegate?.ApplyTheme()
    }

    func PerformSegue(type:Segues){
        self.performSegue(withIdentifier: type.rawValue, sender: nil)
    }
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var AddB: UIBarButtonItem!
    @IBAction func AddButton(_ sender: UIBarButtonItem) {
        ///addcategory meaning table header is disabled
        if !addCategory{
            ///enable addcategory
            self.addCategory = true
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet var SearchB: UIBarButtonItem!
    @IBAction func SearchButton(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "Search", sender: nil)
    }
    
    
    //MARK: - Menu Handler
    @IBOutlet var CloseMenuB: UIButton!
    @IBAction func CloseMenuButton(_ sender: UIButton) {
        ///hide menu
        self.SlideOut()
    }
    @IBOutlet var MenuContainer: UIView!
    @IBOutlet var MenuB: UIBarButtonItem!
    @IBAction func MenuButton(_ sender: UIBarButtonItem) {
        ///show  menu
        self.SlideMenu()
    }
    
    @IBOutlet var CartB: UIBarButtonItem!
    @IBAction func CartButton(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "Cart", sender: nil)
    }

    
    ///init category when user is selecting category to edit we pass to the add category page
    var category=CategoryStruct()
    ///init index when user is selecting category to edit we pass to recipe page
    var selectedIndex:Int=0
    var MenuDelegate:MenuVCOperation?
    ///init option page
    var optionsDelegate:ChoosenOp?
    var indexPath:Int=0 ///user selected indexPath
    
    ///add new category
    lazy var addCategory:Bool=false
    
    ///Show No Category
    let NoView = UIView()
    let Label = UILabel()
    let Image = UIImageView(image: UIImage(systemName: "list.bullet.indent"))
    
    ///Create a var of Message Animation
    var LoadingAnimation:MessageAnimation?
    
    @IBOutlet var initialPage: UIView!
    @IBOutlet var activity: UIActivityIndicatorView!
    var categories = [Categories]()
    
    
    // init Options
    lazy var optionsVC: OptionsVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "OptionsVC") as! OptionsVC
        self.optionsDelegate = viewController
        viewController.delegate = self
        return viewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        //check initial page to add recipes - only doing it once
        if UserDefaults.standard.value(forKey: "InitialPage") == nil{
            self.saveCategory()
        }else{
            self.initialPage.isHidden = true
        }
        
    
        ///Init Loading Animation
        self.LoadingAnimation = MessageAnimation(rect: self.tableView.frame, navigheight: self.navigationController?.navigationBar.frame.height ?? 80)
        self.LoadingAnimation?.SetLoadingAnimtion()
        self.tableView.addSubview(self.LoadingAnimation?.loadingView ?? self.view)
        self.tableView.bringSubviewToFront(self.LoadingAnimation?.loadingView ?? self.view)
        
        ///App Shortcut quickAction
        self.QuickAction()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .bold)]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UI.AC.toColor().darker
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UI.AC.toColor().darker
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        
        self.view.backgroundColor = UI.MC.toColor()
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = UI.MC.toColor().withAlphaComponent(0.7)
        self.tableView.contentInset = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)

        Label.setWB(W: .black, B: .white)
        NoView.backgroundColor = UI.WB ? .black : .white
        Image.tintColor = UI.WB ? .black : .white
        self.SetUpNoView()
        
        ///If we dont have any category show the image and label that we dont
        if UI.CT.count == 0{
            self.ShowNoView()
        }else{
            self.NoView.removeFromSuperview()
        }
        
        self.tableView.delegate=self
        self.tableView.dataSource=self

        ///Tableview cell registeration
        self.tableView.register(UINib(nibName: "LabelsNib", bundle: nil), forCellReuseIdentifier: "LabelsNib")
        self.tableView.register(UINib(nibName: "TextFieldNib", bundle: nil), forCellReuseIdentifier: "TextFieldNib")
        
        ///Add Swipe gesture for our menu
        let EdgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(SlideMenu))
        EdgeSwipe.edges = .left
        self.view.addGestureRecognizer(EdgeSwipe)
        
        ///Reload Page upon adding a new category from cloud
        NotificationCenter.default.addObserver(self, selector: #selector(ReloadHomePage), name: NSNotification.Name("ReloadHomePage"), object: nil)
        
        ///Quick action was called
        NotificationCenter.default.addObserver(self, selector: #selector(QuickAction), name: NSNotification.Name(rawValue: "QuickAction"), object: nil)
        
        ///Calling this if language was changed
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeLanguage), name: NSNotification.Name(rawValue: "ChangeLanguage"), object: nil)
        
    }
    
    
    //MARK: - Language cahnge
    @objc func ChangeLanguage(){
        Label.text = UI.EF ? "Tap + to add a category.":"برای افزودن دسته ، روی + ضربه بزنید."
    }
    
    //MARK: - Reload HomePage
    @objc func ReloadHomePage(){
        DispatchQueue.main.async {
            ///If we dont have any category show the image and label that we dont
            if UI.CT.count == 0{
                self.ShowNoView()
            }else{
                self.NoView.removeFromSuperview()
            }
            self.tableView.reloadData()
        }
    }

    
    //MARK: - Quick Actions
    @objc func QuickAction(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if UI.QA == 1{
                self.performSegue(withIdentifier: "Cart", sender: nil)
            }else if UI.QA == 2{
                UI.QA = -1
                self.performSegue(withIdentifier: "Search", sender: nil)
            }
        }
    }
    
    
    
  
    //MARK: - Menu Functions
    @objc func SlideMenu(){
        self.MenuB.isEnabled=false
        if self.MenuContainer.frame.origin.x < self.MenuContainer.frame.width{
            UIView.animate(withDuration: 0.2, animations: {
                self.MenuContainer.frame.origin.x = 0
                self.CloseMenuB.alpha = 0.5
                self.MenuContainer.Shadow(color: .black, radius: 20, alpha: 0.4)
            })
        }
    }
    func SlideOut(){
        self.MenuB.isEnabled=true
        if self.MenuContainer.frame.origin.x == 0{
            UIView.animate(withDuration: 0.2, animations: {
                self.MenuContainer.frame.origin.x-=self.MenuContainer.frame.size.width
                self.CloseMenuB.alpha = 0.0
                self.MenuContainer.Shadow(color: .black, radius: 20, alpha: 0)
            })
        }
    }

    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "Recipe"{
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.topViewController as? RecipesVC
            destination?.category=UI.CT[self.selectedIndex]
        }else if segue.identifier == "Menu", let destination = segue.destination as? MenuCVC{
            destination.delegate=self
            self.MenuDelegate=destination
        }else if segue.identifier == "Theme", let destination = segue.destination as? ThemeCV{
            destination.delegate=self
        }
    }
    
    
    
    //MARK: - Show No View
    private func SetUpNoView(){
        
        NoView.backgroundColor = .clear
        NoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        NoView.alpha = 0.0
           
        Label.setWB(W: .black, B: .white)
        Label.textAlignment = .center
        Label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        Label.text = UI.EF ? "Tap + to add a category.":"برای افزودن دسته ، روی + ضربه بزنید."
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
        viewController.delegate = self
    
        viewController.modalPresentationStyle = .overFullScreen
        viewController.view.backgroundColor = .clear
        
        viewController.choosen(0)
        
        self.present(viewController, animated: true, completion: nil)
    }
    
}


