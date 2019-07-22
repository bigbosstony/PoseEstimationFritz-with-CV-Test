//
//  ViewController.swift
//  PoseEstimationFr
//
//  Created by YAN YU on 2019-05-22.
//  Copyright © 2019 YAN YU. All rights reserved.

import UIKit
import Photos
import Fritz

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    //outlets
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var jointView: DrawingJointView!
    
    @IBOutlet var fpsLabel: UILabel!
    
    //fps
    var frames = 0
    var timer = Timer()
    
    //data
    var dataArray = [Double]()
    
    //url
    let serverURL = URL(string: "http://172.16.0.225:5055")
    
    // model
    lazy var poseModel = FritzVisionPoseModel()
    // smooth
    lazy var poseSmoother = PoseSmoother<OneEuroPointFilter>(minCutoff: 1.0, beta: 0.0, derivateCutoff: 1.0)
    
    let networkHelper = NetworkHelper()
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        
        guard
            let backCamera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }
        session.addInput(input)
        
        // The style transfer takes a 640x480 image as input and outputs an image of the same size.
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add preview View as a subview
        previewView.contentMode = .scaleAspectFit
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait

        let bounds = view.bounds.inset(by: view.safeAreaInsets)
        print(bounds)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateFPSLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateFPSLabel() {
        fpsLabel.text = "FPS: " + String(frames)
        frames = 0
    }
    
    func updateExerciseLabel(from data: ResultData) {
        navigationItem.title = String("\(data.classification) \(data.counting)")
    }
    
    func displayInputImage(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let image = UIImage(pixelBuffer: pixelBuffer)
        DispatchQueue.main.async {
            self.previewView.image = image
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let fritzImage = FritzVisionImage(buffer: sampleBuffer)
        //
        let options = FritzVisionPoseModelOptions()
        options.minPoseThreshold = 0.1
        options.minPartThreshold = 0.1
        options.nmsRadius = 50
        
        guard let result = try? poseModel.predict(fritzImage, options: options) else {
            // If there was no pose, display original image
            displayInputImage(sampleBuffer)
            return
        }
        
        guard var pose = result.decodePose() else {
            displayInputImage(sampleBuffer)
            return
        }
        //
        frames += 1
        
        let _ = pose.keypoints.map { (keyPoint) -> () in
            self.dataArray.append(keyPoint.position.x)
            self.dataArray.append(keyPoint.position.y)
        }
        
        //clean points
        var cleanedDataArray = keepAnkleCleanSave(points: dataArray)
        dataArray[26] = cleanedDataArray[0]
        dataArray[28] = cleanedDataArray[1]
        dataArray[30] = cleanedDataArray[2]
        dataArray[32] = cleanedDataArray[3]
        //
        print(dataArray)
        
        // make call to server
        networkHelper.internetRequest(send: dataArray, to: serverURL!, with: "POST") { (resultData) in
            // get result
            DispatchQueue.main.async {
                self.updateExerciseLabel(from: resultData)
            }
            print(resultData.classification, resultData.counting)
        }

        //clear array
        dataArray = []
        
        // Uncomment to use pose smoothing to smoothe output of model.
        // Will increase lag of pose a bit.
        pose = poseSmoother.smoothe(pose)
        
        guard let poseResult = result.drawPose(pose) else {
            displayInputImage(sampleBuffer)
            return
        }
        
        DispatchQueue.main.async {
            self.previewView.image = poseResult
        }
    }
}




//Convert pose.keypoint to bodypoint
//        let bodyPoints = pose.keypoints.map { (keyPoint) -> BodyPoint in
//            let maxPoint = CGPoint(x: CGFloat(keyPoint.position.x) / 500, y: CGFloat(keyPoint.position.y) / 500)
//            let maxConfidence = keyPoint.score
//            // prepare data, 26 double array
//            if !exclusiveDataArray.contains(keyPoint.index) {
//                self.dataArray.append(keyPoint.position.x)
//                self.dataArray.append(keyPoint.position.y)
//            }
//            let bodyPoint: BodyPoint = BodyPoint(maxPoint: maxPoint, maxConfidence: maxConfidence)
//            return bodyPoint
//        }




//DispatchQueue.main.async {
//    //            self.displayInputImage(sampleBuffer)
//    self.previewView.image = poseResult
//    //            self.jointView.bodyPoints = bodyPoints
//}
