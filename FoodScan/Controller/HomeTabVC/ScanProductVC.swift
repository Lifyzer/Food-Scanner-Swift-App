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
//import TesseractOCR
import SwiftyJSON
import CoreMedia
import CoreImage
import Firebase


var selectedScanColor = UIColor(red: 68/255, green: 176/255, blue: 91/255, alpha: 1.0)//(red: 68/255, green: 176/255, blue: 91/255)
var IsScanWithLogin = false
var ScanParam = NSMutableDictionary()
var SCANNED_DETAILS = "scanned_product"

class ScanProductVC: UIViewController/*,G8TesseractDelegate*/ {
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var btnBarcode: UIButton!
    
    //    private var textDetectionRequest: VNDetectTextRectanglesRequest?
    //    private var textObservations = [VNTextObservation]()
    //    private var tesseract = G8Tesseract(language: "eng", engineMode:.tesseractCubeCombined)
    ////    private var font = CTFontCreateWithName("ArialMT" as CFString, 17, nil)
    
    var recognizedTextPositionTuples = [(rect: CGRect, text: String)]()
    var session = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    let metadataOutput = AVCaptureMetadataOutput()
    var flag = 0
    var scanOptions = -1
    var productCode = ""
    var param : NSMutableDictionary?
    var objUser: WSUser?
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    //MARK: - Text scanning
    lazy var vision = Vision.vision()
    lazy var textRecognizer = vision.onDeviceTextRecognizer()
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var drawingView: DrawingView!
    var videoCapture: VideoCapture!
    var isInference = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        scanOptions = 1
        //        scanOptions = 1
        //        self.videoPreview.isHidden = true
        //        self.drawingView.isHidden = true
        //        self.cameraView.isHidden = false
        //        btnBarcode.setTitleColor(selectedScanColor, for: .normal)
        //        btnProduct.setTitleColor(UIColor.white, for: .normal)
        //        let scanValue = GetScanOption()
        //        if scanValue != nil
        //        {
        //            scanOptions = scanValue!
        //        }
        //        else
        //        {
        //            scanOptions = 0
        //            SetScanOption(value: scanOptions)
        //        }
        //        if isAuthorized()
        //        {
        //            if session.outputs.contains(metadataOutput)
        //            {
        //                session.removeOutput(metadataOutput)
        //            }
        //            configureCamera()
        //        }
        //        self.setUpCamera()
        self.setUpCamera()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if IsScanWithLogin
        {
            IsScanWithLogin = false
            let scanValue = GetScanOption()
            scanOptions = scanValue!
            if UserDefaults.standard.bool(forKey: kLogIn) ==  true {
                ScanParam = UserDefaults.standard.getCustomObjFromUserDefaults(forKey: SCANNED_DETAILS) as! NSMutableDictionary
                self.param = ScanParam
                
                let user_id = UserDefaults.standard.string(forKey: kUserId) ?? ""
                
                includeSecurityCredentials {(data) in
                    let data1 = data as! [AnyHashable : Any]
                    self.param!.addEntries(from: data1)
                }
                self.param!.setValue(user_id, forKey: WS_KUser_id)
                GetProductDetailsAPI()
            }
        }
        else
        {
            let scanValue = GetScanOption()
            if scanValue != nil
            {
                scanOptions = scanValue!
            }
            else
            {
                scanOptions = 0
                SetScanOption(value: scanOptions)
            }
        }
        
        RefreshScan()
        
