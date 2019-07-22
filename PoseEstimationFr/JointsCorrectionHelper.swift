//
//  JointsCorrectionHelper.swift
//  PoseEstimationFr
//
//  Created by YAN YU on 2019-07-22.
//  Copyright © 2019 YAN YU. All rights reserved.
//

import Foundation

//-------Supporting function
func keepAnkleCleanSave(points:[Double]) ->[Double]
{
    var NPoints:[Double] = points
    let leftHip:Double = NPoints[22]
    let rightHip:Double = NPoints[24]
    var leftKnee:Double = NPoints[26]
    var rightKnee:Double = NPoints[28]
    var leftAnkle:Double = NPoints[30]
    var rightAnkle:Double = NPoints[32]
    var tempLeftKneeX:Double = NPoints[32]
    var tempRightKneeX:Double = NPoints[32]
    var tempLeftAnkleX:Double = NPoints[32]
    var tempRightAnkleX:Double = NPoints[32]
    var minSep:Double = 0.3 * abs((leftHip - rightHip))
    if (leftHip > rightHip)
    {
        tempLeftKneeX = max(leftKnee,rightKnee)
        tempLeftKneeX = max(tempLeftKneeX,((leftKnee + rightKnee)/2) + minSep)
        tempRightKneeX = min(leftKnee, rightKnee)
        tempRightKneeX = min(tempRightKneeX,((leftKnee + rightKnee)/2) - minSep)
        tempLeftAnkleX = max(leftAnkle, rightAnkle)
        tempRightAnkleX = min(leftAnkle, rightAnkle)
    }
        
    else
    {
        tempLeftKneeX = min(leftKnee, rightKnee)
        tempLeftKneeX = min(tempLeftKneeX,((leftKnee + rightKnee)/2) - minSep)
        tempRightKneeX = max(leftKnee, rightKnee)
        tempRightKneeX = max(tempRightKneeX,((leftKnee + rightKnee)/2) + minSep)
        tempLeftAnkleX = min(leftAnkle, rightAnkle)
        tempRightAnkleX = max(leftAnkle, rightAnkle)
    }
    
    leftKnee = tempLeftKneeX
    rightKnee = tempRightKneeX
    leftAnkle = tempLeftAnkleX
    rightAnkle = tempRightAnkleX
    return [leftKnee,rightKnee,leftAnkle,rightAnkle]
}
