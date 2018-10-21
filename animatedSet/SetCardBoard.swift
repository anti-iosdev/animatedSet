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
    
    func chooseCard(_ index: Int)
}

class SetCardBoard: UIView, CardDelegate {
    
    //-------------------------------------------------------------
    // Essential Definitions
    
    var deck = [SetCard]() { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    var cardGridLayout = Grid.Layout.aspectRatio(Consts.cardAspectRatio)  { didSet { setNeedsDisplay(); setNeedsLayout() } }
    lazy var cardGrid = Grid(layout: cardGridLayout, frame: bounds)
    
    var sets = 0
    
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
    var startingPositions = [SetCardView]()
    
    var positionIndexTracker = [Int]()
    var positionDict = [Int:CGRect]()
    var newPositionDict = [Int:SetCardView]()
    
    var positionDictCopy = [Int:SetCardView]()
    var donePile = [SetCardView]()
    
    var oldSpawns = [Int]()
    var newSpawns = [Int]()
    
    //-------------------------------------------------------------
    // Positioning Code
    
    func updatePositionDict() {
        for index in positionIndexTracker {
            positionDict[index] = newPositionDict[index]!.frame
            //positionDictCopy[index] = newPositionDict[index]
        }
    }
    
    // index of old cards used
    // index of new cards used
    // if old card isn't in new cards, send to score
    // update old index to new index
    
    // returns true if card wasn't taken out
    
    func spawnMerger() {
        oldSpawns = newSpawns
        newSpawns = []
    }
    
    func spawnCheckerHelper() {
        for index in oldSpawns {
            spawnChecker(index)
        }
    }
    
    func spawnChecker(_ index: Int) {
        if !newSpawns.contains(index) {
            // animate going to bin
            addSubview(positionDictCopy[index]!)
            positionDictCopy[index]?.despawnCard(scoreDespawnFrame!, delay: 0.0)
            donePile.append(positionDictCopy[index]!)
            sets += 1
        }
    }
    
    func donePileRender() {
        for view in donePile {
            addSubview(view)
        }
    }
    
    var cardAnimationDelay = 0.0
    
    func configureCardView(_ rect: CGRect) {
        let cardView = SetCardView(frame: rect)
        
        cardView.index = currentIndex
        cardView.currentCard = currentCard
        cardView.backgroundColor = UIColor.clear
        cardView.cardDelegate = self
        addSubview(cardView)
        
        if let position = positionDict[cardView.index!] {
            cardView.moveCard(position, delay: 0.0)
            positionDict[cardView.index!] = cardView.frame
            positionDictCopy[cardView.index!] = cardView
            newSpawns.append(cardView.index!)
        } else {
            cardView.spawnCardV2(dealButtonFrame!, delay: cardAnimationDelay)
            positionDict[cardView.index!] = cardView.frame
            positionDictCopy[cardView.index!] = cardView
            cardAnimationDelay = cardAnimationDelay + 0.1
            newSpawns.append(cardView.index!)
        }
        
        //positionIndexTracker.append(cardView.index!)
        //newPositionDict[cardView.index!] = cardView
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

    func configureCardViewV2(_ rect: CGRect) {
        let cardView = SetCardView(frame: rect)
        
        cardView.index = currentIndex
        cardView.currentCard = currentCard
        cardView.backgroundColor = UIColor.clear
        cardView.cardDelegate = self
        
        addSubview(cardView)
        for index in cardViews.indices {
            if cardViews[index].index == currentIndex {
                cardViews[index] = cardView
            } else {
                cardViews.append(cardView)
            }
        }
    }
    
    func configureAllCardViewsV2() {
        var validCards = [Int]()
        for index in deck.indices {
            if deck[index].isFaceUp, !deck[index].isMatched {
                validCards.append(index)
            }
        }
        if validCards.count > 0 {
            for index in validCards.indices {
                if let rect = cardGrid[index] {
                    currentIndex = validCards[index]
                    configureCardView(rect)
                }
            }
        }
    }
    
    //-------------------------------------------------------------
    // Laying Out Subviews

    var dealButtonFrame: CGRect?
    var cardSize: CGSize?
    var scoreDespawnFrame: CGRect?
    var setLabel: UILabel?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //// Testing
        for view in self.subviews{
            view.removeFromSuperview()
        }
        
        donePileRender()
        
        // Button setup
        let layout = Grid.Layout.dimensions(rowCount: 7, columnCount: 1)
        let cardGridInitial = Grid(layout: layout, frame: bounds)
        
        let cardBoardGridWidth = bounds.width
        let cardBoardGridHeight = bounds.height*6/7
        
        let cardBoardGrid = CGRect(x: 0, y: 0, width: cardBoardGridWidth, height: cardBoardGridHeight)
        
        // initialize the Grid whenever the layout changes
        cardGrid = Grid(layout: cardGridLayout, frame: cardBoardGrid)
        cardGrid.cellCount = deck.filter() { $0.isFaceUp && !$0.isMatched }.count
        
        cardSize = cardGrid.cellSize
        
        if let buttonZone = cardGridInitial[6] {
            let layout = Grid.Layout.dimensions(rowCount: 1, columnCount: 3)
            let buttonGrid = Grid(layout: layout, frame: buttonZone)
            
            if let leftButtonRect = buttonGrid[0], let size = cardSize {
                let buttonLeftCenterPoint = CGPoint(x: leftButtonRect.midX-cardSize!.width/2, y: leftButtonRect.midY-cardSize!.height/2)
                let cardSpawnFrame = CGRect(origin: buttonLeftCenterPoint, size: size)
                dealButtonFrame = cardSpawnFrame
                dealButtonSetupV2(leftButtonRect)
            }
            
            if let rightButtonRect = buttonGrid[1], let despawnRect = buttonGrid[2] {
                
                let despawnCardLayout = Grid.Layout.aspectRatio(Consts.cardAspectRatio)
                var despawnCardGrid = Grid(layout: despawnCardLayout, frame: despawnRect)
                despawnCardGrid.cellCount = 1
                scoreDespawnFrame = despawnCardGrid[0]
                
                setLabel = scoreButtonSetup(rightButtonRect)
                
                //dealButtonFrame = cardSpawnFrame
                //dealButtonSetupV2(leftButtonRect)
            }
        }
        
        configureAllCardViewsV2()
        updatePositionDict()
        cardAnimationDelay = 0
        
        spawnCheckerHelper()
        spawnMerger()
        
        setLabel!.text = "Sets: \(sets)"
        
    }
    

    func scoreButtonUpdate() {
        
    }
    
    func scoreButtonSetup(_ labelSize: CGRect) -> UILabel {
        let smallConst = CGFloat(0.4)
        
        func smallerSize() -> CGFloat {
            if labelSize.width > labelSize.height*2 {
                return labelSize.height
            } else {
                return labelSize.width*smallConst
            }
        }
        
        let rect = labelSize
        
        let label = UILabel()
        label.frame = rect
        label.backgroundColor = UIColor.blue
        label.text = "Sets: \(sets)"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: smallerSize()/2)
        
        addSubview(label)
        return label
    }
    
