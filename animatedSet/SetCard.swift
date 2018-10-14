//
//  SetCard.swift
//  animatedSet
//
//  Created by Anti on 10/14/18.
//  Copyright © 2018 Anti. All rights reserved.
//

import Foundation
import UIKit

struct SetCard
{
    var number: Number
    var symbol: Symbol
    var shading: Shading
    var color: Color
    
    var isFaceUp = false
    var isSelected = false
    var isMatched = false
    
    enum Number: Int {
        case one = 1
        case two = 2
        case three = 3
        
        static var all = [Number.one,.two,.three]
        
        var description: Int { return rawValue }
    }
    
    enum Symbol {
        case one
        case two
        case three
        
        var result: String {
            switch self {
            case .one: return "▲"
            case .two: return "●"
            case .three: return "■"
            }
        }
        
        var match: Int {
            switch self {
            case .one: return 1
            case .two: return 2
            case .three: return 3
            }
        }
        
        static var all = [Symbol.one,.two,.three]
    }
    
    enum Shading {
        // filled in, hollow, striped
        case one
        case two
        case three
        
        var result: Int {
            switch self {
            case .one: return 1
            case .two: return 2
            case .three: return 3
            }
        }
        
        var match: Int {
            switch self {
            case .one: return 1
            case .two: return 2
            case .three: return 3
            }
        }
        
        static var all = [Shading.one,.two,.three]
    }
    
    enum Color {
        case one
        case two
        case three
        
        var result:  UIColor {
            switch self {
            case .one: return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            case .two: return #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            case .three: return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            }
        }
        
        var match: Int {
            switch self {
            case .one: return 1
            case .two: return 2
            case .three: return 3
            }
        }
        
        
        
        static var all = [Color.one,.two,.three]
    }
}

