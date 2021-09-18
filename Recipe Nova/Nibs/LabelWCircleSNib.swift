
import UIKit

class LabelWCircleSNib: UITableViewCell {
    @IBOutlet var Label: UILabel!{
        didSet{
            self.Label.SetTextColor(Color: .white)
        }
    }
    @IBOutlet var Circle: UIImageView!{
        didSet{
            self.Circle.tintColor = .white
        }
    }
    
    
    func SelectedCell(){
        DispatchQueue.main.async{
            self.Circle.image = UIImage(systemName: "circle.fill")
        }
    }
    func DeSelectedCell(){
        DispatchQueue.main.async{
            self.Circle.image = UIImage(systemName: "circle")
        }
    }
    
}
