//
//  FollowersViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/9/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var followers:[User] = []
    var user:User! // Inited by the previous VC - AthleteProfileVC, ProProfileVC, FanProfileVC, CoachProfileVC, ViewAthleteVC, ViewCoachVC, ViewProVC, ViewFanVC
    
    @IBOutlet weak var tvFollowers: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show activity indicator while fetching streams
        self.tvFollowers.tableFooterView = UIView()
        self.tvFollowers.dataSource = self
        self.tvFollowers.delegate = self
        self.indicator.startAnimating()
        self.indicator.isHidden = false
        
        // Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tvFollowers.addSubview(refreshControl)
        
        self.getFollowers()
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.getFollowers()
    }
    func getFollowers(){
        FirebaseUtil.shared.getFollowersOnce(user: self.user) { (followers, error) in
            if error != nil{
                DispatchQueue.main.async {
                    if self.indicator.isHidden == false{
                        self.indicator.isHidden = true
                        self.indicator.stopAnimating()
                    }
                }
                print(">>>Failed to get followers. Error: \(String(describing: error))")
                //                self.showErrorSnackBar(message: SnackbarMessage.noConnection)
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.followers = followers
                DispatchQueue.main.async {
                    if self.indicator.isHidden == false{
                        self.indicator.isHidden = true
                        self.indicator.stopAnimating()
                    }
                    self.tvFollowers.reloadData()
                    self.refreshControl.endRefreshing()
                }
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

    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = self.followers[indexPath.row]
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
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersTableViewCell", for: indexPath) as! FollowersTableViewCell
        let user = self.followers[indexPath.row]
        
        cell.lblName.text = user.firstName + " " + user.lastName
        
        if user.imageURL != ""{
            let url = URL(string: user.imageURL)
            cell.ivPhoto.kf.setImage(with: url)
            cell.ivPhoto.kf.indicatorType = .activity
        }
        cell.ivPhoto.layer.cornerRadius = 20.0
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
