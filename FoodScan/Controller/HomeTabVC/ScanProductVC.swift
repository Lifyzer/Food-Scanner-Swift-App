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

var selectedScanColor = UIColor(red: 68/255, green: 176/255, blue: 91/255, alpha: 1.0)//(red: 68/255, green: 176/255, blue: 91/255)
var IsScanWithLogin = false
var ScanParam = NSMutableDictionary()
var SCANNED_DETAILS = "scanned_product"

class ScanProductVC: UIViewController,G8TesseractDelegate {
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var btnBarcode: UIButton!
    
    private var textDetectionRequest: VNDetectTextRectanglesRequest?
    private var textObservations = [VNTextObservation]()
    private var tesseract = G8Tesseract(language: "eng", engineMode:.tesseractCubeCombined)
//    private var font = CTFontCreateWithName("ArialMT" as CFString, 17, nil)
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        scanOptions = 1
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if IsScanWithLogin
        {
            IsScanWithLogin = false
            ScanParam = UserDefaults.standard.getCustomObjFromUserDefaults(forKey: SCANNED_DETAILS) as! NSMutableDictionary
            self.param = ScanParam
            GetProductDetailsAPI()
        }
        
            // Do any additional setup after loading the view, typically from a nib.
            tesseract?.pageSegmentationMode = .sparseText//.auto
            // Recognize only these characters
            tesseract?.charWhitelist = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"//0123456789()-+*!/?.,@#$%&"
            tesseract?.delegate = self
        
            scanOptions = 1
            btnBarcode.setTitleColor(selectedScanColor, for: .normal)
            btnProduct.setTitleColor(UIColor.white, for: .normal)
            if isAuthorized()
            {
                    if session.outputs.contains(metadataOutput)
                    {
                        session.removeOutput(metadataOutput)
                    }
//                    startTextDetection()
                
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
                metadataOutput.metadataObjectTypes = supportedCodeTypes
            }
        }
      
        cameraView1.videoPreviewLayer.videoGravity = .resizeAspectFill
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
            textObservations.removeAll()
            return
        }
        textObservations = textResults as! [VNTextObservation]
    }
    func checkLoginAlert(){
        if !UserDefaults.standard.bool(forKey: kLogIn){
            let alert = UIAlertController(title: APPNAME, message: please_login,preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "LOGIN",
                                          style: .default,
                                          handler: {(_: UIAlertAction!) in
                                            
                                            IsScanWithLogin = true
                                            self.pushViewController(Storyboard: StoryBoardLogin, ViewController: idWelComeVC, animation: true)
            }))
            alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (UIAlertAction) in
                if (self.session.isRunning == false) {
                    self.session.startRunning()
                }
            }))
            
            let userToken = UserDefaults.standard.string(forKey: kTempToken)
            let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
            //        DEFAULT_ACCESS_KEY = encodeString
            self.param = [
                WS_KProduct_name:productCode,
                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
           
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                self.param!.addEntries(from: data1)
            }
            UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: param!, forKey: SCANNED_DETAILS)
            self.present(alert, animated: true, completion: nil)
            
        }else {
            let userToken = UserDefaults.standard.string(forKey: kTempToken)
            let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
            //        DEFAULT_ACCESS_KEY = encodeString
            self.param = [
                WS_KProduct_name:productCode,
                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
           
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
            
//            if metadataObjects.count == 0 {
//                print("No Code deteected")
//                return
//            }
//
//            // Get the metadata object.
//            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
//
//            if supportedCodeTypes.contains(metadataObj.type) {
//                print("Detected Code",metadataObj.stringValue)
//            }
        }
    }
}

//MARK: AVCaptureVideoDataOutputSampleBufferDelegate
extension ScanProductVC: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
        
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
                    self.tesseract?.image = uiImage.g8_blackAndWhitemap()!
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
                        if i is UILabel
                        {
//                            if i != self.cameraView
//                            {
                                i.removeFromSuperview()
                                
//                            }
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
        if Connectivity.isConnectedToInternet
        {
        showIndicator(view: self.view)
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
                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
            }

        })
        }
        else
        {
            showBanner(title: "", subTitle: no_internet_connection, bannerStyle: .danger)
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
        
//        CGImageRelease(cgiimage!)
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
