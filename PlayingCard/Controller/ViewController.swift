//
//  ViewController.swift
//  PlayingCard
//
//  Created by Владимир on 02.08.2020.
//  Copyright © 2020 VladCorp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 1...10 {
            if let card = deck.draw() {
                print("\(card)")
            }
        }
    }
    
    

}

