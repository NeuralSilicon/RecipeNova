
import UIKit

class LanguageTV: UITableViewController,UIGestureRecognizerDelegate {
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    let PLabels=["انگلیسی (ایالات متحده)","فارسی (ایران)"]
    let ELabels=["English (United States)","Farsi (Iran)"]
    //Create a var of Message Animation
    var LoadingAnimation:MessageAnimation?
    
    var delegate:SettingOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationItem.title = UI.EF ? "Language":"زبان"

        self.tableView.backgroundColor = UI.MC.toColor()

        self.tableView.register(UINib(nibName: "LabelsNib", bundle: nil), forCellReuseIdentifier: "LabelsNib")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Init Loading Animation
        self.LoadingAnimation = MessageAnimation(rect: self.tableView.frame, navigheight: self.navigationController?.navigationBar.frame.height ?? 80)
        self.LoadingAnimation?.SetLoadingAnimtion()
        self.tableView.addSubview(self.LoadingAnimation?.loadingView ?? self.view)
        self.tableView.bringSubviewToFront(self.LoadingAnimation?.loadingView ?? self.view)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsNib") as? LabelsNib
        
        cell?.Label.text = UI.EF ? "Changing language will not effect widget.":"تغییر زبان همچنین باعث تأثیر ویجت نخواهد شد."
        cell?.SetUpSectionLabel()
        cell?.backgroundColor = .clear
        
        return cell?.contentView
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsNib", for: indexPath) as? LabelsNib

        cell?.Label.text = UI.EF ? self.ELabels[indexPath.row] : self.PLabels[indexPath.row]
        cell?.tintColor = UI.WB ? .black : .white
        
        if indexPath.row == 0 {
            if UI.EF{
                cell?.accessoryType = .checkmark
            }else{
               cell?.accessoryType = .none
            }
            
        }else if indexPath.row == 1 {
            if !UI.EF{
                cell?.accessoryType = .checkmark
            }else{
                cell?.accessoryType = .none
            }
        }
        
        cell?.textField.isEnabled = false
        cell?.backgroundColor = UI.AC.toColor()
        cell?.Label.textColor = .white
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UI.EF = indexPath.row == 0 ? true : false
        
        self.LoadingAnimation?.StartloadingAnimation(E: "", F: "")
        self.LoadingAnimation?.RemoveWithNoDelayLoadingScreen()
    
        self.delegate?.ReloadPage()
        
        self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: UI.EF ? .right : .left)
        self.navigationItem.title = UI.EF ? "Language":"زبان"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadMenu"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeLanguage"), object: nil)
    }

}
