
import UIKit

class OptionsNib: UITableViewCell {
    
    @IBOutlet var Label: UILabel!
    @IBOutlet var icon: UIImageView!
    
    
    func initCell(){
        self.Label.setWB(W: .black, B: .white)
        self.icon.tintColor = UI.AC.toColor()
    }
    
    func selectAndDeselect(){
        self.Label.SetTextColor(Color: .white)
        self.backgroundColor = UI.AC.toColor()
        self.icon.tintColor = .white
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.Label.setWB(W: .black, B: .white)
            self.icon.tintColor = UI.AC.toColor()
            self.backgroundColor = .clear
        }
    }
}
