
import UIKit

extension ListTV{
    
    //MARK: - Options
    @objc func showOptions(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "OptionsVC") as! OptionsVC
        viewController.delegateList = self
        
        viewController.modalPresentationStyle = .overFullScreen
        viewController.view.backgroundColor = .clear
            
        viewController.choosen(2)
            
        self.present(viewController, animated: true, completion: nil)
    }
    
    func ListControl(){
        self.LoadingAnimation?.StartloadingAnimation(E: "", F: "")
        self.LoadingAnimation?.RemoveWithNoDelayLoadingScreen()
        self.SyncWWidget(AddingList:true)
    }
    
}
