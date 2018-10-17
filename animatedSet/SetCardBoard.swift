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
    
    func configureCardViewV2(_ rect: CGRect) -> SetCardView {
        let cardView = SetCardView(frame: rect)
        cardView.index = currentIndex
        cardView.currentCard = currentCard
        //cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
        //cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))
        
        //addSubview(cardView)
        //cardViews.append(cardView)
        
        return cardView
    }
    
    func configureAllCardViewsV2() {
        for index in 0..<cardGrid.cellCount {
            if deck[index].isFaceUp, !deck[index].isMatched {
                if let rect = cardGrid[index] {
                    currentIndex = index
                    let cardView = configureCardViewV2(rect)
                    
                    if cardViews.count > index {
                        if cardViews[index].index == cardView.index {
                            print("is already inside")
                        }
                    } else {
                        addSubview(cardView)
                        cardViews.append(cardView)
                    }
                }
            }
        }
        print("cardViews.count = \(cardViews.count)")
    }
    
    //-------------------------------------------------------------
    // Card Delegation
    
    func chooseCard() {
        
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
        for view in self.subviews{
            view.removeFromSuperview()
        }
        
        // initialize the Grid whenever the layout changes
        cardGrid = Grid(layout: cardGridLayout, frame: bounds)
        cardGrid.cellCount = deck.filter() { $0.isFaceUp }.count
        
        configureAllCardViews()
        
    }

    //-------------------------------------------------------------
    // Legacy Button Code
    
    var answerDelegate: ButtonDelegate?
    
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
