

import UIKit

/*
 Used in recipe cell for name, direction, and ingredients
 */
class LabelNib: UITableViewCell {
    @IBOutlet var Label: UILabel!{
        didSet{
            self.Label.setWB(W: .black, B: .white)
        }
    }
    @IBOutlet var background: UIView!{
        didSet{
            self.background.layer.cornerRadius = 5
        }
    }
    
    
    func SelectCellAndDeselect(){
        DispatchQueue.main.async {
            self.background.backgroundColor = UI.AC.toColor()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.background.backgroundColor = UI.MC.toColor()
        }
    }
    
}
