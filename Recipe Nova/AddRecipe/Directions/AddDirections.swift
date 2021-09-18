
import UIKit

class AddDirections: UIViewController,UITextViewDelegate {
    
    @IBOutlet var TextView:UITextView!
    @IBOutlet var closeB: UIBarButtonItem!
    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var doneB: UIBarButtonItem!
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        saving.NewRecipe.Direction = self.TextView.text
        self.delegate?.ReloadTable()
        self.dismiss(animated: true, completion: nil)
    }
    
    var delegate:AddVCOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = UI.EF ? "Directions" : "جهت ها"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .bold)]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UI.AC.toColor()

        
        self.view.backgroundColor = UI.AC.toColor()
        
        self.TextView.delegate=self
        self.TextView.keyboardAppearance = UI.WB ? .dark : .light
        self.TextView.backgroundColor = UI.MC.toColor()
        self.TextView.textColor = UI.WB ? .white : .black
        self.TextView.tintColor = UI.AC.toColor()
        
        if saving.NewRecipe.Direction == ""{
            self.TextView.text = " 1. "
        }else{
            self.TextView.text = saving.NewRecipe.Direction
        }
        self.TextView.becomeFirstResponder()
    }
    
    // MARK: - Add BulletPoint As User Types Inside The TextView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            if range.location == textView.text.count {
                ///counting the new lines and add them in the beginning as user press return or done
                let count = self.TextView.text.components(separatedBy: "\n")
                let updatedText: String = textView.text!.appending("\n \(count.count + 1). ")
                textView.text = updatedText
            }
            else {
                let count = self.TextView.text.components(separatedBy: "\n")
                let beginning: UITextPosition = textView.beginningOfDocument
                let start: UITextPosition = textView.position(from: beginning, offset: range.location)!
                let end: UITextPosition = textView.position(from: start, offset: range.length)!
                let textRange: UITextRange = textView.textRange(from: start, to:  end)!
                textView.replace(textRange, withText: "\n \(count.count + 1). ")
                let cursor: NSRange =  NSMakeRange(range.location + "\n \(count.count + 1). ".count, 0)
                textView.selectedRange = cursor
            }
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == ""{
            let count = self.TextView.text.components(separatedBy: "\n")
            let updatedText: String = textView.text!.appending(" \(count.count). ")
            textView.text = updatedText
        }
    }
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool{
        textView.resignFirstResponder()
        return false
    }
    
    
}
