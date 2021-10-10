
import UIKit

extension RecipeVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recipe.Images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCVC", for: indexPath) as? RecipeCVC

        let image = UIImage(data: self.recipe.Images[indexPath.row])
        cell?.Image.image = image?.Resize(targetSize: CGSize(width: 100, height: 100))
        cell?.Shadow(color: .black, radius: 1, alpha: 0.4, size: CGSize(width: 1, height: 1))
        cell?.indexPath = indexPath
        cell?.delegate=self
        
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.AnimteEventCell()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.image.images = self.recipe.Images
            self.image.SelectedImage = indexPath.row
            self.performSegue(withIdentifier: "ImageHandler", sender: nil)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -50, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.height / 1.2, height: self.collectionView.frame.height / 1.2)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}



class RecipeCVC: UICollectionViewCell,UIContextMenuInteractionDelegate{
    @IBOutlet weak var Image: UIImageView!{
        didSet{
            self.Image.layer.cornerRadius = 25
            self.Image.layer.masksToBounds = true
        }
    }
    
    var delegate:RecipeVCOperation?
    var indexPath:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.Image.image = nil
    }
    
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in
            
            
            let View = UIAction(title:  UI.EF ? "View":"دیدن", image: UIImage(systemName: "eye.fill"), identifier: UIAction.Identifier(rawValue: "View")) {_ in
                self.delegate?.ImageActions(type: .See, indx: self.indexPath ?? IndexPath(row: 0, section: 0))
              }
            let Share = UIAction(title: UI.EF ? "Share":"اشتراک", image: UIImage(systemName: "square.and.arrow.up.fill"), identifier: UIAction.Identifier(rawValue: "Share")) {_ in
                self.delegate?.ImageActions(type: .Share, indx: self.indexPath ?? IndexPath(row: 0, section: 0))
            }

            return UIMenu(title: "", image: nil, identifier: nil, children: [View, Share])
        }
        
        return configuration
    }
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?{
        let Preview = UITargetedPreview(view: self)
        Preview.view.layer.cornerRadius = 25
        Preview.view.backgroundColor = .clear
        self.Image.layer.masksToBounds = false
        return Preview
    }
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?{
        let Preview = UITargetedPreview(view: self)
        Preview.view.layer.cornerRadius = 25
        Preview.view.backgroundColor = .clear
        self.Image.layer.masksToBounds = true
        return Preview
    }
}
