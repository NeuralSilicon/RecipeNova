
import UIKit

protocol SettingOperation {
    func ShowLoading()
    func ReloadPage()
}

class SettingsTV: UITableViewController,SettingOperation {
    func ShowLoading() {
        self.LoadingAnimation?.StartloadingAnimation(E: "", F: "")
        self.LoadingAnimation?.RemoveLoadingScreenWithDuration(duration: 0.2, delay: 2.5)
    }
    func ReloadPage(){
        self.navigationItem.title = UI.EF ? "Settings":"تنظیمات"
        self.tableView.reloadData()
    }
    @IBAction func CloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //English or Farsi
    let EOptions:[String]=["Language","CopyRight"]
    let FOptions:[String]=["زبان","کپی رایت"]
    //Create a var of Message Animation
    var LoadingAnimation:MessageAnimation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Init Loading Animation
        self.LoadingAnimation = MessageAnimation(rect: self.tableView.frame, navigheight: self.navigationController?.navigationBar.frame.height ?? 80)
        self.LoadingAnimation?.SetLoadingAnimtion()
        self.tableView.addSubview(self.LoadingAnimation?.loadingView ?? self.view)
        self.tableView.bringSubviewToFront(self.LoadingAnimation?.loadingView ?? self.view)
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .bold)]
        self.navigationItem.title = UI.EF ? "Settings":"تنظیمات"

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UI.AC.toColor().darker
        
        self.tableView.backgroundColor = UI.MC.toColor()
        self.tableView.separatorColor = UI.MC.toColor().withAlphaComponent(0.7)
        
        self.tableView.register(UINib(nibName: "LabelsNib", bundle: nil), forCellReuseIdentifier: "LabelsNib")
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsNib", for: indexPath) as? LabelsNib
        
        cell?.Label.text = UI.EF ? self.EOptions[indexPath.row] : self.FOptions[indexPath.row]
        cell?.SetUpArrow()
        cell?.backgroundColor = UI.AC.toColor()
        cell?.textField.isEnabled = false
        cell?.Label.textColor = .white
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? LabelsNib
        cell?.SelectCellAndDeselect()
        self.Options(indx:indexPath.row)
    }
    
    
    func Options(indx:Int){
        switch indx {
        case 0:
            self.performSegue(withIdentifier: "Language", sender: nil)
            break
        case 1: //copyright
            self.performSegue(withIdentifier: "CopyRight", sender: nil)
            break
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Language", let destination = segue.destination as? LanguageTV{
            destination.delegate=self
        }
    }
    
    
}

fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
