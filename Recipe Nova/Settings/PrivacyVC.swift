
import UIKit

class PrivacyVC: UIViewController,UIGestureRecognizerDelegate {
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
        self.navigationItem.title = UI.EF ? "Privacy" : "حریم خصوصی"
        
        self.SetUpTextView()
    }

    
    //TextView
    func SetUpTextView(){
        
        let str = "\n ⚠️ We may collect anonymous statistical information such as locations and devices model that are being used to help us improve the app. However, your inputs are stored securely inside the phone and are not accessible to anyone.\n\n ⚠️ Recipe Nova is a free app that uses advertments provided by Google Admob which collects anonymous statistical information same as mentioned above and by using this application made by Ian Cooper, you are agreeing to this information. To find out more about Google advertising, "

        let attributedString = self.ReturnBoldNormalText(BoldText: "Privacy Policy and Terms of Use", NormalText: str)
        
        self.TextView.attributedText = attributedString
        self.TextView.textColor = UI.WB ? .white : .black
        self.TextView.isUserInteractionEnabled = true
        self.TextView.isEditable = false
        self.TextView.backgroundColor = .clear
        self.TextView.layoutIfNeeded()
        self.TextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func ReturnBoldNormalText(BoldText:String,NormalText:String)->NSMutableAttributedString{
        let url = URL(string: "https://policies.google.com/technologies/ads")!
        
        let boldText  = BoldText + "\n"
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

        let normalText = NormalText
        let attr = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
        let normalString = NSMutableAttributedString(string:normalText, attributes:attr)

        attributedString.append(normalString)
        
        let linkText = NSMutableAttributedString(string: "Privacy Policy and Terms of Use.", attributes: [NSAttributedString.Key.link: url,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)])
        
        attributedString.append(linkText)
        
        return attributedString
    }
}
