//
//  CoachProfileViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/24/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class CoachProfileViewController: BaseViewController {
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFavorites: UILabel!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnMessages: UIButton!
    
    var user = User()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.user.initWithUserDefaults()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
    }
    func setupUI(){
        self.ivPhoto.layer.cornerRadius = 64.0
        let imageData = UserDefaults.standard.data(forKey: "imageData")
        if imageData != nil{
            self.ivPhoto.image = UIImage(data: imageData!)
        }else if self.user.imageURL != "" {
            let url = URL(string: self.user.imageURL)
            self.ivPhoto.kf.indicatorType = .activity
            self.ivPhoto.kf.setImage(with: url)
        }
        
        self.lblName.text = self.user.firstName + " " + self.user.lastName
        self.lblCategory.text = self.user.category
        
        if self.user.city != "" && self.user.province != ""{
            self.lblLocation.text = self.user.city + ", " + self.user.province
        }else{
            self.lblLocation.text = ""
        }
        
        self.lblCompany.text = self.user.extra
        
        
        let nFollowers = self.user.follower.count
        self.lblFollowers.text = "\(nFollowers)"
        
        let nFollowing = self.user.following.count
        self.lblFollowing.text = "\(nFollowing)"
        
        let nFavorite = self.user.favoriteUsers.count
        self.lblFavorites.text = "\(nFavorite)"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    @IBAction func btnEditTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CoachEditProfileViewController") as! CoachEditProfileViewController
        vc.user = self.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMessagesTapped(_ sender: UIButton) {
        navigateToVC(name: "MessagesViewController", fromVC: self, animated: true)
    }
    
    @IBAction func btnPlayTapped(_ sender: UIButton) {
        // Go to StartLiveStreamVC
        navigateToVC(name: "StartLiveStreamViewController", fromVC: self, animated: true)
    }
    @IBAction func btnScheduleTapped(_ sender: UIButton) {
        // Go to ScheduleStreamVC
        navigateToVC(name: "ScheduleStreamViewController", fromVC: self, animated: true)
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
    @IBAction func btnFavoritesTapped(_ sender: UIButton) {
        if self.user.favoriteUsers.count < 1{
            return
        }
//        navigateToVC(name: "FavoritesViewController", fromVC: self, animated: true)
        // Go to FavoritesVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FavoritesViewController") as! FavoritesViewController
        vc.user = self.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
