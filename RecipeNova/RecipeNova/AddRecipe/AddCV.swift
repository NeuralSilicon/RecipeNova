import UIKit

extension AddVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ///add one because first cell is going to be for adding new image
        return saving.NewRecipe.Images.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCVC", for: indexPath) as? AddImageCVC
            cell?.Shadow(color: .black, radius: 1, alpha: 0.4, size: CGSize(width: 1, height: 1))
            cell?.Label.text = self.imageLimit == false ? (UI.EF ? "Reached limit of five photos!":"به محدود پنج عکس رسیده است!"):(UI.EF ? "Add Image":"تصویر اضافه کن")
            return cell!
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCVC", for: indexPath) as? AddCVC

        let image = UIImage(data: saving.NewRecipe.Images[indexPath.row - 1])
        cell?.Image.image = image?.Resize(targetSize: CGSize(width: 70, height: 70))
        cell?.Shadow(color: .black, radius: 1, alpha: 0.4, size: CGSize(width: 1, height: 1))
        cell?.indexPath = indexPath.row - 1
        cell?.delegate=self
        
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.AnimteEventCell()
        
        if indexPath.row == 0 && self.imageLimit{
            self.showOptions()
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row > 0{
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -50, 0)
            cell.layer.transform = rotationTransform
            cell.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                cell.layer.transform = CATransform3DIdentity
                cell.alpha = 1.0
            }, completion: nil)
        }
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




class AddCVC: UICollectionViewCell,UIContextMenuInteractionDelegate {
    @IBOutlet weak var Image:UIImageView!{
        didSet{
            self.Image.layer.cornerRadius = 25
            self.Image.layer.masksToBounds = true
        }
    }
    
    var indexPath:Int?
    var delegate:AddVCOperation?
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = .clear
        self.contentView.layer.cornerRadius = 25
        
        ///menu context
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
    
    
    ///handle memory for loading images
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.Image.image = nil
    }
    
    ///menu context
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in
            
            let Delete = UIAction(title:  UI.EF ? "Delete":"حذف", image: UIImage(systemName: "trash.fill"), identifier:  UIAction.Identifier(rawValue: "Delete"), discoverabilityTitle: "", attributes: .destructive, state: .off) { (_) in
                self.delegate?.RemoveImage(index: self.indexPath ?? 0)
            }
            
            let Replace = UIAction(title: UI.EF ? "Replace":"جایگزین کردن", image: UIImage(systemName: "arrow.2.circlepath"), identifier: UIAction.Identifier(rawValue: "Replace")) {_ in
                self.delegate?.ReplaceImage(index: self.indexPath ?? 0)
            }

            return UIMenu(title: "", image: nil, identifier: nil, children: [Delete, Replace])
        }
        
        return configuration
    }
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?{
        let Preview = UITargetedPreview(view: self)
        Preview.view.layer.cornerRadius = 25
        Preview.view.backgroundColor = UI.MC.toColor()
        self.Image.layer.masksToBounds = false
        return Preview
    }
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?{
        let Preview = UITargetedPreview(view: self)
        Preview.view.layer.cornerRadius = 25
        Preview.view.backgroundColor = UI.MC.toColor()
        self.Image.layer.masksToBounds = true
        return Preview
    }
    
}




class AddImageCVC: UICollectionViewCell {
    @IBOutlet var Label: UILabel!{
        didSet{
            self.Label.SetTextColor(Color: UI.WB ? .lightGray : .darkGray)
        }
    }
    @IBOutlet weak var AddImage: UIImageView!{
        didSet{
            self.AddImage.tintColor = UI.WB ? .lightGray : .darkGray
        }
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UI.WB ? UIColor.MyTheme.Eight.lighter : UIColor.white
        self.contentView.layer.cornerRadius = 25
    }
    
}
