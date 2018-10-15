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
            setCardView.deck = cards
        }
    }
    
    //-------------------------------------------------------------
    // Delegate
    @objc func buttonWasPressed() {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCardView.answerDelegate = self
    }
}

