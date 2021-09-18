
import UIKit

protocol MenuVCOperation {
    func ApplyTheme()
}

class MenuCVC: UICollectionViewController,MenuVCOperation,UIPopoverPresentationControllerDelegate,UICollectionViewDelegateFlowLayout {
    
    @objc func ApplyTheme(){
        self.collectionView.backgroundColor = UI.WB ? UIColor.MyTheme.Nine : .white
        self.collectionView.reloadData()
    }
    
    //MARK: - Variables
    let PMenus:[String]=["تم","تنظیمات"]
    let EMenus:[String]=["Theme","Settings"]
    let MenuiMage:[String]=["circle.righthalf.fill","gear"]

    var delegate:HomeVCOperation?
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UI.WB ? UIColor.MyTheme.Nine : .white
        self.collectionView.clipsToBounds = true
        
        //Calling this to change the language
        NotificationCenter.default.addObserver(self, selector: #selector(ApplyTheme), name: NSNotification.Name("ReloadMenu"), object: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCVCell", for: indexPath) as? MenuCVCell
        
        cell?.label.text = UI.EF ? self.EMenus[indexPath.row] : self.PMenus[indexPath.row]
        cell?.iCon.image = UIImage(systemName: self.MenuiMage[indexPath.row ])
        cell?.iCon.image = cell?.iCon.image?.withRenderingMode(.alwaysTemplate)
        cell?.iCon.tintColor = .white
        cell?.SetUpLabel()
        cell?.view.backgroundColor = UI.AC.toColor()
        
        return cell!
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? MenuCVCell
        cell?.AnimteEventCell()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if indexPath.row == 0{
                ///go to theme page
                self.delegate?.PerformSegue(type: .Theme)
            }else{
                ///go to setting page
                self.delegate?.PerformSegue(type: .Setting)
            }
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height / 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

}

class MenuCVCell: UICollectionViewCell {
    
    @IBOutlet var label:UILabel!{
        didSet{
            self.label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        }
    }
    @IBOutlet weak var iCon:UIImageView!
    @IBOutlet var view: UIView!{
        didSet{
            self.view.layer.cornerRadius = 5
            self.view.Shadow(color: .black, radius: 10, alpha: 0.4, size: CGSize(width: 10, height: 10))
        }
    }
    
    
    func SetUpLabel(){
        self.backgroundColor = UI.WB ? UIColor.MyTheme.Nine : .white
        self.label.textColor = .white
    }
    
    func SelectAndDeselect(){
        DispatchQueue.main.async {
            //self.label.SetTextColor(Color: .white)
            self.backgroundColor = UI.AC.toColor()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
           // self.label.SetTextColor()
            self.backgroundColor = UI.WB ? UIColor.MyTheme.Nine : .white
        }

    }
}
