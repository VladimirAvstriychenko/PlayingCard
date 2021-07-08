//
//  MulitipleCardsViewController.swift
//  PlayingCard
//
//  Created by Владимир on 13.08.2020.
//  Copyright © 2020 VladCorp. All rights reserved.
//

import UIKit
import CoreMotion

class MulitipleCardsViewController: UIViewController {

    private var deck = PlayingCardDeck()
    
    @IBOutlet var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter{$0.isFaceUp && !$0.isHidden}
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2 &&
            faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1) / 2){
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews{
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4Random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
//            collisionBehavior.addItem(cardView)
//            itemBehavior.addItem(cardView)
            cardBehavior.addItem(cardView)
           
            
        }
        
    }
    
    
    
    @objc func flipCard(_ recognizer:UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(with: chosenCardView,
                                  duration: 0.6,
                                  options: [.transitionFlipFromLeft],
                                  animations: {chosenCardView.isFaceUp = !chosenCardView.isFaceUp},
                                  completion: {finished in
                                    if self.faceUpCardViewsMatch {
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 0.6,
                                            delay: 0,
                                            options: [],
                                            animations: {
                                                self.faceUpCardViews.forEach{
                                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                                }
                                        },
                                            completion: {position in
                                                //
                                                UIViewPropertyAnimator.runningPropertyAnimator(
                                                    withDuration: 0.75,
                                                    delay: 0,
                                                    options: [],
                                                    animations: {
                                                        self.faceUpCardViews.forEach{
                                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                            $0.alpha = 0
                                                        }
                                                },
                                                    completion: {position in
                                                        self.faceUpCardViews.forEach{
                                                            $0.isHidden = true
                                                            $0.alpha = 1
                                                            $0.transform = .identity
                                                        }
                                                }
                                                )
                                                
                                        }
                                            //
                                        )
                                    } else {
                                        if self.faceUpCardViews.count == 2 {
                                            self.faceUpCardViews.forEach { cardView in
                                                UIView.transition(with: cardView,
                                                                  duration: 0.6,
                                                                  options: [.transitionFlipFromLeft],
                                                                  animations: {cardView.isFaceUp = false},
                                                                  completion: { finished in
                                                                    self.cardBehavior.addItem(cardView)
                                                }
                                                )
                                            }
                                        } else {
                                            if !chosenCardView.isFaceUp {
                                                self.cardBehavior.addItem(chosenCardView)
                                            }
                                            
                                        }
                                    }
                }
                )
            }
        default:
            break
        }
    }
    
    //MARK: -Gravity
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CMMotionManager.shared.isAccelerometerAvailable {
            cardBehavior.gravityBehavior.magnitude = 1.0
            CMMotionManager.shared.accelerometerUpdateInterval = 1/10
            CMMotionManager.shared.startAccelerometerUpdates(to: .main) { (data, error) in
                if var x = data?.acceleration.x, var y = data?.acceleration.y {
                    switch UIDevice.current.orientation {
                        case .portrait: y *= -1
                        case .portraitUpsideDown: break
                        case .landscapeRight: swap(&x, &y)
                        case .landscapeLeft: swap(&x, &y); y *= -1
                        default: x = 0; y = 0
                    }
                    self.cardBehavior.gravityBehavior.gravityDirection = CGVector(dx: x, dy: y)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cardBehavior.gravityBehavior.magnitude = 0
        CMMotionManager.shared.stopAccelerometerUpdates()
    }
    
}

extension CGFloat {
    var arc4Random: CGFloat {
        switch self {
        case 1...2: return CGFloat(arc4random_uniform(UInt32(self)))
        case -2..<0: return -CGFloat(arc4random_uniform(UInt32(abs(self))))
            default: return 0
        }
    }
}
