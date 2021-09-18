
import UIKit


extension UIColor {
    struct MyTheme {
        static var Zero: UIColor { return UIColor(named: "0")!}
        static var One: UIColor { return UIColor(named: "1")!}
        static var Two: UIColor { return UIColor(named: "2")!}
        static var Three: UIColor { return UIColor(named: "3")!}
        static var Four: UIColor { return UIColor(named: "4")!}
        static var Five: UIColor { return UIColor(named: "5")!}
        static var Six: UIColor { return UIColor(named: "6")!}
        static var Seven: UIColor { return UIColor(named: "7")!}
        static var Eight: UIColor { return UIColor(named: "8")!}
        static var Nine: UIColor { return UIColor(named: "9")!}
        static var ZeroZero: UIColor { return UIColor(named: "00")!}
        static var ZeroOne: UIColor { return UIColor(named: "01")!}
        static var ZeroTwo: UIColor { return UIColor(named: "02")!}
        static var ZeroThree: UIColor { return UIColor(named: "03")!}
        static var ZeroFour: UIColor { return UIColor(named: "04")!}
        static var ZeroFive: UIColor { return UIColor(named: "05")!}
        
        static var DimSeven: UIColor { return  (UIColor(named: "7")?.withAlphaComponent(0.4))!}
        static var DimEight: UIColor { return  (UIColor(named: "8")?.withAlphaComponent(0.4))!}
        static var TableViewSeperator: UIColor {return UI.WB ? UIColor.lightGray.withAlphaComponent(0.5) : UIColor.darkGray.withAlphaComponent(0.5)}
        
        static var Red: UIColor { return  UIColor(named: "Red")!}
        static var Blue: UIColor {return UIColor(named: "Blue")!}
    }
}


extension UICollectionViewCell{
    func AnimteEventCell(){
        self.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
    }
}

//MARK: - TableView extensions
extension UITableViewCell{
    func SelectedBackGroundColor(){
        self.backgroundColor = UI.AC.toColor()
    }
    func BackGroundColor(){
        self.backgroundColor = UI.MC.toColor()
    }
}

extension UITableView{
    func SetTableViewBackGround(){
        self.backgroundColor = UI.WB ? UIColor.MyTheme.Eight : UIColor.MyTheme.Seven
        self.separatorColor  = UIColor.MyTheme.TableViewSeperator
    }
}

extension UIView{
    func Shadow(color:UIColor, radius: CGFloat, alpha: Float){
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = alpha
        self.layer.shadowRadius = radius
    }
    
    func Shadow(color:UIColor, radius: CGFloat, alpha: Float, size:CGSize){
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = alpha
        self.layer.shadowRadius = radius
    }
    
    func bottomShadow(_ color : UIColor){
        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint(x: self.bounds.origin.x, y: self.frame.size.height))
        shadowPath.addLine(to: CGPoint(x: self.bounds.width / 2, y: self.bounds.height + 7.0))
        shadowPath.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        shadowPath.close()
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowRadius = 5
    }
}

extension UILabel{
    
    func SetTextColor(){
        self.setWB(W: .black, B: .white)
    }
    
    func textAlignment(){
        self.textAlignment = UI.EF ? .left : .right
    }

    func setWB(W:UIColor,B:UIColor){
        self.textColor = UI.WB ? B : W
    }
    func SetTextColor(Color:UIColor){
        self.textColor = Color
    }
    
    func SetTextEF(E:String,F:String){ //Set English or Farsi Text
        self.text = UI.EF ? E : F
    }
    
}

extension UIBarButtonItem{
    func setImage(name:String,Size:CGSize){
        self.image = UIImage(named: name)?.Resize(targetSize: Size)
    }
}

extension String{
    func toColor()->UIColor{
        return UIColor(named: self) ?? .white
    }
    func toInt()->Int{
        return Int(self) ?? 0
    }
}

extension Int{
    func toString()->String{
        return String(describing: self)
    }
}


extension UIImage {
    func Resize(targetSize: CGSize) -> UIImage {
         return UIGraphicsImageRenderer(size:targetSize).image { _ in
             self.draw(in: CGRect(origin: .zero, size: targetSize))
         }
     }
}

//MARK: - Array Chunck Extension
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension UIColor {

    var darker: UIColor {

    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

        guard self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            print("** some problem demuxing the color")
            return .gray
        }

        let nudged = b * 0.6

        return UIColor(hue: h, saturation: s, brightness: nudged, alpha: a)
    }
    
    var lighter: UIColor {

    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

        guard self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            print("** some problem demuxing the color")
            return .gray
        }

        let nudged = b * 1.6

        return UIColor(hue: h, saturation: s, brightness: nudged, alpha: a)
    }
}
