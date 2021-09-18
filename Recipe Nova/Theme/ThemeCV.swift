
import UIKit

class ThemeCV: UICollectionViewController,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate {
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Show selected color
    var Index:Int = -1
    //Show selected MC color
    var SelectedMC:Int = UI.MC.replacingOccurrences(of: "00", with: "").toInt()
    
    var delegate:HomeVCOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.collectionView.backgroundColor = UI.MC.toColor()
    }


    
    //MARK: - CollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCVC", for: indexPath) as? ThemeCVC
        
        if indexPath.row < 9{
            cell?.backgroundColor = UIColor(named: "00"+(indexPath.row + 1).toString())
        }else{
            cell?.backgroundColor = UIColor(named: "0"+(indexPath.row + 1).toString())
        }
        cell?.indx = indexPath.row
        cell?.SetUpCell()
        
        if indexPath.row < 3{
            cell?.CheckMark.isHidden = false
            if indexPath.row == self.SelectedMC - 1{
                cell?.isSelected = true
            }else{
                cell?.isSelected = false
            }
            
        }else{
            cell?.CheckMark.isHidden = true
            
            if indexPath.row == self.Index{
                cell?.isSelected = true
            }else{
                cell?.isSelected = false
            }
        }

        return cell!
    }
        
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.Index = indexPath.row
        self.ApplyThemes(indexPath: indexPath.row)
        self.collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = self.collectionView.frame.height
        
        //Handling iPhone x and after
        if size > 675{
            size = size/10
        }else{
            size = size/9
        }
        
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
        
    
    
    func ApplyThemes(indexPath:Int){
        
        if indexPath == 0 || indexPath == 1 || indexPath == 2{
            UI.WB = indexPath == 0 ? false : true
            UI.MC = "00"+(indexPath + 1).toString()
            
            UI.AC = "Blue"
            
            //Set SelectedMC to Our color
            self.SelectedMC = UI.MC.replacingOccurrences(of: "00", with: "").toInt()
        }
        else{
            if indexPath < 9{
                UI.AC = "00"+(indexPath + 1).toString()
            }else{
                UI.AC = "0"+(indexPath + 1).toString()
            }
        }
        
        //Animate changing background
        UIView.animate(withDuration: 0.6, delay: 0, options: .allowUserInteraction, animations: {
            self.collectionView.backgroundColor = UI.MC.toColor()
        }, completion: nil)

        self.delegate?.ApplyTheme()
    }
    

    
    
}



