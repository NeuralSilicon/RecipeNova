
import UIKit

extension RecipesVC: UICollectionViewDelegate, UICollectionViewDataSource,PinterestLayoutDelegate{
    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.limit
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCollectionViewCell", for: indexPath) as? RecipeCollectionViewCell
        
        cell?.Label.text = self.filterRecipes.index(indexPath.row)?.Name
        if self.filterRecipes.index(indexPath.row)?.Images.count ?? 0 > 0{
            cell?.iMage.image = UIImage(data: self.filterRecipes.index(indexPath.row)!.Images[0])?.Resize(targetSize: CGSize(width: 80, height: 80))
            
        }
        
        cell?.backgroundColor = UI.AC.toColor()
        cell?.layer.cornerRadius = 5
        
         return cell!
    }
         
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)

        cell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
            cell?.transform = .identity
        }, completion: { _ in
            self.performSegue(withIdentifier: "Recipe", sender: nil)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let randomHeight = CGFloat.random(in: 150...250)
        return randomHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !self.isSearching{
            cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
            UIView.animate(withDuration: 0.4, animations: {
                cell.layer.transform = CATransform3DMakeScale(1.05,1.05,1)
            },completion:nil)
            UIView.animate(withDuration: 0.4, delay: 0.4, options: .allowUserInteraction, animations: {
                cell.layer.transform = CATransform3DMakeScale(1,1,1)
            }, completion: nil)
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            let main = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = main.instantiateViewController(withIdentifier: "RecipeVC") as! RecipeVC
            vc.delegate=self
            vc.recipe = self.filterRecipes.index(indexPath.row)!
            return vc
        }) { (_: [UIMenuElement]) -> UIMenu? in
    
            let View = UIAction(title:  UI.EF ? "View":"دیدن", image: UIImage(systemName: "eye.fill"), identifier: UIAction.Identifier(rawValue: "View")) {_ in
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
                self.performSegue(withIdentifier: "Recipe", sender: nil)
            }
    
            let Delete = UIAction(title:  UI.EF ? "Delete":"حذف", image: UIImage(systemName: "trash.fill"), identifier: UIAction.Identifier(rawValue: "Delete"), discoverabilityTitle: nil, attributes: .destructive, state: .off) { (_) in
                self.trackRecipe = self.filterRecipes.index(indexPath.row)!
                self.trackIndex = indexPath
                self.showOptions()
            }
            return UIMenu(title: "", image: nil, identifier: nil, children: [Delete,View])
        }
        return configuration
    }
    
    
    
    //MARK: - Reload TableView as Scrolled To Bottom
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == collectionView{

            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                if !CheckLimitCounts(){
                    self.limit = (self.filterRecipes.count >= (self.limit + 10) ? (self.limit + 10) : self.filterRecipes.count)
                    self.collectionView.reloadData()
                }
            }
        }
    }
        
    //Check Our Limit Counts to Not Reload TableView for Nothing
    func CheckLimitCounts()->Bool{
        return self.limit == self.filterRecipes.count
    }
    
    func SetLimit(){
        self.limit = (self.filterRecipes.count >= 10 ? 10 : self.filterRecipes.count)
    }
}



class RecipeCollectionViewCell: UICollectionViewCell {
    @IBOutlet var Label: UILabel!{
        didSet{
            self.Label.SetTextColor(Color: .white)
        }
    }
    @IBOutlet weak var iMage:UIImageView!{
        didSet{
            self.iMage.clipsToBounds = true
            self.iMage.layer.cornerRadius = 5
        }
    }
    @IBOutlet var imageForeground: UIView!{
        didSet{
            self.imageForeground.layer.cornerRadius = 5
            self.imageForeground.Shadow(color: .black, radius: 1, alpha: 0.4, size: CGSize(width: 1, height: 1))
        }
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.iMage.image = nil
    }
    
}
