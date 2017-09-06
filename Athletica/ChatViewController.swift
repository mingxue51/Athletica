//
//  ChatViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/20/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

// Sender == myself, receiver == the user I'm chatting with
import UIKit
import Firebase
import JSQMessagesViewController
import Photos
import TOCropViewController
import SwiftGifOrigin
import Kingfisher

// Sender is me, receiver is the person I'm messaging

class ChatViewController: JSQMessagesViewController, TOCropViewControllerDelegate{
    
    let senderPhotoURL = UserDefaults.standard.string(forKey: "imageURL")!
    let senderUserType = UserDefaults.standard.string(forKey: "userType")!
    
    var receiverId:String!
    var receiverName:String!
    var receiverPhotoURL:String!
    var receiverUserType:String!
    var parentVC:ChatContainerViewController! // Inited by ChatContainerVC
    var messages = [JSQMessage]()
    
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    
    private var channelRef: DatabaseReference!
    private lazy var messageRef: DatabaseReference = self.channelRef.child("messages")
    private var newMessageRefHandle: DatabaseHandle?
    
    
    // Know when user is typing
    private lazy var senderIsTypingRef: DatabaseReference =
        self.channelRef.child("isTyping") // 1
    private lazy var receiverIsTypingRef: DatabaseReference =
        Database.database().reference().child("messages").child(self.receiverId).child(self.senderId).child("isTyping")
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            senderIsTypingRef.setValue(newValue)
        }
    }
//    private lazy var usersTypingQuery: DatabaseQuery =
//        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
   
    
    
    // Sending images
    let storageRef: StorageReference = Storage.storage().reference()
    private let imageURLNotSetKey = "NOTSET"
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updatedMessageRefHandle: DatabaseHandle?
    var selectedImage: UIImage?
    
    
    @IBOutlet weak var ivA: UIImageView!
    
    
    
    
    
    // MARK: - Life cycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.ivA.frame.origin.x = 0
        self.ivA.frame.origin.y = self.view.frame.height - 312 + 20
//        self.ivA.frame.width = 265.0
//        self.ivA.frame.height = 312.0
        dump(self.ivA.frame)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = UIColor.clear
        self.view.insertSubview(self.ivA, at: 0)
        
        
        self.receiverId = self.parentVC.receiverId
        self.receiverName = self.parentVC.receiverName
        self.receiverPhotoURL = self.parentVC.receiverPhotoURL
        self.receiverUserType = self.parentVC.receiverUserType
        
        self.senderId = UserDefaults.standard.string(forKey: "userId")!
        self.senderDisplayName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
        
        // Init channelRef
