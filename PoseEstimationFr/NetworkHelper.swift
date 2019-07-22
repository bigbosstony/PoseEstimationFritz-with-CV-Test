//
//  NetworkHelper.swift
//  PoseEstimationFr
//
//  Created by YAN YU on 2019-07-22.
//  Copyright © 2019 YAN YU. All rights reserved.
//

import Foundation

class NetworkHelper: NSObject {
    func internetRequest(send data: [Double], to serverURL: URL, with method: String, completion: @escaping (ResultData) -> ()) {
        let pointsArray = Data(dataArray: data)
        
        var request = URLRequest(url: serverURL)
        let session = URLSession(configuration: .default)
        
        //Encode
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try jsonEncoder.encode(pointsArray)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.httpMethod = method
        } catch { print(error) }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let responseData = data else { return }
            
            do {
                let resultData = try JSONDecoder().decode(ResultData.self, from: responseData)
                completion(resultData)
            } catch let error { print(error) }
        }
        task.resume()
    }
}
