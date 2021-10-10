
import UIKit

class LabelsNib: UITableViewCell,UITextFieldDelegate{
    @IBOutlet var Label: UILabel!
    @IBOutlet var textField: UITextField!
    
    var homeDelegate:HomeVCOperation? ///Home page
    var cartDelegate:CartVCOperation? ///Cart page
    var pageIndicator:Int=1 ///Using it to determinate which page is calling textfield
    var category = Categories()
    var cart = ShoppingCart()
    
    func initTextField(){
        self.Label.SetTextColor(Color: .white)
        self.textField.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        self.textField.text = ""
        self.textField.delegate = self
        self.textField.textColor = .white
        self.textField.tintColor = .white
        self.textField.keyboardAppearance = UI.WB ? .dark : .light
        self.textField.textAlignment = UI.EF ? .left : .right
        self.textField.tintColor = .white
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.textField.text?.isEmpty == false{
            switch pageIndicator {
            case 1:///Home Page
                ///find the index in our categories and then update it
                if let indx = UI.CT.firstIndex(where: { (arg0) -> Bool in
                    arg0.ID == self.category.ID
                }){
                    self.category.Name = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    UI.CT[indx]=self.category
                    
                    self.textField.isHidden = true
                    self.textField.resignFirstResponder()
                    
                    self.Label.text = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    self.Label.isHidden = false
                    
                    self.homeDelegate?.ReloadCategories(new: false)
                }
            case 2: ///Cart Page
                self.cart.Name = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
  
                ///save to coredata
                SaveLoadListHandler(list:self.cart).EncodeToSave(Update: true)
                
                ///disable the textfield
                self.textField.isHidden = true
                self.textField.resignFirstResponder()
                ///enable back the label
                self.Label.text = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                self.Label.isHidden = false
                ///call cart to reload the page
                self.cartDelegate?.ReloadTable(list: CartStruct(Update: true, list: cart))
            default:
                break
            }
        }
        return true
    }
    
    
    func SetUpSectionLabel(){
        self.Label.lineBreakMode = .byWordWrapping
        self.Label.numberOfLines = 0
        self.Label.setWB(W: .black, B: .white)
        self.Label.textAlignment = .left
        self.Label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    }
    
    func SetUpArrow(){
        var image = UIImage(systemName: "arrow.right.circle.fill")
        image = image?.withRenderingMode(.alwaysTemplate)
        let checkmark  = UIImageView(frame:CGRect(x:0, y:0, width:25, height:25))
        checkmark.image = image
        checkmark.tintColor = .white
        self.accessoryView = checkmark
    }
    
    
     func SelectCellAndDeselect(){
         DispatchQueue.main.async {
            self.backgroundColor = UI.WB ? .black : .white
            self.Label.setWB(W:.black, B: .white)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.backgroundColor = UI.AC.toColor()
            self.Label.SetTextColor(Color: .white)
        }
    }
    
}
