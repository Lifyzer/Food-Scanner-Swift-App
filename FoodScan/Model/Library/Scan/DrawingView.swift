import UIKit
import Firebase

class DrawingView: UIView {

    public var imageSize: CGSize = .zero
    public var visionText: VisionText? {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        for i in self.subviews
        {
            i.removeFromSuperview()
        }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.clear(rect);
        guard let visionText = visionText else { return }

        let frameSize = self.bounds.size

        let blocks: [VisionTextBlock] = visionText.blocks
        print(blocks.count)
        let font = UIFont.systemFont(ofSize: 10)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.green
        ]
        for block in blocks {
            let lines: [VisionTextLine] = block.lines
            for line in lines {
                let elements: [VisionTextElement] = line.elements
                for element in elements {
                    let text = element.text
                    let labl = UILabel()
                    let frame = element.frame * (frameSize / imageSize)
                    labl.frame = frame
                    labl.textColor = UIColor.white
                    labl.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    labl.isUserInteractionEnabled = true
                    labl.layer.borderColor = UIColor.white.cgColor
                    labl.layer.borderWidth = 3.0
                    labl.backgroundColor = UIColor.clear
                    labl.font = UIFont(name: "aribl_bold", size: 15.0)
                    self.addSubview(labl)
                    let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(_:)))
                    tap.numberOfTapsRequired = 1
                    labl.addGestureRecognizer(tap)
                }
            }
        }
    }

    @objc func tapHandle(_ gesture  :UITapGestureRecognizer)
    {
        if gesture.view!.isKind(of: UILabel.classForCoder())
        {
            let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idViewProductPopUpVC) as! ViewProductPopUpVC
            vc.modalPresentationStyle = .overCurrentContext

            var txt = (gesture.view as! UILabel).text!
            txt = txt.trimmingCharacters(in: .whitespaces)
            if txt != "" {
                vc.productName = txt
            }

            self.topMostController()?.present(vc, animated: false, completion: nil)
        }
    }

    private func drawLine(ctx: CGContext, from p1: CGPoint, to p2: CGPoint, color: CGColor) {
        ctx.setStrokeColor(color)
        ctx.setLineWidth(1.0)
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        ctx.strokePath();
    }

    private func drawRect(ctx: CGContext, rect: CGRect, color: CGColor, fill: Bool = true) {
        let points: [CGPoint] = [
            rect.origin + CGSize(width: 0, height: 0),
            rect.origin + CGSize(width: rect.size.width, height: 0),
            rect.origin + CGSize(width: rect.size.width, height: rect.size.height),
            rect.origin + CGSize(width: 0, height: rect.size.height)
        ]
        drawPolygon(ctx: ctx, points: points, color: color, fill: fill)
    }

    private func drawPolygon(ctx: CGContext, points: [CGPoint], color: CGColor, fill: Bool = false) {
        if fill {
            ctx.setStrokeColor(UIColor.clear.cgColor)
            ctx.setFillColor(color)
            ctx.setLineWidth(0.0)
        } else {
            ctx.setStrokeColor(color)
            ctx.setLineWidth(1.0)
        }
        for i in 0..<points.count {
            if i == 0 {
                ctx.move(to: points[i])
            } else {
                ctx.addLine(to: points[i])
            }
        }
        if let firstPoint = points.first {
            ctx.addLine(to: firstPoint)
        }
        if fill {
            ctx.fillPath()
        } else {
            ctx.strokePath();
        }
    }
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func * (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x * right.width, y: left.y * right.height)
}

func / (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x / right.width, y: left.y / right.height)
}

func / (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width / right.width, height: left.height / right.height)
}

func * (left: CGRect, right: CGSize) -> CGRect {
    return CGRect(x: left.origin.x * right.width,
                  y: left.origin.y * right.height,
                  width: left.size.width * right.width,
                  height: left.size.height * right.height)
}

func + (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x + right.width, y: left.y + right.height)
}
