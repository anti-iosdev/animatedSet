//
//  ViewController.swift
//  animatedSet
//
//  Created by Anti on 10/14/18.
//  Copyright © 2018 Anti. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = SetCardDeck().cards
//    lazy var cards = shuffledDeck()
    
//    func shuffledDeck() -> [SetCard] {
//        var cards = [SetCard]()
//        for _ in deck.cards.indices {
//            if let card = deck.draw() {
//                cards.append(card)
//            }
//        }
//        return cards
//    }
    
    @IBOutlet weak var setCardView: SetCardView! {
        didSet {
            setCardView.deck = deck
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

