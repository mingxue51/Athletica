//
//  AthleteProfileViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/2/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Photos


class AthleteProfileViewController: BaseViewController {
   
    var user = User()
    
    let aboutCellTitles = ["Bio", "Honors and Awards",
                           "School and Education", "Volunteering"]
    
    let statsCellTitles = ["Sport Stats", "Highlights and Other Stats"]
    
    
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var btnStats: UIButton!
    @IBOutlet weak var btnStreams: UIButton!
    @IBOutlet weak var btnKudos: UIButton!
    var activeButtonTitle:String!
    
    @IBOutlet weak var tvAbout: ExpyTableView!
    @IBOutlet weak var tvStats: ExpyTableView!
    @IBOutlet weak var viewAbout: UIView!
    @IBOutlet weak var viewStats: UIView!
    @IBOutlet weak var tvStreams: UITableView!
    @IBOutlet weak var viewStreams: UIView!
    @IBOutlet weak var viewKudos: UIView!
    @IBOutlet weak var tvKudos: UITableView!
    
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    
    //----- Streams section ------
    var streams:[Stream] = []
    var streamSelected:[Bool] = [] // Used for download
    
    @IBOutlet weak var indicatorStreams: UIActivityIndicatorView!
    var isStreamDownloaded:Bool = false
    
    @IBOutlet weak var viewDownload: UIView!
    var isDownloadMode:Bool = false
    
    var isDownloadingCanceled:Bool = false // Stop error snack bar if the view disappeared
    
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnDownloadAll: UIButton!
    //-----------------------------
    
    //----- Kudos section ------
    var kudos:[Kudo] = []
    var isKudoDownloaded:Bool = false
    @IBOutlet weak var indicatorKudos: UIActivityIndicatorView!
    
    //--------------------------
    
    var refreshControlStreams: UIRefreshControl!
    var refreshControlKudos: UIRefreshControl!
    
    
    @IBOutlet weak var viewUpgrade: UIView!
    
    
    
    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblName.adjustsFontSizeToFitWidth = true

        setupTableViews()
        setupButtons(title:"ABOUT")
        // Register nibs for table view cell
        self.registerNibs()
        
        self.ivPhoto.layer.cornerRadius = 40.0
        
        // Refresh control
        refreshControlStreams = UIRefreshControl()
        refreshControlStreams.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlStreams.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.tvStreams.addSubview(refreshControlStreams)
        
        refreshControlKudos = UIRefreshControl()
        refreshControlKudos.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlKudos.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.tvKudos.addSubview(refreshControlKudos)
        ///
        
        // Get user info from UserDefaults first
        self.user.initWithUserDefaults()
        
        // Show Followers and Following
        self.lblFollowers.text = String(self.user.follower.count)
        self.lblFollowing.text = String(self.user.following.count)
        
