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
    func buttonWasPressed()
    func drawButtonWasPressed()
}

class SetCardBoard: UIView, CardDelegate {

    //-------------------------------------------------------------
    // Essential Definitions
    
    var deck = [SetCard]() { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    var cardGridLayout = Grid.Layout.aspectRatio(Consts.cardAspectRatio)  { didSet { setNeedsDisplay(); setNeedsLayout() } }
    lazy var cardGrid = Grid(layout: cardGridLayout, frame: bounds) 
    
    //-------------------------------------------------------------
    // Defining Variables
    
    var currentIndex: Int? {
        didSet {
            if let index = currentIndex {
                currentCard = deck[index]
            }
        }
    }
    // set after currentIndex is set
    var currentCard: SetCard?
    
    
    //-------------------------------------------------------------
    // Card Configuration
    
    var cardViews = [SetCardView]()

    func configureCardView(_ rect: CGRect) {
        let cardView = SetCardView(frame: rect)
        
        cardView.index = currentIndex
        cardView.currentCard = currentCard
        cardView.backgroundColor = UIColor.clear
        //cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
        //cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))

        addSubview(cardView)
        cardViews.append(cardView)
    }
    
    func configureAllCardViews() {
        for index in 0..<cardGrid.cellCount {
            if deck[index].isFaceUp, !deck[index].isMatched {
                if let rect = cardGrid[index] {
                    currentIndex = index
                    configureCardView(rect)
                }
            }
        }
    }

    func alterCardView(_ rect: CGRect) {
        

        cardViews[currentIndex!].frame = rect
        //cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
        //cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))
        
        //addSubview(cardView)
        //cardViews.append(cardView)
    }
    
    func alterAllCardViews() {
        for index in 0..<cardGrid.cellCount {
            if deck[index].isFaceUp, !deck[index].isMatched {
                if let rect = cardGrid[index] {
                    currentIndex = index
                    alterCardView(rect)
                }
            }
        }
    }
    
    //-------------------------------------------------------------
    // UIView Animations
    
    let cornerPoint = CGPoint(x: 0, y: 0)
    let spawnCardAnimationDuration = 0.3
    
    @objc func spawnCardSequential() {
        var delay = 0.0
        for cardView in cardViews {
            spawnCard(initial: cornerPoint, cardView, delay: delay)
            delay = delay + spawnCardAnimationDuration
        }
    }
    
    @objc func spawnCard(initial: CGPoint, _ cardView: SetCardView, delay: Double) {
        let destination = cardView.frame
        let origin = CGRect(x: initial.x, y: initial.y, width: cardView.frame.width, height: cardView.frame.height)
        //cardView.frame = origin
        UIView.animate(withDuration: 0,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        
                        cardView.frame = origin
        },
                       completion: nil )
        
        UIView.animate(withDuration: spawnCardAnimationDuration,
                       delay: delay,
                       options: [.curveEaseOut],
                       animations: {
                        
                        cardView.frame = destination
        },
                       completion: nil )
    }

    //-------------------------------------------------------------
    // Laying Out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // removes subviews from the superview
        //        for view in self.subviews{
        //            view.removeFromSuperview()
        //        }
        
        // Button setup
        let layout = Grid.Layout.dimensions(rowCount: 7, columnCount: 1)
        let cardGridInitial = Grid(layout: layout, frame: bounds)
        
        if let buttonZone = cardGridInitial[6] {
            let layout = Grid.Layout.dimensions(rowCount: 1, columnCount: 2)
            let buttonGrid = Grid(layout: layout, frame: buttonZone)
            configureButton(buttonGrid[0]!)
        }
        
        // Grid setup
        let cardBoardGridWidth = bounds.width
        let cardBoardGridHeight = bounds.height*6/7
        
        let cardBoardGrid = CGRect(x: 0, y: 0, width: cardBoardGridWidth, height: cardBoardGridHeight)
        
        // initialize the Grid whenever the layout changes
        cardGrid = Grid(layout: cardGridLayout, frame: cardBoardGrid)
        cardGrid.cellCount = deck.filter() { $0.isFaceUp }.count
        
        if cardViews.count == 0 {
            configureAllCardViews()
        } else {
            alterAllCardViews()
        }
        
        // configureButton(cardGridInitial[6]!)
    }
    
    //-------------------------------------------------------------
    // Card Delegation
    
    func chooseCard() {
        
    }
    
    //-------------------------------------------------------------
    // New Button Code
    
    
    lazy var button = UIButton()
    
    func configureButton(_ rect: CGRect) {
        //let buttonRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let rectWidth = rect.size.width
        let rectHeight = rect.size.height
        let smallConst = CGFloat(0.4)
        
        func smallerSize() -> CGFloat {
            if rect.width > rect.height*2 {
                return rectHeight
            } else {
                return rectWidth*smallConst
            }
        }
        
        button.showsTouchWhenHighlighted = true
        button.frame = rect
        button.backgroundColor = UIColor.blue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: smallerSize()/2)
        button.setTitle("Deal", for: UIControl.State.normal)
        button.addTarget(self, action: #selector(drawButtonWasPressed), for: .touchUpInside)

        addSubview(button)
        
    }
    
    @objc func drawButtonWasPressed() {
        drawButtonDelegate?.drawButtonWasPressed()
    }
    
    func drawButton() {

    }
    
    //-------------------------------------------------------------
    // Legacy Button Code
    
    var drawButtonDelegate: ButtonDelegate?
    var buttonDelegate: ButtonDelegate?
    
    /*
    @objc func someButtonPressed(_ sender: UIButton) {
        selectedButtonIndex = Int((sender.titleLabel?.text)!)
        answerDelegate?.buttonWasPressed()
    }
    */
}


extension SetCardBoard {
    private struct Consts {
        static let cardAspectRatio: CGFloat = 1/1.586
    }

}

/* Archived Code
 lazy var animator = UIDynamicAnimator(referenceView: self)
 lazy var cardBehavior = CardBehavior(in: animator)
 
 
 
 @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
 switch recognizer.state {
 case .ended:
 if let chosenCardView = recognizer.view as? SetCardView {
 cardBehavior.removeItem(chosenCardView)
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
 
 @objc func tapCard(_ recognizer: UITapGestureRecognizer) {
 switch recognizer.state {
 case .ended:
 if let chosenCardView = recognizer.view as? SetCardView {
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
 
 func alterCard(_ rect: CGRect) {
 cardViews[currentIndex!].frame = rect
 }
 
 func alterAllCardViewsV2() {
 for cardView in cardViews {
 cardView.frame = cardGrid[cardView.index!]!
 }
 }
 
 func alterAllCardViews() {
 for index in 0..<cardGrid.cellCount {
 if deck[index].isFaceUp, !deck[index].isMatched {
 if let rect = cardGrid[index] {
 currentIndex = index
 alterCard(rect)
 }
 }
 }
 }
 */
