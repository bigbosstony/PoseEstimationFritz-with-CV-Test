//
//  Data.swift
//  PoseEstimationFr
//
//  Created by YAN YU on 2019-07-22.
//  Copyright © 2019 YAN YU. All rights reserved.
//

import Foundation

struct Data: Codable {
    let dataArray: [Double]
}


struct ResultData: Decodable {
    let classification: String
    let counting: Int
}
