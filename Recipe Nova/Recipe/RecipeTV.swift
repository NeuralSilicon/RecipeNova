

import UIKit

extension RecipeVC:UITableViewDelegate,UITableViewDataSource{
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeSection") as? RecipeSection
           
        cell?.Label.text = UI.EF ? self.Etitles[section]:self.Ptitles[section]
        cell?.Label.SetTextColor(Color: .white)
        cell?.backgroundColor = .clear
        cell?.accessoryView = .none
        cell?.initPage()
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.NumOfSection
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return self.recipe.Ingredients.components(separatedBy: "\n").count
        }else if section == 2{
            return self.recipe.Direction.components(separatedBy: "\n").count
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelNib", for: indexPath) as? LabelNib
        
        if indexPath.section == 0{
            cell?.Label.text = self.recipe.Name
        }else if indexPath.section == 1{
            cell?.Label.text = self.recipe.Ingredients.components(separatedBy: "\n")[indexPath.row]
        }else{
            cell?.Label.text = self.recipe.Direction.components(separatedBy: "\n")[indexPath.row]
        }
        
        cell?.background.Shadow(color: .black, radius: 10, alpha: 0.4, size: CGSize(width: 10, height: 10))
        cell?.background.backgroundColor = UI.MC.toColor()
        cell?.backgroundColor = .clear
        
        return cell!
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -100, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }, completion: nil)
    }
    
    
    
}


class RecipeSection: UITableViewCell {
    @IBOutlet var Label: UILabel!{
        didSet{
            self.Label.lineBreakMode = .byWordWrapping
            self.Label.numberOfLines = 1
            self.Label.textAlignment = .left
            self.Label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        }
    }
    
    func initPage(){
        let draw = DrawLine(frame: self.bounds)
        draw.labelSize = self.Label.frame
        draw.color = UI.MC.toColor().cgColor
        draw.backgroundColor = .clear
        self.addSubview(draw)
    }

}