        self.getUser(userId:user.userId)
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        if sender as! NSObject == self.refreshControlStreams{
            self.getStreams()
        }else{
            self.getKudos()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupButtons(title:"ABOUT")
        
        //----- Show changed profile info when returned from AthleteEditProfileVC ----
        self.lblName.text = self.user.firstName + " " + self.user.lastName
        self.lblCategory.text = self.user.category
        
        let imageData = UserDefaults.standard.data(forKey: "imageData")
        if imageData != nil{
            self.ivPhoto.image = UIImage(data: imageData!)
        }else if self.user.imageURL != "" {
            let url = URL(string: self.user.imageURL)
            self.ivPhoto.kf.indicatorType = .activity
            self.ivPhoto.kf.setImage(with: url)
        }
        
        if self.user.city != "" && self.user.province != ""{
            self.lblLocation.text = self.user.city + ", " + self.user.province
        }
        
        self.tvAbout.reloadData()
        self.tvStats.reloadData()
        //----------------------------------------------------------------------------
        
        // Hide viewUpgrade if purchased
        // Check if the user has paid
        let timestamp = UserDefaults.standard.double(forKey: "expiryTimestamp")
        if isPurchasedAthlete(timestamp: timestamp){
            self.viewUpgrade.isHidden = true
        }
    }
    func getUser(userId:String){
        self.startAnimating()
        FirebaseUtil.shared.getUser(userId: userId) { (user, error) in
            self.stopAnimating()
            if error != nil{
                print(">>>Failed to get the user info. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.user = user
                self.tvAbout.reloadData()
                self.tvStats.reloadData()
                if self.user.city != "" && self.user.province != ""{
                    self.lblLocation.text = self.user.city + ", " + self.user.province
                }
                self.lblFollowers.text = String(self.user.follower.count)
                self.lblFollowing.text = String(self.user.following.count)
                let imageData = UserDefaults.standard.data(forKey: "imageData")
                if imageData == nil{
                    if self.user.imageURL != ""{
                        let url = URL(string: self.user.imageURL)
                        self.ivPhoto.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                            if image != nil{
                                UserDefaults.standard.set(UIImageJPEGRepresentation(image!, 1.0), forKey: "imageData")
                            }
                        })
                        
                    }
                }
                
            }
        }
    }
    func registerNibs(){
        // Nibs for profile detail cell
        // tvAbout
        let nib = UINib(nibName: "AthleteProfileBioTableViewCell", bundle: nil)
        self.tvAbout.register(nib, forCellReuseIdentifier: "AthleteProfileBioTableViewCell")
        
        let nibSchool = UINib(nibName: "AthleteProfileSchoolTableViewCell", bundle: nil)
        self.tvAbout.register(nibSchool, forCellReuseIdentifier: "AthleteProfileSchoolTableViewCell")
        
        let nibVolunteering = UINib(nibName: "AthleteProfileVolunteeringTableViewCell", bundle: nil)
        self.tvAbout.register(nibVolunteering, forCellReuseIdentifier: "AthleteProfileVolunteeringTableViewCell")
        
        let nibHonors = UINib(nibName: "AthleteProfileHonorsTableViewCell", bundle: nil)
        self.tvAbout.register(nibHonors, forCellReuseIdentifier: "AthleteProfileHonorsTableViewCell")
        
        // tvStats
        let nibHighlights = UINib(nibName: "AthleteProfileHighlightsTableViewCell", bundle: nil)
        self.tvStats.register(nibHighlights, forCellReuseIdentifier: "AthleteProfileHighlightsTableViewCell")
        // Nibs for each category
        let nibSoccer = UINib(nibName: "SoccerTableViewCell", bundle: nil)
        self.tvStats.register(nibSoccer, forCellReuseIdentifier: "SoccerTableViewCell")
        
        let nibBasketball = UINib(nibName: "BasketballTableViewCell", bundle: nil)
        self.tvStats.register(nibBasketball, forCellReuseIdentifier: "BasketballTableViewCell")
        
        let nibSwimming = UINib(nibName: "SwimmingTableViewCell", bundle: nil)
        self.tvStats.register(nibSwimming, forCellReuseIdentifier: "SwimmingTableViewCell")
        
        let nibTrack = UINib(nibName: "TrackTableViewCell", bundle: nil)
        self.tvStats.register(nibTrack, forCellReuseIdentifier: "TrackTableViewCell")
        
        let nibTennis = UINib(nibName: "TennisTableViewCell", bundle: nil)
        self.tvStats.register(nibTennis, forCellReuseIdentifier: "TennisTableViewCell")
        
        let nibSoftball = UINib(nibName: "SoftballTableViewCell", bundle: nil)
        self.tvStats.register(nibSoftball, forCellReuseIdentifier: "SoftballTableViewCell")
        
        let nibGolf = UINib(nibName: "GolfTableViewCell", bundle: nil)
        self.tvStats.register(nibGolf, forCellReuseIdentifier: "GolfTableViewCell")
        
        let nibVolleyball = UINib(nibName: "VolleyballTableViewCell", bundle: nil)
        self.tvStats.register(nibVolleyball, forCellReuseIdentifier: "VolleyballTableViewCell")
        
        let nibLacrosse = UINib(nibName: "LacrosseTableViewCell", bundle: nil)
        self.tvStats.register(nibLacrosse, forCellReuseIdentifier: "LacrosseTableViewCell")
        
        let nibHockey = UINib(nibName: "HockeyTableViewCell", bundle: nil)
        self.tvStats.register(nibHockey, forCellReuseIdentifier: "HockeyTableViewCell")
        
        let nibRowing = UINib(nibName: "RowingTableViewCell", bundle: nil)
        self.tvStats.register(nibRowing, forCellReuseIdentifier: "RowingTableViewCell")
        
        let nibWaterpolo = UINib(nibName: "WaterpoloTableViewCell", bundle: nil)
        self.tvStats.register(nibWaterpolo, forCellReuseIdentifier: "WaterpoloTableViewCell")
        
        let nibGymnastics = UINib(nibName: "GymnasticsTableViewCell", bundle: nil)
        self.tvStats.register(nibGymnastics, forCellReuseIdentifier: "GymnasticsTableViewCell")
        
        let nibSkiing = UINib(nibName: "SkiingTableViewCell", bundle: nil)
        self.tvStats.register(nibSkiing, forCellReuseIdentifier: "SkiingTableViewCell")
        
    }
    func setupTableViews(){
        tvAbout.dataSource = self
        tvAbout.delegate = self
        //Alter the animations as you want
        tvAbout.expandingAnimation = .fade
        tvAbout.collapsingAnimation = .fade
        tvAbout.tableFooterView = UIView()
        tvAbout.estimatedRowHeight = 65
        
        tvStats.dataSource = self
        tvStats.delegate = self
        //Alter the animations as you want
        tvStats.expandingAnimation = .fade
        tvStats.collapsingAnimation = .fade
        tvStats.tableFooterView = UIView()
        tvStats.estimatedRowHeight = 65
        
        tvStreams.dataSource = self
        tvStreams.delegate = self
        tvStreams.tableFooterView = UIView()
        tvStreams.estimatedRowHeight = 70
        
        tvKudos.dataSource = self
        tvKudos.delegate = self
        tvKudos.tableFooterView = UIView()
        tvKudos.estimatedRowHeight = 157
    }
    // Highlight a button with the title
    func setupButtons(title:String!){
        self.activeButtonTitle = title
        
        self.btnAbout.isSelected = false
        self.btnStats.isSelected = false
        self.btnStreams.isSelected = false
        self.btnKudos.isSelected = false
        self.btnAbout.titleLabel?.font = UIFont(name:"HelveticaNeue-Light", size: 15.0)
        self.btnStats.titleLabel?.font = UIFont(name:"HelveticaNeue-Light", size: 15.0)
        self.btnStreams.titleLabel?.font = UIFont(name:"HelveticaNeue-Light", size: 15.0)
        self.btnKudos.titleLabel?.font = UIFont(name:"HelveticaNeue-Light", size: 15.0)
        
        self.viewAbout.isHidden = true
        self.viewStats.isHidden = true
        self.viewStreams.isHidden = true
        self.viewKudos.isHidden = true
        self.viewUpgrade.isHidden = true
        
        switch title {
        case "ABOUT":
            self.btnAbout.isSelected = true
            self.btnAbout.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
            self.viewAbout.isHidden = false
            
        case "STATS":
            self.btnStats.isSelected = true
            self.btnStats.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
            self.viewStats.isHidden = false
            
        case "SAVED":
            self.btnStreams.isSelected = true
            self.btnStreams.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
            self.viewStreams.isHidden = false
            
        case "KUDOS":
            self.btnKudos.isSelected = true
            self.btnKudos.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
            self.viewKudos.isHidden = false
            
        default:
            break
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
    
    // MARK: - Button actions
    @IBAction func btnAboutTapped(_ sender: UIButton) {
        setupButtons(title: sender.titleLabel?.text)
       
    }
    @IBAction func btnStatsTapped(_ sender: UIButton) {
        setupButtons(title: sender.titleLabel?.text)
        
    }
    @IBAction func btnStreamsTapped(_ sender: UIButton) {
        
        setupButtons(title: sender.titleLabel?.text)
        
        // Check if the user has paid
        let timestamp = UserDefaults.standard.double(forKey: "expiryTimestamp")
        if !isPurchasedAthlete(timestamp: timestamp){
            self.viewUpgrade.isHidden = false
            return
        }
        
        self.isDownloadMode = false
        self.viewDownload.isHidden = true
        
        if self.isStreamDownloaded {
            // If it was in downloadMode,
            // reload tvStreams so it can show trash icons
            self.tvStreams.reloadData()
            return
        }
        
        // Show activity indicator while fetching streams
        self.indicatorStreams.startAnimating()
        self.indicatorStreams.isHidden = false
        
        self.getStreams()
    }
    func getStreams(){
        let userId = UserDefaults.standard.string(forKey: "userId")!
        FirebaseUtil.shared.getUserStreams(userId: userId) { (streams, error) in
            if error != nil{
                DispatchQueue.main.async {
                    if self.indicatorStreams.isHidden == false{
                        self.indicatorStreams.isHidden = true
                        self.indicatorStreams.stopAnimating()
                    }
                }
                print(">>>Failed to get streams. Error: \(String(describing: error))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.streams = streams
                for _ in streams{
                    self.streamSelected.append(false)
                }
                self.isStreamDownloaded = true
                DispatchQueue.main.async {
                    if self.indicatorStreams.isHidden == false{
                        self.indicatorStreams.isHidden = true
                        self.indicatorStreams.stopAnimating()
                    }
                    self.tvStreams.reloadData()
                    self.refreshControlStreams.endRefreshing()
                }
            }
        }
    }
    @IBAction func btnKudosTapped(_ sender: UIButton) {
        setupButtons(title: sender.titleLabel?.text)
        
        // Check if the user has paid
        let timestamp = UserDefaults.standard.double(forKey: "expiryTimestamp")
        if !isPurchasedAthlete(timestamp: timestamp){
            self.viewUpgrade.isHidden = false
            return
        }
        
        if self.isKudoDownloaded {
            return
        }
        
        // Show activity indicator while fetching kudos
        self.indicatorKudos.startAnimating()
        self.indicatorKudos.isHidden = false
        
        self.getKudos()
    }
    func getKudos(){
        FirebaseUtil.shared.getKudosOnce(userId: self.user.userId) { (kudos, error) in
            if error != nil{
                DispatchQueue.main.async {
                    if self.indicatorKudos.isHidden == false{
                        self.indicatorKudos.isHidden = true
                        self.indicatorKudos.stopAnimating()
                    }
                }
                print(">>>Failed to get streams. Error: \(String(describing: error))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.kudos = kudos
                self.isKudoDownloaded = true
                DispatchQueue.main.async {
                    if self.indicatorKudos.isHidden == false{
                        self.indicatorKudos.isHidden = true
                        self.indicatorKudos.stopAnimating()
                    }
                    self.tvKudos.reloadData()
                    self.refreshControlKudos.endRefreshing()
                }
            }
        }
    }
    @IBAction func btnUpgradeTapped(_ sender: UIButton) {
        navigateToVC(name: "UpgradeViewController", fromVC: self, animated: true)
    }
    
    
    @IBAction func btnPlayTapped(_ sender: Any) {
        navigateToVC(name: "StartLiveStreamViewController", fromVC: self, animated: true)
    }
    @IBAction func btnScheduleTapped(_ sender: UIButton) {
        navigateToVC(name: "AthleteScheduleStreamViewController", fromVC: self, animated: true)
    }
    
    @IBAction func btnEditTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AthleteEditProfileViewController") as! AthleteEditProfileViewController
        vc.oldUser = self.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMessagesTapped(_ sender: UIButton) {
        navigateToVC(name: "MessagesViewController", fromVC: self, animated: true)
    }

    @IBAction func btnArrowDownTapped(_ sender: UIButton) {
        if self.streams.count < 1{
            showAlert(title: nil, message: "You have no streams published", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }
        self.isDownloadMode = true
        self.viewDownload.isHidden = false
        self.tvStreams.reloadData()
    }
    @IBAction func btnDownloadTapped(_ sender: UIButton) {
        if self.countStreamsSelected() < 1 {
            showAlert(title: nil, message: "Please select streams to download first", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }
        // Disable Download and Download All buttons while downloading
        self.btnDownload.isHidden = true
        self.btnDownloadAll.isHidden = true
        self.isDownloadingCanceled = false
        self.downloadStreamWith(index: 0)
    }
    // Returns the number of streams selected
    func countStreamsSelected()->Int{
        var count = 0
        for item in self.streamSelected{
            if item == true{
                count += 1
            }
        }
        return count
    }
    
    func downloadStreamWith(index:Int){
        print(">>>downloadStream \(index) called")
        if self.isDownloadingCanceled == true{
            return
        }
        
        if index >= self.streamSelected.count {
            // Download finished            
            showAlert(title: nil, message: "Download finished", controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                self.btnDownload.isHidden = false
                self.btnDownloadAll.isHidden = false
            }, cancelAction: nil)
            return
        }
        
        if self.streamSelected[index] == true{
            let stream = self.streams[index]
            self.downloadStream(stream: stream, completion: { (error) in
                if error != nil{
                    print(">>>Failed to download streams. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: "Failed to download streams. Please check the Internet connection.", controller: nil, okTitle: "OK", cancelTitle: nil, okAction: {
                        // Download failed.
                        self.btnDownload.isHidden = false
                        self.btnDownloadAll.isHidden = false
                    }, cancelAction: nil)
                }else{
                    self.downloadStreamWith(index: index+1)
                }
                
            })
           
        }else{
            self.downloadStreamWith(index: index+1)
        }
    }
    @IBAction func btnDownloadAllTapped(_ sender: UIButton) {
        if self.streamSelected.count < 1 {return}
        
        for index in 0...self.streamSelected.count-1{
            self.streamSelected[index] = true
        }
        self.tvStreams.reloadData()
        self.btnDownloadTapped(sender)
    }
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.isDownloadMode = false
        self.viewDownload.isHidden = true
        self.tvStreams.reloadData()
        
        self.btnDownload.isHidden = false
        self.btnDownloadAll.isHidden = false
        self.isDownloadingCanceled = true
    }
    @IBAction func btnTrashTapped(_ sender: UIButton) {
        print(">>>Trash button \(sender.tag) tapped")
        let stream = self.streams[sender.tag]
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this?\nDeleting can not be undone.", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes, Delete", style: .cancel) { (action) in
            self.startAnimating()
            FirebaseUtil.shared.deleteMyStream(streamId: stream.id, completion: { (error) in
                self.stopAnimating()
                if error != nil{
                   showAlert(title: nil, message: "Failed to delete the stream. Please check the Internet connection.", controller: nil, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.streams.remove(at: sender.tag)
                    self.streamSelected.remove(at: sender.tag)
                    self.tvStreams.reloadData()
                    self.showSuccessSnackBar(message: "Stream deleted")
                    
                    //----- Decrease nSavedStreams by 1 -----
                    var nSavedStreams = 0
                    if let temp = UserDefaults.standard.object(forKey: "nSavedStreams"){
                        nSavedStreams = temp as! Int
                    }
                    nSavedStreams -= 1
                    
                    UserDefaults.standard.set(nSavedStreams, forKey: "nSavedStreams")
                    UserDefaults.standard.synchronize()
                    
                    self.setNSavedStreams(nSavedStreams:nSavedStreams)
                    //-----------------------------------
                }
            })
        }
        let noAction = UIAlertAction(title: "No, Keep", style: .default) { (action) in
            
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    func setNSavedStreams(nSavedStreams:Int){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        FirebaseUtil.shared.setNSavedStreams(userId: myUserId, nSavedStreams: nSavedStreams) { (error) in
            if error != nil{
                print(">>>Failed to set nSavedStreams. Error: \(String(describing: error?.localizedDescription))")
                self.setNSavedStreams(nSavedStreams: nSavedStreams)
            }else{
                print(">>>Success to set nSavedStreams")
            }
        }
    }
    
    @IBAction func btnRadioTapped(_ sender: UIButton) {
        print(">>>Radio button \(sender.tag) tapped")
        self.streamSelected[sender.tag] = !self.streamSelected[sender.tag]
        if self.streamSelected[sender.tag] == true{
            sender.setImage(UIImage(named:"radio"), for: .normal)
        }else{
            sender.setImage(UIImage(named:"radioUnchecked"), for: .normal)
        }
    }
    
    @IBAction func btnTrashKudosTapped(_ sender: UIButton) {
        print(">>>Trash button \(sender.tag) tapped")
        let kudo = self.kudos[sender.tag]
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this?\nDeleting can not be undone.", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes, Delete", style: .cancel) { (action) in
            self.startAnimating()
            FirebaseUtil.shared.deleteMyKudo(kudoId: kudo.kudoId, completion: { (error) in
                self.stopAnimating()
                if error != nil{
                    showAlert(title: nil, message: "Failed to delete the kudo. Please check the Internet connection.", controller: nil, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.kudos.remove(at: sender.tag)
                    self.tvKudos.reloadData()
                    self.showSuccessSnackBar(message: "Kudo deleted")
                }
            })
        }
        let noAction = UIAlertAction(title: "No, Keep", style: .default) { (action) in
            
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnFollowersTapped(_ sender: UIButton) {
        if self.user.follower.count < 1{
            return
        }
//        navigateToVC(name: "FollowersViewController", fromVC: self, animated: true)
        // Go to FollowersVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        vc.user = self.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnFollowingTapped(_ sender: UIButton) {
        if self.user.following.count < 1{
            return
        }
//        navigateToVC(name: "FollowingViewController", fromVC: self, animated: true)
        // Go to FollowingVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FollowingViewController") as! FollowingViewController
        vc.user = self.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: ExpyTableViewDataSourceMethods
extension AthleteProfileViewController: ExpyTableViewDataSource {
    func canExpand(section: Int, inTableView tableView: ExpyTableView) -> Bool {
        return true
    }
    
    func expandableCell(forSection section: Int, inTableView tableView: ExpyTableView) -> UITableViewCell {
        if tableView == self.tvAbout {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileAboutTableViewCell") as! ProfileAboutTableViewCell
            cell.lblTitle.text = self.aboutCellTitles[section]
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }else{ // tvStats
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileAboutTableViewCell") as! ProfileAboutTableViewCell
            cell.lblTitle.text = self.statsCellTitles[section]
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        
    }
}

//MARK: ExpyTableView delegate methods
extension AthleteProfileViewController: ExpyTableViewDelegate {
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) {
        
        switch state {
        case .willExpand:
            print("WILL EXPAND")
            
        case .willCollapse:
            print("WILL COLLAPSE")
            
        case .didExpand:
            print("DID EXPAND")
            
        case .didCollapse:
            print("DID COLLAPSE")
        }
    }
}


extension AthleteProfileViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //If you don't deselect the row here, seperator of the above cell of the selected cell disappears.
        //Check here for detail: https://stackoverflow.com/questions/18924589/uitableviewcell-separator-disappearing-in-ios7
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        //This solution obviously has side effects, you can implement your own solution from the given link.
        //This is not a bug of ExpyTableView hence, I think, you should solve it with the proper way for your implementation.
        //If you have a generic solution for this, please submit a pull request or open an issue.
        
//        print("DID SELECT row: \(indexPath.row), section: \(indexPath.section)")
        if tableView == self.tvKudos{
            // Get the user info
            let kudo = self.kudos[indexPath.row]
            self.startAnimating()
            FirebaseUtil.shared.getUser(userId: kudo.senderId, completion: { (user, error) in
                self.stopAnimating()
                
                if error != nil{
                    print(">>>Failed to get the user info. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                    return
                }
                
                //----- Show the user info ------------------------------------
                
                switch user.userType {
                case UserType.coach.rawValue:
                    // Go to ViewCoachVC
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ViewCoachViewController") as! ViewCoachViewController
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                case UserType.fan.rawValue:
                    // Go to ViewFanVC
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ViewFanViewController") as! ViewFanViewController
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                case UserType.proAthlete.rawValue:
                    // Go to ViewProVC
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ViewProViewController") as! ViewProViewController
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                case UserType.athlete.rawValue:
                    // Go to ViewAthleteVC
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ViewAthleteViewController") as! ViewAthleteViewController
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                default:
                    break
                }
                //-------------------------------------------------
            })
            
        }
        
        if tableView == self.tvStreams{
            // Go to PlayerVC
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            vc.stream = self.streams[indexPath.row]
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
}

//MARK: UITableView Data Source Methods
extension AthleteProfileViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tvAbout {
            return self.aboutCellTitles.count
        }else if tableView == self.tvStats{
            return self.statsCellTitles.count
        }else{ //tvStreams or tvKudos
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tvAbout || tableView == self.tvStats{
            return 2
        }else if tableView == self.tvStreams{ //tvStreams
            return self.streams.count
        }else{ //tvKudos
            return self.kudos.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tvStreams {
            return 70.0
        }
        if tableView == self.tvAbout && indexPath.row == 0 {
            return 65.0
        }
        if tableView == self.tvStats && indexPath.row == 0 {
            return 65.0
        }
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tvAbout {
            let section = indexPath.section
            switch section {
            case 0: // Bio
                let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileBioTableViewCell") as! AthleteProfileBioTableViewCell
                
                cell.tfHeight.isUserInteractionEnabled = false
                cell.tfWeight.isUserInteractionEnabled = false
                cell.tfState.isUserInteractionEnabled = false
                cell.tfCity.isUserInteractionEnabled = false
                cell.tfClassOf.isUserInteractionEnabled = false
                cell.tfPhone.isUserInteractionEnabled = false
                
                cell.tfHeight.text = self.user.athleteProfile?.height
                cell.tfWeight.text = self.user.athleteProfile?.weight
                cell.tfState.text = self.user.province
                cell.tfCity.text = self.user.city
                cell.tfClassOf.text = self.user.athleteProfile?.classOf
                cell.tfPhone.text = self.user.athleteProfile?.phone
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case 1: // Honors
                let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileHonorsTableViewCell") as! AthleteProfileHonorsTableViewCell
                
                cell.textView.isUserInteractionEnabled = false
                cell.textView.text = self.user.athleteProfile?.honorsAwards
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case 2: // School
                let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileSchoolTableViewCell") as! AthleteProfileSchoolTableViewCell
                
                cell.tfSchoolName.isUserInteractionEnabled = false
                cell.tfZipcode.isUserInteractionEnabled = false
                cell.tfGpa.isUserInteractionEnabled = false
                cell.tfActScore.isUserInteractionEnabled = false
                cell.tfSatScore.isUserInteractionEnabled = false
                cell.tfApCredits.isUserInteractionEnabled = false
                
                cell.tfSchoolName.text = self.user.athleteProfile?.schoolName
                cell.tfZipcode.text = self.user.athleteProfile?.schoolZipCode
                cell.tfGpa.text = self.user.athleteProfile?.gpa
                cell.tfActScore.text = self.user.athleteProfile?.actScore
                cell.tfSatScore.text = self.user.athleteProfile?.satScore
                cell.tfApCredits.text = self.user.athleteProfile?.apCredits
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            default: // Volunteering
                let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileVolunteeringTableViewCell") as! AthleteProfileVolunteeringTableViewCell
                
                cell.textView.isUserInteractionEnabled = false
                cell.textView.text = self.user.athleteProfile?.volunteering
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            }
        }else if tableView == self.tvStats {
            let section = indexPath.section
            switch section {
            case 0: // Sports stats
                let category = UserDefaults.standard.string(forKey: "category")!
                switch category {
                case "Soccer":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SoccerTableViewCell") as! SoccerTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Basketball":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "BasketballTableViewCell") as! BasketballTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Swimming":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SwimmingTableViewCell") as! SwimmingTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Track & Field":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell") as! TrackTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Tennis":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TennisTableViewCell") as! TennisTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Softball":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SoftballTableViewCell") as! SoftballTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Golf":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GolfTableViewCell") as! GolfTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    cell.tfStat9.isUserInteractionEnabled = false
                    cell.tfStat10.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    cell.tfStat9.text = self.user.athleteProfile?.stat9
                    cell.tfStat10.text = self.user.athleteProfile?.stat10
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Volleyball":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "VolleyballTableViewCell") as! VolleyballTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    cell.tfStat9.isUserInteractionEnabled = false
                    cell.tfStat10.isUserInteractionEnabled = false
                    cell.tfStat11.isUserInteractionEnabled = false
                    cell.tfStat12.isUserInteractionEnabled = false
                    cell.tfStat13.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    cell.tfStat9.text = self.user.athleteProfile?.stat9
                    cell.tfStat10.text = self.user.athleteProfile?.stat10
                    cell.tfStat11.text = self.user.athleteProfile?.stat11
                    cell.tfStat12.text = self.user.athleteProfile?.stat12
                    cell.tfStat13.text = self.user.athleteProfile?.stat13
                    
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Lacrosse":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LacrosseTableViewCell") as! LacrosseTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Hockey":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "HockeyTableViewCell") as! HockeyTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    cell.tfStat9.isUserInteractionEnabled = false
                    cell.tfStat10.isUserInteractionEnabled = false
                    cell.tfStat11.isUserInteractionEnabled = false
                    cell.tfStat12.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    cell.tfStat9.text = self.user.athleteProfile?.stat9
                    cell.tfStat10.text = self.user.athleteProfile?.stat10
                    cell.tfStat11.text = self.user.athleteProfile?.stat11
                    cell.tfStat12.text = self.user.athleteProfile?.stat12
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Rowing":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RowingTableViewCell") as! RowingTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    cell.tfStat9.isUserInteractionEnabled = false
                    cell.tfStat10.isUserInteractionEnabled = false
                    cell.tfStat11.isUserInteractionEnabled = false
                    cell.tfStat12.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    cell.tfStat9.text = self.user.athleteProfile?.stat9
                    cell.tfStat10.text = self.user.athleteProfile?.stat10
                    cell.tfStat11.text = self.user.athleteProfile?.stat11
                    cell.tfStat12.text = self.user.athleteProfile?.stat12
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Water Polo":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "WaterpoloTableViewCell") as! WaterpoloTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    cell.tfStat9.isUserInteractionEnabled = false
                    cell.tfStat10.isUserInteractionEnabled = false
                    cell.tfStat11.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    cell.tfStat9.text = self.user.athleteProfile?.stat9
                    cell.tfStat10.text = self.user.athleteProfile?.stat10
                    cell.tfStat11.text = self.user.athleteProfile?.stat11
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                case "Gymnastics":
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GymnasticsTableViewCell") as! GymnasticsTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    cell.tfStat9.isUserInteractionEnabled = false
                    cell.tfStat10.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    cell.tfStat9.text = self.user.athleteProfile?.stat9
                    cell.tfStat10.text = self.user.athleteProfile?.stat10
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                default: // skiing
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SkiingTableViewCell") as! SkiingTableViewCell
                    
                    cell.tfStat1.isUserInteractionEnabled = false
                    cell.tfStat2.isUserInteractionEnabled = false
                    cell.tfStat3.isUserInteractionEnabled = false
                    cell.tfStat4.isUserInteractionEnabled = false
                    cell.tfStat5.isUserInteractionEnabled = false
                    cell.tfStat6.isUserInteractionEnabled = false
                    cell.tfStat7.isUserInteractionEnabled = false
                    cell.tfStat8.isUserInteractionEnabled = false
                    cell.tfStat9.isUserInteractionEnabled = false
                    cell.tfStat10.isUserInteractionEnabled = false
                    
                    cell.tfStat1.text = self.user.athleteProfile?.stat1
                    cell.tfStat2.text = self.user.athleteProfile?.stat2
                    cell.tfStat3.text = self.user.athleteProfile?.stat3
                    cell.tfStat4.text = self.user.athleteProfile?.stat4
                    cell.tfStat5.text = self.user.athleteProfile?.stat5
                    cell.tfStat6.text = self.user.athleteProfile?.stat6
                    cell.tfStat7.text = self.user.athleteProfile?.stat7
                    cell.tfStat8.text = self.user.athleteProfile?.stat8
                    cell.tfStat9.text = self.user.athleteProfile?.stat9
                    cell.tfStat10.text = self.user.athleteProfile?.stat10
                    
                    cell.layoutMargins = UIEdgeInsets.zero
                    return cell
                }
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileHighlightsTableViewCell") as! AthleteProfileHighlightsTableViewCell
                
                cell.textView.isUserInteractionEnabled = false
                cell.textView.text = self.user.athleteProfile?.other
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            }
        }else if tableView == self.tvStreams{ //tvStreams
            let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileStreamsTableViewCell") as! AthleteProfileStreamsTableViewCell
            let stream = self.streams[
            indexPath.row]
            
            let url = URL(string:stream.imageURL)
            cell.ivStream.kf.setImage(with: url)
            cell.ivStream.contentMode = .scaleAspectFill
            cell.ivStream.kf.indicatorType = .activity
            cell.lblTitle.text = stream.title
            cell.lblDate.text = stringWithTimestamp(timestamp: stream.endedAt/1000.0)
            if self.isDownloadMode == true {
                cell.btnRadio.isHidden = false
                cell.btnTrash.isHidden = true
                cell.btnTrash2.isHidden = true
                if self.streamSelected[indexPath.row] == true {
                    cell.btnRadio.setImage(UIImage(named:"radio"), for: .normal)
                }else{
                    cell.btnRadio.setImage(UIImage(named:"radioUnchecked"), for: .normal)
                }
            }else{
                cell.btnRadio.isHidden = true
                cell.btnTrash.isHidden = false
                cell.btnTrash2.isHidden = false
            }
            cell.btnRadio.tag = indexPath.row
            cell.btnTrash.tag = indexPath.row
            cell.btnTrash2.tag = indexPath.row
            
            cell.layoutMargins = UIEdgeInsets.zero
            
            cell.lblTitle.type = .continuous
            cell.lblTitle.scrollDuration = 10.0
            cell.lblTitle.animationCurve = .easeInOut
            cell.lblTitle.fadeLength = 10.0
            
            cell.lblDate.type = .continuous
            cell.lblDate.scrollDuration = 10.0
            cell.lblDate.animationCurve = .easeInOut
            cell.lblDate.fadeLength = 10.0
            
            return cell
        }else{ // tvKudos
            let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileKudosTableViewCell") as! AthleteProfileKudosTableViewCell
            let kudo = self.kudos[
                indexPath.row]
            if kudo.senderPhotoURL != ""{
                let url = URL(string:kudo.senderPhotoURL)
                cell.ivPhoto.kf.setImage(with: url)
            }
            cell.ivPhoto.kf.indicatorType = .activity
            cell.lblName.text = kudo.senderName
            cell.lblSenderType.text = kudo.senderType
            cell.lblText.text = kudo.text
            
            cell.btnTrashKudos.tag = indexPath.row
            
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        
    }
    
    //MARK: - Download a stream
    func downloadStream(stream:Stream, completion: @escaping (Error?)->()){
        print(">>>downloadStream called")
        AWSUtil.shared.downloadStream(stream: stream) { (error, url) in
            if error == nil{
                print(">>>Stream downloaded.")
                DispatchQueue.main.async {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                    }) { completed, error in
                        if completed {
                            print(">>>Video is saved!")
                            completion(nil)
                        }else{
                            print("Failed to save a video. Error: \(String(describing: error?.localizedDescription))")
                            completion(error)
                        }
                    }
                }
            }else{
                print(">>>Failed to download the stream")
                if self.isDownloadingCanceled == false{
                    completion(error)
                }
            }
        }
        /*
        // Get the metadata of the broadcast
        Network.downloadLinkWith(broadcastId: stream.id) { (metadata) in
            if metadata == nil{
                print(">>>Failed to get download link from Iris backend server. Retrying...")
                if self.isDownloadingCanceled == false{
                    showAlert(title: nil, message: "Failed to download streams. Please check the Internet connection.", controller: nil, okTitle: "OK", cancelTitle: nil, okAction: { 
                        self.btnDownload.isHidden = false
                        self.btnDownloadAll.isHidden = false
                    }, cancelAction: nil)
                    
                }
                return
            }
            let downloadLink = metadata?.value(forKey: "url") as! String
            DispatchQueue.global(qos: .background).async {
                if let url = URL(string: downloadLink),
                    let urlData = NSData(contentsOf: url)
                {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/stream_\(stream.id).mov";
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                print(">>>Video is saved!")
                                completion()
                            }else{
                                print("Failed to save a video. Error: \(error?.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
        */
    }
    
}
