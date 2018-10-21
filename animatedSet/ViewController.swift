//
//  ViewController.swift
//  animatedSet
//
//  Created by Anti on 10/14/18.
//  Copyright © 2018 Anti. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ButtonDelegate {

    //-------------------------------------------------------------
    // Definitions
    
    var game = SetGame(numberOfTotalSlots: 81)
    
    // debug deck
    var deck = SetCardDeck().cards
    lazy var cards = debugDeck()
    
    func debugDeck() -> [SetCard] {
        cards = [SetCard]()
        for index in deck.indices {
            if index < 12 {
                cards.append(deck[index])
            }
        }
        return cards
    }
    
    @IBOutlet weak var setCardView: SetCardBoard! {
        didSet {
            setCardView.deck = game.cards
        }
    }
    
    //-------------------------------------------------------------
    // Delegate
    @objc func buttonWasPressed() {
        
    }
    @objc func drawButtonWasPressed() {
        // print("drawButton @ viewcontroller")
        game.drawButtonMaster()
        updateViewFromModel()
    }
    
    @objc func chooseCard(_ index: Int) {
        //print("card: \(index) @ viewcontroller")
        game.chooseCard(at: index)
        updateViewFromModel()
    }
    
    //-------------------------------------------------------------
    // Update View From Model
    
    func updateViewFromModel() {
        setCardView.deck = game.cards
    }
    
    
    
    
    
    //-------------------------------------------------------------
    // Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        setCardView.buttonDelegate = self
        setCardView.drawButtonDelegate = self
        
    }
}

