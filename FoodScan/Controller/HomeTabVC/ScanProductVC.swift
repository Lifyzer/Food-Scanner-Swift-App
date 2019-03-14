//
//  ViewController.swift
//  Text Detection Starter Project
//
//  Created by Sai Kambampati on 6/21/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import TesseractOCR

//import TesseractOCR


class ScanProductVC: UIViewController {
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    private var textDetectionRequest: VNDetectTextRectanglesRequest?
    private var textObservations = [VNTextObservation]()
    private var tesseract = G8Tesseract(language: "eng", engineMode:.tesseractOnly)
    private var font = CTFontCreateWithName("ArialMT" as CFString, 17, nil)
    
    var recognizedTextPositionTuples = [(rect: CGRect, text: String)]()
    
    let operationQueue = OperationQueue()
    var imageLayer : AVCaptureVideoPreviewLayer?
    
    var activityIndicator = UIActivityIndicatorView()
    
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    var req = [VNDetectTextRectanglesRequest] ()
    
    var arrLayer : [CALayer] = [CALayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tesseract?.pageSegmentationMode = .sparseText
        // Recognize only these characters
        tesseract?.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890()-+*!/?.,@#$%&"
        
        if isAuthorized()
        {
            configureCamera()
            startTextDetection()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
    }
    
    private func isAuthorized() -> Bool {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                          completionHandler: { (granted:Bool) -> Void in
                                            if granted {
                                                DispatchQueue.main.async {
                                                    self.configureCamera()
                                                    self.startTextDetection()
                                                }
                                            }
            })
            return true
        case .authorized:
            return true
        case .denied, .restricted: return false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //    override func viewDidLayoutSubviews() {
    //        imageView.layer.sublayers?[0].frame = imageView.bounds
    //    }
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if touches.first != nil
//        {
//            let point:CGPoint = (touches.first as AnyObject).location(in: cameraView)
//            let vw = cameraView.hitTest(point, with: nil)
//            if vw != nil
//            {
//                if vw!.isKind(of: CATextLayer.classForCoder())
//                {
//                    print((vw as! CATextLayer).string)
//                }
//            }
//        }
//    }
    private var cameraView1: CameraView {
        return cameraView as! CameraView
    }
    @objc func tapHandle(_ gesture  :UITapGestureRecognizer)
    {
        if gesture.view!.isKind(of: UILabel.classForCoder())
        {
            session.stopRunning()
            let txt = (gesture.view as! UILabel).text!
            generateAlertWithOkButton(text: txt)
        
        }
    }
    private func configureCamera() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(_:)))
//        tap.numberOfTapsRequired = 1
//        self.cameraView.addGestureRecognizer(tap)
//
        cameraView1.session = session
        
        let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        var cameraDevice: AVCaptureDevice?
        for device in cameraDevices.devices {
            if device.position == .back {
                cameraDevice = device
                break
            }
        }
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
            if session.canAddInput(captureDeviceInput) {
                session.addInput(captureDeviceInput)
            }
        }
        catch {
            print("Error occured \(error)")
            return                  
        }
        session.sessionPreset = .high
        let videoDataOutput = AVCaptureVideoDataOutput()
//        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos:.userInitiated, attributes: .concurrent, autoreleaseFrequency:.inherit, target: nil))
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        cameraView1.videoPreviewLayer.videoGravity = .resize
        session.startRunning()
    }
    
    func startTextDetection() {
        textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: detectTextHandler)
        textDetectionRequest?.reportCharacterBoxes = true
    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let detectionResults = request.results else {
            print("No detection results")
            return
        }
        let textResults = detectionResults.map() {
            return $0 as? VNTextObservation
        }
        if textResults.isEmpty {
            return
        }
        textObservations = textResults as! [VNTextObservation]
        DispatchQueue.main.async {
            
//            guard let sublayers = self.view.layer.sublayers else {
//                return
//            }
//            for layer in sublayers[1...] {
//                if (layer as? CATextLayer) == nil {
//                    layer.removeFromSuperlayer()
//                }
//            }
//            let viewWidth = self.view.frame.size.width
//            let viewHeight = self.view.frame.size.height
//            for result in textResults {
            
//                if let textResult = result {
//
//                    let layer = CALayer()
//                    var rect = textResult.boundingBox
//                    rect.origin.x *= viewWidth
//                    rect.size.height *= viewHeight
//                    rect.origin.y = ((1 - rect.origin.y) * viewHeight) - rect.size.height
//                    rect.size.width *= viewWidth
//
//                    layer.frame = rect
//                    layer.borderWidth = 2
//                    layer.borderColor = UIColor.red.cgColor
//                    self.view.layer.addSublayer(layer)
//                }
//            }
        }
    }
    
    func highlightWord(box: VNTextObservation) {
        
        guard let boxes = box.characterBoxes else {
            return
        }
        
        var maxX: CGFloat = 9999.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 9999.0
        var minY: CGFloat = 0.0
        
       
        
        for char in boxes {
            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
        }
        
        let xCord = maxX * imageView.frame.size.width
        let yCord = (1 - minY) * imageView.frame.size.height
        let width = (minX - maxX) * imageView.frame.size.width
        let height = (minY - maxY) * imageView.frame.size.height
        
        //        let outline = CALayer()
        //        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        //        outline.borderWidth = 2.0
        //        outline.borderColor = UIColor.red.cgColor
        //
        
        let txt = UIView()
        txt.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        txt.borderWidth = 2.0
        txt.borderColor = UIColor.white
        txt.backgroundColor = UIColor.clear
        imageView.addSubview(txt)
        //        imageView.layer.addSublayer(outline)
    }
    
    func highlightLetters(box: VNRectangleObservation) {
        let xCord = box.topLeft.x * imageView.frame.size.width
        let yCord = (1 - box.topLeft.y) * imageView.frame.size.height
        let width = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.blue.cgColor
        
        imageView.layer.addSublayer(outline)
    }
}


