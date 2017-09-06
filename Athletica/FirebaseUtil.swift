//
//  File.swift
//  Athletica
//
//  Created by SilverStar on 7/9/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseMessaging
import MBProgressHUD

class FirebaseUtil {
//    private var firebaseUtil:FirebaseUtil!
    
    static let shared = FirebaseUtil()
    
    // MARK: - Stream
    // Change the stream type from live to archived
    func archiveStream(stream:Stream, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let streamRef = Database.database().reference().child("streams").child(stream.id)
            streamRef.child("type").setValue("archived") { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
        
    }
    // Change the upcoming stream type from upcoming to archived
    // Called from LiveStreamVC when the user taps on the X button
    func archiveUpcomingStream(streamId:String, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let streamRef = Database.database().reference().child("upcomingStreams").child(streamId)
            streamRef.child("type").setValue("archived") { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
        
    }
    // Delete one of my streams
    func deleteMyStream(streamId:String, completion: @escaping (_ error:Error?)->()){
        
        if Reachability.isConnectedToNetwork(){
            // Delete from AWS S3 first
            AWSUtil.shared.deleteStream(streamId: streamId, completion: { (error) in
                if error != nil{
                    print(">>>Failed to delete Stream from AWS S3")
                    completion(error)
                }else{
                    let streamsRef = Database.database().reference().child("streams").child(streamId)
                    streamsRef.removeValue(completionBlock: { (error, ref) in
                        if error == nil{
                            print(">>>Stream: \(streamId) deleted")
                            completion(nil)
                        }else{
                            completion(error)
                        }
                    })
                }
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Delete streams up to 5 min ago
    func deleteUpcomingStream(streamId:String){
        
        if Reachability.isConnectedToNetwork(){
            
            let streamsRef = Database.database().reference().child("upcomingStreams").child(streamId)
            streamsRef.removeValue(completionBlock: { (error, ref) in
                if error == nil{
                    print(">>>Stream: \(streamId) deleted")
                }
            })
            
        }else{
            print(">>>No Internet connection")
        }
    }
    
    // Delete streams 4+ hours ago
    func deleteStream(streamId:String){
        
        if Reachability.isConnectedToNetwork(){
            
            // Delete stream mp4 file from AWS S3 first
            AWSUtil.shared.deleteStream(streamId: streamId, completion: { (error) in
                if error != nil{
                    print(">>>Failed to delete Stream from AWS S3")
                }else{
                    // Delete stream from Firebase DB
                    let streamsRef = Database.database().reference().child("streams").child(streamId)
                    streamsRef.removeValue(completionBlock: { (error, ref) in
                        if error == nil{
                            print(">>>Stream: \(streamId) deleted")
                        }
                    })
                }
            })
            
        }else{
            print(">>>No Internet connection")
        }
    }
    
    // Get Streams whenever changed
    // Called from AthelteStreamsVC
    func getStreams(completion:@escaping (DatabaseHandle?, [Stream], Error?)->()){
        var streams:[Stream] = []
        var dbHandle:DatabaseHandle?
        
        if Reachability.isConnectedToNetwork(){
            
            let streamsRef = Database.database().reference().child("streams")
            dbHandle = streamsRef.observe(.value, with: { (snapshot) in
                print(">>>getStreams called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                streams.removeAll()
                for snap in snapshots{
                    let dicStream = snap.value as! [String:Any]
                    let stream = Stream()
                    stream.initWithDic(dic: dicStream)
                    
                    // Check if the stream ended 4+ hours ago
                    let timestamp = dateSubtracted(hours: 4, from: Date()).timeIntervalSince1970 * 1000
                    if stream.endedAt < timestamp {
                        // If isSaveStream is false, remove the stream
                        if stream.isSaveStream == false{
                            self.deleteStream(streamId: stream.id)
                        }else{ // Do nothing
                            
                        }
                        continue
                    }
                    
                    streams.append(stream)
                }
                
                // Sort streams by timestamp. recent streams come first
                streams.sort(by: { (first: Stream, second: Stream) -> Bool in
                    first.endedAt > second.endedAt
                })
                ///
                
                
                completion(dbHandle, streams, nil)
            }, withCancel: { (error) in
                completion(dbHandle, streams, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(dbHandle, streams, err as Error)
        }
    }
    // Get Streams only once
    func getStreamsOnce(completion:@escaping ([Stream], Error?)->()){
        var streams:[Stream] = []
        
        if Reachability.isConnectedToNetwork(){
            
            let streamsRef = Database.database().reference().child("streams")
            streamsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(">>>getStreams called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                streams.removeAll()
                for snap in snapshots{
                    let dicStream = snap.value as! [String:Any]
                    let stream = Stream()
                    stream.initWithDic(dic: dicStream)
                    
                    // Check if the stream ended 4+ hours ago
                    let timestamp = dateSubtracted(hours: 4, from: Date()).timeIntervalSince1970 * 1000
                    if stream.endedAt < timestamp {
                        // If isSaveStream is false, remove the stream
                        if stream.isSaveStream == false{
                            self.deleteStream(streamId: stream.id)
                        }else{ // Do nothing
                            
                        }
                        continue
                    }
                    streams.append(stream)
                }
                completion(streams, nil)
            }, withCancel: { (error) in
                completion(streams, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(streams, err as Error)
        }
    }
    // Get streams with userId
    func getUserStreams(userId:String, completion:@escaping ([Stream], Error?)->()){
        var streams:[Stream] = []
        
        if Reachability.isConnectedToNetwork(){
            
            let streamsRef = Database.database().reference().child("streams")
            streamsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(">>>getUserStreams called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                for snap in snapshots{
                    let dicStream = snap.value as! [String:Any]
                    let stream = Stream()
                    stream.initWithDic(dic: dicStream)
                    
                    if stream.creatorId == userId && stream.isSaveStream == true{
                        streams.append(stream)
                    }
                }
                // Sort streams by timestamp
                streams.sort(by: { (first: Stream, second: Stream) -> Bool in
                    first.endedAt > second.endedAt
                })
                ///
                
                completion(streams, nil)
            }, withCancel: { (error) in
                completion(streams, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(streams, err as Error)
        }
    }
    func getUpcomingStreams(completion:@escaping (DatabaseHandle?, [Stream], Error?)->()){
        var streams:[Stream] = []
        var dbHandle:DatabaseHandle?
        
        if Reachability.isConnectedToNetwork(){
            
            let streamsRef = Database.database().reference().child("upcomingStreams")
            dbHandle = streamsRef.observe(.value, with: { (snapshot) in
                print(">>>getUpcomingStreams called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                streams.removeAll()
                let myUserId = UserDefaults.standard.string(forKey: "userId")!
                for snap in snapshots{
                    let dicStream = snap.value as! [String:Any]
                    let stream = Stream()
                    stream.initWithDic(dic: dicStream)
                    // Delete past streams up to 10 min ago
                    var timestamp = dateSubtracted(minutes: 10, from: Date()).timeIntervalSince1970
                    if stream.startAt < timestamp {
                        self.deleteUpcomingStream(streamId: stream.id)
                        continue
                    }
                    // Hide past streams up to 5 min ago
                    timestamp = dateSubtracted(minutes: 5, from: Date()).timeIntervalSince1970
                    if stream.startAt < timestamp {
                        continue
                    }
                    // Hide archived streams
                    if stream.type == "archived"{
                        continue
                    }
                    
                    // Sort upcomingStreams
                    // My streams come first
                    if stream.creatorId == myUserId{
                        streams.insert(stream, at: 0)
                    }else{
                        streams.append(stream)
                    }
                }
                completion(dbHandle, streams, nil)
            }, withCancel: { (error) in
                completion(dbHandle, streams, error)
            })
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(dbHandle, streams, err as Error)
        }
    }
    
    // Upload a stream to Firebase DB at "streams/{streamId}"
    func uploadStream(stream:Stream, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let streamRef = Database.database().reference().child("streams").child(stream.id)
            streamRef.setValue(stream.dictionary()) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
        
    }
    // Set resourceUri of an upcoming stream
    // Called from LiveStreamVC when the user starts an upcoming stream
    func setResourceUri(streamId:String, resourceUri:String, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("upcomingStreams").child(streamId).child("resourceUri")
            ref.setValue(resourceUri) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Update currentViewers to Firebase DB at "streams/{streamId}/currentViewers"
    func updateCurrentViewers(stream:Stream, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let streamRef = Database.database().reference().child("streams").child(stream.id)
            streamRef.child("currentViewers").setValue(stream.currentViewers) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Update totalViewers to Firebase DB at "streams/{streamId}/totalViewers"
    func updateTotalViewers(stream:Stream, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let streamRef = Database.database().reference().child("streams").child(stream.id)
            streamRef.child("totalViewers").setValue(stream.totalViewers) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    
    
    // Upload an upcoming stream to Firebase DB at "upcomingStreams/{streamId}"
    func uploadUpcomingStream(stream:Stream, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let streamRef = Database.database().reference().child("upcomingStreams").childByAutoId()
            stream.id = streamRef.key
            streamRef.setValue(stream.dictionary()) { (err, dataRef) in
                
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
            
        }
        
    }
    
    
    //-------------------------------------------------------------------------------------------------------------------------------
    // MARK: - Kudo
    // Approve a kudo to Firebase DB at "kudos/{userId}/{kudoId}"
    // Called from ApproveKudosVC
    func approveKudo(kudo:Kudo, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("kudos").child(kudo.receiverId).child(kudo.kudoId).child("isApproved")
            ref.setValue(true) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
        
    }
    // Upload a kudo to Firebase DB at "kudos/{userId}/{kudoId}"
    func uploadKudo(kudo:Kudo, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("kudos").child(kudo.receiverId).childByAutoId()
            kudo.kudoId = ref.key
            ref.setValue(kudo.dictionary()) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
        
    }
    // Get approved kudos only once
    // Called from AthleteProfileVC and ViewAthleteVC
    func getKudosOnce(userId:String, completion:@escaping ([Kudo], Error?)->()){
        var kudos:[Kudo] = []
        
        if Reachability.isConnectedToNetwork(){
            let kudosRef = Database.database().reference().child("kudos").child(userId)
            kudosRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(">>>getMyKudosOnce called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                for snap in snapshots{
                    let dicKudo = snap.value as! [String:Any]
                    let kudo = Kudo()
                    kudo.initWithDic(dic: dicKudo)
                    if kudo.isApproved == true{
                        kudos.append(kudo)
                    }
                }
                // Sort kudos by timestamp
                kudos.sort(by: { (first: Kudo, second: Kudo) -> Bool in
                    first.timestamp > second.timestamp
                })
                ///
                
                completion(kudos, nil)
            }, withCancel: { (error) in
                completion(kudos, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(kudos, err as Error)
        }
    }
    // Get pending kudos only once
    // Called from MessagesVC
    func getPendingKudosOnce(userId:String, completion:@escaping ([Kudo], Error?)->()){
        var kudos:[Kudo] = []
        
        if Reachability.isConnectedToNetwork(){
            let kudosRef = Database.database().reference().child("kudos").child(userId)
            kudosRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(">>>getMyKudosOnce called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                for snap in snapshots{
                    let dicKudo = snap.value as! [String:Any]
                    let kudo = Kudo()
                    kudo.initWithDic(dic: dicKudo)
                    if kudo.isApproved == false{
                        kudos.append(kudo)
                    }
                }
                // Sort kudos by timestamp
                kudos.sort(by: { (first: Kudo, second: Kudo) -> Bool in
                    first.timestamp > second.timestamp
                })
                ///
                completion(kudos, nil)
            }, withCancel: { (error) in
                completion(kudos, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(kudos, err as Error)
        }
    }
    // Delete one of my kudos
    // Called from AthleteProfileVC and ApproveKudoVC
    func deleteMyKudo(kudoId:String, completion: @escaping (_ error:Error?)->()){
        
        if Reachability.isConnectedToNetwork(){
            let userId = UserDefaults.standard.string(forKey: "userId")
            let ref = Database.database().reference().child("kudos").child(userId!).child(kudoId)
            ref.removeValue(completionBlock: { (error, ref) in
                if error == nil{
                    print(">>>Kudo: \(kudoId) deleted")
                    completion(nil)
                }else{
                    completion(error)
                }
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    // MARK: - Storage
    // Upload image to Firebase storage
    // Called from LiveStreamVC
    func uploadImage(image:UIImage, imageName:String, completion:@escaping (String)->()){
        
        if Reachability.isConnectedToNetwork(){
            
            guard let imageData = UIImageJPEGRepresentation(image, 0.6) else { return }
            let imagePath = "snapshots/" + imageName
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            Storage.storage().reference().child(imagePath)
                .putData(imageData, metadata: metadata) { (metadata, error) in
                    
                    if let error = error {
                        print(">>>Failed to upload a snapshot. Error: \(error)")
                        completion("")
                        
                    }else{
                        completion((metadata?.downloadURL()!.absoluteString)!)
                    }
            }
            
        }else{
            print(">>>Not connected to the Internet")
            completion("")
        }
        
    }
    
    // Send an image via Firebase Storage
    // Called when editing profiles
    func sendImage(_ image:UIImage, showHUD:Bool, view:UIView, completion:@escaping (StorageMetadata)->()){
        
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.determinateHorizontalBar;
        if showHUD == false{
            hud.hide(animated: true)
        }
        
        // Upload cropped image to Firebase storage
        guard let imageData = UIImageJPEGRepresentation(image, 0.6) else { return }
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let imagePath = userId + ".jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let storageRef = Storage.storage().reference()
        
        let task = storageRef.child("profilePhotos").child(imagePath).putData(imageData, metadata: metadata, completion: { (metadata, error) in
            if showHUD == true{
                hud.hide(animated: true)
            }
            
            if let error = error {
                print("Error uploading: \(error)")
                showAlert(title: nil, message: "Failed to upload the image", controller: nil, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                return
            }
            
            completion(metadata!)
        })
        
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            hud.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
        }
        
    }
    // Upload an image on Firebase Storage
    // Called from ChatVC when sending image messages
    func uploadImageMessage(_ image:UIImage, showHUD:Bool, view:UIView, completion:@escaping (StorageMetadata)->()){
        
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.determinateHorizontalBar;
        if showHUD == false{
            hud.hide(animated: true)
        }
        
        // Upload cropped image to Firebase storage
        guard let imageData = UIImageJPEGRepresentation(image, 0.6) else { return }
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let imagePath = "\(userId)/\(Int(Date.timeIntervalSinceReferenceDate)).jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let storageRef = Storage.storage().reference()
        
        let task = storageRef.child("imageMessages").child(imagePath).putData(imageData, metadata: metadata, completion: { (metadata, error) in
            if showHUD == true{
                hud.hide(animated: true)
            }
            
            if let error = error {
                print("Error uploading: \(error)")
                showAlert(title: nil, message: "Failed to upload the image", controller: nil, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                return
            }
            
            completion(metadata!)
        })
        
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            hud.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------
    // MARK: - User
    // Block user
    func blockUser(userId:String, completion:@escaping (Error?)->()){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        let ref = Database.database().reference().child("users").child(myUserId).child("blockedUsers").child(userId)
        
        if Reachability.isConnectedToNetwork(){
            ref.setValue(userId) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Favorite user
    // Called from ViewAthleteVC by coaches
    func favoriteUser(userId:String, completion:@escaping (Error?)->()){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        let ref = Database.database().reference().child("users").child(myUserId).child("favoriteUsers").child(userId)
        
        if Reachability.isConnectedToNetwork(){
            ref.setValue(userId) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Follow user
    func followUser(userId:String, completion:@escaping (Error?)->()){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        let ref = Database.database().reference().child("users").child(myUserId).child("following").child(userId)
        
        if Reachability.isConnectedToNetwork(){
            ref.setValue(userId) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Get user with userId
    func getUser(userId:String, completion:@escaping (User, Error?)->()){
        let user = User()
        
        if Reachability.isConnectedToNetwork(){
            
            let ref = Database.database().reference().child("users").child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let dic = snapshot.value as? [String:Any]
                if dic != nil{
                    user.initWithDic(dic: dic!)
                }
                completion(user, nil)
            }, withCancel: { (error) in
                completion(user, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(user, err as Error)
        }
    }
    
    // Get user email for userId
    // Called from ReportUserVC
    func getUserEmail(userId:String, completion:@escaping (String, Error?)->()){
        
        if Reachability.isConnectedToNetwork(){
            
            let ref = Database.database().reference().child("users").child(userId).child("email")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let email = snapshot.value as! String
                
                completion(email, nil)
            }, withCancel: { (error) in
                completion("", error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion("", err as Error)
        }
    }
    
    
    // Get coaches from Firebase Database for an athlete
    // [Bool] is an array used to check/uncheck coaches
    func getCoaches(completion:@escaping ([User], [Bool], Error?)->()){
        var coaches:[User] = []
        var selected:[Bool] = []
        
        if Reachability.isConnectedToNetwork(){
            
            let usersRef = Database.database().reference().child("users")
            usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                for snap in snapshots{
                    let dicUser = snap.value as! [String:Any]
                    let user = User()
                    user.initWithDic(dic: dicUser)
                    if user.userType == UserType.coach.rawValue{
                        let state = dicUser["state"] as! String
                        if state == "verified"{
                            coaches.append(user)
                            selected.append(false)
                        }
                    }
                    
                }
                completion(coaches, selected, nil)
            }, withCancel: { (error) in
                completion(coaches, selected, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(coaches, selected, err as Error)
        }
    }
    
    // Get users from Firebase Database
    // [Bool] is an array used to check/uncheck users
    // Used for AuthrizedUsersVC
    func getAuthorizedUsers(completion:@escaping ([User], [Bool], Int, Error?)->()){
        var users:[User] = []
        var selected:[Bool] = []
        var nAuthUsers:Int = 0
        
        if Reachability.isConnectedToNetwork(){
            
            let usersRef = Database.database().reference().child("users")
            usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                let authUsers = UserDefaults.standard.object(forKey: "authorizedUsers") as! [String:String]
                let userId = UserDefaults.standard.string(forKey: "userId")
                
                for snap in snapshots{
                    let dicUser = snap.value as! [String:Any]
                    let user = User()
                    user.initWithDic(dic: dicUser)
                    // Skip oneself
                    if user.userId == userId{ continue }
                    
                    if user.userType == UserType.coach.rawValue{
                        let state = dicUser["state"] as! String
                        if state == "verified"{
                            users.append(user)
                            if authUsers[user.userId] != nil{
                                selected.append(true)
                                nAuthUsers += 1
                            }else{
                                selected.append(false)
                            }
                        }
                    }else{
                        users.append(user)
                        if authUsers[user.userId] != nil{
                            selected.append(true)
                            nAuthUsers += 1
                        }else{
                            selected.append(false)
                        }
                    }
                    
                }
                completion(users, selected, nAuthUsers, nil)
            }, withCancel: { (error) in
                completion(users, selected, nAuthUsers, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(users, selected, nAuthUsers, err as Error)
        }
    }
    
    // Get blocked users from Firebase Database
    // Used for BlockedUsersVC
    func getBlockedUsers(completion:@escaping ([User], Error?)->()){
        var users:[User] = []
        
        if Reachability.isConnectedToNetwork(){
            
            let usersRef = Database.database().reference().child("users")
            usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                let blockedUsers = UserDefaults.standard.object(forKey: "blockedUsers") as! [String:String]
                
                for snap in snapshots{
                    let dicUser = snap.value as! [String:Any]
                    let user = User()
                    user.initWithDic(dic: dicUser)
                    
                    if blockedUsers[user.userId] == nil{
                        continue
                    }
                    
                    if user.userType == UserType.coach.rawValue{
                        let state = dicUser["state"] as! String
                        if state == "verified"{
                            users.append(user)
                        }
                    }else{
                        users.append(user)
                    }
                    
                }
                completion(users, nil)
            }, withCancel: { (error) in
                completion(users, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(users, err as Error)
        }
    }
    
    // Get users from Firebase Database
    // Used for SearchVC
    func getUsers(completion:@escaping ([User], Error?)->()){
        var users:[User] = []
        
        if Reachability.isConnectedToNetwork(){
            
            let usersRef = Database.database().reference().child("users")
            usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                let myUserId = UserDefaults.standard.string(forKey: "userId")!
                for snap in snapshots{
                    let dicUser = snap.value as! [String:Any]
                    let user = User()
                    user.initWithDic(dic: dicUser)
                    // Ignore myself
                    if user.userId == myUserId {continue}
                    
                    
                    if user.userType == UserType.coach.rawValue{
                        if user.state == "verified"{
                            users.append(user)
                        }
                    }else{
                        users.append(user)
                    }
                    
                }
                completion(users, nil)
            }, withCancel: { (error) in
                completion(users, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(users, err as Error)
        }
    }
    
    // Get onBehalfOf users from Firebase Database
    // Used for StartLiveStreamVC
    func getOnBehalfOfUsers(completion:@escaping ([String:String], Error?)->()){
        var users:[String:String] = [:]
        
        if Reachability.isConnectedToNetwork(){
            let userId = UserDefaults.standard.string(forKey: "userId")!
            let ref = Database.database().reference().child("users").child(userId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let dicUser = snapshot.value as! [String:Any]
                
                if dicUser["onBehalfOfUsers"] != nil{
                    users = dicUser["onBehalfOfUsers"] as! [String : String]
                }
                
                completion(users, nil)
            }, withCancel: { (error) in
                completion(users, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(users, err as Error)
        }
    }
    // Get nSavedStreams property of a user.
    // Called from StartLiveStreamVC
    func getNSavedStreams(userId:String, completion:@escaping (Int, Error?)->()){
        var nSavedStreams = 0
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let dicUser = snapshot.value as! [String:Any]
                
                if dicUser["nSavedStreams"] != nil{
                    nSavedStreams = dicUser["nSavedStreams"] as! Int
                }
                
                completion(nSavedStreams, nil)
            }, withCancel: { (error) in
                completion(0, error)
            })
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(0, err as Error)
        }
    }
    // Get followers once
    func getFollowersOnce(user:User, completion:@escaping ([User], Error?)->()){
        var followers:[User] = []
        
        if Reachability.isConnectedToNetwork(){
//            let dicFollower = UserDefaults.standard.object(forKey: "follower") as! [String:String]
            let dicFollower = user.follower
            let ref = Database.database().reference().child("users")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print(">>>getFollowersOnce called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                for snap in snapshots{
                    let dic = snap.value as! [String:Any]
                    let user = User()
                    user.initWithDic(dic: dic)
                    if dicFollower[user.userId] != nil{
                        followers.append(user)
                    }
                }
                completion(followers, nil)
            }, withCancel: { (error) in
                completion(followers, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(followers, err as Error)
        }
    }
    
    // Get following once
    func getFollowingOnce(user:User, completion:@escaping ([User], Error?)->()){
        var following:[User] = []
        
        if Reachability.isConnectedToNetwork(){
//            let dicFollowing = UserDefaults.standard.object(forKey: "following") as! [String:String]
            let dicFollowing = user.following
            let ref = Database.database().reference().child("users")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print(">>>getFollowingOnce called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                for snap in snapshots{
                    let dic = snap.value as! [String:Any]
                    let user = User()
                    user.initWithDic(dic: dic)
                    if dicFollowing[user.userId] != nil{
                        following.append(user)
                    }
                }
                completion(following, nil)
            }, withCancel: { (error) in
                completion(following, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(following, err as Error)
        }
    }
    
    // Get favorite users once
    func getFavoritesOnce(user:User, completion:@escaping ([User], Error?)->()){
        var following:[User] = []
        
        if Reachability.isConnectedToNetwork(){
//            let dicFollowing = UserDefaults.standard.object(forKey: "favoriteUsers") as! [String:String]
            let dicFollowing = user.favoriteUsers
            let ref = Database.database().reference().child("users")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print(">>>getFavoritesOnce called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                for snap in snapshots{
                    let dic = snap.value as! [String:Any]
                    let user = User()
                    user.initWithDic(dic: dic)
                    if dicFollowing[user.userId] != nil{
                        following.append(user)
                    }
                }
                completion(following, nil)
            }, withCancel: { (error) in
                completion(following, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(following, err as Error)
        }
    }
    
    
    // Get profile for userId
    func getAthleteProfile(userId:String, completion:@escaping (AthleteProfile, Error?)->()){
        let profile = AthleteProfile()
        
        if Reachability.isConnectedToNetwork(){
            
            let profileRef = Database.database().reference().child("profiles").child(userId)
            profileRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let dicProfile = snapshot.value as? [String:Any]
                if dicProfile != nil{
                    profile.initWithDic(dic: dicProfile!)
                }
                completion(profile, nil)
            }, withCancel: { (error) in
                completion(profile, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(profile, err as Error)
        }
    }
    
    
    // Set isPrivate property of a user
    func setIsPrivate(userId:String, isPrivate:Bool, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId).child("isPrivate")
            ref.setValue(isPrivate) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Set isSomeoneFollows property of a user
    func setIsSomeoneFollows(userId:String, isSomeoneFollows:Bool, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId).child("isSomeoneFollows")
            ref.setValue(isSomeoneFollows) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Set isScheduledStream property of a user
    func setIsScheduledStream(userId:String, isScheduledStream:Bool, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId).child("isScheduledStream")
            ref.setValue(isScheduledStream) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Set isFriendStarts property of a user
    func setIsFriendStarts(userId:String, isFriendStarts:Bool, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId).child("isFriendStarts")
            ref.setValue(isFriendStarts) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Set isInvites property of a user
    func setIsInvites(userId:String, isInvites:Bool, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId).child("isInvites")
            ref.setValue(isInvites) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Set expiryTimestamp property of a user.
    // The expiryTimestamp value is the timestamp of the expirydate.
    // Called from UpgradeVC
    func setExpiryTimestamp(userId:String, expiryTimestamp:Double, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId).child("expiryTimestamp")
            ref.setValue(expiryTimestamp) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Set nSavedStreams property of a user.
    // Called from LiveStreamVC
    func setNSavedStreams(userId:String, nSavedStreams:Int, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId).child("nSavedStreams")
            ref.setValue(nSavedStreams) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    // Unblock user
    func unblockUser(userId:String, completion:@escaping (Error?)->()){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        let ref = Database.database().reference().child("users").child(myUserId).child("blockedUsers").child(userId)
        
        if Reachability.isConnectedToNetwork(){
            ref.removeValue(completionBlock: { (err, dataRef) in
                completion(err)
            })
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Unfollow user
    func unfollowUser(userId:String, completion:@escaping (Error?)->()){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        let ref = Database.database().reference().child("users").child(myUserId).child("following").child(userId)
        
        if Reachability.isConnectedToNetwork(){
            ref.setValue(nil){ (error, dataRef) in
                completion(error)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Unfavorite user
    func unfavoriteUser(userId:String, completion:@escaping (Error?)->()){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        let ref = Database.database().reference().child("users").child(myUserId).child("favoriteUsers").child(userId)
        
        if Reachability.isConnectedToNetwork(){
            ref.setValue(nil){ (error, dataRef) in
                completion(error)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Update email in Firebase DB
    func updateEmail(email:String, completion:@escaping (Error?)->()){
        let userId = UserDefaults.standard.string(forKey: "userId")
        let ref = Database.database().reference().child("users").child(userId!).child("email")
        
        if Reachability.isConnectedToNetwork(){
            ref.setValue(email) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Upload OneSignal userId to Firebase DB
    func uploadOneSignalUserId(userId:String, completion:@escaping (Error?)->()){
        
        guard let user = Auth.auth().currentUser else{return}
        let userRef = Database.database().reference().child("users").child((user.uid))
        
        if Reachability.isConnectedToNetwork(){
            
            
            userRef.child("oneSignalUserId").setValue(userId) { (err, dataRef) in
                
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
            
        }
    }
    // Upload authorized users to Firebase DB at "users/{userId}/authorizedUsers"
    func uploadAuthorizedUsers(authorizedUsers:[String:String], completion:@escaping (Error?)->()){
        let userId = UserDefaults.standard.string(forKey: "userId")!
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId).child("authorizedUsers")
            ref.setValue(authorizedUsers) { (err, dataRef) in
                completion(err)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
            
        }
        
    }
    
    // Update an athlete info(firstName, lastName, category, city, province, imageURL and athleteProfile) to Firebase DB at "users/{userId}"
    // Called when the athlete edits and saves her profile
    func updateUser(user:User, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(user.userId)
            var dic:[String:Any] = [:]
            dic["firstName"] = user.firstName
            dic["lastName"] = user.lastName
            dic["category"] = user.category
            dic["city"] = user.city
            dic["province"] = user.province
            dic["imageURL"] = user.imageURL
            if user.userType == UserType.athlete.rawValue{
                dic["athleteProfile"] = user.athleteProfile?.dictionary()
            }
            ref.updateChildValues(dic, withCompletionBlock: { (error, ref) in
                completion(error)
            })
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Update the imageURL to Firebase DB at "users/{userId}/imageURL"
    // Called when the athlete uploads a photo
    func updateUserPhoto(imageURL:String, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let userId = UserDefaults.standard.string(forKey: "userId")!
            let ref = Database.database().reference().child("users").child(userId).child("imageURL")
            ref.setValue(imageURL, withCompletionBlock: { (error, databaseRef) in
                completion(error)
            })
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Update a coach info(imageURL and city, province/state, and extra/company) to Firebase DB at "users/{userId}"
    // Called when a coach/pro edits and saves her profile
    func updateCoach(firstName:String, lastName:String, category:String,
                     imageURL:String, city:String, province:String, extra:String, completion:@escaping (Error?)->()){
        let userId = UserDefaults.standard.string(forKey: "userId")!
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("users").child(userId)
            var dic:[String:Any] = [:]
            dic["firstName"] = firstName
            dic["lastName"] = lastName
            dic["category"] = category
            dic["imageURL"] = imageURL
            dic["city"] = city
            dic["province"] = province
            dic["extra"] = extra
            
            ref.updateChildValues(dic, withCompletionBlock: { (error, ref) in
                completion(error)
            })
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    // MARK: - Messages
    // Get messagingUsers from Firebase at "messagingUsers/{userId}"
    // Called from MessagesVC
    func getMessagingUsers(userId:String, completion:@escaping ([MessagingUser], Error?)->()){
        var users:[MessagingUser] = []
        
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("messagingUsers").child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print(">>>getMessagingUsers called")
                let snapshots = snapshot.children.allObjects as! [DataSnapshot]
                
                for snap in snapshots{
                    let dic = snap.value as! [String:Any]
                    let user = MessagingUser()
                    user.initWithDic(dic: dic)
                    users.append(user)
                }
                // Sort users by timestamp
                users.sort(by: { (first: MessagingUser, second: MessagingUser) -> Bool in
                    first.timestamp > second.timestamp
                })
                ///
                completion(users, nil)
            }, withCancel: { (error) in
                completion(users, error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(users, err as Error)
        }
    }
    // Delete a messagingUser from Firebase at "messagingUsers/{myUserId}/{userId}"
    // Called from MessagesVC
    func deleteMessagingUser(userId:String, completion:@escaping (Error?)->()){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        if Reachability.isConnectedToNetwork(){
            let ref = Database.database().reference().child("messagingUsers").child(myUserId).child(userId)
            ref.removeValue(completionBlock: { (error, databaseRef) in
                completion(error)
            })
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Check if I'm blocked by the user
    // Called from ChatContainerVC
    func observeIfBlockedByUser(userId:String, completion:@escaping (DatabaseHandle?, Bool, Error?)->()){
        var dbHandle:DatabaseHandle?
        
        if Reachability.isConnectedToNetwork(){
            let myUserId = UserDefaults.standard.string(forKey: "userId")!
            let blockedRef = Database.database().reference().child("users").child(userId).child("blockedUsers").child(myUserId)
            dbHandle = blockedRef.observe(.value, with: { (snapshot) in
                print(">>>observeIfBlockedByUser called")
                if (snapshot.value as? String) != nil{
                    completion(dbHandle, true, nil)
                }else{
                    completion(dbHandle, false, nil)
                }
                
            }) { (error) in
                
                completion(dbHandle, false, error)
            }
            
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(dbHandle, false, err as Error)
        }
        
    }
    // Check if I and the user muted notifications
    // Called from ChatContainerVC
    func observeMuteNotifications(userId:String, completion:@escaping (DatabaseHandle?, Bool, Bool, Error?)->()){
        var dbHandle:DatabaseHandle?
        if Reachability.isConnectedToNetwork(){
            let myUserId = UserDefaults.standard.string(forKey: "userId")!
            var channelId:String!
            if myUserId.compare(userId) == ComparisonResult.orderedAscending{
                channelId = myUserId + "-" + userId
            }else{
                channelId = userId + "-" + myUserId
            }
            let ref = Database.database().reference().child("channels").child(channelId).child("muteNotifications")
            dbHandle = ref.observe(.value, with: { (snapshot) in
                let dic = snapshot.value as? [String:Any]
                if dic != nil{
                    var isMutedByMe = dic?[myUserId] as? Bool
                    var isMutedByUser = dic?[userId] as? Bool
                    if isMutedByMe == nil{
                        isMutedByMe = false
                    }
                    if isMutedByUser == nil{
                        isMutedByUser = false
                    }
                    completion(dbHandle, isMutedByMe!, isMutedByUser!, nil)
                }else{
                    completion(dbHandle, false, false, nil) // Not muted as default
                }
                
            }) { (error) in
                
                completion(dbHandle, false, false, error)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(dbHandle, false, false, err as Error)
        }
        
        
    }
    
    // Set muteNotifications to true or false
    // Called from ChatContainerVC
    func setMuteNotifications(userId:String, isMuted:Bool, completion:@escaping (Error?)->()){
        if Reachability.isConnectedToNetwork(){
            let myUserId = UserDefaults.standard.string(forKey: "userId")!
            var channelId:String!
            if myUserId.compare(userId) == ComparisonResult.orderedAscending{
                channelId = myUserId + "-" + userId
            }else{
                channelId = userId + "-" + myUserId
            }
            let ref = Database.database().reference().child("channels").child(channelId).child("muteNotifications").child(myUserId)
            ref.setValue(isMuted) { (error, dbRef) in
                completion(error)
            }
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion(err as Error)
        }
    }
    
    // Get OneSignal userId from Firebase DB
    // Called from ChatContainerVC
    func getOneSignalUserId(userId:String, completion:@escaping (String, Error?)->()){
        
        let ref = Database.database().reference().child("users").child((userId))
        
        if Reachability.isConnectedToNetwork(){
            
            ref.child("oneSignalUserId").observeSingleEvent(of: .value, with: { (snapshot) in
                let oneSignalUserId = snapshot.value as! String
                completion(oneSignalUserId, nil)
            }, withCancel: { (error) in
                completion("", error)
            })
        }else{
            let err = NSError(domain:"", code:0, userInfo:nil)
            completion("", err as Error)
        }
    }
    
    
}
