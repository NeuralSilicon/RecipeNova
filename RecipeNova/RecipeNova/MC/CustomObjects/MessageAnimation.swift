
import UIKit

public class MessageAnimation:NSObject{
    
    // View which contains the loading text and the spinner
    public let loadingView = UIView()
    // Spinner shown during load the TableView
    public let spinner = UIActivityIndicatorView()
    // Text shown during load the TableView
    private let loadingLabel = UILabel()
    
    private let frame:CGRect
    private let navigHeight:CGFloat


    init(rect:CGRect,navigheight:CGFloat) {
        self.frame = rect
        self.navigHeight = navigheight
    }
    
    // MARK: Private methods
    public func SetLoadingScreen() {
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 160
        let height: CGFloat = 150
        let x = (self.frame.width / 2) - (width / 2)
        let y = (self.frame.height / 2.5) - (height / 2) - (self.navigHeight)
        
        self.loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        self.loadingView.backgroundColor = UI.WB ? UIColor.black.withAlphaComponent(0.7) : UIColor.white.withAlphaComponent(0.9)
        self.loadingView.Shadow(color: .black, radius: 1.0, alpha: 0.3)
        self.loadingView.layer.cornerRadius = 10
        self.loadingView.alpha = 0.0
        
        // Sets loading text
        self.loadingLabel.SetTextColor()
        self.loadingLabel.textAlignment = .center
        self.loadingLabel.lineBreakMode = .byWordWrapping
        self.loadingLabel.numberOfLines = 0
        self.loadingLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        self.loadingLabel.textColor = UI.WB ? .white : .black
        self.loadingLabel.frame = CGRect(x:30 ,y: 40,width: 100,height: 100)
           
        // Sets spinner
        self.spinner.tintColor = UI.WB ? .white : .black
        self.spinner.color = UI.WB ? .white : .black
        self.spinner.backgroundColor = .clear
        self.spinner.frame = CGRect(x: (self.loadingView.frame.width / 2) - 15 ,y:20,width: 30,height: 30)
           
        // Adds text and spinner to the view
        self.loadingView.addSubview(self.loadingLabel)
        self.loadingView.addSubview(self.spinner)
           
    }
    
    // MARK: Private methods
    public func SetLoadingAnimtion() {
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 50
        let height: CGFloat = 50
        let x = (self.frame.width / 2) - (width / 2)
        let y = (self.frame.height / 2.5) - (height / 2) - (self.navigHeight)
        
        self.loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        self.loadingView.backgroundColor = UI.WB ? UIColor.black.withAlphaComponent(0.7) : UIColor.white.withAlphaComponent(0.9)
        self.loadingView.Shadow(color: .black, radius: 1.0, alpha: 0.3)
        self.loadingView.layer.cornerRadius = 10
        self.loadingView.alpha = 0.0
           
        // Sets spinner
        self.spinner.tintColor = UI.WB ? .white : .black
        self.spinner.color = UI.WB ? .white : .black
        self.spinner.backgroundColor = .clear
        self.spinner.frame = CGRect(x:10,y:10,width: 30,height: 30)
           
        // Adds text and spinner to the view
        self.loadingView.addSubview(self.spinner)
    }
    
    
    //Start Animation
    func StartloadingAnimation(E:String,F:String){
        self.loadingLabel.text = UI.EF ? E:F
        self.spinner.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1.0
        }
    }
    
    // Remove the activity indicator from the main view
    func RemoveLoadingScreen() {
        UIView.animate(withDuration: 0.3, delay: 1.2, options: .allowUserInteraction, animations: {
            self.loadingView.alpha = 0.0
        }) { (_) in
            self.spinner.stopAnimating()
        }
    }
    
    // Remove the activity indicator from the main view
    func RemoveLoadingScreenWithDuration(duration:Double,delay:Double) {
        UIView.animate(withDuration: duration, delay: delay, options: .allowUserInteraction, animations: {
            self.loadingView.alpha = 0.0
        }) { (_) in
            self.spinner.stopAnimating()
        }
    }
    
    // Remove the activity indicator from the main view
    func RemoveWithNoDelayLoadingScreen() {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .allowUserInteraction, animations: {
            self.loadingView.alpha = 0.0
        }) { (_) in
            self.spinner.stopAnimating()
        }
    }
    
}
