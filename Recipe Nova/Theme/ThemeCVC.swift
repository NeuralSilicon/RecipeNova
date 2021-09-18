
import UIKit

class ThemeCVC: UICollectionViewCell {
    @IBOutlet var view:UIView!
    @IBOutlet var CheckMark: UIImageView!
    
    var indx:Int = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
    }
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected{
                if indx < 3{
                    self.view.layer.borderColor = UI.AC.toColor().cgColor
                    self.CheckMark.tintColor = UI.WB ? UIColor.MyTheme.Seven : UIColor.MyTheme.Nine
                }else{
                    self.view.layer.borderColor = UI.WB ? UIColor.black.cgColor:UIColor.white.cgColor
                }
            }else{
                if indx > 2{
                    self.view.layer.borderColor = UIColor.clear.cgColor
                }else{
                    self.view.layer.borderColor = UIColor.clear.cgColor
                    self.CheckMark.tintColor = UIColor.clear
                }
            }
        }
    }

    
    func SetUpCell(){
        self.bottomShadow(.black)
        
        //Set corner radius
        self.layer.cornerRadius = floor(self.frame.width / 2)
        //Create Border for Main Colors to separate them: White,Nine,Black
        self.view.layer.cornerRadius = (self.frame.width - 10)/2
        self.view.backgroundColor = .clear
        self.view.layer.borderWidth = 3
        self.view.layer.borderColor = UIColor.clear.cgColor
        
        //SetUp our checkmark image
        self.CheckMark.image = UIImage(systemName: "checkmark")
        self.CheckMark.image = self.CheckMark.image?.withRenderingMode(.alwaysTemplate)
        self.CheckMark.tintColor = UIColor.clear

    }
    
    
}
