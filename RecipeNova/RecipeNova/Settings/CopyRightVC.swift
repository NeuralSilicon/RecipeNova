
import UIKit

class CopyRightVC: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet var TextView: UITextView!
    @IBOutlet var backB: UIBarButtonItem!
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.view.backgroundColor = UI.MC.toColor()
        self.navigationItem.title = UI.EF ? "CopyRight": "کپی رایت"

        self.SetUpTextView()
    }

    
    //TextView
    func SetUpTextView(){
        
        let str = "\nAll recipes included in application are from FoodNetwork. We do not claim ownership of any kind, the sole purpose of including these recipes is for school project and not of any commercial types. If by any chance you or others like these recipes, please consider going to FoodNetwork.com.\n\n"

        let attributedString = self.ReturnBoldNormalText(BoldText: "CopyRight", NormalText: str)
        
        self.TextView.attributedText = attributedString
        self.TextView.textColor = UI.WB ? .white : .black
        self.TextView.isUserInteractionEnabled = true
        self.TextView.isEditable = false
        self.TextView.backgroundColor = .clear
        self.TextView.layoutIfNeeded()
        self.TextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func ReturnBoldNormalText(BoldText:String,NormalText:String)->NSMutableAttributedString{
        let url = URL(string: "https://www.foodnetwork.com/")!
        
        let boldText  = BoldText + "\n"
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

        let normalText = NormalText
        let attr = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
        let normalString = NSMutableAttributedString(string:normalText, attributes:attr)

        attributedString.append(normalString)
        
        let linkText = NSMutableAttributedString(string: "You can find more at FoodNetwork.com", attributes: [NSAttributedString.Key.link: url,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)])
        
        attributedString.append(linkText)
        
        return attributedString
    }
}
