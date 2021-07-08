//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by Владимир on 16.08.2020.
//  Copyright © 2020 VladCorp. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {

    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
        addChildBehavior(gravityBehavior)
    }
    
    convenience init(in animator:UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        //animator.addBehavior(behavior)
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1.0
        behavior.resistance = 0
        //animator.addBehavior(behavior)
        return behavior
    }()
    
    private func push (_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        //push.angle = (2*CGFloat.pi).arc4Random
        //Выбираем угол, чтобы карты толкались в центр
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi / 2).arc4Random
            case let (x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi - (CGFloat.pi / 2).arc4Random
            case let (x, y) where x < center.x && y > center.y:
                push.angle = (-CGFloat.pi / 2).arc4Random
            case let (x, y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi + (CGFloat.pi / 2).arc4Random
            default:
                push.angle = (CGFloat.pi * 2).arc4Random
            }
        }
        push.magnitude = CGFloat (1.0) + CGFloat(2.0).arc4Random
        push.action = { [unowned push, weak self] in
            //push.dynamicAnimator?.removeBehavior(push)
            self?.removeChildBehavior(push)
        }
        //animator.addBehavior(push)
        addChildBehavior(push)
    }
    
    func addItem(_ item:UIDynamicItem){
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        gravityBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item:UIDynamicItem){
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
        gravityBehavior.removeItem(item)
    }
    
    //MARK: -Gravity
    
    var gravityBehavior: UIGravityBehavior = {
        let behavior = UIGravityBehavior()
        behavior.magnitude = 0
        return behavior
    }()
}
