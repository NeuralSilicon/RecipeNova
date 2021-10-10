
import UIKit

struct Option {
    var name:String=""
    var image:String=""
}

protocol ChoosenOp {
    func choosen(_ option:Int)
    func dismiss()
}


class OptionsVC:UIViewController, UITableViewDelegate,UITableViewDataSource,ChoosenOp {
    func dismiss() {
        self.background.alpha = 0.0
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func choosen(_ option: Int) {
        self.bar.backgroundColor = UI.WB ? UIColor.MyTheme.Nine : .white
        self.barView.backgroundColor = UI.WB ? .darkGray : .lightGray
        self.tableView.backgroundColor = UI.WB ? UIColor.MyTheme.Nine : .white
        
        self.showHeader = false ///header is where asking questions about the option
        self.choosenOption = option ///chosen option to show
        self.addOptions() ///add the option to our list
        
        ///set the height for our tableview based on the number of options
        if self.options[option]?.count ?? 0 > 3{
            self.height.constant = CGFloat(((self.options[option]?.count ?? 0) * 60) + 15)
        }else{
            self.height.constant = CGFloat((3 * 60) + 15)
        }
        ///reload tableview layout after change in height
        self.tableView.layoutIfNeeded()
        
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIView.animate(withDuration: 0.3) {
                ///show the bottom background that let user dismiss page
                self.background.alpha = 1.0
            }
        }
    }

    @IBOutlet var background: UIView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var height: NSLayoutConstraint!
    @IBOutlet var bar: UIView! ///top view in tableview
    @IBOutlet var barView: UIView! ///bar in top view in tableview
    
    
    ///Pan Gesture
    var gesture = UIPanGestureRecognizer()
    ///Initial position of tableView
    var trayOriginalCenter: CGPoint! ///original tableview position
    var trayDownOffset: CGFloat! ///how much our tableview can be moved up
    var trayUp: CGPoint! ///moving tableview up
    var trayDown: CGPoint! ///moving tableview down
    
    
    ///home: 0, recipeList: 1, recipes: 2, cartList: 3, list: 4
    var choosenOption:Int = -1
    var options:[Int:[Option]]=[:]
    
    ///selected cell
    var indexPath:Int=0
    
    ///showHide Header
    var showHeader:Bool=false
    
    ///HomeVC delegate
    var delegate:HomeVCOperation?
    
    ///Cart Delegate
    var delegateCart:CartVCOperation?
    
    ///List Delegate
    var delegateList:ListTVOperation?
    
    ///Recipes Delegate
    var delegateRecipes:RecipesVCOperation?
    
    ///Recipe Delegate
    var delegateRecipe:RecipeVCOperation?
    
