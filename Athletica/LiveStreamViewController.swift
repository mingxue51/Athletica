//
//  LiveStreamViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/8/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import AVFoundation

enum BroadcastState {
    case connecting
    case broadcasting
    case stopped
}

class LiveStreamViewController: BaseViewController, BambuserViewDelegate, UIGestureRecognizerDelegate {
    
    //----- Inited by StartLiveStreamVC or UpcomingStreamsVC -----
    var category:String!
    var happening:String!
    var isSaveStream:Bool!
    var creatorId:String!
    var creatorName:String!
    var upcomingStreamId:String? // Inited by UpcomingStreamsVC only
    var nSavedStreams:Int?
    //---------------------------------------
    
    var broadcastState:BroadcastState = .stopped
    
    var bambuserView: BambuserView
    var talkbackStatus: UILabel
    var pinchRecognizer: UIPinchGestureRecognizer
    var initialZoom: Float
    var progressBar: UIProgressView?
    
    var isAnimating:Bool = false
    
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var ivUsers: UIImageView!
    @IBOutlet weak var ivClose: UIImageView!
    @IBOutlet weak var lblCurrentViewers: UILabel!
    
    var stream:Stream!
    
    
    
    // MARK: - Lifecycle methods
    
    required init?(coder aDecoder: NSCoder) {
        bambuserView = BambuserView(preset: kSessionPresetAuto)
        talkbackStatus = UILabel()
        pinchRecognizer = UIPinchGestureRecognizer()
        initialZoom = 0.0
        
        super.init(coder: aDecoder)
        
        bambuserView.delegate = self;
        bambuserView.applicationId = Iris.appId
        bambuserView.talkback = true
        
        bambuserView.orientation = UIApplication.shared.statusBarOrientation
    
        
        
        talkbackStatus.textAlignment = NSTextAlignment.left;
        talkbackStatus.text = ""
        talkbackStatus.backgroundColor = UIColor.clear
        talkbackStatus.textColor = UIColor.white
        talkbackStatus.shadowColor = UIColor.black
        talkbackStatus.shadowOffset = CGSize(width: 1, height: 1)

        
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(LiveStreamViewController.handlePinchGesture(_:)))
       
        
        // Configure what options are visible in the settings view
        bambuserView.enableOption(kAudioQualityOption, enabled:true)
        bambuserView.enableOption(kSaveLocallyOption, enabled:true)
        bambuserView.enableOption(kTalkbackOption, enabled:true)
        bambuserView.enableOption(kArchiveOption, enabled:true)
        bambuserView.enableOption(kPositionOption, enabled:true)
        bambuserView.enableOption(kPrivateModeOption, enabled:true)
    }
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(bambuserView.view)
        //		self.view.addSubview(bambuserView.chatView)
        
        //		self.view.addSubview(talkbackStatus)
        self.view.addGestureRecognizer(pinchRecognizer);
        
        self.view.bringSubview(toFront: self.btnClose)
        self.view.bringSubview(toFront: self.lblCurrentViewers)
        self.view.bringSubview(toFront: self.ivUsers)
        self.view.bringSubview(toFront: self.ivClose)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bambuserView.broadcastTitle = happening
        print(">>>broadcastTitle: \(bambuserView.broadcastTitle)")
        self.startAnimating()
        self.isAnimating = true
        self.broadcast()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillLayoutSubviews() {
        var statusBarOffset : CGFloat = 0.0
        statusBarOffset = CGFloat(self.topLayoutGuide.length)
        
        talkbackStatus.frame = CGRect(x: 110.0, y: 150.0 + statusBarOffset, width: 180.0, height: 50.0);
        
        bambuserView.previewFrame = CGRect(x: 0.0, y: 0.0 + statusBarOffset, width: self.view.bounds.size.width, height: self.view.bounds.size.height - statusBarOffset)
        bambuserView.chatView.frame = CGRect(x: 0.0, y: self.view.bounds.size.height-self.view.bounds.size.height/3.0, width: self.view.bounds.size.width, height: self.view.bounds.size.height/3.0)
        if (bambuserView.settingsView.isViewLoaded) {
            bambuserView.settingsView.view.frame = CGRect(x: 0.0, y: 0.0 + statusBarOffset, width: self.view.bounds.size.width, height: self.view.bounds.size.height - statusBarOffset);
        }
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    func broadcast() {
        self.broadcastState = .connecting
        bambuserView.startBroadcasting()
    }
    
    func stopBroadcast(){
        self.bambuserView.stopBroadcasting()
        self.broadcastState = .stopped
        showAlert(title: nil, message: "Failed to upload stream. Please check the Internet connection.", controller: nil, okTitle: "OK", cancelTitle: nil, okAction: {
            self.navigationController?.popViewController(animated: true)
        }, cancelAction: nil)
        
    }
    
    func broadcastStarted() {
        self.stopAnimating()
        self.isAnimating = false
        self.broadcastState = .broadcasting
        print(">>>Broadcast started")
        self.showSuccessSnackBar(message: "Broadcast started.")
        self.stream = Stream()
        self.stream.category = self.category
        self.stream.isSaveStream = self.isSaveStream
        self.stream.creatorId = self.creatorId
        self.stream.creatorName = self.creatorName
        
        self.sendNotifications()
        
        // If this is a saved stream, increase nSavedStreams in UserDefaults and Firebase DB
        if self.isSaveStream{
            self.setNSavedStreams(nSavedStreams:nSavedStreams!+1)
            
        }
    }
    func setNSavedStreams(nSavedStreams:Int){
        FirebaseUtil.shared.setNSavedStreams(userId: self.creatorId, nSavedStreams: nSavedStreams) { (error) in
            if error != nil{
                print(">>>Failed to set nSavedStreams. Error: \(String(describing: error?.localizedDescription))")
                self.setNSavedStreams(nSavedStreams: nSavedStreams)
            }else{
                print(">>>Success to set nSavedStreams")
            }
        }
    }
    func broadcastIdReceived(_ broadcastId: String!) {
        print(">>>broadcastIdReceived: \(broadcastId)")
        
        
        // Get the metadata of the broadcast
        Network.metadataWith(broadcastId: broadcastId) { (metadata) in
            if metadata == nil{
                print(">>>Failed to get metadata from Iris backend server. Retrying...")
                self.showErrorSnackBar(message: SnackbarMessage.noConnection)
                self.broadcastIdReceived(broadcastId)
                return
            }            
            self.stream.initWith(metadata: metadata!)
            
            // Set resourceUri to upcomingStreams/{streamId}/resourceUri
            // Called only if it was an upcomig stream
            if self.upcomingStreamId != nil{
                FirebaseUtil.shared.setResourceUri(streamId: self.upcomingStreamId!, resourceUri: self.stream.resourceUri, completion: { (error) in
                    if error != nil{
                        print(">>>Failed to set resourceUri of the upcoming stream")
                    }else{
                        print(">>>Success to set resourceUri of the upcoming stream")
                    }
                })
            }
            
            // Start uploading streams by taking a snapshot
            self.takeSnapshot()
        }
    }
    func takeSnapshot(){
        self.bambuserView.takeSnapshot()
    }
    func uploadStream(stream:Stream){
        // Upload the stream to Firebase Database
        FirebaseUtil.shared.uploadStream(stream: stream, completion: { (error) in
            if error != nil {
                print(">>>Failed to upload a stream to Firebase DB. Error: \(String(describing: error?.localizedDescription))")
                self.showErrorSnackBar(message: SnackbarMessage.noConnection)
                self.uploadStream(stream: stream)
            }else{
                print(">>>Uploaded a stream to Firebase DB")
                // Take a screenshot in 5 sec
                if self.broadcastState == .broadcasting{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        self.takeSnapshot()
                    })
                }
            }
        })
    }
    
    
    func bambuserError(_ code: BambuserError, message: String) {
        if self.isAnimating{
            self.stopAnimating()
            self.isAnimating = false
        }
        switch (code) {
        case kBambuserErrorServerFull,
             kBambuserErrorIncorrectCredentials,
             kBambuserErrorConnectionLost,
             kBambuserErrorUnableToConnect:
            // Enable broadcastbutton on connection error
            
            break
        case kBambuserErrorServerDisconnected, kBambuserErrorLocationDisabled, kBambuserErrorNoCamera:
            break;
        default:
            break
        }
        DispatchQueue.main.async {
            showAlert(title: nil, message: message, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
        }
    }
    
    func chatMessageReceived(_ message : String) {
        bambuserView.displayMessage(String(message))
    }
    
    func talkbackRequest(_ request : String, caller : String, talkbackID : Int32) {
        let talkbackRequest = UIAlertView(title: caller, message: request, delegate: self, cancelButtonTitle: nil)
        talkbackRequest.addButton(withTitle: "Accept")
        talkbackRequest.addButton(withTitle: "Decline")
        talkbackRequest.tag = Int(talkbackID)
        talkbackRequest.show()
    }
    
    func talkbackStateChanged(_ state: TalkbackState) {
        switch (state) {
        case kTalkbackNeedsAccept:
            talkbackStatus.text = "Talkback pending";
            break;
        case kTalkbackAccepted:
            talkbackStatus.text = "Talkback accepted";
            break;
        case kTalkbackPlaying:
            talkbackStatus.text = "Talkback playing";
            break;
        default:
            talkbackStatus.text = "";
        }
        
        // Add or remove button for ending talkback
//        if (state == kTalkbackPlaying) {
//            endTalkbackButton = UIButton(type: UIButtonType.system)
//            endTalkbackButton.addTarget(bambuserView, action: #selector(BambuserView.endTalkback), for: UIControlEvents.touchUpInside)
//            let statusBarOffset = self.topLayoutGuide.length;
//            endTalkbackButton.frame = CGRect(x: 0.0, y: 150.0 + statusBarOffset, width: 100.0, height: 50.0);
//            endTalkbackButton.setTitle("End talkback", for: UIControlState())
//            self.view.addSubview(endTalkbackButton)
//        } else {
//            endTalkbackButton.removeFromSuperview()
//        }
    }
    
    func currentViewerCountUpdated(_ viewers: Int32) {
        self.lblCurrentViewers.text = "\(viewers)"
        if self.stream != nil {
            self.stream.currentViewers = Int(viewers)
        }
        
    }
    
    func totalViewerCountUpdated(_ viewers: Int32) {
        print("Total viewers: \(viewers)")
        if self.stream != nil {
            self.stream.totalViewers = Int(viewers)
        }
        
    }
   
    
    func handlePinchGesture(_ sender : UIPinchGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.began) {
            initialZoom = bambuserView.zoom
        }
        bambuserView.zoom = initialZoom * Float(sender.scale)
    }

    @IBAction func btnCloseTapped(_ sender: UIButton) {
        if self.broadcastState == .broadcasting {
            bambuserView.stopBroadcasting()
            // Archive the stream
            if self.stream != nil {
                self.stream.type = "archived"
            }
            self.takeSnapshot()
        }
        self.broadcastState = .stopped
        if self.upcomingStreamId == nil{ // Not an upcoming stream
            let index = (self.navigationController?.viewControllers.count)! - 3
            let vc = self.navigationController?.viewControllers[index]
            self.navigationController?.popToViewController(vc!, animated: true)
        }else{ // Upcoming stream
            self.archiveUpcomingStream()
            self.dismiss(animated: true, completion: nil)
        }
    }
    func archiveUpcomingStream(){
        // Set the upcoming stream type to archive
        FirebaseUtil.shared.archiveUpcomingStream(streamId: self.upcomingStreamId!, completion: { (error) in
            if error != nil {
                print(">>>Failed to archive the upcoming stream in Firebase DB. Error: \(String(describing: error?.localizedDescription))")
                self.archiveUpcomingStream()
            }else{
                print(">>>Archived the upcoming stream in Firebase DB")
            }
        })
    }
    func archiveStream(stream:Stream){
        FirebaseUtil.shared.archiveStream(stream: stream, completion: { (error) in
            if error != nil {
                print(">>>Failed to archive the stream in Firebase DB. Error: \(String(describing: error?.localizedDescription))")
                self.archiveStream(stream: stream)
            }else{
                print(">>>Archived the stream in Firebase DB")
            }
        })
    }
    
    func snapshotTaken(_ image: UIImage!) {
        let newImage = ImageUtil.shared.resizeImage(image: image, compressionQuality: 0.6, targetSize: CGSize(width: image.size.width/2.0, height: image.size.height/2.0))
        FirebaseUtil.shared.uploadImage(image: newImage, imageName: self.stream.id) { (imageURL) in
            self.stream.imageURL = imageURL
            if imageURL == "" {
                // Failed. Retry uploading
                self.snapshotTaken(image)
            }else{
                self.uploadStream(stream: self.stream)
            }
            
        }
    }
    
    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        bambuserView.setOrientation(toInterfaceOrientation, previewOrientation: toInterfaceOrientation)
    }
    override var shouldAutorotate : Bool {
        print(self.broadcastState)
        if self.broadcastState == .broadcasting {
            return false
        }else{
            return true
        }
    }
    
    // MARK: - Notifications
    // Send notifications to followers
    // Called when the stream started
    func sendNotifications(){
        
        // Get OneSignal userIds to send push notifications to
//        let myOneSignalUserId = UserDefaults.standard.string(forKey: "oneSignalUserId")
//        var userIds:[String] = []
//        // Send a notification to the user only if isScheduledStream is true
//        let isScheduledStream = UserDefaults.standard.bool(forKey: "isScheduledStream")
//        if isScheduledStream == true{
//            userIds.append(myOneSignalUserId!)
//        }
//        for item in self.invitedCoaches {
//            if item.isInvites == true{
//                userIds.append(item.oneSignalUserId)
//            }
//        }
//        let message = self.stream.creatorName + " will start a stream(" + self.stream.title + ") in 5 minutes."
//        let heading = "Category: " + self.stream.category
//        
//        OneSignalUtil.shared.sendNotification(date: Date(), userIds: userIds, message: message, heading: heading)
    }
}


