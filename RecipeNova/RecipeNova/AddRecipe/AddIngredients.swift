
import UIKit

class AddIngredients: UIViewController,UITextViewDelegate {
    
    @IBOutlet var TextView:UITextView!
    @IBOutlet var closeB: UIBarButtonItem!
    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var doneB: UIBarButtonItem!
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        ///adding the ingredient to our recipe and reload previous page
        saving.NewRecipe.Ingredients = self.TextView.text
        self.delegate?.ReloadTable()
        self.dismiss(animated: true, completion: nil)
    }
    
    var delegate:AddVCOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = UI.EF ? "Ingredients" : "اجزاء"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .bold)]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UI.AC.toColor()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UI.AC.toColor().darker
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        
        self.view.backgroundColor = UI.AC.toColor()
        
        self.TextView.delegate=self
        self.TextView.keyboardAppearance = UI.WB ? .dark : .light
        self.TextView.backgroundColor = UI.MC.toColor()
        self.TextView.textColor = UI.WB ? .white : .black
        self.TextView.tintColor = UI.AC.toColor()
        
        ///if its not updating the recipe, then add dot in the begining of our textview
        if saving.NewRecipe.Ingredients == ""{
            self.TextView.text = " \u{2022} "
        }else{
            self.TextView.text = saving.NewRecipe.Ingredients
        }
        self.TextView.becomeFirstResponder()
    }
    
    
    // MARK: - Add BulletPoint As User Types Inside The TextView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {///check for new line in text last character
            if range.location == textView.text.count { ///if text is going forward then add dot
                ///append a new line and a dot
                let updatedText: String = textView.text!.appending("\n \u{2022} ")
                textView.text = updatedText
            }
            else { /// if text is going backward then check for text positioning and add dots
                let beginning: UITextPosition = textView.beginningOfDocument
                let start: UITextPosition = textView.position(from: beginning, offset: range.location)!
                let end: UITextPosition = textView.position(from: start, offset: range.length)!
                let textRange: UITextRange = textView.textRange(from: start, to:  end)!
                textView.replace(textRange, withText: "\n \u{2022} ")
                let cursor: NSRange =  NSMakeRange(range.location + "\n \u{2022} ".count, 0)
                textView.selectedRange = cursor
            }
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == ""{ ///if textview is back to empty string then append dot in the beginning
            let updatedText: String = textView.text!.appending(" \u{2022} ")
            textView.text = updatedText
        }
    }
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool{
        textView.resignFirstResponder()
        return false
    }
    
    
}
