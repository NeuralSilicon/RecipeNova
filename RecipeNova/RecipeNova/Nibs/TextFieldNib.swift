

import UIKit


class TextFieldNib: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var add: UIImageView!
    
    func initTextField(){
        self.textField.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        self.textField.text = ""
        self.textField.delegate = self
        self.textField.placeholderColor = UI.WB ? UIColor.MyTheme.Seven : UIColor.MyTheme.Eight
        self.textField.textColor = UI.WB ? .white : .black
        self.textField.tintColor = UI.AC.toColor()
        self.textField.keyboardAppearance = UI.WB ? .dark : .light
        self.textField.textAlignment = UI.EF ? .left : .right
        self.add.tintColor = UI.WB ? UIColor.MyTheme.Seven : UIColor.MyTheme.Eight
    }
    
    var delegate:ListTVOperation? ///List
    var HomeDelegate:HomeVCOperation? ///Home
    var cartDelegate:CartVCOperation? ///Cart
    ///page indicator:  1 home, 2  cart, 3 list
    var pageIndicator:Int = 1
    var category = CategoryStruct()
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.textField.text?.isEmpty == false{
            switch pageIndicator {
            case 1:
                ///Home
                ///if we dont have the name in our category let the user save it
                if !UI.CT.contains(where: { (Arg0) -> Bool in
                    Arg0.Name == self.textField.text ?? ""
                }){
                    ///Add the category
                    self.category.category.Name = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    UI.CT.append(self.category.category)
                    self.HomeDelegate?.ReloadCategories(new: true)
                    self.textField.resignFirstResponder()
                }
            case 2:
                ///Cart
                let cart = ShoppingCart(Name: self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", List: "", Selected: [], ID: UUID.init())
                ///saving list to coredata
                SaveLoadListHandler(list:cart).EncodeToSave(Update: false)
                ///reload cart vc
                self.cartDelegate?.ReloadTable(list: CartStruct(Update: false, list: cart))
                ///resign the textfield keyboard
                self.textField.resignFirstResponder()
            case 3:
                ///List
                var NewText:String = self.textField.text ?? "NA"
                ///insert a new line and . at the begining of the our new text
                NewText.insert(contentsOf: "\n \u{2022} ", at: NewText.startIndex)
                ///insert the new text in list page
                self.delegate?.ReloadTable(list: NewText)
            default:
                break
            }
            self.textField.text = ""
        }else{
            ///if user didnt input any text, then we dismiss the keyboard and textfield
            switch pageIndicator {
            case 1:
                self.HomeDelegate?.ReloadCategories(new: false)
                self.textField.resignFirstResponder()
            case 2:
                self.cartDelegate?.ReloadTable()
                self.textField.resignFirstResponder()
            case 3:
                self.delegate?.ReloadSection()
            default:
                break
            }
            
        }
        return true
    }
}
