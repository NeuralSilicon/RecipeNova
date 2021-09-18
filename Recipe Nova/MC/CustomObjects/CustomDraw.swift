

import UIKit

class DrawLine: UIView {
    
    public var labelSize:CGRect?
    public var lineWith:CGFloat = 2.0
    public var color:CGColor = UI.AC.toColor().cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw( _ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(lineWith)
        context!.setStrokeColor(color)

        //make and invisible path first then we fill it in
        context!.move(to: CGPoint(x: self.labelSize?.width ?? 0, y: rect.midY))
        context!.addLine(to: CGPoint(x: rect.width - 10, y:rect.midY))
        context!.strokePath()
    }
}