        //        if scanOptions == 1
        //        {
        //            if (session.isRunning == false) {
        //                session.startRunning()
        //            }
        //            self.videoPreview.isHidden = true
        //            self.drawingView.isHidden = true
        //            self.cameraView.isHidden = false
        //            btnBarcode.setTitleColor(selectedScanColor, for: .normal)
        //            btnProduct.setTitleColor(UIColor.white, for: .normal)
        //        }
        //        else
        //        {
        //            btnBarcode.setTitleColor(UIColor.white, for: .normal)
        //            btnProduct.setTitleColor(selectedScanColor, for: .normal)
        //            self.videoPreview.isHidden = false
        //            self.drawingView.isHidden = false
        //            self.cameraView.isHidden = true
        //            videoCapture.start()
        //        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        if scanOptions == 1
        {
            if (session.isRunning == true) {
                session.stopRunning()
            }
        }
        else
        {
            videoCapture.stop()
        }
    }
    
    func SetScanOption(value:Int) {
        UserDefaults.standard.set( value, forKey: KScanOption)
    }
    func GetScanOption() -> Int?{
        let scanValue = UserDefaults.standard.integer(forKey: KScanOption)
        return scanValue
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
                                                    //                        self.startTextDetection()
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
        if sender == btnBarcode
        {
            btnBarcode.setTitleColor(selectedScanColor, for: .normal)
            btnProduct.setTitleColor(UIColor.white, for: .normal)
        }
        else
        {
            btnBarcode.setTitleColor(UIColor.white, for: .normal)
            btnProduct.setTitleColor(selectedScanColor, for: .normal)
        }
        scanOptions = sender.tag
        SetScanOption(value: scanOptions)
        RefreshScan()
        
        
    }
    
    func RefreshScan()
    {
        if scanOptions == 0
        {
            btnBarcode.setTitleColor(UIColor.white, for: .normal)
            btnProduct.setTitleColor(selectedScanColor, for: .normal)
            self.videoPreview.isHidden = false
            self.drawingView.isHidden = false
            self.cameraView.isHidden = true
            self.videoCapture.start()
            
        }
        else
        {
            btnBarcode.setTitleColor(selectedScanColor, for: .normal)
            btnProduct.setTitleColor(UIColor.white, for: .normal)
            self.videoCapture.stop()
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
            configureCamera()
            print(scanOptions)
            
            self.videoPreview.isHidden = true
            self.drawingView.isHidden = true
            self.cameraView.isHidden = false
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var cameraView1: CameraView {
        return cameraView as! CameraView
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
        //1
        //        session.sessionPreset = AVCaptureSession.Preset.photo
        //        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            
            print("Error: no video devices available")
            return
        }
        
        cameraView1.session = session
        
        let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInWideAngleCamera,.builtInTelephotoCamera,.builtInDualCamera],mediaType: AVMediaType.video,position: .back)
        var cameraDevice: AVCaptureDevice?
        for device in cameraDevices.devices {
            if device.position == .back {
                cameraDevice = device
                break
            }
        }
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device:cameraDevice!)
            if session.canAddInput(captureDeviceInput) {
                session.addInput(captureDeviceInput)
            }
        }
        catch {
            print("Error occured \(error)")
            return
        }
        session.sessionPreset = .high
        if scanOptions == 1
        {
            
            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = supportedCodeTypes
            }
        }
        
        cameraView1.videoPreviewLayer.videoGravity = .resizeAspectFill
        session.startRunning()
        
    }
    
    
    func checkLoginAlert(){
        if !UserDefaults.standard.bool(forKey: kLogIn){
            //            let alert = UIAlertController(title: APPNAME, message: please_login,preferredStyle: .alert)
            //            alert.addAction(UIAlertAction(title: "LOGIN",
            //                                          style: .default,
            //                                          handler: {(_: UIAlertAction!) in
            //
            //                                            IsScanWithLogin = true
            //                                            self.pushViewController(Storyboard: StoryBoardLogin, ViewController: idWelComeVC, animation: true)
            //            }))
            //            alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (UIAlertAction) in
            //                if (self.session.isRunning == false) {
            //                    self.session.startRunning()
            //                }
            //            }))
            
            
            self.param = [
                WS_KProduct_name:productCode,
                WS_FLAG : 1]//,
            //                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
            
            //            includeSecurityCredentials {(data) in
            //                let data1 = data as! [AnyHashable : Any]
            //                self.param!.addEntries(from: data1)
            //            }
            UserDefaults.standard.set(1, forKey: KScanOption)
            UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: param!, forKey: SCANNED_DETAILS)
            IsScanWithLogin = true
            self.pushViewController(Storyboard: StoryBoardLogin, ViewController: idWelComeVC, animation: true)
            //            self.present(alert, animated: true, completion: nil)
            
        }else {
            
            self.param = [
                WS_KProduct_name:productCode,
                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
                WS_FLAG : 1]
            
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                self.param!.addEntries(from: data1)
            }
            objUser = UserDefaults.standard.getCustomObjFromUserDefaults(forKey: KUser) as? WSUser
            GetProductDetailsAPI()
            
        }
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
            if metadataObjects.count == 0 {
                print("No Code deteected")
                return
            }
            
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if supportedCodeTypes.contains(metadataObj.type) {
                print("Detected Code",metadataObj.stringValue)
            }
            
            self.session.stopRunning()
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                print(stringValue)
                self.productCode = stringValue
                //                self.productCode = "00449458"
                checkLoginAlert()
                
            }
            
            
        }
    }
}


