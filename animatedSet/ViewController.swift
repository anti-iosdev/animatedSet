//
//  ViewController.swift
//  animatedSet
//
//  Created by Anti on 10/14/18.
//  Copyright © 2018 Anti. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ButtonDelegate {

    @objc func buttonWasPressed(_ sender: UIButton) {

    }
    
    var deck = SetCardDeck().cards
    
    @IBOutlet weak var setCardView: SetCardView! {
        didSet {
            setCardView.deck = deck
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCardView.answerDelegate = self
    }
}

