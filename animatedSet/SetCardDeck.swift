//
//  SetCardDeck.swift
//  animatedSet
//
//  Created by Anti on 10/14/18.
//  Copyright © 2018 Anti. All rights reserved.
//

import Foundation

struct SetCardDeck
{
    var cards = [SetCard]()
    
    init() {
        for number in SetCard.Number.all {
            for symbol in SetCard.Symbol.all {
                for shading in SetCard.Shading.all {
                    for color in SetCard.Color.all {
                        cards.append(SetCard(number: number, symbol: symbol, shading: shading, color: color, isFaceUp: true, isSelected: false, isMatched: false))
                    }
                }
            }
        }
    }
    
    mutating func draw() -> SetCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