extension ScanProductVC
{
    func GetProductDetailsAPI()
    {
        if Connectivity.isConnectedToInternet
        {
            showIndicator(view: self.view)
            //        param?.setValue(self.flag, forKey: WS_FLAG)
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetProductDetails, parameters: param!, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                self.hideIndicator(view: self.view)
                if response != nil
                {
                    let objData = JSON(response!)[WS_KProduct]
                    let objProduct = objData.to(type: WSProduct.self) as! [WSProduct]
                    
                    self.flag = 0
                    HomeTabVC.sharedHomeTabVC?.selectedIndex = 0
                    let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idFoodDetailVC) as! FoodDetailVC
                    vc.objProduct = objProduct[0]
                    HomeTabVC.sharedHomeTabVC?.selectedIndex = 1
                    HomeTabVC.sharedHomeTabVC?.navigationController?.pushViewController(vc, animated: true)
                    
                }
                else
                {
                    //                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
                    self.generateAlertWithOkButton(text: message!)
                    if self.scanOptions == 1
                    {
                        self.session.startRunning()
                    }
                    else
                    {
                        self.videoCapture.start()
                    }
                }
                
            })
        }
        else
        {
            //            showBanner(title: "", subTitle: no_internet_connection, bannerStyle: .danger)
            self.generateAlertWithOkButton(text: no_internet_connection)
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
    
    func invertedImage() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let ciImage = CoreImage.CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        guard let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: outputImageCopy)
    }
    
    func g8_blackAndWhitemap() -> UIImage? {
        var beginImage: CIImage? = nil
        if let anImage = cgImage {
            beginImage = CIImage(cgImage: anImage)
        }
        
        var blackDict : [String : Any] = [kCIInputImageKey : beginImage,
                                          "inputBrightness" : 0.0,
                                          "inputContrast" : 1.1,
                                          "inputSaturation" : 0.0]
        var blackAndWhite: CIImage? = CIFilter(name: "CIColorControls", parameters: blackDict)?.outputImage
        
        var opDict : [String : Any] = [kCIInputImageKey : blackAndWhite,
                                       "inputEV" : 0.7]
        
        let output: CIImage? = CIFilter(name: "CIExposureAdjust", parameters: opDict)?.outputImage
        
        let context = CIContext(options: nil)
        var cgiimage: CGImage? = nil
        if let anOutput = output {
            cgiimage = context.createCGImage(anOutput, from: output?.extent ?? CGRect.zero)
        }
        var newImage: UIImage? = nil
        if let aCgiimage = cgiimage {
            newImage = UIImage(cgImage: aCgiimage, scale: 0, orientation: imageOrientation)
        }
        return newImage
    }
    
    
    
    
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
// MARK: - VideoCaptureDelegate
extension ScanProductVC: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // the captured image from camera is contained on pixelBuffer
        if !self.isInference, let pixelBuffer = pixelBuffer {
            
            self.isInference = true
            
            // predict!
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.predictUsingVision(pixelBuffer: pixelBuffer)
            }
            //            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
}
//Text scanning
extension ScanProductVC
{
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                    
                }
                
                // start video preview when setup is done
                //                self.videoCapture.start()
            }
            
        }
    }
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds//CGRect(x: videoPreview.frame.origin.x, y: videoPreview.frame.origin.y, width: videoPreview.frame.size.width, height: videoPreview.frame.size.height)//videoPreview.bounds videoPreview.frame//
    }
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        
        let ciimage: CIImage = CIImage(cvImageBuffer: pixelBuffer)
        // crop found word
        let ciContext = CIContext()
        guard let cgImage: CGImage = ciContext.createCGImage(ciimage, from: ciimage.extent) else {
            self.isInference = false
            return
        }
        let uiImage: UIImage = UIImage(cgImage: cgImage)
        let visionImage = VisionImage(image: uiImage)
        textRecognizer.process(visionImage) { (features, error) in
            // this closure is called on main thread
            if error == nil, let features: VisionText = features {
                self.drawingView.imageSize = uiImage.size
                self.drawingView.visionText = features
            } else {
                self.drawingView.imageSize = .zero
                self.drawingView.visionText = nil
            }
            
            self.isInference = false
        }
    }
}
//text detection with IOS
//extension ScanProductVC : AVCaptureVideoDataOutputSampleBufferDelegate{
//
//
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
//
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//
//            if self.flag == 0 && self.scanOptions == 0
//            {
//                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//                    return
//                }
//                var imageRequestOptions = [VNImageOption: Any]()
//                if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
//                    imageRequestOptions[.cameraIntrinsics] = cameraData
//                }
//                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: imageRequestOptions)
//                do {
//                    try imageRequestHandler.perform([self.textDetectionRequest!])
//                }
//                catch {
//                    print("Error occured \(error)")
//                }
//                var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//                let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
//                ciImage = ciImage.transformed(by: transform)
//                let size = ciImage.extent.size
//                var recognizedTextPositionTuples = [(rect: CGRect, text: String)]()
//                for textObservation in self.textObservations {
//                    guard let rects = textObservation.characterBoxes else {
//                        continue
//                    }
//                    var xMin = CGFloat.greatestFiniteMagnitude
//                    var xMax: CGFloat = 0
//                    var yMin = CGFloat.greatestFiniteMagnitude
//                    var yMax: CGFloat = 0
//                    for rect in rects {
//
//                        xMin = min(xMin, rect.bottomLeft.x)
//                        xMax = max(xMax, rect.bottomRight.x)
//                        yMin = min(yMin, rect.bottomRight.y)
//                        yMax = max(yMax, rect.topRight.y)
//                    }
//                    let imageRect = CGRect(x: xMin * size.width, y: yMin * size.height, width: (xMax - xMin) * size.width, height: (yMax - yMin) * size.height)
//                    let context = CIContext(options: nil)
//                    guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
//                        continue
//                    }
//                    let uiImage = UIImage(cgImage: cgImage)
//                    self.tesseract?.image = uiImage.g8_blackAndWhitemap()!
//                    self.tesseract?.recognize()
//                    guard var text = self.tesseract?.recognizedText else {
//                        continue
//                    }
//                    text = text.trimmingCharacters(in: CharacterSet.newlines)
//                    if !text.isEmpty {
//                        let x = xMin
//                        let y = 1 - yMax
//                        let width = xMax - xMin
//                        let height = yMax - yMin
//                        recognizedTextPositionTuples.append((rect: CGRect(x: x, y: y, width: width, height: height), text: text))
//                    }
//                }
//                self.textObservations.removeAll()
//                let viewWidth = self.cameraView.frame.size.width
//                let viewHeight = self.cameraView.frame.size.height
//
//                let subviews = self.cameraView.subviews
//                if subviews.count > 1
//                {
//                    for i in subviews
//                    {
//                        if i is UILabel
//                        {
//                            //                            if i != self.cameraView
//                            //                            {
//                            i.removeFromSuperview()
//
//                            //                            }
//                        }
//                    }
//                }
//                for tuple in recognizedTextPositionTuples {
//                    var rect = tuple.rect
//                    rect.origin.x *= viewWidth
//                    rect.size.width *= viewWidth
//                    rect.origin.y *= viewHeight
//                    rect.size.height *= viewHeight
//
//                    // Increase the size of text layer to show text of large lengths
//                    rect.size.width += 100
//                    rect.size.height += 30
//
//                    let labl = UILabel()
//                    labl.frame = rect
//                    labl.textColor = UIColor.white
//                    labl.text = tuple.text
//                    labl.isUserInteractionEnabled = true
//                    labl.layer.borderColor = UIColor.white.cgColor
//                    labl.layer.borderWidth = 2.0
//                    labl.backgroundColor = UIColor.clear
//                    labl.font = UIFont(name: "arial", size: 16.0)
//
//                    self.cameraView.addSubview(labl)
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandle(_:)))
//                    tap.numberOfTapsRequired = 1
//                    labl.addGestureRecognizer(tap)
//
//                }
//            }
//        }
//    }
//    func ConfigureTesseract() {
//        // Do any additional setup after loading the view, typically from a nib.
//        tesseract?.pageSegmentationMode = .sparseText//.auto
//        // Recognize only these characters
//        tesseract?.charWhitelist = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"//0123456789()-+*!/?.,@#$%&"
//        tesseract?.delegate = self
//
//    }
//    func startTextDetection() {
//        textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: detectTextHandler)
//        textDetectionRequest?.reportCharacterBoxes = true
//    }
//
//    func detectTextHandler(request: VNRequest, error: Error?) {
//        guard let detectionResults = request.results else {
//            print("No detection results")
//            return
//        }
//        let textResults = detectionResults.map() {
//            return $0 as? VNTextObservation
//        }
//        if textResults.isEmpty {
//            textObservations.removeAll()
//            return
//        }
//        textObservations = textResults as! [VNTextObservation]
//    }
//}