    func dealButtonSetupV2(_ buttonRect: CGRect) {
        //        let rectWidth = rectSize.width
        //        let rectHeight = rect.size.height
        let smallConst = CGFloat(0.4)
        
        func smallerSize() -> CGFloat {
            if buttonRect.width > buttonRect.height*2 {
                return buttonRect.height
            } else {
                return buttonRect.width*smallConst
            }
        }
        
        let rect = buttonRect
        
        button.showsTouchWhenHighlighted = true
        button.frame = rect
        button.backgroundColor = UIColor.blue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: smallerSize()/2)
        button.setTitle("Deal", for: UIControl.State.normal)
        button.addTarget(self, action: #selector(drawButtonWasPressed), for: .touchUpInside)
        
        addSubview(button)
        
        }
    
    func dealButtonSetup(locationPoint: CGPoint, rectSize: CGSize) -> CGRect {
//        let rectWidth = rectSize.width
//        let rectHeight = rect.size.height
        let smallConst = CGFloat(0.4)
        
        func smallerSize() -> CGFloat {
            if rectSize.width > rectSize.height*2 {
                return rectSize.height
            } else {
                return rectSize.width*smallConst
            }
        }
        
        let rect = CGRect(origin: locationPoint, size: rectSize)
        
        button.showsTouchWhenHighlighted = true
        button.frame = rect
        button.backgroundColor = UIColor.blue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: smallerSize()/2)
        button.setTitle("Deal", for: UIControl.State.normal)
        button.addTarget(self, action: #selector(drawButtonWasPressed), for: .touchUpInside)
        
        addSubview(button)
        
        return rect
    }
    
    //-------------------------------------------------------------
    // UIView Animations
    
    let cornerPoint = CGPoint(x: 0, y: 0)
    let spawnCardAnimationDuration = 0.3
    
    @objc func moveCard() {
        
    }
    
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
    // Card Delegation
    
    var cardDelegate: CardDelegate?
    var drawButtonDelegate: ButtonDelegate?
    var buttonDelegate: ButtonDelegate?
    
    func chooseCard(_ index: Int) {
        //print("card: \(index) was selected")
        drawButtonDelegate?.chooseCard(index)
        
    }
    
    @objc func drawButtonWasPressed() {
        drawButtonDelegate?.drawButtonWasPressed()
    }
    
    //-------------------------------------------------------------
    // New Button Code
    
    
    lazy var button = UIButton()
    
    func configureButton(_ rect: CGRect) {
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
    

    
    //-------------------------------------------------------------
    // Legacy Button Code

    
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
