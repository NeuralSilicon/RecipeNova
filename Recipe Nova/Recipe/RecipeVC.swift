
import UIKit

struct ImageStruct {
    var SelectedImage:Int = -1
    var images:[Data]=[]
}

enum RecipeImage:Int {
    case See=0
    case Share=1
}

protocol RecipeVCOperation {
    func UpdateRecipe(recipe:Recipes)///In case recipe was updated
    func ImageActions(type:RecipeImage,indx:IndexPath) ///When image was selected to either be shared or see
    func RecipeControl(choice:Int) ///Calling from options
    func DeleteControl() ///Calling from options
}


class RecipeVC: UIViewController,RecipeVCOperation,UIGestureRecognizerDelegate {
    //MARK: - Protocols
    func ImageActions(type:RecipeImage,indx:IndexPath) {
        if type.rawValue == 0{
            ///Showing the selected image in image handler
            self.image.SelectedImage = indx.row
            self.image.images = self.recipe.Images
            self.performSegue(withIdentifier: "ImageHandler", sender: nil)
        }else{
            ///Share the selected Image
            var imagesToShare = [AnyObject]()
            imagesToShare.append(UIImage(data: self.recipe.Images[indx.row])!)
            let activityViewController = UIActivityViewController(activityItems: imagesToShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func UpdateRecipe(recipe:Recipes){
        ///Call back recipeVC to update our recipe
        self.delegate?.UpdateRecipe(recipe: recipe)
        ///call back seachvc to update recipe
        if self.Search{
            self.delegateSearch?.UpdateRecipe(recipe: recipe)
        }
        self.recipe = recipe
        ///Set how many section is being shown for example, ingredient or directions was added to the recipe
        self.SetSections()
        self.collectionView.reloadData()
    }
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var collectionView:UICollectionView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var MoreB: UIBarButtonItem!
    @IBAction func MoreButton(_ sender: UIBarButtonItem) {
        self.showOptions()
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    let Etitles=["Name","Ingredients","Directions"]
    let Ptitles=["اسم","اجزاء","جهت ها"]
    var recipe = Recipes()
    var delegate:RecipesVCOperation?
    var delegateSearch:SearchOperation?
    var image=ImageStruct() ///handling all image selection in collectionview
    var NumOfSection=3 ///initial tableview sections
    var Search:Bool=false ///if its opened from search page
    
    //Create a var of Message Animation
    var LoadingAnimation:MessageAnimation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // Init Loading Animation
        self.LoadingAnimation = MessageAnimation(rect: self.view.frame, navigheight: self.navigationController?.navigationBar.frame.height ?? 80)
        self.LoadingAnimation?.SetLoadingAnimtion()
        self.view.addSubview(self.LoadingAnimation?.loadingView ?? self.view)
        self.view.bringSubviewToFront(self.LoadingAnimation?.loadingView ?? self.view)
     
        self.navigationItem.title = self.recipe.Name
        
        self.view.backgroundColor = UI.AC.toColor().withAlphaComponent(0.8)
        self.tableView.backgroundColor = .clear
        self.collectionView.backgroundColor = UI.MC.toColor()
        
        self.tableView.delegate=self
        self.tableView.dataSource=self
        self.tableView.clipsToBounds = false

        self.tableView.register(UINib(nibName: "LabelNib", bundle: nil), forCellReuseIdentifier: "LabelNib")
        self.tableView.contentInset = UIEdgeInsets(top: self.collectionView.frame.size.height, left: 0, bottom: 30, right: 0)
        
        self.collectionView.delegate=self
        self.collectionView.dataSource=self
        self.SetSections()
    }
    
    ///hide or unhide the sections that dont have contents to show
    private func SetSections(){
        self.NumOfSection=3
        
        if self.recipe.Ingredients == "" || self.recipe.Ingredients == " \u{2022} "{
            self.NumOfSection-=1
        }else{
            self.NumOfSection=3
        }
        if self.recipe.Direction == "" || self.recipe.Direction ==  " 1. "{
            self.NumOfSection-=1
        }else{
            if self.NumOfSection != 3{
                self.NumOfSection+=1
            }
        }
        self.tableView.reloadData()
    }
    
   ///handle the scrolling in tableview which makes the collectionview smaller
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let y = 100 - (scrollView.contentOffset.y + 100)
            let height = min(max(y, 100), 300)
            self.collectionViewHeight.constant = height
            self.collectionView.updateConstraints()
            self.collectionView.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Add"{
            let navigc = segue.destination as! UINavigationController
            let vc = navigc.topViewController as? AddVC
            vc?.delegateRecipe=self
        }
        else if segue.identifier == "ImageHandler" ,let destination = segue.destination as? ImageHandler {
              destination.image = self.image
        }
    }
    
    //MARK: - Options
    func showOptions(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "OptionsVC") as! OptionsVC

        viewController.delegateRecipe = self
        
        viewController.modalPresentationStyle = .overFullScreen
        viewController.view.backgroundColor = .clear
            
        viewController.choosen(4)
            
        self.present(viewController, animated: true, completion: nil)
    }
}

