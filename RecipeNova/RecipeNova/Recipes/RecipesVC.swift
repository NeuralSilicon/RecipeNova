
import UIKit

protocol RecipesVCOperation {
    func UpdateRecipe(recipe:Recipes) ///In case our recipe was updated
    func AddRecipe(recipe:Recipes) ///In case we added a new recipe
    func RemoveRecipe(recipe:Recipes) ///In case our recipe was removed
    func DeleteControl()///Calling from option
}

class RecipesVC: UIViewController,RecipesVCOperation,UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate{
    func UpdateRecipe(recipe: Recipes) {
        /*
         Update our array
         Update the filter array
         Set our table count limits
         Reload table
         */
        self.recipes.updateValue(recipe)
        self.filterRecipes.updateValue(recipe)
        self.SetLimit()
        
        guard let index = self.filterRecipes.indexOf(recipe) else {
            return
        }
        self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    func AddRecipe(recipe: Recipes) {
        /*
         Add recipe to our array
         Sort our array
         Update the filter array
         Set our table count limits
         Reload table
         */

        self.recipes.insert(recipe)
        self.filterRecipes.insert(recipe)
        self.NoView.removeFromSuperview() ///No recipe image and label
        self.SetLimit()
        
        guard let indx = self.filterRecipes.indexOf(recipe) else {
            return
        }
        self.collectionView.insertItems(at: [IndexPath(row: indx, section: 0)])
    }
    
    func RemoveRecipe(recipe:Recipes){
        /*
         remove recipe from our array
         Update the filter array
         Set our table count limits
         Reload table
         */
        self.recipes.remove(recipe)
        self.filterRecipes.remove(recipe)
        self.SetLimit()
        if filterRecipes.count == 0{
            self.ShowNoView()
        }else{
            self.NoView.removeFromSuperview()
        }
        
        guard let index = self.filterRecipes.indexOf(recipe) else {
            return
        }
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }

    
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var AddB: UIBarButtonItem!
    @IBAction func AddButton(_ sender: UIBarButtonItem) {
        saving.Editing = false ///not editing the recipe
        saving.NewRecipe = Recipes() ///init a new recipe struct which creates a new uiid
        saving.ReplaceIndex = -1 ///Replace certain image
        saving.NewRecipe.Category = self.category ///pass the current category to the recipe
        self.performSegue(withIdentifier: "Add", sender: nil)
    }
    @IBOutlet var closeB: UIBarButtonItem!
    @IBAction func CloseButton(_ sender: UIBarButtonItem) {
        let vc = self
        self.view.window?.rootViewController?.dismiss(animated: true) {
            self.recipes = AVLTree<Recipes>()
            self.filterRecipes = AVLTree<Recipes>()
            vc.collectionView.removeFromSuperview()
        }
    }
    
    
    var limit = 0
    var category=Categories()
    var trieSearch = Trie<String>()
    var recipes = AVLTree<Recipes>()
    var filterRecipes = AVLTree<Recipes>()
    lazy var imageData:[Int:UIImage]=[:]
    let controller = UISearchController(searchResultsController: nil)
    var isSearching:Bool = false
    
    ///track recipes for showing options
    var trackRecipe = Recipes()
    var trackIndex = IndexPath(row: 0, section: 0)
    
    ///Show NoView
    let NoView = UIView()
    let Label = UILabel()
    let Image = UIImageView(image: UIImage(systemName: "list.bullet.below.rectangle"))
    
    ///Create a var of Message Animation
    var LoadingAnimation:MessageAnimation?
    
    @objc func dismissPage(){
        let vc = self
        self.view.window?.rootViewController?.dismiss(animated: true) {
            self.recipes = AVLTree<Recipes>()
            self.filterRecipes = AVLTree<Recipes>()
            vc.collectionView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        ///dismiss page on swipe
        let swipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(dismissPage))
        swipe.edges = .left
        self.view.addGestureRecognizer(swipe)
        
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
        
        self.view.backgroundColor = UI.MC.toColor()
        self.collectionView.backgroundColor = .clear
        
        ///init Loading Animation
        self.LoadingAnimation = MessageAnimation(rect: self.collectionView.frame, navigheight: self.navigationController?.navigationBar.frame.height ?? 80)
        self.LoadingAnimation?.SetLoadingAnimtion()
        self.collectionView.addSubview(self.LoadingAnimation?.loadingView ?? self.view)
        self.collectionView.bringSubviewToFront(self.LoadingAnimation?.loadingView ?? self.view)
        
        self.LoadingAnimation?.StartloadingAnimation(E: "", F: "")
        
        ///No recipe view
        Label.setWB(W: .black, B: .white)
        NoView.backgroundColor = .clear
        Image.tintColor = UI.WB ? .white : .black
        self.SetUpNoView()
          
        self.navigationItem.title = self.category.Name
        
        self.collectionView.delegate=self
        self.collectionView.dataSource=self
        
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        

        self.SetUpSearchController()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ///Fetch all the recipes under declared category and sort them based on names
            LoadHandler().FetchFromCoreData(category: self.category) { (recipe) in
                
                recipe.root?.traversePreOrder(visit: { (RC) in
                    self.recipes.insert(RC)
                    self.filterRecipes.insert(RC)
                    self.trieSearch.insert(RC.Name)
                })
                
                self.SetLimit()
                self.collectionView.reloadData()
            }
            self.LoadingAnimation?.RemoveWithNoDelayLoadingScreen()
                
            if self.filterRecipes.count == 0{
                self.ShowNoView()
            }else{
                self.NoView.removeFromSuperview()
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
        
        controller.searchBar.placeholder = UI.EF ? "Search Recipes" : "جستجو در دستور غذا"
        controller.searchBar.tintColor = UIColor.MyTheme.Seven

        controller.searchBar.isTranslucent = false
        controller.searchBar.barStyle = .black
        controller.searchBar.keyboardAppearance = UI.WB ? .dark : .light
        
        controller.automaticallyShowsScopeBar = true
        controller.searchBar.searchTextField.backgroundColor = UI.WB ? UIColor.MyTheme.Nine : UIColor.MyTheme.Eight
        controller.searchBar.searchTextField.tintColor = UI.WB ? UIColor.MyTheme.Eight : UIColor.MyTheme.Seven
        controller.searchBar.searchTextField.textColor = .white
         
        definesPresentationContext = true
        self.navigationItem.searchController = controller
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive{
            if controller.searchBar.text?.isEmpty == false{
                ///look into our trie and find the matching prefix
                let results = self.trieSearch.collections(startWith: searchController.searchBar.text?.trimmingCharacters(in:CharacterSet.whitespaces) ?? "")
                
                self.filterRecipes = AVLTree<Recipes>()
                
                ///for all the names in the result, search the source and find the matching recipes and add them to the filter
                for names in results{
                    self.recipes.root?.traversePreOrder(visit: { (R) in
                        if names == R.Name{
                            self.filterRecipes.insert(R)
                        }
                    })
                }
                
                self.isSearching = true
                
                self.SetLimit()
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
                }, completion: nil)
                
            }else{
                self.isSearching = true
                
                self.filterRecipes = AVLTree<Recipes>()

                self.SetLimit()
                self.collectionView.reloadData()
            }
        }else{
            self.isSearching = false
            
            
            self.filterRecipes = AVLTree<Recipes>()
            
            self.recipes.root?.traversePreOrder(visit: { (R) in
                self.filterRecipes.insert(R)
            })
            
            self.SetLimit()
            self.collectionView.reloadData()
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Add"{
            let naviC = segue.destination as! UINavigationController
            let vc = naviC.topViewController as? AddVC
            vc?.delegate=self
        }else if segue.identifier == "Recipe"{
            let vc = segue.destination as? RecipeVC
            if let index = self.collectionView.indexPathsForSelectedItems{
                vc?.recipe = self.filterRecipes.index(index.first?.row ?? 0) ?? self.filterRecipes.root!.value
            }
            vc?.delegate=self
        }
    }
    
    
    
