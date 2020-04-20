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
import SwiftyJSON
import CoreMedia
import CoreImage
import Firebase


var selectedScanColor = UIColor(red: 68/255, green: 176/255, blue: 91/255, alpha: 1.0)
var IsScanWithLogin = false
var ScanParam = NSMutableDictionary()
var SCANNED_DETAILS = "scanned_product"

class ScanProductVC: UIViewController{

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var btnBarcode: UIButton!
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var btnSelectCountry: UIButton!

    
    var recognizedTextPositionTuples = [(rect: CGRect, text: String)]()
    var session = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    let metadataOutput = AVCaptureMetadataOutput()
    var flag = 0
    var foodType = 0
    var scanOptions = -1
    var productCode = ""
    var param : NSMutableDictionary?
    var objUser: WSUser?
    lazy var vision = Vision.vision()
    lazy var textRecognizer = vision.onDeviceTextRecognizer()
    var videoCapture: VideoCapture!
    var isInference = false
    private var cameraView1: CameraView {
        return cameraView as! CameraView
    }
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
        self.setUpCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        if IsScanWithLogin{
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
        }else{
            let scanValue = GetScanOption()
            if scanValue != nil{
                scanOptions = scanValue!
            }else{
                scanOptions = 0
                SetScanOption(value: scanOptions)
            }
        }
        RefreshScan()
        setFoodType(foodType: self.foodType)
    }
    override func viewWillDisappear(_ animated: Bool) {
        if scanOptions == 1{
            if (session.isRunning == true) {
                session.stopRunning()
            }
        }else{
            videoCapture.stop()
        }
    }

    //MARK: Button Actions
    @IBAction func btnSelectCountry(_ sender: Any) {
        //Show popup for edit and delete review => NOTE : used popover library for this
        let countryVC = loadViewController(Storyboard: StoryBoardMain, ViewController: idSelectCountryVC) as! SelectCountryVC
        countryVC.modalPresentationStyle = .popover
        let heightPopUp = CGFloat(countryVC.arrCountry.count * CountryHeight)
        let widthPopUp = self.view.frame.size.width
        countryVC.preferredContentSize = CGSize(width: widthPopUp, height: heightPopUp)
        countryVC.delegate = self
        countryVC.selectedCountry = self.foodType
        let popOverVC = countryVC.popoverPresentationController
        popOverVC?.permittedArrowDirections = .up
        popOverVC?.delegate = self
        popOverVC?.sourceView = btnSelectCountry
        popOverVC?.sourceRect = CGRect(x: btnSelectCountry.bounds.minX, y: btnSelectCountry.bounds.minY + 35, width: 0, height: 0)
        self.present(countryVC, animated: true, completion: nil)
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

    @IBAction func btnFlashClicked(_ sender: Any) {
        toggleFlash()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: Fucntions
extension ScanProductVC
{
    func setFoodType(foodType : Int){
        if let selectedFoodType = UserDefaults.standard.value(forKey: KFoodType){
            if self.foodType == 0{
                self.foodType = selectedFoodType as! Int
            }else{
                self.foodType = foodType
            }
        }
        btnSelectCountry.setImage(arrCountryImages[self.foodType], for: .normal)
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
                                                }
                                            }
            })
            return true
        case .authorized:
            return true
        case .denied, .restricted: return false
        }
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
            for i in self.drawingView.subviews
            {
                i.removeFromSuperview()
            }
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
    private func configureCamera()
    {
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
        if scanOptions == 1{
            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = supportedCodeTypes
            }
        }
        cameraView1.videoPreviewLayer.videoGravity = .resizeAspectFill
        session.startRunning()
    }

    func checkLoginAlert()
    {
        if !UserDefaults.standard.bool(forKey: kLogIn){
            self.param = [
                WS_KProduct_name:productCode,
                WS_FLAG : 1]
            UserDefaults.standard.set(1, forKey: KScanOption)
            UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: param!, forKey: SCANNED_DETAILS)
            IsScanWithLogin = true
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
        }
        GetProductDetailsAPI()
    }
    
    func toggleFlash()
    {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
}

//MARK: Popover presenation Delegate
extension ScanProductVC: UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
}
//MARK: Country Popup delegate
extension ScanProductVC: CountryPopupDelegate{
    func selectedCountry(index: Int) {
        setFoodType(foodType: index)
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
            self.session.stopRunning()
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                print(stringValue)
                self.productCode = stringValue
                checkLoginAlert()
            }
        }
    }
}

//MARK: API related stuff
extension ScanProductVC
{
    func GetProductDetailsAPI()
    {
        if Connectivity.isConnectedToInternet
        {
            showIndicator(view: self.view)
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetProductDetails, parameters: param!, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                self.hideIndicator(view: self.view)
                if response != nil{
                    let objData = JSON(response!)[WS_KProduct]
                    let objProduct = objData.to(type: WSProduct.self) as! [WSProduct]
                    self.flag = 0
                    let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idFoodDetailVC) as! FoodDetailVC
                    vc.objProduct = objProduct[0]
                    HomeTabVC.sharedHomeTabVC?.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    self.generateAlertWithOkButton(text: message!)
                    if self.scanOptions == 1{
                        self.session.startRunning()
                    }else{
                        self.videoCapture.start()
                    }
                }

            })
        }
        else{
            self.generateAlertWithOkButton(text: no_internet_connection)
        }
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
        }
    }
}

//MARK: Text Scaning
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
            }
        }
    }
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
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
                print("Success",features)
                self.drawingView.imageSize = uiImage.size
                self.drawingView.visionText = features
            } else {
                print("Failed",features)
                self.drawingView.imageSize = .zero
                self.drawingView.visionText = nil
            }
            self.isInference = false
        }
    }
}
