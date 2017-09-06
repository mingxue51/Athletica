//
//  ViewAthleteViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/17/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class ViewAthleteViewController: BaseViewController, GiveKudosDelegate {

    var user:User! // Init by SearchVC, BlockedUsersVC, FollowersVC, FollowingVC, FavoritesVC
       
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
    @IBOutlet weak var tvStreams: UITableView!
    @IBOutlet weak var viewAbout: UIView!
    @IBOutlet weak var viewStats: UIView!
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
    //-----------------------------
    
    //----- Kudos section ------
    var kudos:[Kudo] = []
    var isKudoDownloaded:Bool = false
    @IBOutlet weak var indicatorKudos: UIActivityIndicatorView!
    
    //--------------------------
    
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var viewFilterBg: UIView!
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var indicatorBlock: UIActivityIndicatorView!
    var following:[String:String]?
    var blockedUsers:[String:String]?
    var favoriteUsers:[String:String]?
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var btnGiveKudos: UIButton!
    @IBOutlet weak var indicatorFollow: UIActivityIndicatorView!
    @IBOutlet weak var indicatorFavorite: UIActivityIndicatorView!
    
    
    let myUserType = UserDefaults.standard.string(forKey: "userType")!
    
    
    
    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableViews()
        
        // Setup UI according to user type
        if self.myUserType == UserType.coach.rawValue{
            setupButtons(title:"ABOUT")
        }else{
            setupButtons(title:"STATS")
            self.btnFavorite.isHidden = true
            self.btnAbout.isHidden = true
        }
        
        // Register nibs for table view cell
        self.registerNibs()
        
        
        // Set the title of the Give Kudos button
        let text = " Give Kudos to " + self.user.firstName
        self.btnGiveKudos.setTitle(text, for: .normal)
        
        self.viewFilter.isHidden = true
        self.viewFilter.layer.cornerRadius = 5
        self.viewFilterBg.isHidden = true
        
        self.lblName.text = self.user.firstName + " " + self.user.lastName
        self.lblCategory.text = self.user.category
        
        self.ivPhoto.layer.cornerRadius = 40.0
        if self.user.imageURL != "" {
            let url = URL(string: self.user.imageURL)
            self.ivPhoto.kf.indicatorType = .activity
            self.ivPhoto.kf.setImage(with: url)
        }
        
        if self.user.city != "" && self.user.province != ""{
            self.lblLocation.text = self.user.city + ", " + self.user.province
        }
        
        self.tvAbout.reloadData()
        self.tvStats.reloadData()
        
        //----- Check if the user is one whom I'm following
        self.following = UserDefaults.standard.object(forKey: "following") as? [String:String]
        if self.following != nil && self.following?[self.user.userId] != nil {
            self.btnFollow.setImage(UIImage(named:"viewAthleteUnfollow"), for: .normal)
        }else{
            self.btnFollow.setImage(UIImage(named:"viewAthleteFollow"), for: .normal)
        }
        self.indicatorFollow.isHidden = true
        //-------------------------------------------
        
        //-----Check if the user is blocked or not
        self.blockedUsers = UserDefaults.standard.object(forKey: "blockedUsers") as? [String:String]
        if self.blockedUsers != nil && self.blockedUsers?[self.user.userId] != nil {
            self.btnBlock.setTitle("UNBLOCK USER", for: .normal)
        }else{
            self.btnBlock.setTitle("BLOCK USER", for: .normal)
        }
        self.indicatorBlock.isHidden = true
        //-----------------------------------------------
        
        
        //-----Check if the user is a favorite user or not
        self.favoriteUsers = UserDefaults.standard.object(forKey: "favoriteUsers") as? [String:String]
        if self.favoriteUsers != nil && self.favoriteUsers?[self.user.userId] != nil {
            self.btnFavorite.setImage(UIImage(named:"removeFavorites"), for: .normal)
            
        }else{
            self.btnFavorite.setImage(UIImage(named:"addToFavorites"), for: .normal)
        }
        self.indicatorFavorite.isHidden = true
        //-----------------------------------------------
        
        
        //----- Followers and Following ----------
        let nFollowers = self.user.follower.count
        self.lblFollowers.text = "\(nFollowers)"
        
        let nFollowing = self.user.following.count
        self.lblFollowing.text = "\(nFollowing)"
        //----------------------------------------
        
        
        // Check if the user has paid
        if self.user.expiryTimestamp < Date().timeIntervalSince1970{
            self.btnStreams.isHidden = true
            self.btnKudos.isHidden = true
            return
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
        tvAbout.estimatedRowHeight = 44
        
        tvStats.dataSource = self
        tvStats.delegate = self
        //Alter the animations as you want
        tvStats.expandingAnimation = .fade
        tvStats.collapsingAnimation = .fade
        tvStats.tableFooterView = UIView()
        tvStats.estimatedRowHeight = 44
        
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
        FirebaseUtil.shared.getUserStreams(userId: self.user.userId, completion: { (streams, error) in
            if error != nil{
                DispatchQueue.main.async {
                    if self.indicatorStreams.isHidden == false{
                        self.indicatorStreams.isHidden = true
                        self.indicatorStreams.stopAnimating()
                    }
                }
                print(">>>Failed to get streams. Error: \(String(describing: error))")
                //                self.showErrorSnackBar(message: SnackbarMessage.noConnection)
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
                }
            }
        }) 
    }
    @IBAction func btnKudosTapped(_ sender: UIButton) {
        setupButtons(title: sender.titleLabel?.text)
        
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
                }
            }
        }
    }
    
    
    
    @IBAction func btnFollowTapped(_ sender: UIButton) {
       /*
        // Follow the user
        self.btnFollow.isHidden = true
        self.indicatorFollow.isHidden = false
        self.indicatorFollow.startAnimating()
        FirebaseUtil.shared.followUser(userId: self.user.userId, completion: { (error) in
            self.indicatorFollow.stopAnimating()
            self.indicatorFollow.isHidden = true
            self.btnFollow.isHidden = false
            if error != nil{
                print(">>>Failed to follow the user. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.btnFollow.setImage(UIImage(named:"viewAthleteFollowing"), for: .normal)
                self.btnFollow.isEnabled = false
                // Save to UserDefaults
                if self.following == nil{
                    self.following = [:]
                }
                self.following?[self.user.userId] = self.user.userId
                UserDefaults.standard.set(self.following, forKey: "following")
                
                // Send a push notification to the creator
                let userName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
                let message = "\(userName) is following you!"
                self.sendNotification(message: message)
                
                // Update the user's follower dictionary
                let myUserId = UserDefaults.standard.string(forKey: "userId")!
                self.user.follower[myUserId] = myUserId
                self.lblFollowers.text = "\(self.user.follower.count)"
            }
        })
 */
        if sender.image(for: .normal) == UIImage(named:"viewAthleteFollow"){
            // Follow the user
            self.btnFollow.isHidden = true
            self.indicatorFollow.isHidden = false
            self.indicatorFollow.startAnimating()
            FirebaseUtil.shared.followUser(userId: self.user.userId, completion: { (error) in
                self.indicatorFollow.stopAnimating()
                self.indicatorFollow.isHidden = true
                self.btnFollow.isHidden = false
                if error != nil{
                    print(">>>Failed to follow the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnFollow.setImage(UIImage(named:"viewAthleteUnfollow"), for: .normal)
                    // Save to UserDefaults
                    if self.following == nil{
                        self.following = [:]
                    }
                    self.following?[self.user.userId] = self.user.userId
                    UserDefaults.standard.set(self.following, forKey: "following")
                    
                    // Send a push notification to the creator
                    let userName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
                    let message = "\(userName) is following you!"
                    self.sendNotification(message: message)
                    
                    // Update the user's follower dictionary
                    let myUserId = UserDefaults.standard.string(forKey: "userId")!
                    self.user.follower[myUserId] = myUserId
                    self.lblFollowers.text = "\(self.user.follower.count)"
                }
            })
            
        }else{
            // Unfollow the user
            self.btnFollow.isHidden = true
            self.indicatorFollow.isHidden = false
            self.indicatorFollow.startAnimating()
            FirebaseUtil.shared.unfollowUser(userId: self.user.userId, completion: { (error) in
                self.indicatorFollow.stopAnimating()
                self.indicatorFollow.isHidden = true
                self.btnFollow.isHidden = false
                if error != nil{
                    print(">>>Failed to unfollow the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnFollow.setImage(UIImage(named:"viewAthleteFollow"), for: .normal)
                    
                    // Save to UserDefaults
                    if self.following == nil{
                        return
                    }
                    self.following?[self.user.userId] = nil
                    UserDefaults.standard.set(self.following, forKey: "following")
                    
                    // Send a push notification to the creator
                    let userName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
                    let message = "Oops! \(userName) unfollowed you!"
                    self.sendNotification(message: message)
                    
                    // Update the user's follower dictionary
                    let myUserId = UserDefaults.standard.string(forKey: "userId")!
                    self.user.follower[myUserId] = nil
                    self.lblFollowers.text = "\(self.user.follower.count)"
                }
            })
        }
        
    }
    
    @IBAction func btnFavoriteTapped(_ sender: UIButton) {
        if sender.image(for: .normal) == UIImage(named:"addToFavorites"){
            // Add the user to favoriteUsers
            self.btnFavorite.isHidden = true
            self.indicatorFavorite.isHidden = false
            self.indicatorFavorite.startAnimating()
            FirebaseUtil.shared.favoriteUser(userId: self.user.userId, completion: { (error) in
                self.indicatorFavorite.stopAnimating()
                self.indicatorFavorite.isHidden = true
                self.btnFavorite.isHidden = false
                if error != nil{
                    print(">>>Failed to favorite the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnFavorite.setImage(UIImage(named:"removeFavorites"), for: .normal)
                    // Save to UserDefaults
                    if self.favoriteUsers == nil{
                        self.favoriteUsers = [:]
                    }
                    self.favoriteUsers?[self.user.userId] = self.user.userId
                    UserDefaults.standard.set(self.favoriteUsers, forKey: "favoriteUsers")
                    
                }
            })
            
        }else{
            // Remove the user from favoriteUsers
            self.btnFavorite.isHidden = true
            self.indicatorFavorite.isHidden = false
            self.indicatorFavorite.startAnimating()
            FirebaseUtil.shared.unfavoriteUser(userId: self.user.userId, completion: { (error) in
                self.indicatorFavorite.stopAnimating()
                self.indicatorFavorite.isHidden = true
                self.btnFavorite.isHidden = false
                if error != nil{
                    print(">>>Failed to unfavorite the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnFavorite.setImage(UIImage(named:"addToFavorites"), for: .normal)
                    // Save to UserDefaults
                    if self.favoriteUsers == nil{
                        self.favoriteUsers = [:]
                    }
                    self.favoriteUsers?[self.user.userId] = nil
                    UserDefaults.standard.set(self.favoriteUsers, forKey: "favoriteUsers")
                    
                }
            })
        }
        
        
    }
    
    @IBAction func btnDotsTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            self.viewFilter.isHidden = false
            
        }, completion: { (finished) -> Void in
            self.viewFilterBg.isHidden = false
        })
    }
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
    @IBAction func btnSendMessageTapped(_ sender: UIButton) {
        self.closeFilterView()
        
        // Go to ChatContainerVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatContainerViewController") as! ChatContainerViewController
        vc.receiverId = self.user.userId
        vc.receiverName = self.user.firstName + " " + self.user.lastName
        vc.receiverPhotoURL = self.user.imageURL
        vc.receiverUserType = self.user.userType
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func btnBlockTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "BLOCK USER"{
            // Block the user
            self.btnBlock.isHidden = true
            self.indicatorBlock.isHidden = false
            self.indicatorBlock.startAnimating()
            FirebaseUtil.shared.blockUser(userId: self.user.userId, completion: { (error) in
                self.indicatorBlock.stopAnimating()
                self.indicatorBlock.isHidden = true
                self.btnBlock.isHidden = false
                if error != nil{
                    print(">>>Failed to block the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnBlock.setTitle("UNBLOCK USER", for: .normal)
                    
                    // Save to UserDefaults
                    if self.blockedUsers == nil{
                        self.blockedUsers = [:]
                    }
                    self.blockedUsers?[self.user.userId] = self.user.userId
                    UserDefaults.standard.set(self.blockedUsers, forKey: "blockedUsers")
                }
            })
            
        }else{
            // Unblock the user
            self.btnBlock.isHidden = true
            self.indicatorBlock.isHidden = false
            self.indicatorBlock.startAnimating()
            FirebaseUtil.shared.unblockUser(userId: self.user.userId, completion: { (error) in
                self.indicatorBlock.stopAnimating()
                self.indicatorBlock.isHidden = true
                self.btnBlock.isHidden = false
                if error != nil{
                    print(">>>Failed to unblock the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnBlock.setTitle("BLOCK USER", for: .normal)
                    
                    // Save to UserDefaults
                    if self.blockedUsers == nil{
                        return
                    }
                    self.blockedUsers?[self.user.userId] = nil
                    UserDefaults.standard.set(self.blockedUsers, forKey: "blockedUsers")
                }
            })
        }
    }
    @IBAction func btnReportTapped(_ sender: UIButton) {
        self.closeFilterView()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReportUserViewController") as! ReportUserViewController
        vc.userId = self.user.userId
        vc.userName = self.user.firstName + " " + self.user.lastName
        vc.userType = self.user.userType
        vc.photoURL = self.user.imageURL
//        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true, completion: nil)
    }
    func sendNotification(message:String){
        // If the user whom I'm following/unfollowing, doesn't want the push notifications, we don't send the notification
        if self.user.isSomeoneFollows == false {
            return
        }
        
        OneSignalUtil.shared.sendNotification(date: Date(), userIds: [self.user.oneSignalUserId], message: message, heading: nil)
    }
    @IBAction func btnBackTapped(_ sender: UIButton) {
        var isPoped = false
        // Pop to BlockedUsersVC or SearchVC or AthleteProfileVC or ViewAthleteVC
        let controllers = self.navigationController!.viewControllers
        for index in (0...controllers.count-2).reversed() {
            let controller = controllers[index]
            if controller.isKind(of: BlockedUsersViewController.self) ||
                controller.isKind(of: SearchViewController.self) ||
                controller.isKind(of: AthleteProfileViewController.self) ||
                controller.isKind(of: ViewAthleteViewController.self){
                isPoped = true
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        if isPoped == false{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    @IBAction func btnGiveKudosTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GiveKudosViewController") as! GiveKudosViewController
        vc.user = self.user
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    // MARK: - GiveKudosDelegate
    func didGiveKudos() {
        // Show activity indicator while fetching kudos
        self.indicatorKudos.startAnimating()
        self.indicatorKudos.isHidden = false
        
        self.getKudos()
    }
    
   
    
}


//MARK: ExpyTableViewDataSourceMethods
extension ViewAthleteViewController: ExpyTableViewDataSource {
    func canExpand(section: Int, inTableView tableView: ExpyTableView) -> Bool {
        return true
    }
    
    func expandableCell(forSection section: Int, inTableView tableView: ExpyTableView) -> UITableViewCell {
        if tableView == self.tvAbout {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileAboutTableViewCell") as! ProfileAboutTableViewCell
            cell.lblTitle.text = self.aboutCellTitles[section]
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileAboutTableViewCell") as! ProfileAboutTableViewCell
            cell.lblTitle.text = self.statsCellTitles[section]
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        
    }
}

//MARK: ExpyTableView delegate methods
extension ViewAthleteViewController: ExpyTableViewDelegate {
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


extension ViewAthleteViewController {
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
extension ViewAthleteViewController {
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
            cell.btnRadio.isHidden = true
            cell.btnTrash.isHidden = true
            
            
            cell.lblTitle.type = .continuous
            cell.lblTitle.scrollDuration = 10.0
            cell.lblTitle.animationCurve = .easeInOut
            cell.lblTitle.fadeLength = 10.0
            
            cell.lblDate.type = .continuous
            cell.lblDate.scrollDuration = 10.0
            cell.lblDate.animationCurve = .easeInOut
            cell.lblDate.fadeLength = 10.0
            
            cell.layoutMargins = UIEdgeInsets.zero
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
            
            cell.btnTrashKudos.isHidden = true
            
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        
    }
    
}
