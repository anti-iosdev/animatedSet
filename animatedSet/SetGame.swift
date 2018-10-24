//
//  SetGame.swift
//  animatedSet
//
//  Created by Anti on 10/19/18.
//  Copyright © 2018 Anti. All rights reserved.
//

import Foundation

class SetGame
{
    var deck = SetCardDeck()
    var cards = [SetCard]()
    
    var activeIndices: [Int]?
    var matchSuccess = 0
    var score = 0
    
    var uglyColorSolution = 0
    
    func deselect() {
        activeIndices = nil
        for index in cards.indices {
            cards[index].isSelected = false
        }
    }
    
    func drawButtonMaster() {
        drawButton()
        drawButton()
        drawButton()
    }
    
    var drawCounter = 0
    
    func drawButton() {
        if drawCounter < cards.count {
            cards[drawCounter].isFaceUp = true
            drawCounter += 1
        }
        
//        for index in cards.indices {
//            if index > 36 {
//                cards[47].isFaceUp = true
//                return true
//            }
//            if !cards[index].isFaceUp, !cards[index].isMatched {
//                cards[index].isFaceUp = true
//                return true
//            }
//        }
//        return false
    }
    
    func chooseCard(at index: Int) {
        uglyColorSolution = 0
        matchSuccess = 0
        //resetButton()
        //print("cards[\(index)].isFaceUp = \(cards[index].isFaceUp)")
        if cards[index].isFaceUp == true {
            if let matchIndex = activeIndices, !matchIndex.contains(index) {
                if matchIndex.count < 2 {
                    activeIndices!.append(index)
                    cards[index].isSelected = true
                } else {
                    // we now have an array of the needed three to be compared
                    if var matchMaker = activeIndices {
                        matchMaker.append(index)
                        if setMatcher(matchMaker) {
                            //var uglyCountSolution = 0
                            
//                            for index in cards.indices {
//                                if matchMaker.contains(index) {
//                                    cards.remove(at: index-uglyCountSolution)
//                                    uglyCountSolution += 1
//                                }
//                            }
                            
                            for index in matchMaker {
                                cards[index].isMatched = true
                            }
                            
                            //cards[index].isSelected = false
                            //print("A set was found!")
                            uglyColorSolution = 1
                            matchSuccess = 1
                            score += 5
                        } else {
                            uglyColorSolution = 2
                            score -= 2
                        }
                    }
                    
                    //                    for index in activeIndices ?? [] {
                    //                        cards[index].isMatched = true
                    //                        uglyColorSolution = 2
                    //                    }
                    
                    // reset
                    activeIndices = nil
                    cards[index].isSelected = true
                }
            } else if activeIndices == nil {
                activeIndices = [index]
                for index in cards.indices {
                    cards[index].isSelected = false
                }
                cards[index].isSelected = true
            } else if let matchIndex = activeIndices, matchIndex.contains(index) {
                //print("this is already a selected card!")
                for activeIndex in matchIndex.indices {
                    if matchIndex[activeIndex] == index {
                        activeIndices!.remove(at: activeIndex)
                    }
                }
                if let matchIndex = activeIndices {
                    for index in cards.indices {
                        if matchIndex.contains(index) {
                            cards[index].isSelected = true
                        } else {
                            cards[index].isSelected = false
                        }
                    }
                }
            }
        }
    }
    
    func setMatcher(_ checkedIndices: [Int]) -> Bool{
        var numberArray = [Int]()
        var symbolArray = [Int]()
        var shadingArray = [Int]()
        var colorArray = [Int]()
        
        for index in checkedIndices {
            numberArray.append(cards[index].number.rawValue)
            symbolArray.append(cards[index].symbol.result)
            shadingArray.append(cards[index].shading.result)
            colorArray.append(cards[index].color.match)
        }
        //        print("numberArray = \(numberArray)")
        //        print("symbolArray = \(symbolArray)")
        //        print("shadingArray = \(shadingArray)")
        //        print("colorArray = \(colorArray)")
        // isSame(myArray: numberArray) ? print("numbers are same!") : print("numbers are not all the same!")
        
        var matchCounter = 0
        
        if isSame(myArray: numberArray) || isDifferent(myArray: numberArray) {
            //print("Numbers are a set!")
            matchCounter += 1
        }
        if isSame(myArray: symbolArray) || isDifferent(myArray: symbolArray) {
            //print("Symbols are a set!")
            matchCounter += 1
        }
        if isSame(myArray: shadingArray) || isDifferent(myArray: shadingArray) {
            //print("Shadings are a set!")
            matchCounter += 1
        }
        if isSame(myArray: colorArray) || isDifferent(myArray: colorArray) {
            //print("Colors are a set!")
            matchCounter += 1
        }
        
        //print("\n")
        
        return matchCounter == 4 ? true : false
    }
    
    func sameOrDifferent(isSame: Bool, isDifferent: Bool) -> Bool {
        if isSame || isDifferent {
            return true
        } else {
            return false
        }
    }
    
    func isSame(myArray: [Int]) -> Bool {
        return myArray.filter{$0 == myArray[0]}.count == myArray.count
    }
    
    func isDifferent(myArray: [Int]) -> Bool {
        for value in myArray {
            if myArray.filter({$0 == value}).count > 1 {
                return false
            }
        }
        return true
    }
    
    func selectionBot (at index: Int) {
        cards[index].isFaceUp ? (cards[index].isSelected = true) : (cards[index].isSelected = false)
    }
    
    func simpleFlip(at index: Int) {
        cards[index].isFaceUp ? (cards[index].isFaceUp = false) : (cards[index].isFaceUp = true)
    }
    
    //var voidCard = Card.init(number: one, symbol: one, shading: one, color: one, isFaceUp: false, isSelected: false, isMatched: false)
    
    func shuffleCardDebug() {
        for index in deck.cards.indices {
            //var card = deck.cards[index]
            if index >= 24 {
                //cards[index] = false
                deck.cards[index].isFaceUp = false
                cards.append(deck.cards[index])
            }
            else {
                cards.append(deck.cards[index])
                drawCounter += 1
            }
        }
    }
    
    func shuffleCard() {
        for index in deck.cards.indices {
            if index >= 12 {
                var cardTemp = deck.draw()!
                cardTemp.isFaceUp = false
                cards.append(cardTemp)
            }
            else {
                cards.append(deck.draw()!)
                drawCounter += 1
            }
        }
    }
    
    init(numberOfTotalSlots: Int) {

        shuffleCard()
    }
}

