//
//  ViewController.swift
//  InteractiveBurger
//
//  Created by Saoud Rizwan on 12/16/16.
//  Copyright © 2016 Saoud Rizwan. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    // MARK: - Constants
    
    let lineHeight = 5.0
    let containerHeight = 120.0
    let containerWidth = 150.0
    
    let startPoint = 50.0 // how far user must pan to register as a swipe
    let swipeLength = 200.0 // how far a user must pan to complete animation, after passing startPoint
    
    // MARK: - Views
    
    // Container View : holds the three lines, acts as a super view in terms of constraints
    
    lazy var containerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.clear
        // view.layer.borderWidth = 1.0
        // view.layer.borderColor = UIColor.red.cgColor
        
        return view
    }()
    
    // Three lines in burger are each views whose constraints will be manipulated
    
    lazy var firstLine: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = CGFloat(self.lineHeight / 2)
        
        return view
    }()
    
    lazy var secondLine: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = CGFloat(self.lineHeight / 2)
        
        return view
    }()
    
    lazy var thirdLine: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = CGFloat(self.lineHeight / 2)
        
        return view
    }()
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        // add a UIPanGestureRecognizer to the view
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.view.addGestureRecognizer(panRecognizer)
        self.view.isUserInteractionEnabled = true
        
        // add the containerView to self.view and set its constraints
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.height.equalTo(containerHeight)
            make.width.equalTo(containerWidth)
            make.center.equalTo(self.view.snp.center)
        }
        
        // add the three lines to the containerView and set their constraints in respect to the containerView
        containerView.addSubview(firstLine)
        firstLine.snp.makeConstraints { (make) in
            make.height.equalTo(lineHeight)
            make.width.equalTo(containerView.snp.width)
            make.centerX.equalTo(containerView.snp.centerX)
            make.centerY.equalTo(0 + lineHeight/2)
        }
        
        containerView.addSubview(secondLine)
        secondLine.snp.makeConstraints { (make) in
            make.height.equalTo(lineHeight)
            make.width.equalTo(containerView.snp.width)
            make.centerX.equalTo(containerView.snp.centerX)
            make.centerY.equalTo(containerHeight/2)
        }
        
        containerView.addSubview(thirdLine)
        thirdLine.snp.makeConstraints { (make) in
            make.height.equalTo(lineHeight)
            make.width.equalTo(containerView.snp.width)
            make.centerX.equalTo(containerView.snp.centerX)
            make.centerY.equalTo(containerHeight - lineHeight/2)
        }
        
    }
    
    // MARK: - Animation Variables
    
    var linesConvergingAnimation: UIViewPropertyAnimator!
    
    var XDivergingAnimation: UIViewPropertyAnimator!
    
    var linesAreX = false
    
    // MARK: - UIPanGestureRecognizer
    
    func didPan(sender:UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view) // amount user pans
        let verticalPan = abs(Double(translation.y)) // absolute value of vertical pan
        let percentageComplete = CGFloat((verticalPan - startPoint) / swipeLength) // convert the amount of "swipe" to a percentage
        
        switch sender.state {
        case .began:
            // user begins panning after touching screen
            
            if !linesAreX { // lines are not 'X'
                
                // Lines Converging Animation Into One Line
                
                // changed 'curve: UIViewAnimationCurve.linear' to 'dampingRatio: 0.3' but it results in a buggy animation
                /*
                 Theoretically, the only way to get "springiness" in a reversed animation is to not use a reversed animation,
                 but to simply finish the current animation, create a new UIVPA that animates from the current positiong to the previous
                 animation's start position with a dampingRation instead of linear curve, finishing the new UIVPA, and instantiating the
                 old UIVPA back into existence. .isReversed is like playing a movie backwards.
                 */
                linesConvergingAnimation = UIViewPropertyAnimator(duration: 0.2, curve: UIViewAnimationCurve.linear, animations: {
                    
                    // update constraints
                    self.firstLine.snp.remakeConstraints({ (make) in
                        make.height.equalTo(self.lineHeight)
                        make.width.equalTo(self.containerView.snp.width)
                        make.centerX.equalTo(self.containerView.snp.centerX)
                        make.centerY.equalTo(self.containerView.snp.centerY)
                    })
                    
                    self.thirdLine.snp.remakeConstraints({ (make) in
                        make.height.equalTo(self.lineHeight)
                        make.width.equalTo(self.containerView.snp.width)
                        make.centerX.equalTo(self.containerView.snp.centerX)
                        make.centerY.equalTo(self.containerView.snp.centerY)
                    })
                    
                    self.view.layoutIfNeeded()
                    
                })
                
            } else { // lines are 'X'
                
                // X Diverging Into Three Lines Animation
                
                XDivergingAnimation = UIViewPropertyAnimator(duration: 0.2, curve: UIViewAnimationCurve.linear, animations: {
                    // make lines in 'X' form one line
                    self.firstLine.transform = CGAffineTransform(rotationAngle: 0.0)
                    self.thirdLine.transform = CGAffineTransform(rotationAngle: 0.0)
                })
                
            }
            
        case .changed:
            // user is panning
            
            if verticalPan >= startPoint { // if past start point
                
                // print(percentageComplete)
                
                if linesAreX {
                    XDivergingAnimation.fractionComplete = percentageComplete
                } else {
                    linesConvergingAnimation.fractionComplete = percentageComplete
                }
                
            }
            
        case .ended, .cancelled:
            // panning ended
            
            if Double(percentageComplete) > 1.0 { // check if animation is 100% complete to animate into X
                
                if linesAreX {
                    
                    // Finish diverging animation
                    XDivergingAnimation.startAnimation()
                    // FYI, after an animation ends, .finishAnimation() is internally called, and this calls the completion block
                    
                    // When animation completes, un-hide the second line and form three lines burger menu
                    
                    XDivergingAnimation.addCompletion({ (position) in
                        
                        // NOTE: if an animation is reversed, then the completion block's UIViewAnimatingPosition would be .start
                        
                        if position == .end {
                            
                            self.secondLine.isHidden = false
                            
                            // make sure view is not interactive otherwise app will crash since you're trying to start an animation too soon, creates reference to animation that doesn't exist?
                            self.view.isUserInteractionEnabled = false
                            
                            // NOTE: use [unowned self] when you don't want a reference to the view in the closure, otherwise you risk creating a strong reference cycle
                            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: { [unowned self] in
                                
                                // reset constraints back to normal
                                
                                self.firstLine.snp.remakeConstraints({ (make) in
                                    make.height.equalTo(self.lineHeight)
                                    make.width.equalTo(self.containerView.snp.width)
                                    make.centerX.equalTo(self.containerView.snp.centerX)
                                    make.centerY.equalTo(0 + self.lineHeight/2)
                                })
                                
                                self.thirdLine.snp.remakeConstraints({ (make) in
                                    make.height.equalTo(self.lineHeight)
                                    make.width.equalTo(self.containerView.snp.width)
                                    make.centerX.equalTo(self.containerView.snp.centerX)
                                    make.centerY.equalTo(self.containerHeight - self.lineHeight/2)
                                })
                                
                                self.view.layoutIfNeeded()
                                
                                }, completion: { [unowned self] (_) in
                                    // Lines are back to normal 🍔
                                    self.linesAreX = false
                                    // make view interactive again
                                    self.view.isUserInteractionEnabled = true
                            })
                        }
                    })
                    
                } else { // lines are 🍔 and not 'X'
                    
                    // Finish completing converging animation
                    linesConvergingAnimation.startAnimation()
                    
                    // When animation completes, call the springy X animation
                    linesConvergingAnimation.addCompletion({ (position) in
                        // position is .start, .current, or .end
                        if position == .end {
                            
                            // You could use another UIViewPropertyAnimator, but sometimes it's just easier to use .animate()
                            /*
                             self.secondLine.isHidden = true
                             
                             self.snappingToX = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.5, animations: {
                             //
                             self.view.isUserInteractionEnabled = false
                             
                             self.firstLine.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
                             self.thirdLine.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_4))
                             })
                             
                             self.snappingToX.startAnimation()
                             
                             self.snappingToX.addCompletion({ (position) in
                             self.linesAreX = true
                             
                             self.view.isUserInteractionEnabled = true
                             })
                             */
                            
                            // Hide second (middle) line
                            self.secondLine.isHidden = true
                            
                            // make sure view is not interactive otherwise app will crash since you're trying to start an animation too soon, creates reference to animation that doesn't exist?
                            self.view.isUserInteractionEnabled = false
                            
                            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: { [unowned self] in
                                
                                self.firstLine.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4)) // rotate first line pi/4 radians (45 degrees)
                                self.thirdLine.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_4)) // rotate third line -(pi/4) radians
                                
                                }, completion: { [unowned self] (_) in
                                    // Lines are now an 'X'
                                    self.linesAreX = true
                                    
                                    self.view.isUserInteractionEnabled = true
                            })
                            
                        }
                    })
                }
                
            } else if Double(percentageComplete) > 0.0 { // user didn't pan enough to complete UIVPA animation, reset back to normal
                if linesAreX {
                    
                    // Reset back to 'X'
                    
                    // .isReversed simply reverses the animation declared in the UIViewPropertyAnimator, almost like a movie being played backwards
                    XDivergingAnimation.isReversed = true
                    
                    // Finish reversed diverging animation
                    XDivergingAnimation.startAnimation()
                    
                    XDivergingAnimation.addCompletion({ (position) in
                        if position == .start {
                            print("finished reversed animation, back at start pos")
                            self.linesAreX = true // not necessary
                        }
                    })
                    
                    
                } else { // !linesAreX
                    
                    // Reset back to 🍔
                    
                    linesConvergingAnimation.isReversed = true
                    
                    // Finish reversed converging animation
                    linesConvergingAnimation.startAnimation()
                    
                    // When animation completes, reset constraints
                    linesConvergingAnimation.addCompletion({ (position) in
                        if position == .start {
                            
                            print("finished reversed convergence animation, back at start pos")
                            self.linesAreX = false
                            
                            /*
                             ⚠️ The code below took me a while to figure out:
                             Basically when a UIViewPropertyAnimator reverses an animation that sets/remakes constraints, it doesn't properly set those new constraints back to "normal"
                             you have to manually (without animating .layoutIfNeeded()) set the constraints back to normal in the reverse animation's completion block to tell
                             the internal system what "normal" is
                             */
                            
                            // reset constraints back to normal
                            
                            self.firstLine.snp.remakeConstraints({ (make) in
                                make.height.equalTo(self.lineHeight)
                                make.width.equalTo(self.containerView.snp.width)
                                make.centerX.equalTo(self.containerView.snp.centerX)
                                make.centerY.equalTo(0 + self.lineHeight/2)
                            })
                            
                            self.thirdLine.snp.remakeConstraints({ (make) in
                                make.height.equalTo(self.lineHeight)
                                make.width.equalTo(self.containerView.snp.width)
                                make.centerX.equalTo(self.containerView.snp.centerX)
                                make.centerY.equalTo(self.containerHeight - self.lineHeight/2)
                            })
                        }
                    })
                }
                
            } else { // Double(percentageComplete) < 0.0
                // user didnt swipe long enough
            }
        default:
            break
        }
        
    }
}


