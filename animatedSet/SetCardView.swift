//
//  SetCardView.swift
//  animatedSet
//
//  Created by Anti on 10/15/18.
//  Copyright © 2018 Anti. All rights reserved.
//

import UIKit

@objc protocol CardDelegate {
    // Defined in ViewController
    func chooseCard()
}

class SetCardView: UIView
{
    //-------------------------------------------------------------
    // Definitions
    
    var currentCard: SetCard!
    var index: Int?
    var cardDelegate: CardDelegate?
    
    //-------------------------------------------------------------
    // Gridding
    
    lazy var drawingBoundsRect = drawingBoundsRectConverter(bounds)
    lazy var cardGrid = gridConverter(drawingBoundsRect)
    
    func drawingBoundsRectConverter(_ rect: CGRect) -> CGRect {
        return CGRect(x: rect.minX+rect.width/4, y: rect.minY, width: rect.width-rect.width/2, height: rect.height)
    }
    func gridConverter(_ rect: CGRect) -> Grid {
        let layout = Grid.Layout.dimensions(rowCount: currentCard.number.rawValue, columnCount: 1)
        let cardGrid = Grid(layout: layout, frame: bounds)
        return cardGrid
    }
    
    //-------------------------------------------------------------
    // Animation
    
    let cornerPoint = CGPoint(x: 0, y: 0)
    let spawnCardAnimationDuration = 0.3
    
    @objc func spawnCardSequential(initial: CGPoint, _ delay: Double) {
        spawnCard(initial: initial, delay: delay)
    }
    
    @objc func spawnCard(initial: CGPoint, delay: Double) {
        let destination = self.frame
        let origin = CGRect(x: initial.x, y: initial.y, width: self.frame.width, height: self.frame.height)
        //cardView.frame = origin
        UIView.animate(withDuration: 0,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        
                        self.frame = origin
        },
                       completion: nil )
        
