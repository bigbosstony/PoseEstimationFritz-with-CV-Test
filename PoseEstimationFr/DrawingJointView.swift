//
//  PoseView.swift
//  PoseEstimation-CoreML
//
//  Created by GwakDoyoung on 15/07/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class DrawingJointView: UIView {
    
    // the count of array may be <#14#> when use PoseEstimationForMobile's model
    private var keypointLabelBGViews: [UIView] = []

    public var bodyPoints: [BodyPoint?] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            let size = self.bounds.size
            
            let color = Constant.jointLineColor.cgColor
            if Constant.pointLabels.count == bodyPoints.count {
                let _ = Constant.connectingPointIndexs.map { pIndex1, pIndex2 in
                    if let bp1 = self.bodyPoints[pIndex1], bp1.maxConfidence > 0.5,
                        let bp2 = self.bodyPoints[pIndex2], bp2.maxConfidence > 0.5 {
                        let p1 = bp1.maxPoint
                        let p2 = bp2.maxPoint
                        let point1 = CGPoint(x: p1.x * size.width, y: p1.y*size.height)
                        let point2 = CGPoint(x: p2.x * size.width, y: p2.y*size.height)
                        drawLine(ctx: ctx, from: point1, to: point2, color: color)
                    }
                }
            }
        }
    }
    
    private func drawLine(ctx: CGContext, from p1: CGPoint, to p2: CGPoint, color: CGColor) {
        ctx.setStrokeColor(color)
        ctx.setLineWidth(3.0)
        
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        
        ctx.strokePath();
    }
}

// MARK: - Constant for edvardHua/PoseEstimationForMobile
struct Constant {
    static let pointLabels = [
        "nose",             //0
        "left eye",         //1
        "right eye",        //2
        "left ear",         //3
        "right ear",        //4
        
        "left shoulder",    //5
        "right shoulder",   //6
        "left elbow",       //7
        "right elbow",      //8
        "left wrist",       //9
        "right wrist",      //10
        "left hip",         //11
        "right hip",        //12
        
        "left knee",        //13
        "right knee",       //14
        "left ankle",       //15
        "right ankle",      //16
    ]
    
    static let connectingPointIndexs: [(Int, Int)] = [
        (3, 1),     // left ear-left eye
        (4, 2),     // right ear-right eye
        (0, 5),     // nose-left shoulder
        (0, 6),     // nose-right shoulder
        
        (6, 8),     // rshoulder-relbow
        (8, 10),     // relbow-rwrist
        (5, 7),     // left shoulder-left elbow
        (7, 9),     // left elbow-left wrist
        (5, 6),     // left shoulder-right shoulder
        (5, 11),    // left shoulder-left hip
        (6, 12),    // right shoulder-right hip
        (11, 12),   // left hip-right-hip
        
        (11, 13),   // left hip-left knee
        (13, 15),   // left knee-left left ankle
        (12, 14),   // right hip-right knee
        (14, 16),   // right knee-right ankle
    ]
    
    static let jointLineColor: UIColor = UIColor(displayP3Red: 87.0/255.0,
                                                 green: 255.0/255.0,
                                                 blue: 211.0/255.0,
                                                 alpha: 0.5)
    
    static let colors: [UIColor] = [
        .red,
        .green,
        .blue,
        .cyan,
        .yellow,
        .magenta,
        .orange,
        .purple,
        .brown,
        .black,
        .darkGray,
        .lightGray,
        .white,
        .gray,
        ]
}
