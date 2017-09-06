//
//  AthleteStreamsViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/3/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseDatabase

class AthleteStreamsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var viewFilterBg: UIView!
    @IBOutlet weak var tvStreams: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    var streams:[Stream] = []
    var filteredStreams:[Stream] = []
    var refreshControl: UIRefreshControl!
    
    
    // MARK: - Lifecycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIDevice.current.setValue(NSNumber(integerLiteral:UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.viewFilter.isHidden = true
        self.viewFilter.layer.cornerRadius = 5
        self.viewFilterBg.isHidden = true
        
        // Show activity indicator while fetching streams
        self.tvStreams.tableFooterView = UIView()
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        // Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tvStreams.addSubview(refreshControl)
        
        self.getStreams()
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.getStreams()
    }
    func getStreams(){
        FirebaseUtil.shared.getStreams { (dbHandle, streams, error) in
            self.dbHandle = dbHandle
            if error != nil{
                DispatchQueue.main.async {
                    if self.activityIndicator.isHidden == false{
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                }
                print(">>>Failed to get streams. Error: \(String(describing: error))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)

            }else{
                self.streams = streams
                self.filteredStreams = streams
                DispatchQueue.main.async {
                    if self.activityIndicator.isHidden == false{
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                    self.tvStreams.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    

    // MARK: - Button actions
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.closeFilterView()
    }
    func closeFilterView(){
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            self.viewFilter.isHidden = true
            
        }, completion: { (finished) -> Void in
            self.viewFilterBg.isHidden = true
        })
    }
    
    @IBAction func btnFollowingTapped(_ sender: UIButton) {
        self.closeFilterView()
        
        self.filteredStreams = []
        let following = UserDefaults.standard.object(forKey: "following") as? [String:String]
        if following == nil || following!.count < 1{
            self.tvStreams.reloadData()
            return
        }
        for stream in self.streams{
            if following?[stream.creatorId] != nil{
                self.filteredStreams.append(stream)
            }
        }
        self.tvStreams.reloadData()
    }
    
    @IBAction func btnViewAllTapped(_ sender: UIButton) {
        self.filteredStreams = self.streams
        self.tvStreams.reloadData()
        self.closeFilterView()
    }
    
    @IBAction func btnStartStreamTapped(_ sender: UIButton) {
        self.closeFilterView()
        navigateToVC(name: "StartLiveStreamViewController", fromVC: self, animated: true)
    }
    
    @IBAction func btnScheduleStreamTapped(_ sender: UIButton) {
        self.closeFilterView()
        let userType = UserDefaults.standard.string(forKey: "userType")
        if userType == UserType.athlete.rawValue{
            navigateToVC(name: "AthleteScheduleStreamViewController", fromVC: self, animated: true)
        }else{
            navigateToVC(name: "ScheduleStreamViewController", fromVC: self, animated: true)
        }
        
    }
    
    @IBAction func btnDotsTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            self.viewFilter.isHidden = false
            
        }, completion: { (finished) -> Void in
            self.viewFilterBg.isHidden = false
        })
        
    }
    
    // MARK: - UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to PlayerVC
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        vc.stream = self.filteredStreams[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredStreams.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StreamTableViewCell", for: indexPath) as! StreamTableViewCell
        let stream = self.filteredStreams[indexPath.row]
        
        cell.lblTitle.text = stream.title
        cell.lblUserName.text = stream.creatorName
        
        if stream.type == "live" {
            cell.ivLive.isHidden = false
            cell.lblWatching.text = "\(stream.currentViewers) watching"
        }else{
            cell.ivLive.isHidden = true
            cell.lblWatching.text = "\(stream.totalViewers) watched"
        }
        let url = URL(string: stream.imageURL)
        cell.ivStream.kf.setImage(with: url)
        cell.ivStream.kf.indicatorType = .activity
        
        print(">>>viewFrame")
        dump(cell.viewFrame.frame)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    // Used to remove observer when this view controller is dismissed
    private var dbHandle: DatabaseHandle?
    deinit{        
        if let handle = dbHandle {
            let streamsRef = Database.database().reference().child("streams")
            streamsRef.removeObserver(withHandle: handle)
            print(">>>streamsRef observer removed")
        }
    }
}