        UIView.animate(withDuration: spawnCardAnimationDuration,
                       delay: delay,
                       options: [.curveEaseOut],
                       animations: {
                        
                        self.frame = destination
        },
                       completion: nil )
    }
    
    @objc func tapCardV3(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            
            print("hi")
        default:
            break
        }
    }
    
    @objc func tapCardV2(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if (recognizer.view as? SetCardView) != nil {
                //cardBehavior.removeItem(chosenCardView)
                UIView.animate(withDuration: 0.75,
                               delay: 0,
                               options: [.curveEaseOut],
                               animations: {
                                self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y - self.frame.width/4, width: self.frame.width, height: self.frame.height)
                },
                               completion: nil )
            }
        default:
            break
        }
    }
    
    @objc func tapCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if (recognizer.view as? SetCardView) != nil {
                //cardBehavior.removeItem(chosenCardView)
                UIView.animate(withDuration: 0.75,
                               delay: 0,
                               options: [.curveEaseOut],
                               animations: {
                                self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y - self.frame.width/4, width: self.frame.width, height: self.frame.height)
                },
                               completion: nil )
            }
        default:
            break
        }
    }
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? SetCardView {
                UIView.transition(with: chosenCardView,
                                  duration: 0.5,
                                  options: [.transitionFlipFromLeft],
                                  animations: {
                                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                },
                                  completion: { Void in() }
                )
            }
        default:
            break
        }
    }
    
    //-------------------------------------------------------------
    // Layout and Initialization
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))

    }
    
    
    

    
    
    
    
    
    
    
    //-------------------------------------------------------------
    // Drawing Code
    
    func drawStripes(_ cellRect: CGRect) {
        //let center = CGPoint(x: cellRect.midX-shapeSize, y: cellRect.midY-shapeSize/2)
        let width = cellRect.width*1.4
        var stripeRect = CGRect(x: cellRect.minX-width*0.2, y: cellRect.minY, width: width, height: cellRect.height/2)
        let path = UIBezierPath(rect: stripeRect)
        path.lineWidth = 2.0
        //UIColor.blue.setStroke()
        path.stroke()
        
        stripeRect = CGRect(x: cellRect.minX-width*0.2, y: cellRect.midY-shapeSize/2, width: width, height: shapeSize)
        let path2 = UIBezierPath(rect: stripeRect)
        path2.lineWidth = 2.0
        //UIColor.blue.setStroke()
        path2.stroke()
    }
    
    func drawShading(_ path: UIBezierPath, rect: CGRect) {
        // check shading for cases: 1 = empty, 2 = fill, 3 = striped
        if let card = currentCard {
            let shading = card.shading.result
            if shading == 1 {
                UIColor.white.setFill()
                path.fill()
                card.color.result.setStroke()
            } else if shading == 2 {
                card.color.result.setFill()
                path.fill()
                //UIColor.black.setStroke()
                card.color.result.setStroke()
            } else if shading == 3 {
                UIColor.white.setFill()
                path.fill()
                card.color.result.setStroke()
                drawStripes(rect)
                //UIColor.black.setStroke()
            }
        }
    }
    
    func drawSquare(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let center = CGPoint(x: rect.midX-squareSize/2, y: rect.midY-squareSize/2)
        let sizeRect = CGSize(width: squareSize, height: squareSize)
        let drawnRect = CGRect(origin: center, size: sizeRect)
        
        let path = UIBezierPath(rect: drawnRect)
        
        // making sure of clipping
        context!.saveGState()
        path.addClip()
        
        drawShading(path, rect: rect)
        
        path.lineWidth = 3.0
        path.stroke()
        context!.restoreGState()
    }
    
    func drawCircle(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let path = UIBezierPath(arcCenter: center, radius: shapeSize, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        
        // making sure of clipping
        context!.saveGState()
        path.addClip()
        
        drawShading(path, rect: rect)
        
        path.lineWidth = 3.0
        path.stroke()
        context!.restoreGState()
    }
    
    func drawSquiggle(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        // defining the circles
        let centerSemiOne = CGPoint(x: rect.midX+shapeSize/2, y: rect.midY)
        let centerSemiTwo = CGPoint(x: rect.midX-shapeSize/2, y: rect.midY)
        
        let pathSemiOne = UIBezierPath(arcCenter: centerSemiOne, radius: shapeSize, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true)
        let pathSemiTwo = UIBezierPath(arcCenter: centerSemiTwo, radius: shapeSize, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: false)
        
        let path = pathSemiOne
        path.append(pathSemiTwo)
        
        // making sure of clipping
        context!.saveGState()
        path.addClip()
        
        drawShading(path, rect: rect)
        
        path.lineWidth = 3.0
        path.stroke()
        context!.restoreGState()
    }
    
    func drawDiamond(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let center = CGPoint(x: rect.midX-squareSize/2, y: rect.midY-squareSize/2)
        let sizeRect = CGSize(width: squareSize, height: squareSize)
        let drawnRect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizeRect)
        
        let path = UIBezierPath(rect: drawnRect)
        
        let diagonalHalf = squareSize/2
        let pathRotation = CGAffineTransform(rotationAngle: CGFloat.pi/4)
        let pathTranslation2 = CGAffineTransform(translationX: center.x, y: center.y)
        let pathTranslation3 = CGAffineTransform(translationX: diagonalHalf, y: -diagonalHalf/2.5)
        
        path.apply(pathRotation)
        path.apply(pathTranslation2)
        path.apply(pathTranslation3)
        
        // making sure of clipping
        context!.saveGState()
        path.addClip()
        
        drawShading(path, rect: rect)
        
        path.lineWidth = 3.0
        path.stroke()
        context!.restoreGState()
    }
    
    func drawOval(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let width = squareSize*1.5
        let center = CGPoint(x: rect.midX-width/2, y: rect.midY-squareSize/2)
        let sizeRect = CGSize(width: squareSize*1.5, height: squareSize)
        let drawnRect = CGRect(origin: center, size: sizeRect)
        
        let path = UIBezierPath(ovalIn: drawnRect)
        
        // making sure of clipping
        context!.saveGState()
        path.addClip()
        
        drawShading(path, rect: rect)
        
        path.lineWidth = 3.0
        path.stroke()
        context!.restoreGState()
    }
    
    func masterDrawFunction() {
        if let card = currentCard {
            for index in 0..<cardGrid.cellCount {
                if let rect = cardGrid[index] {
                    if card.symbol.result == 1 {
                        drawSquiggle(rect)
                    } else if card.symbol.result == 2 {
                        drawDiamond(rect)
                    } else if card.symbol.result == 3 {
                        drawOval(rect)
                    }
                }
            }
        }
    }
    
    //-------------------------------------------------------------
    // Custom Code
    
    var drawnFaceCardImage: UIImage?
    
    func faceDrawer() {
        if isFaceUp {
            masterDrawFunction()
        } else {
            if let cardBackImage = UIImage(named: "hearthstoneCardback", in: Bundle(for:
                self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
        }
    }
    
    func isSelected() {
        if currentCard.isSelected {
            
        } else {
            
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        // prevents drawing outside of rectangle
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        //self.frame = roundedRect
        
        
        faceDrawer()
        //        if isFaceUp {
        //            if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for:
        //                self.classForCoder), compatibleWith: traitCollection) {
        //                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
        //            } else {
        //                drawPips()
        //            }
        //        } else {
        //            if let cardBackImage = UIImage(named: "hearthstoneCardback", in: Bundle(for:
        //                self.classForCoder), compatibleWith: traitCollection) {
        //                cardBackImage.draw(in: bounds)
        //            }
        //        }
    }
    
    //-------------------------------------------------------------
    
    // need the weird didSet as the view must change if any of the values change
    @IBInspectable // must be explicitly typed for interface builder
    var rank: Int = 12 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var suit: String = "❤️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay() }}
    
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        // required for scaled fonts
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    private lazy var upperLeftCornerLabel = createCornerLabel()
    private lazy var lowerRightCornerLabel = createCornerLabel()
    
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        // 0 means it wont get cut off
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureCornerLabel(_ label: UILabel) {
        label.attributedText = cornerString
        // clears its size
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = !isFaceUp
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    

    
    private func drawPips()
    {
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height /
                verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize /
                    (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy:
                cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
}

extension SetCardView {
    // how to constants in swift
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}

extension SetCardView {
    private struct Consts {
        static let cellCount: Int = 12
        static let cardAspectRatio: CGFloat = 1/1.586
        static let centerFontSizeToBoundsHeight: CGFloat = 0.4
        static let shapeRatio: CGFloat = 0.2
    }
    private var centerFontSize: CGFloat {
        return cardGrid.cellSize.height * Consts.centerFontSizeToBoundsHeight
    }
    private var shapeSize: CGFloat {
        return cardGrid.cellSize.width * Consts.shapeRatio
    }
    private var squareSize: CGFloat {
        return shapeSize*1.5
    }
}
