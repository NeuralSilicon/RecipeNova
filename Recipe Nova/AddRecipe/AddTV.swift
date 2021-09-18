
import UIKit

extension AddVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2{
            return 50
        }
        return 5
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddSection") as? AddSection
           
        cell?.Label.text = UI.EF ? self.Etitles[section]:self.Ptitles[section]
        cell?.backgroundColor = UI.MC.toColor()
        cell?.accessoryView = .none
        cell?.Label.setWB(W: .black, B: .white)
        cell?.initPage()
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNib", for: indexPath) as? LabelNib
        
        if indexPath.section == 0{
            cell?.Label.text = saving.NewRecipe.Name
        }else if indexPath.section == 1{
            cell?.Label.text = saving.NewRecipe.Ingredients
        }else{
            cell?.Label.text = saving.NewRecipe.Direction
        }
        
        cell?.background.backgroundColor = UI.MC.toColor()
        cell?.backgroundColor = .clear
        cell?.Label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        var image = UIImage(systemName: "arrow.right.circle.fill")
        image = image?.withRenderingMode(.alwaysTemplate)
        let checkmark  = UIImageView(frame:CGRect(x:0, y:0, width:25, height:25))
        checkmark.image = image
        checkmark.tintColor = .white
        cell?.accessoryView = checkmark
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? LabelNib
        cell?.SelectCellAndDeselect()
        
        if indexPath.section == 0{
            self.performSegue(withIdentifier: "Name", sender: nil)
        }
        else if indexPath.section == 1{
            self.performSegue(withIdentifier: "Ingredients", sender: nil)
        }else{
            self.performSegue(withIdentifier: "Directions", sender: nil)
        }
    }
    
    
    
}


class AddSection: UITableViewCell {
    @IBOutlet var Label: UILabel!{
        didSet{
            self.Label.lineBreakMode = .byWordWrapping
            self.Label.numberOfLines = 0
            self.Label.textAlignment = .left
            self.Label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        }
    }

    func initPage(){
        let draw = DrawLine(frame: self.bounds)
        draw.labelSize = self.Label.frame
        draw.color = UI.AC.toColor().cgColor
        draw.backgroundColor = .clear
        self.addSubview(draw)
    }
}