//        var channelId:String!
//        if self.senderId.compare(self.receiverId) == ComparisonResult.orderedAscending{
//            channelId = self.senderId + "/" + self.receiverId
//        }else{
//            channelId = self.receiverId + "/" + self.senderId
//        }
        self.channelRef = Database.database().reference().child("messages").child(self.senderId).child(self.receiverId)
        
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        observeMessages()
        
        observeTyping()
        
        // 1
        receiverIsTypingRef.observe(.value) { (data: DataSnapshot) in
            let temp = data.value as? Bool
            if temp != nil{
                self.showTypingIndicator = temp!
            }else{
                self.showTypingIndicator = false
            }
            
            self.scrollToBottom(animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        let cache = KingfisherManager.shared.cache
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.cleanExpiredDiskCache()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    // MARK: - CollectionView Datasource and delegate
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if let test = self.getImage(indexPath: indexPath) {
            
            // Go to ViewImageVC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewImageViewController") as! ViewImageViewController
            vc.image = test
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func getImage(indexPath: IndexPath) -> UIImage? {
        let message = self.messages[indexPath.row]
        if message.isMediaMessage == true {
            let mediaItem = message.media
            if mediaItem is JSQPhotoMediaItem {
                let photoItem = mediaItem as! JSQPhotoMediaItem
                if let test: UIImage = photoItem.image {
                    let image = test
                    return image
                }
            }
        }
        return nil
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if self.isBlocked() == true{return}
        
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "senderPhotoURL": senderPhotoURL,
            "senderUserType": senderUserType,
            "text": text!,
            "receiverId":self.receiverId,
            "receiverName":self.receiverName,
            "receiverPhotoURL":self.receiverPhotoURL,
            "receiverUserType":self.receiverUserType,
            "timestamp":ServerValue.timestamp()
            ] as [String : Any]
        
        itemRef.setValue(messageItem) // 3
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
        
        isTyping = false
        
        // Send message with quotation marks
        let locale = NSLocale.current
        let qBegin = locale.quotationBeginDelimiter
        let qEnd = locale.quotationEndDelimiter
        var quote = qBegin! + text! + qEnd!
        quote = self.senderDisplayName + ": " + quote
        self.sendNotification(message: quote)
    }
    private func observeMessages() {
        // 1
        let messageQuery = messageRef.queryLimited(toLast:50)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as! Dictionary<String, Any>
            
            if let id = messageData["senderId"] as! String!, let name = messageData["senderName"] as! String!, let text = messageData["text"] as! String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                // 5
                self.finishReceivingMessage()
                
                
                
            }else if let id = messageData["senderId"] as! String!,
                let photoURL = messageData["photoURL"] as! String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    //if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    //}
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, Any> // 1
            
            if let photoURL = messageData["photoURL"] as! String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        if self.isBlocked() == true{
            textView.resignFirstResponder()
            return
        }
        
        
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    private func observeTyping() {
        senderIsTypingRef.onDisconnectRemoveValue()
    }
    
    func sendPhotoMessage(photoURL:String) {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": photoURL,
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "senderPhotoURL": senderPhotoURL,
            "senderUserType": senderUserType,
            "receiverId":self.receiverId,
            "receiverName":self.receiverName,
            "receiverPhotoURL":self.receiverPhotoURL,
            "receiverUserType": self.receiverUserType,
            "timestamp":ServerValue.timestamp()
            ] as [String : Any]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        
        let message = self.senderDisplayName + " sent you an image"
        self.sendNotification(message: message)
    }
    
//    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
//        let itemRef = messageRef.child(key)
//        itemRef.updateChildValues(["photoURL": url])
//    }
    func isBlocked()->Bool{
        // Can't send text while checking if blocked
        if self.parentVC.isBlockedByUser == nil{
            self.view.endEditing(true)
            return true
        }
        if self.parentVC.isBlockedByMe == true {
            self.view.endEditing(true)
            showAlert(title: nil, message: "You blocked the user. Unblock the user to continue the conversation.", controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                
            }, cancelAction: nil)
            return true
        }
        if self.parentVC.isBlockedByUser == true {
            self.view.endEditing(true)
            showAlert(title: nil, message: "Sorry, the user blocked you.", controller: self, okTitle: "OK", cancelTitle: nil, okAction: { 
                
            }, cancelAction: nil)
            return true
        }
        
        return false
    }
    override func didPressAccessoryButton(_ sender: UIButton) {
        if self.isBlocked() == true{return}
        
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { (action) in
            let picker = UIImagePickerController()
            picker.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
            } else {
                print(">>>Camera not available!")
                return
            }
            picker.allowsEditing = false
            picker.showsCameraControls = true
            
            self.present(picker, animated: true, completion:nil)
        }
        let libraryAction = UIAlertAction(title: "Pick from Library", style: .default) { (action) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            
            self.present(picker, animated: true, completion:nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        vc.addAction(cameraAction)
        vc.addAction(libraryAction)
        vc.addAction(cancelAction)
        self.present(vc, animated: true) {
            
        }
    }
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        let tempImageView = UIImageView(image: nil)
        
        tempImageView.kf.setImage(with: URL(string:photoURL), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
            mediaItem.image = image
            self.collectionView.reloadData()
        }
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    func sendNotification(message:String){
        // Don't send notifications if the user muted it.
        if self.parentVC.isMutedByUser == true {
            return
        }
        OneSignalUtil.shared.sendMessageNotification(date: Date(), userIds: [self.parentVC.receiverOneSignalUserId], message: message, heading: nil, userId: self.senderId, userName: self.senderDisplayName, userPhotoURL: self.senderPhotoURL, userType: self.senderUserType)
        
    }
    
    // MARK: - Crop Image
    func presentCropViewController(_ image:UIImage){
        let cropViewController:TOCropViewController = TOCropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self;
        self.present(cropViewController, animated: true, completion: nil)
    }
    public func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int){
        print(">>>didCrop called")
        let newImage = ImageUtil.shared.resizeImage(image: image)
        self.dismiss(animated: true) {
            FirebaseUtil.shared.uploadImageMessage(newImage, showHUD: true, view: self.view, completion: { (metadata) in
                let photoURL = metadata.downloadURL()?.absoluteString
                self.sendPhotoMessage(photoURL: photoURL!)
            })
        }
    }
    public func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool){
        print(">>>didFinishCancelled called")
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) {
            // if it's a photo from the library, not an image from the camera
            if let referenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
                let assets = PHAsset.fetchAssets(withALAssetURLs: [referenceUrl], options: nil)
                let asset = assets.firstObject
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFile = contentEditingInput?.fullSizeImageURL
                    guard let data = try? Data(contentsOf: imageFile!) else{return}
                    guard let image = UIImage(data: data) else{ return }
                    
                    // Show CropViewController
                    self.presentCropViewController(image)
                })
            } else {
                guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
                
                // Show CropViewController
                //let vc:AthleteEditProfileViewController = picker.delegate as! AthleteEditProfileViewController
                self.presentCropViewController(image)
                
            }
        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
