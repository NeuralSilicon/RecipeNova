
import UIKit

class OptionsNib: UITableViewCell {
    
    @IBOutlet var Label: UILabel!
    @IBOutlet var icon: UIImageView!
    
    
    func initCell(){
        self.Label.setWB(W: .black, B: .white)
        self.icon.tintColor = UI.AC.toColor()//UI.WB ? UIColor.MyTheme.Seven : UIColor.MyTheme.Eight
    }
    
    func selectAndDeselect(){
       // self.Label.setWB(W: .white, B: .black)
        self.Label.SetTextColor(Color: .white)
        self.backgroundColor = UI.AC.toColor()//UI.WB ? .white : UIColor.MyTheme.Eight
        self.icon.tintColor = .white//UI.WB ? UIColor.MyTheme.Eight : UIColor.MyTheme.Seven
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.Label.setWB(W: .black, B: .white)
            self.icon.tintColor = UI.AC.toColor()//UI.WB ? UIColor.MyTheme.Seven : UIColor.MyTheme.Eight
            self.backgroundColor = .clear
        }
    }
}