    //Add Recipe
    var delegateAddRecipe:AddVCOperation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(_:)))
        self.gesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gesture)
        gesture.delegate = self as? UIGestureRecognizerDelegate
        
        self.tableView.separatorColor = .clear
        
        self.background.backgroundColor = UIColor.MyTheme.Eight.withAlphaComponent(0.6)
        self.background.alpha = 0.0
        
        self.barView.layer.cornerRadius = 3
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        self.tableView.register(UINib(nibName: "OptionsNib", bundle: nil), forCellReuseIdentifier: "OptionsNib")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPage))
        self.background.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trayDownOffset = self.height.constant
        trayUp = self.tableView.center
        trayDown = CGPoint(x: tableView.center.x ,y: tableView.center.y + trayDownOffset)
    }
    
    
    @objc func wasDragged(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        let velocity = gestureRecognizer.velocity(in: view)

        /*
         We can tell which way a user is panning by looking at the gesture property, velocity. Like translation, velocity has a value for both x and y components. If the y component of the velocity is a positive value, the user is panning down. If the y component is negative, the user is panning up.
         */
        if gestureRecognizer.state == .began {
            self.tableView.allowsSelection = false
            ///When the gesture begans (.Began), store the tray's center into the trayOriginalCenter variable:
            trayOriginalCenter = self.tableView.center
            
        } else if gestureRecognizer.state == .changed {
            ///As the user pans (.Changed), change the trayView.center by the translation. Note: we ignore the x translation because we only want the tray to move up and down:
            if translation.y > 0{
                self.tableView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            }
                    
        } else if gestureRecognizer.state == .ended {
            ///panning down
            if velocity.y > 0 {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                    self.tableView.center = self.trayDown
                }) { (_) in
                    self.dismiss()
                }
            ///panning up
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                    self.tableView.center = self.trayUp
                }, completion: { _ in
                    self.tableView.allowsSelection = true
                })
            }
        }
    }
    
    
    @objc func dismissPage(){
        self.background.alpha = 0.0
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if showHeader{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsNib") as? OptionsNib
        
            cell?.Label.text = UI.EF ? "Are you sure?":"شما مطمئن هستید?"
            cell?.icon.image = UIImage(systemName: "exclamationmark.triangle.fill")
            cell?.initCell()

            return cell
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showHeader{
            return 50
        }
        return 0.01
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[choosenOption]?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsNib", for: indexPath) as? OptionsNib
        
        if let option = self.options[choosenOption]?[indexPath.row]{
            cell?.Label.text = option.name
            cell?.icon.image = UIImage(systemName: option.image)
        }
        cell?.initCell()
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


extension OptionsVC{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? OptionsNib
        cell?.selectAndDeselect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        switch self.choosenOption {
        case 0: ///Home Page
            if self.showHeader{ ///delete options
                if indexPath.row == 0 {
                    self.delegate?.DeleteControl(Choice: self.indexPath)
                    self.dismiss()
                }else{
                   self.dismiss()
                }
            }else{
                if indexPath.row == 0 || indexPath.row == 1{ ///delete category or category and recipe
                    self.indexPath = indexPath.row
                    self.questionOption()
                }
                else if indexPath.row == 2{
                    self.dismiss()
                }
            }
        case 1: ///Cart Page
            if self.showHeader{ ///delete options
                if indexPath.row == 0 {
                    self.delegateCart?.DeleteControl()
                    self.dismiss()
                }else{
                    self.dismiss()
                }
            }else{
                if indexPath.row == 0 { ///delete list
                    self.indexPath = indexPath.row
                    self.questionOption()
                }
                else if indexPath.row == 1{
                    self.dismiss()
                }
            }
        case 2: ///List page
            if indexPath.row == 0 { /// add list to widget
                self.delegateList?.ListControl()
                self.dismiss()
            }
            else if indexPath.row == 1{
                self.dismiss()
            }
        case 3: ///Recipies page
            if self.showHeader{ ///delete control
                if indexPath.row == 0 {
                    self.delegateRecipes?.DeleteControl()
                    self.dismiss()
                }else{
                    self.dismiss()
                }
            }else{
                if indexPath.row == 0 { ///delete recipe
                    self.questionOption()
                }
                else if indexPath.row == 1{
                    self.dismiss()
                }
            }
        case 4: ///Recipe Page
            if self.showHeader{ ///delete options
                if indexPath.row == 0 {
                    
                    self.background.alpha = 0.0
                    
                    self.dismiss(animated: true) {
                        self.delegateRecipe?.DeleteControl()
                    }
                }else{
                    self.dismiss()
                }
            }else{
                if indexPath.row == 0 { ///edit recipe
                    
                    self.background.alpha = 0.0
                    
                    self.dismiss(animated: true) {
                        self.delegateRecipe?.RecipeControl(choice: 0)
                    }
                }
                else if indexPath.row == 1{ ///share recipe
                    
                    self.background.alpha = 0.0
                    
                    self.dismiss(animated: true) {
                        self.delegateRecipe?.RecipeControl(choice: 1)
                    }
                }
                else if indexPath.row == 2{ ///add ingredient to list
                    
                    self.background.alpha = 0.0
                    
                    self.dismiss(animated: true) {
                        self.delegateRecipe?.RecipeControl(choice: 2)
                    }
                }
                else if indexPath.row == 3{ ///delete recipe
                    self.questionOption()
                }
                else if indexPath.row == 4{
                    self.dismiss()
                }
            }
        case 5: ///Add Recipe page for image
            self.background.alpha = 0.0
            
            if indexPath.row == 0 { ///access camera
                self.dismiss(animated: true) {
                    self.delegateAddRecipe?.AddImageAC(0)
                }
            }
            else if indexPath.row == 1{ ///access library
                self.dismiss(animated: true) {
                    self.delegateAddRecipe?.AddImageAC(1)
                }
            }
            else if indexPath.row == 2{ ///dismiss
                self.dismiss()
            }
        default:
            break
        }
        }
    }
    
    
    
    
    private func questionOption(){
        
        self.options = [:]
        var option:[Option]=[]
        option.append(contentsOf:[Option(name: UI.EF ? "Yes":"بله", image: "trash.circle.fill"),Option(name: UI.EF ? "No":"خیر", image: "xmark.circle.fill")])
        self.options[self.choosenOption] = option
        self.showHeader = true
        
        self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableView.reloadData()
        }
    }
    
    ///home: 0, recipeList: 1, recipes: 2, cartList: 3, list: 4
    public func addOptions(){
        switch self.choosenOption {
        case 0:
            var option:[Option]=[]
            option.append(contentsOf: [Option(name: UI.EF ? "Delete only category" : "فقط دسته را حذف کنید", image: "trash.circle.fill"),Option(name: UI.EF ? "Delete category and recipes" : "حذف دسته و دستور غذاها", image: "trash.circle.fill"),Option(name: UI.EF ? "Dismiss" : "رد", image: "xmark.circle.fill")])
            self.options[0] = option
            
        case 1:
            var option:[Option]=[]
            option.append(contentsOf: [Option(name: UI.EF ? "Would you like to delete this list?":"آیا می خواهید این دستور غذا را حذف کنید؟", image: "trash.circle.fill"),Option(name: UI.EF ? "Dismiss" : "رد", image: "xmark.circle.fill")])
            self.options[1] = option
            
        case 2:
            var option:[Option]=[]
            option.append(contentsOf: [Option(name: UI.EF ? "Add to Widget" : "افزودن به ویجت", image: "plus.circle.fill"),Option(name: UI.EF ? "Dismiss" : "رد", image: "xmark.circle.fill")])
            self.options[2] = option
            
        case 3:
            var option:[Option]=[]
            option.append(contentsOf: [Option(name: UI.EF ? "Would you like to delete this recipe?":"آیا می خواهید این دستور غذا را حذف کنید؟", image: "plus.circle.fill"),Option(name: UI.EF ? "Dismiss" : "رد", image: "xmark.circle.fill")])
            self.options[3] = option
            
        case 4:
            var option:[Option]=[]
            option.append(contentsOf: [Option(name: UI.EF ? "Edit" : "ویرایش", image: "pencil.circle.fill") ,Option(name: UI.EF ? "Share" : "اشتراک گذاری", image: "arrowshape.turn.up.left.circle.fill"),Option(name: UI.EF ? "Add Ingredients to Cart" : "مواد لازم را به سبد خرید اضافه کنید", image: "cart.fill"),Option(name: UI.EF ? "Delete" : "حذف", image: "trash.circle.fill"),Option(name: UI.EF ? "Dismiss" : "رد", image: "xmark.circle.fill")])
            self.options[4] = option
            
        case 5:
            var option:[Option]=[]
            option.append(contentsOf: [Option(name: UI.EF ? "Camera" : "دوربین", image: "camera.circle.fill") ,Option(name: UI.EF ? "Library" : "کتابخانه", image: "folder.circle.fill"),Option(name: UI.EF ? "Dismiss" : "رد", image: "xmark.circle.fill")])
            self.options[5] = option
        default:
            break
        }
    }
    
    
}
