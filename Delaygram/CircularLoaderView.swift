//
//  CircularLoaderView.swift
//  Delaygram
//
//  Created by nicholaslee on 20/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit

class CircularLoaderView: UIView {

    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat = 20.0
    
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        configure()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 2
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIColor.blue.cgColor
        layer.addSublayer(circlePathLayer)
        backgroundColor = UIColor.white
        
    
    }
    
    func circleInFrame() -> CGRect{
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        circleFrame.origin.x = circlePathLayer.bounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathLayer.bounds.midY - circleFrame.midY
    
        return circleFrame
        
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleInFrame())
    }
    
   
    
    
    
    
}