extension ScanProductVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var imageRequestOptions = [VNImageOption: Any]()
        if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            imageRequestOptions[.cameraIntrinsics] = cameraData
        }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: imageRequestOptions)
        do {
            try imageRequestHandler.perform([self.textDetectionRequest!])
        }
        catch {
            print("Error occured \(error)")
        }
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.transformed(by: transform)
        let size = ciImage.extent.size
        var recognizedTextPositionTuples = [(rect: CGRect, text: String)]()
            for textObservation in self.textObservations {
            guard let rects = textObservation.characterBoxes else {
                continue
            }
            var xMin = CGFloat.greatestFiniteMagnitude
            var xMax: CGFloat = 0
            var yMin = CGFloat.greatestFiniteMagnitude
            var yMax: CGFloat = 0
            for rect in rects {
                
                xMin = min(xMin, rect.bottomLeft.x)
                xMax = max(xMax, rect.bottomRight.x)
                yMin = min(yMin, rect.bottomRight.y)
                yMax = max(yMax, rect.topRight.y)
            }
            let imageRect = CGRect(x: xMin * size.width, y: yMin * size.height, width: (xMax - xMin) * size.width, height: (yMax - yMin) * size.height)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
                continue
            }
            let uiImage = UIImage(cgImage: cgImage)
                self.tesseract?.image = uiImage
                self.tesseract?.recognize()
                guard var text = self.tesseract?.recognizedText else {
                continue
            }
            text = text.trimmingCharacters(in: CharacterSet.newlines)
            if !text.isEmpty {
                let x = xMin
                let y = 1 - yMax
                let width = xMax - xMin
                let height = yMax - yMin
                recognizedTextPositionTuples.append((rect: CGRect(x: x, y: y, width: width, height: height), text: text))
            }
        }
            self.textObservations.removeAll()
        
            let viewWidth = self.cameraView.frame.size.width
            let viewHeight = self.cameraView.frame.size.height
            
            let subviews = self.cameraView.subviews
            if subviews.count > 1
            {
                for i in subviews
                {
                    if i != self.cameraView
                    {
                        i.removeFromSuperview()
                    }
                }
            }
            
//            guard let sublayers = self.cameraView.layer.sublayers else {
//                return
//            }
//            for layer in sublayers[1...] {
//
//                if let _ = layer as? CATextLayer {
//                    layer.removeFromSuperlayer()
//                }
//            }
            
            for tuple in recognizedTextPositionTuples {
                var rect = tuple.rect
                
                rect.origin.x *= viewWidth
                rect.size.width *= viewWidth
                rect.origin.y *= viewHeight
                rect.size.height *= viewHeight
                
                // Increase the size of text layer to show text of large lengths
                rect.size.width += 100
                rect.size.height += 20
                
                var labl = UILabel()
                labl.frame = rect
                labl.textColor = UIColor.white
                labl.text = tuple.text
                labl.isUserInteractionEnabled = true
                labl.layer.borderColor = UIColor.white.cgColor
                labl.layer.borderWidth = 2.0
                labl.font = UIFont(name: "arial", size: 17.0)
     
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandle(_:)))
                tap.numberOfTapsRequired = 1
                labl.addGestureRecognizer(tap)

                self.cameraView.addSubview(labl)

            }
        }
    }

}

extension UIView {
    
    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
// MARK: - UIImage extension
extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}