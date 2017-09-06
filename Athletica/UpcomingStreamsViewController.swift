
//
//  UpcomingStreamsViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/18/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher

class UpcomingStreamsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var streams:[Stream] = []
    
    @IBOutlet weak var tvStreams: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tvStreams.tableFooterView = UIView()
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        // Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tvStreams.addSubview(refreshControl)
        
        self.getUpcomingStreams()
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.getUpcomingStreams()
    }
    func getUpcomingStreams(){
        FirebaseUtil.shared.getUpcomingStreams { (dbHandle, streams, error) in
            self.dbHandle = dbHandle
            if error != nil{
                DispatchQueue.main.async {
                    if self.activityIndicator.isHidden == false{
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                }
                print(">>>Failed to get streams. Error: \(String(describing: error))")
//                self.showErrorSnackBar(message: SnackbarMessage.noConnection)
                self.getUpcomingStreams()
            }else{
                self.streams = streams
                DispatchQueue.main.async {
                    if self.activityIndicator.isHidden == false{
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                    self.tvStreams.reloadData()
                    self.refreshControl.endRefreshing()
                }
                // Delete old streams in Firebase DB
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //  MARK: - UITableViewDataSource and Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.streams.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingStreamsTableViewCell") as! UpcomingStreamsTableViewCell
        if self.streams.count < 1 { return cell}
        
        let stream = self.streams[indexPath.row]
        
        cell.lblTitle.text = stream.title
        cell.lblCategory.text = stream.category
        cell.lblTime.text = stringWithTimestamp(timestamp: stream.startAt)
        cell.lblName.text = stream.creatorName
        
        if stream.creatorImageURL != ""{
            let url = URL(string: stream.creatorImageURL)
            cell.ivPhoto.kf.setImage(with: url)
            cell.ivPhoto.kf.indicatorType = .activity
        }
        cell.ivPhoto.layer.cornerRadius = 41.0
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let stream = self.streams[indexPath.row]
        
        // Return if the stream is already archived
        if stream.type == "archived"{
            showAlert(title: nil, message: "The stream has already ended!", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }
        
        // Check if the user is the creator or a viewer
        let myUserId = UserDefaults.standard.string(forKey: "userId")
        if stream.creatorId == myUserId{
            print(">>>The user is the creator")
            
            // Return if time isn't up yet
            let currentTimeStamp = Date().timeIntervalSince1970
            if stream.startAt > currentTimeStamp {
                print(">>>Too early to start the stream")
                self.showErrorSnackBar(message: "It's too early to start the stream.")
                return
            }
            
            // If the user sets the Save Stream switch on,
            // check if maximum number has been reached
            if stream.isSaveStream{
                // Starting my own stream
                // Get nSavedStreams of Mine
                let myUserId = UserDefaults.standard.string(forKey: "userId")!
                self.startAnimating()
                FirebaseUtil.shared.getNSavedStreams(userId: myUserId, completion: { (nSavedStreams, error) in
                    self.stopAnimating()
                    if error != nil{
                        print(">>>Failed to get nSavedStreams. Error: \(String(describing: error?.localizedDescription))")
                        showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                    }else{
                        if nSavedStreams > 4{
                            showAlert(title: nil, message: AlertMessage.maxNumOfYourSavedStreams, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                            
                        }else{
                            // Go to LiveStreamVC
                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "LiveStreamViewController") as! LiveStreamViewController
                            vc.creatorId = stream.creatorId
                            vc.creatorName = stream.creatorName
                            vc.category = stream.category
                            vc.happening = stream.title
                            vc.isSaveStream = true
                            vc.upcomingStreamId = stream.id
                            vc.nSavedStreams = nSavedStreams
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                })
                
            }else{
                // Go to LiveStreamVC
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LiveStreamViewController") as! LiveStreamViewController
                vc.creatorId = stream.creatorId
                vc.creatorName = stream.creatorName
                vc.category = stream.category
                vc.happening = stream.title
                vc.isSaveStream = true
                vc.upcomingStreamId = stream.id
                self.present(vc, animated: true, completion: nil)
            }
            
            
            
        }else{ // The user is a viewer
            print(">>>The user is a viewer")
            
            // Check if the stream has started
            if stream.resourceUri == ""{
                self.showErrorSnackBar(message: "This stream has not started yet. Hang tight!")
//                showAlert(title: nil, message: "This stream has not started yet. Hang tight!", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                return
            }
            
            // Go to PlayerVC
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            vc.stream = stream
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // Used to remove observer when this view controller is dismissed
    private var dbHandle: DatabaseHandle?
    deinit{        
        if let handle = dbHandle {
            let streamsRef = Database.database().reference().child("upcomingStreams")
            streamsRef.removeObserver(withHandle: handle)
            print(">>>streamsRef observer removed")
        }
    }

}
