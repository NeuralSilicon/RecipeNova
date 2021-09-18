

import UIKit

class UITextFieldWithBorders: UITextField {
    
    var borderWidth: CGFloat = 0 {
        didSet {
            updateTextField()
        }
    }
    
    var borderColor: UIColor = UIColor.clear {
        didSet {
            updateTextField()
        }
    }
    
    var bottomBorder: Bool = false {
        didSet {
            updateTextField()
        }
    }
    

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        updateTextField()
    }
    
    

    func updateTextField() {
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(borderColor.cgColor)
            context.setLineWidth(borderWidth)
            
            // Bottom Line
            if bottomBorder {
                borderStyle = .none
                
                context.move(to: CGPoint(x: 0, y: bounds.height - borderWidth))
                context.addLine(to: CGPoint(x: bounds.width , y: bounds.height - borderWidth))
                context.strokePath()
            }
        }
    }
}


extension UITextField {
  var placeholderColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }
}
