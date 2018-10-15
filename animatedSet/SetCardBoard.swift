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
    
    func configureCardView(_ rect: CGRect) {
        let cardView = SetCardView(frame: rect)
        
        cardView.index = currentIndex
        cardView.currentCard = currentCard
        //cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
        //cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(_:))))

        addSubview(cardView)
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
    
    //-------------------------------------------------------------
    // UIView Animations
    
    lazy var animator = UIDynamicAnimator(referenceView: self)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
//    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
//        switch recognizer.state {
//        case .ended:
//            if let chosenCardView = recognizer.view as? SetCardView {
//                cardBehavior.removeItem(chosenCardView)
//                UIView.transition(with: chosenCardView,
//                                  duration: 0.5,
//                                  options: [.transitionFlipFromLeft],
//                                  animations: {
//                                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
//                },
//                                  completion: { Void in() }
//                )
//            }
//        default:
//            break
//        }
//    }

    
    @objc func tapCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? SetCardView {
                cardBehavior.removeItem(chosenCardView)
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               options: [.curveEaseInOut],
                               animations: {
                                self.frame = CGRect(x: self.frame.origin.x, y: 20, width: self.frame.width, height: self.frame.height)
                },
                               completion: nil)
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
        configureAllCardViews()
    }
}

extension SetCardBoard {
    private struct Consts {
        static let cardAspectRatio: CGFloat = 1/1.586
    }

}
