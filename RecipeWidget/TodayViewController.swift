
import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {
        
    var id:String=""
    var list:String=""
    //get the max size we can have for our extension
    var maxSizeForCompactMode: CGFloat {
        return extensionContext?.widgetMaximumSize(for: .compact).height ?? 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate=self
        self.tableView.dataSource=self
        self.tableView.frame = self.view.frame
        
        self.SyncWApp()
        self.tableView.reloadData()
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
    }
    
    //In case darkmode or lightmode changed
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.SetDynamicHight()
        } else {
            preferredContentSize = maxSize
        }
    }
    
    func SyncWApp(){
        if let userDefaults = UserDefaults(suiteName:"group.iNfamousPersian.Recipe") {
            guard let ingredients = userDefaults.string(forKey: "List"),let id = userDefaults.string(forKey: "ID") else{
                return
            }
            self.list = ingredients
            self.id = id
            SetDynamicHight()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.list == ""{
            return UIView()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Section") as? Section
        cell?.Label.layer.borderColor = traitCollection.userInterfaceStyle == .light ? UIColor.black.cgColor : UIColor.white.cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.ClearList))
        cell?.addGestureRecognizer(tap)
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.list == ""{
            return 0.01
        }
        return 30
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TVCell", for: indexPath) as? TVCell
        
        if self.list == ""{
            cell?.Label.text = "No list was added to widget."
            cell?.Label.textAlignment = .center
        }else{
            cell?.Label.text = self.list.replacingOccurrences(of: "\n", with: "")
            cell?.Label.textAlignment = .left
        }
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: "OpenList://")
        {
            if let userDefaults = UserDefaults(suiteName: "group.iNfamousPersian.Recipe"){
                userDefaults.set(true, forKey: "OpenList")
                userDefaults.synchronize()
            }
            
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    
    @objc private func ClearList(){
        self.list = ""
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        if let userDefaults = UserDefaults(suiteName: "group.iNfamousPersian.Recipe"){
            userDefaults.set(nil, forKey: "List")
            userDefaults.set(nil, forKey: "ID")
            userDefaults.synchronize()
        }
    }
    
    
    func SetDynamicHight(){
        if self.extensionContext?.widgetActiveDisplayMode == NCWidgetDisplayMode.expanded{
            if self.list == ""{
                self.preferredContentSize = CGSize(width: 0, height: maxSizeForCompactMode)
            }else{
                let Height = self.HeightForView(text: self.list, font: UIFont.systemFont(ofSize: 5, weight: .medium), width: self.view.frame.width) + maxSizeForCompactMode
                self.preferredContentSize = CGSize(width: 0, height:Height)
            }
        }
    }
    
     func HeightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    
}


class TVCell: UITableViewCell {
    @IBOutlet var Label: UILabel!
}

class Section: UITableViewCell {
    @IBOutlet var Label: UILabel!{
        didSet{
            self.Label.layer.cornerRadius=15
            self.Label.layer.borderWidth=1
        }
    }
}

