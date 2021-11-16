
import UIKit

//Add Model
var saving=Saving()
struct Saving {
    var Editing:Bool=false //editing evenr ot not
    var NewRecipe=Recipes() //recipe Model
    var ReplaceIndex = -1 //Replace certain image
}

protocol AddVCOperation {
    func ReloadTable()
    func RemoveImage(index:Int) ///In case image was removed
    func ReplaceImage(index:Int) ///In case image was replaced
    func AddImageAC(_ choice:Int) ///Calling from optionvc
}

class AddVC: UIViewController,AddVCOperation {
    func RemoveImage(index: Int) {
        /*
         remove the image from our recipe image array
         reload our collectionview
         */
        saving.NewRecipe.Images.remove(at: index)
        self.imageLimit = saving.NewRecipe.Images.count >= 5 ? false : true
        ///relaod image cell if we have less than  5 image
        if self.imageLimit == true{
            self.collectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
        }

    }
    func ReplaceImage(index: Int) {
        /*
         set our image index for replacements
         call the options for adding image for our replacement
         */
        saving.ReplaceIndex = index
        self.showOptions()
    }
    func ReloadTable(){self.tableView.reloadData()}

    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var SaveB: UIBarButtonItem!
    @IBAction func SaveButton(_ sender: UIBarButtonItem) {
        let SR = SavingHandler(recipe: saving.NewRecipe)
        SR.EncodeRecipeToSave(edit: saving.Editing)
        
        if saving.Editing{
            self.delegateRecipe?.UpdateRecipe(recipe: saving.NewRecipe)
        }else{
            self.delegate?.AddRecipe(recipe: saving.NewRecipe)
        }
        
        let vc = self
        self.dismiss(animated: true) {
            saving = Saving()
            vc.collectionView.removeFromSuperview()
            vc.tableView.removeFromSuperview()
        }
    }
    @IBOutlet var CloseB: UIBarButtonItem!
    @IBAction func CloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let Etitles=["Name","Ingredients","Directions"]
    let Ptitles=["اسم","اجزاء","جهت ها"]
    var delegate:RecipesVCOperation?
    var delegateRecipe:RecipeVCOperation?
    var imageLimit:Bool=true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = UI.EF ? "Add Recipe":"دستور آشپزی"
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
        self.tableView.separatorColor = .clear
        self.view.backgroundColor = UI.MC.toColor()
        self.collectionView.backgroundColor = UI.MC.toColor()
        
        self.tableView.delegate=self
        self.tableView.dataSource=self
        self.tableView.register(UINib(nibName: "LabelNib", bundle: nil), forCellReuseIdentifier: "LabelNib")
        
        self.collectionView.delegate=self
        self.collectionView.dataSource=self
        
        self.tableView.contentInset = UIEdgeInsets(top: self.collectionView.frame.size.height, left: 0, bottom: 20, right: 0)
        self.imageLimit = saving.NewRecipe.Images.count >= 5 ? false : true
    }
    

    ///handle tableview scrolling to make collectionview smaller
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let y = 150 - (scrollView.contentOffset.y + 150)
            let height = min(max(y, 150), 300)
            self.collectionViewHeight.constant = height
            self.collectionView.updateConstraints()
            self.collectionView.layoutIfNeeded()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Name"{
            let navigc = segue.destination as! UINavigationController
            let vc = navigc.topViewController as? AddName
            vc?.delegate=self
        }else if segue.identifier == "Ingredients"{
            let navigc = segue.destination as! UINavigationController
            let vc = navigc.topViewController as? AddIngredients
            vc?.delegate=self
        }else if segue.identifier == "Directions"{
            let navigc = segue.destination as! UINavigationController
            let vc = navigc.topViewController as? AddDirections
            vc?.delegate=self
        }
    }
    
    
    //MARK: - Options
    func showOptions(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "OptionsVC") as! OptionsVC

        viewController.delegateAddRecipe = self
        
        viewController.modalPresentationStyle = .overFullScreen
        viewController.view.backgroundColor = .clear
            
        viewController.choosen(5)
            
        self.present(viewController, animated: true, completion: nil)
    }

}



