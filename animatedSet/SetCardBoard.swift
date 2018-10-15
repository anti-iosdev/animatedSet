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

class SetCardBoard: UIView {

    //-------------------------------------------------------------
    // Essential Definitions
    
    var deck = [SetCard]() { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    let cardGridLayout = Grid.Layout.aspectRatio(Consts.cardAspectRatio)
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
    // UIView Definitions
    
    var cardViews: [SetCardView]?
    var cardTest = SetCardView()
    
    func configureCardViews() {
        if let cardViews = cardViews {
            for cardView in cardViews {
                cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            }
        }
    }
    
    func configureCardViews2() {
        for index in 0..<cardGrid.cellCount {
            if deck[index].isFaceUp, !deck[index].isMatched {
                if let cell = cardGrid[index] {
                    currentIndex = index
                    
                    let cardView = SetCardView(frame: cell)
                    
                    cardView.currentCard = currentCard
                    
                    cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
                    
                    addSubview(cardView)
                }
            }
        }
    }
    
    //-------------------------------------------------------------
    // UIView Animations
    
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
    
    
    //-------------------------------------------------------------
    // Legacy Button Code
    
    var answerDelegate: ButtonDelegate?
    
    /*
    @objc func someButtonPressed(_ sender: UIButton) {
        selectedButtonIndex = Int((sender.titleLabel?.text)!)
        answerDelegate?.buttonWasPressed()
    }
    */
    
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
        
        // initialization of drawing
        configureCardViews2()
    }
}

extension SetCardBoard {
    private struct Consts {
        static let cardAspectRatio: CGFloat = 1/1.586
    }

}