    //MARK: -Show No View
    func SetUpNoView(){
        
        NoView.backgroundColor = .clear
        NoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        NoView.alpha = 1.0
           
        Label.setWB(W: .black, B: .white)
        Label.textAlignment = .center
        Label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        Label.text = UI.EF ? "Tap + to add a recipe.":"برای افزودن دستور غذا، روی + ضربه بزنید."
        Label.frame.size = CGSize(width: 270, height: 100)
        
        Label.frame.origin = CGPoint(x: self.NoView.frame.midX - 130 , y:self.NoView.frame.midY - 250)
        Image.frame = CGRect(x: self.NoView.frame.midX - 30, y: Label.frame.origin.y + 50
            , width: 50, height: 100)

        Image.contentMode = .scaleAspectFit
        Image.image = Image.image?.withRenderingMode(.alwaysTemplate)
        Image.tintColor = UI.WB ? .white: .black
        self.NoView.addSubview(Label)
        self.NoView.addSubview(Image)

    }
    func ShowNoView(){
        self.collectionView.addSubview(self.NoView)
        UIView.animate(withDuration: 0.5) {
            self.NoView.alpha = 1.0
        }
    }
    
    //MARK: - Options
    func showOptions(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "OptionsVC") as! OptionsVC

        viewController.delegateRecipes = self
        
        viewController.modalPresentationStyle = .overFullScreen
        viewController.view.backgroundColor = .clear
            
        viewController.choosen(3)
            
        self.present(viewController, animated: true, completion: nil)
    }
    
}
