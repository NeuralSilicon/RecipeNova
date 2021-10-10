import UIKit

protocol SearchOperation {
    func UpdateRecipe(recipe:Recipes) ///For the time recipe was edited
    func RemoveRecipe(recipe:Recipes) ///For the time recipe was removed
}

class SearchTV: UITableViewController,UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,SearchOperation {
    
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
        self.tableView.reloadData()
    }
    func RemoveRecipe(recipe:Recipes){
        /*
         Remove recipe from our array
         Update the filter array
         Set our table count limits
         if our array is empty then show no recipe image and label
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
        self.tableView.reloadData()
    }
    
    
    
    @IBAction func CloseButton(_ sender: UIBarButtonItem) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    var limit = 0
    var trieSearch = Trie<String>()
    var recipes = AVLTree<Recipes>()
    var filterRecipes = AVLTree<Recipes>()
    let controller = UISearchController(searchResultsController: nil)

    
    //Show NoView
    let NoView = UIView()
    let Label = UILabel()
    let Image = UIImageView(image: UIImage(systemName: "magnifyingglass"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        Label.setWB(W: .black, B: .white)
        NoView.backgroundColor = .clear
        Image.tintColor = UI.WB ? .white : .black
        self.SetUpNoView()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .bold)]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UI.AC.toColor().darker
        
        self.tableView.backgroundColor = UI.MC.toColor()
        self.tableView.separatorColor = UI.MC.toColor().withAlphaComponent(0.7)
        self.tableView.contentInset = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)
        
        self.navigationItem.title = UI.EF ? "Search":"جستجو"
        
        self.tableView.delegate=self
        self.tableView.dataSource=self
        self.tableView.register(UINib(nibName: "LabelsNib", bundle: nil), forCellReuseIdentifier: "LabelsNib")
        
        self.SetUpSearchController()
        
        ///Fetch all the recipes and sort them based on their names
        LoadHandler().FetchFromCoreData{ (recipe) in

            recipe.root?.traversePreOrder(visit: { (R) in
                self.recipes.insert(R)
                self.trieSearch.insert(R.Name)
            })
        }
        
        if filterRecipes.count == 0{
            self.ShowNoView()
        }else{
            self.NoView.removeFromSuperview()
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controller.isActive = true

        DispatchQueue.main.async{
            self.controller.searchBar.becomeFirstResponder()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.limit
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsNib", for: indexPath) as? LabelsNib
        
        cell?.Label.text = self.filterRecipes.index(indexPath.row)?.Name
        cell?.Label.textColor = .white
        cell?.SetUpArrow()
        cell?.backgroundColor = UI.AC.toColor()
        cell?.textField.isEnabled = false
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? LabelsNib
        cell?.SelectCellAndDeselect()
        
        self.performSegue(withIdentifier: "Recipe", sender: nil)
    }

    override func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            let main = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = main.instantiateViewController(withIdentifier: "RecipeVC") as! RecipeVC
            vc.delegateSearch=self
            vc.Search=true
            vc.recipe = self.filterRecipes.index(indexPath.row) ?? Recipes()
            return vc
        }) { (_: [UIMenuElement]) -> UIMenu? in
            let View = UIAction(title:  UI.EF ? "View":"دیدن", image: UIImage(systemName: "eye.fill"), identifier: UIAction.Identifier(rawValue: "View")) {_ in
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                self.performSegue(withIdentifier: "Recipe", sender: nil)
            }
            return UIMenu(title: "", image: nil, identifier: nil, children: [View])
        }
        return configuration
    }
    //MARK: - Reload TableView as Scrolled To Bottom
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tableView{

            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                if !CheckLimitCounts(){
                    self.limit = (self.filterRecipes.count >= (self.limit + 11) ? (self.limit + 11) : self.filterRecipes.count)
                    self.tableView.reloadData()
                }
            }
        }
    }
        
    //Check Our Limit Counts to Not Reload TableView for Nothing
    func CheckLimitCounts()->Bool{
        return self.limit == self.filterRecipes.count
    }
    
    func SetLimit(){
        self.limit = (self.filterRecipes.count >= 11 ? 11 : self.filterRecipes.count)
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
        controller.searchBar.searchTextField.tintColor = UI.AC.toColor()
        controller.searchBar.searchTextField.textColor = .white
         
        definesPresentationContext = true
        self.navigationItem.searchController = controller
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
   
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive{
            if controller.searchBar.text?.isEmpty == false{
                
                ///search our trie to see if we can find matching recipes with the same prefix
                let result = self.trieSearch.collections(startWith: searchController.searchBar.text?.trimmingCharacters(in:CharacterSet.whitespaces) ?? "")
                ///reinit our filter tree
                self.filterRecipes = AVLTree<Recipes>()
                
                ///for all the names in our result, go through our source and add them back to our filter tree
                result.forEach { (name) in
                    self.recipes.root?.traversePreOrder(visit: { (R) in
                        if name == R.Name{
                            self.filterRecipes.insert(R)
                        }
                    })
                }

                if filterRecipes.count == 0{
                    self.ShowNoView()
                }else{
                    self.NoView.removeFromSuperview()
                }

                self.SetLimit()
                self.tableView.reloadData()
                
            }else{

                self.filterRecipes = AVLTree<Recipes>()
                self.ShowNoView()

                self.SetLimit()
                self.tableView.reloadData()
            }
        }else{
            
            self.filterRecipes = AVLTree<Recipes>()
            self.SetLimit()
            self.ShowNoView()
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Recipe"{
            let vc = segue.destination as? RecipeVC
            if let index = self.tableView.indexPathForSelectedRow{
                vc?.recipe = self.filterRecipes.index(index.row) ?? Recipes()
            }
            vc?.delegateSearch=self
            vc?.Search=true
        }
    }
    
    
    //Show No View
    func SetUpNoView(){
        
        NoView.backgroundColor = .clear
        NoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        NoView.alpha = 1.0
           
        Label.setWB(W: .black, B: .white)
        Label.textAlignment = .center
        Label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        Label.text = UI.EF ? "Search recipes":"جستجو در دستور غذاها"
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
}
