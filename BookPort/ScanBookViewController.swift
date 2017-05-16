//
//  ScanBookViewController.swift
//  BookPort
//
//  Created by Zhifu Ge on 2016-11-06.
//  Copyright © 2016 Zhifu Ge. All rights reserved.
//

import AVFoundation
import UIKit

class ScanBookViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    fileprivate let showScannedBookDetailSegue = "show scanned book detail"

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);

        captureSession.startRunning();
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: readableObject.stringValue);
        }


    }

    func found(code: String) {
        // querry Google Books for details
        let session = URLSession(configuration: .ephemeral)
        if let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(code)") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let data = data,
                    error == nil else {
                        print("error retrieving book data")
                        return
                }

                if let bookJson = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
                    let itemInfo = (bookJson["items"] as? [Any])?[0] as? [String: Any] {
                    if let volumeInfo = itemInfo["volumeInfo"] as? [String: Any],
                        let title = volumeInfo["title"] as? String,
                        let authors = (volumeInfo["authors"] as? [String]),
                        let selfLink = itemInfo["selfLink"] as? String {

                        let bookInfoString = "Title: \(title)\nAuthor(s): \(authors.reduce("") {return $0 + "\n" + $1})"
                        let ac = UIAlertController(title: "Add New Book?", message: bookInfoString, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (_) -> Void in
                            self.insertNewBook(isbn: code, userId: UserDefaults().string(forKey: Constants.userIdKey), lon: UserDefaults().string(forKey: Constants.lonKey), lat: UserDefaults().string(forKey: Constants.latKey), selfLink: selfLink)
                            self.dismiss(animated: true)
                        }))
                        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) -> Void in self.dismiss(animated: true)}))
                        self.present(ac, animated: true)
                    }
                } else {
                    print("Error retrieving book data")
                    let ac = UIAlertController(title: "Error", message: "This bar code does not contain valid ISBN", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(_) -> Void in self.dismiss(animated: true)}))
                    self.present(ac, animated: true)
                }
            })

            task.resume()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @IBAction func cancelAddNewBook(segue: UIStoryboardSegue) {
        // do nothing
    }

    @IBAction func doneAddNewBook(segue: UIStoryboardSegue) {
        // add code to add new book
    }


    private func insertNewBook(isbn: String, userId: String?, lon: String?, lat: String?, selfLink: String) {
        guard let userId = userId,
            let lon = lon,
            let lat = lat else {
                return
        }

        let session = URLSession(configuration: .ephemeral)
        if let url = URL(string: "http://thetsntech.in/ios/insert.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let params = "user=\(userId)&isbn=\(isbn)&lon=\(lon)&lat=\(lat)$selflink=\(selfLink)"
            request.httpBody = params.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if error == nil {
                    NotificationCenter.default.post(name: NotificationNames.userBooksDidLoadNotification, object: nil)
                }
            })
            
            task.resume()
        }
    }
}
