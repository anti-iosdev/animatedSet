//
//  SetCardView.swift
//  animatedSet
//
//  Created by Anti on 10/15/18.
//  Copyright © 2018 Anti. All rights reserved.
//

import UIKit

@objc protocol ButtonDelegate {
    // Defined in ViewController
    func buttonWasPressed(_ sender: UIButton)
}

class SetCardView: UIView {
    
    //-------------------------------------------------------------
    // Animations
    
    @IBAction func animateButton(sender: UIButton) {
        
        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        sender.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
    }
    
    
    
    
    
    //-------------------------------------------------------------
    // Essential Definitions
    
    var deck = [SetCard]() { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var uglyColorSolution = 0 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    let cardGridLayout = Grid.Layout.aspectRatio(Consts.cardAspectRatio)
    lazy var cardGrid = Grid(layout: cardGridLayout, frame: bounds)
    
    //-------------------------------------------------------------
    // Defining Variables
    
    var currentIndex: Int? {
        didSet {
            if let index = currentIndex {
                currentCard = deck[index]
                currentCardCell = cardGrid[index]
            }
        }
    }
    // set after currentIndex is set
    var currentCard: SetCard? {
        didSet {
            if let card = currentCard {
                cardCellMiniGridLayout = Grid.Layout.dimensions(rowCount: card.number.rawValue, columnCount: 1)
            }
        }
    }
    var cardCellMiniGridLayout: Grid.Layout?
    var currentCardCell: CGRect? {
        didSet {
            if let rect = currentCardCell {
                cardCellMini = cardCellMiniConverter(rect)
                //cardButtons.append(createUIButton(rect))
            }
        }
    }
    var cardCellMini: CGRect? {
        didSet {
            if let layout = cardCellMiniGridLayout, let cardCell = cardCellMini {
                cardCellMiniGrid = Grid(layout: layout, frame: cardCell)
            }
        }
    }
    var cardCellMiniGrid: Grid?
    func cardCellMiniConverter(_ rect: CGRect) -> CGRect {
        return CGRect(x: rect.minX+rect.width/4, y: rect.minY, width: rect.width-rect.width/2, height: rect.height)
    }
    
    //-------------------------------------------------------------
    // Button Code
    
    var cardButtons = [UIButton]()
    
    lazy var deckCopy = deck
    var selectedButtonIndex: Int?
    
    var answerDelegate: ButtonDelegate?
    @objc func someButtonPressed(_ sender: UIButton) {
        animateButton(sender: sender)
        selectedButtonIndex = Int((sender.titleLabel?.text)!)
        answerDelegate?.buttonWasPressed(sender)
    }
    
    private func createUIButton(_ rect: CGRect) -> UIButton {
        let button = UIButton(frame: rect)
        
        button.setTitle(String(currentIndex!), for: UIControl.State.normal)
        button.setTitleColor(UIColor.clear, for: UIControl.State.normal)
        
        button.layer.cornerRadius = 8.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.gray.cgColor
        
        if deck[currentIndex!].isSelected {
            button.layer.borderWidth = 3.0
            button.layer.borderColor = UIColor.blue.cgColor
        }
        
        if uglyColorSolution == 1 {
            button.layer.borderColor = UIColor.green.cgColor
        } else if uglyColorSolution == 2 {
            button.layer.borderColor = UIColor.red.cgColor
        }
        
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.addTarget(self, action: #selector(someButtonPressed), for: .touchUpInside)
        
        self.addSubview(button)
        return button
    }
    
    @objc func buttonAction(sender: UIButton!) {
        //print("Button index: \(sender.titleLabel!)")
        //print("\(cardButtons.count)")
    }
    
    func buttonInitializer() {
        for index in 0..<cardGrid.cellCount {
            if deck[index].isFaceUp, !deck[index].isMatched {
                if let cell = cardGrid[index] {
                    currentIndex = index
                    var button = createUIButton(currentCardCell!)
                }
            }
        }
    }
    
    //-------------------------------------------------------------
    // Laying Out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // removes subviews from the superview
        for view in self.subviews{
            view.removeFromSuperview()
        }
        
        // initialize the Grid whenever the layout changes
        cardGrid = Grid(layout: cardGridLayout, frame: bounds)
        cardGrid.cellCount = deck.filter() { $0.isFaceUp }.count
        
        // initialize buttons
        buttonInitializer()
    }
    
    //-------------------------------------------------------------
    // Drawing Logic
    
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
        if let card = currentCard, let cardGrid = cardCellMiniGrid {
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    //-------------------------------------------------------------
    // Draw Function
    
    override func draw(_ rect: CGRect) {
        
        for index in 0..<cardGrid.cellCount {
            if let cell = cardGrid[index] {
                // draw in the grid
                //let path = UIBezierPath(rect: cell)
                //path.lineWidth = 2.0
                //UIColor.gray.setStroke()
                //path.stroke()
                
                // draw shapes in the grid
                currentIndex = index
                masterDrawFunction()
            }
        }
    }
}

extension SetCardView {
    private struct Consts {
        static let cellCount: Int = 81
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
