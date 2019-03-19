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
import SwiftyJSON


class ScanProductVC: UIViewController {
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var btnBarcode: UIButton!
    
    private var textDetectionRequest: VNDetectTextRectanglesRequest?
    private var textObservations = [VNTextObservation]()
    private var tesseract = G8Tesseract(language: "eng", engineMode:.tesseractOnly)
//    private var font = CTFontCreateWithName("ArialMT" as CFString, 17, nil)
    
    var recognizedTextPositionTuples = [(rect: CGRect, text: String)]()
    var session = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    let metadataOutput = AVCaptureMetadataOutput()
    var flag = 0
    var scanOptions = -1
   var productCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanOptions = 0
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view, typically from a nib.
        tesseract?.pageSegmentationMode = .auto
        // Recognize only these characters
        tesseract?.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890()-+*!/?.,@#$%&"
//        flag = 0
        scanOptions = 0
        if isAuthorized()
        {
                if session.outputs.contains(metadataOutput)
                {
                    session.removeOutput(metadataOutput)
                }
                startTextDetection()
            
            configureCamera()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if (session.isRunning == true) {
            session.stopRunning()
        }
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
    
    @IBAction func btnScanOptionActions(_ sender: UIButton) {
        scanOptions = sender.tag
        if scanOptions == 0
        {
            if session.outputs.contains(metadataOutput)
            {
                session.removeOutput(metadataOutput)
            }
            startTextDetection()
        }
        else
        {
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
            if session.outputs.contains(videoDataOutput)
            {
                session.removeOutput(videoDataOutput)
            }
        }
        configureCamera()
        print(scanOptions)
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
    
    @objc func btnAction(_ sender : UIButton)
    {
        print(sender.currentTitle)
    }
    @objc func tapHandle(_ gesture  :UITapGestureRecognizer)
    {
        if gesture.view!.isKind(of: UILabel.classForCoder())
        {
            let txt = (gesture.view as! UILabel).text!
            if txt != ""
            {
                flag = 1
                session.stopRunning()
                let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idViewProductPopUpVC) as! ViewProductPopUpVC
                vc.productName = txt
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.tabBarController?.present(vc, animated: false, completion: nil)
            }
        }
      
    }
    private func configureCamera() {

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
        
        if scanOptions == 0
        {
            
            //        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
            
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)//(self, queue: DispatchQueue(label: "Buffer Queue", qos:.userInitiated, attributes: .concurrent, autoreleaseFrequency:.inherit, target: nil))
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
            }
        }
        else if scanOptions == 1
        {
            
            
            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
            }
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
    }
}



//MARK: Scan Flag delegate
extension ScanProductVC: SelectTextDelegate
{
    func scanFlag(flag: Int) {
        session.startRunning()
        self.flag = flag
    }
}
//MARK: AVCaptureMetadataOutputObjectsDelegate
extension ScanProductVC: AVCaptureMetadataOutputObjectsDelegate{
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if self.flag == 0 && self.scanOptions == 1
        {
            self.session.stopRunning()
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                print(stringValue)
                self.productCode = stringValue
                self.productCode = "00449458"
                GetProductDetailsAPI()
                //                found(code: stringValue)
            }
        }
    }
}

//MARK: AVCaptureVideoDataOutputSampleBufferDelegate
extension ScanProductVC: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
           
        if self.flag == 0 && self.scanOptions == 0
        {
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
                for tuple in recognizedTextPositionTuples {
                    var rect = tuple.rect
                    rect.origin.x *= viewWidth
                    rect.size.width *= viewWidth
                    rect.origin.y *= viewHeight
                    rect.size.height *= viewHeight
                    
                    // Increase the size of text layer to show text of large lengths
                    rect.size.width += 100
                    rect.size.height += 30
                    
                    let labl = UILabel()
                    labl.frame = rect
                    labl.textColor = UIColor.white
                    labl.text = tuple.text
                    labl.isUserInteractionEnabled = true
                    labl.layer.borderColor = UIColor.white.cgColor
                    labl.layer.borderWidth = 2.0
                    labl.backgroundColor = UIColor.clear
                    labl.font = UIFont(name: "arial", size: 16.0)
                   
                    self.cameraView.addSubview(labl)
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandle(_:)))
                    tap.numberOfTapsRequired = 1
                    labl.addGestureRecognizer(tap)
                    
                }
            }
        }
    }

}
extension ScanProductVC
{
    func GetProductDetailsAPI()
    {
        
        let userToken = UserDefaults.standard.string(forKey: kTempToken)
        let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
        //        DEFAULT_ACCESS_KEY = encodeString
        let param:NSMutableDictionary = [
            WS_KProduct_name:productCode,
            WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
        //            WS_KAccess_key:DEFAULT_ACCESS_KEY,
        //            WS_KSecret_key:userToken ?? ""]
        
        includeSecurityCredentials {(data) in
            let data1 = data as! [AnyHashable : Any]
            param.addEntries(from: data1)
        }
        
        showIndicator(view: self.view)
        
        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetProductDetails, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
            self.hideIndicator(view: self.view)
            if response != nil
            {
                let objData = JSON(response!)[WS_KProduct]
                let objProduct = objData.to(type: WSProduct.self) as! [WSProduct]
               
                    self.flag = 0
                    HomeTabVC.sharedHomeTabVC?.selectedIndex = 0
                    let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idFoodDetailVC) as! FoodDetailVC
                    vc.objProduct = objProduct[0]
                    HomeTabVC.sharedHomeTabVC?.navigationController?.pushViewController(vc, animated: true)
            
            }
            else
            {
                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
            }
        })
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
