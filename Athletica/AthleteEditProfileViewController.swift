//
//  AthleteEditProfileViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/3/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Kingfisher
import TOCropViewController
import Photos


class AthleteEditProfileViewController: BaseViewController, UIImagePickerControllerDelegate, TOCropViewControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let aboutCellTitles = ["Bio", "Honors and Awards",
                           "School and Education", "Volunteering",
                           "Sports Stats", "Highlights & Other Stats"]
    
    @IBOutlet weak var tvProfile: ExpyTableView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfCategory: UITextField!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var ivPhoto: UIImageView!
    
    var oldUser:User!// Init by AthleteProfileVC
    var user:User! //
    var imageData:Data? // Assigned after user uploads her photo
    
    let myPickerData = [String](arrayLiteral: "Soccer", "Basketball", "Swimming", "Track & Field", "Tennis", "Softball", "Golf", "Volleyball", "Lacrosse", "Hockey", "Rowing", "Water Polo", "Gymnastics", "Skiiing", "Football")
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    func setupUI(){
        
        self.tfFirstName.layer.borderColor = UIColor.lightGray.cgColor
        self.tfLastName.layer.borderColor = UIColor.lightGray.cgColor
        self.tfCategory.layer.borderColor = UIColor.lightGray.cgColor
        self.tfCity.layer.borderColor = UIColor.lightGray.cgColor
        self.tfState.layer.borderColor = UIColor.lightGray.cgColor
        
        self.tfFirstName.adjustsFontSizeToFitWidth = true
        self.tfLastName.adjustsFontSizeToFitWidth = true
        self.tfCategory.adjustsFontSizeToFitWidth = true
        self.tfCity.adjustsFontSizeToFitWidth = true
        self.tfState.adjustsFontSizeToFitWidth = true
        
        let thePicker = UIPickerView()
        tfCategory.inputView = thePicker
        thePicker.delegate = self
        
        self.user = User()
        self.user.initWithUser(user: self.oldUser)
        if self.user.athleteProfile == nil {
            self.user.athleteProfile = AthleteProfile()
        }
        
        // Do any additional setup after loading the view.
        tvProfile.expandingAnimation = .fade
        tvProfile.collapsingAnimation = .fade
        tvProfile.tableFooterView = UIView()
        tvProfile.estimatedRowHeight = 44
        
        // Register nibs for table view cell
        self.registerNibs()
        
        //----- Show profile info -----
        self.tfFirstName.text = self.user.firstName
        self.tfLastName.text = self.user.lastName
        self.tfCategory.text = self.user.category
        self.tfCity.text = self.user.city
        self.tfState.text = self.user.province
        self.ivPhoto.layer.cornerRadius = 40.0
        
        let imageData = UserDefaults.standard.data(forKey: "imageData")
        if imageData != nil{
            self.ivPhoto.image = UIImage(data: imageData!)
        }else if self.user.imageURL != ""{
            let url = URL(string: self.user.imageURL)
            self.ivPhoto.kf.setImage(with: url)
        }
        
        //------------------------------
    }
    func registerNibs(){
        // Nibs for profile detail cell
        let nib = UINib(nibName: "AthleteProfileBioTableViewCell", bundle: nil)
        self.tvProfile.register(nib, forCellReuseIdentifier: "AthleteProfileBioTableViewCell")
        
        let nibSchool = UINib(nibName: "AthleteProfileSchoolTableViewCell", bundle: nil)
        self.tvProfile.register(nibSchool, forCellReuseIdentifier: "AthleteProfileSchoolTableViewCell")
        
        let nibVolunteering = UINib(nibName: "AthleteProfileVolunteeringTableViewCell", bundle: nil)
        self.tvProfile.register(nibVolunteering, forCellReuseIdentifier: "AthleteProfileVolunteeringTableViewCell")
        
        let nibHighlights = UINib(nibName: "AthleteProfileHighlightsTableViewCell", bundle: nil)
        self.tvProfile.register(nibHighlights, forCellReuseIdentifier: "AthleteProfileHighlightsTableViewCell")
        
        let nibHonors = UINib(nibName: "AthleteProfileHonorsTableViewCell", bundle: nil)
        self.tvProfile.register(nibHonors, forCellReuseIdentifier: "AthleteProfileHonorsTableViewCell")
        
        
        // Nibs for each category
        let nibSoccer = UINib(nibName: "SoccerTableViewCell", bundle: nil)
        self.tvProfile.register(nibSoccer, forCellReuseIdentifier: "SoccerTableViewCell")
        
        let nibBasketball = UINib(nibName: "BasketballTableViewCell", bundle: nil)
        self.tvProfile.register(nibBasketball, forCellReuseIdentifier: "BasketballTableViewCell")
        
        let nibSwimming = UINib(nibName: "SwimmingTableViewCell", bundle: nil)
        self.tvProfile.register(nibSwimming, forCellReuseIdentifier: "SwimmingTableViewCell")
        
        let nibTrack = UINib(nibName: "TrackTableViewCell", bundle: nil)
        self.tvProfile.register(nibTrack, forCellReuseIdentifier: "TrackTableViewCell")
        
        let nibTennis = UINib(nibName: "TennisTableViewCell", bundle: nil)
        self.tvProfile.register(nibTennis, forCellReuseIdentifier: "TennisTableViewCell")
        
        let nibSoftball = UINib(nibName: "SoftballTableViewCell", bundle: nil)
        self.tvProfile.register(nibSoftball, forCellReuseIdentifier: "SoftballTableViewCell")
        
        let nibGolf = UINib(nibName: "GolfTableViewCell", bundle: nil)
        self.tvProfile.register(nibGolf, forCellReuseIdentifier: "GolfTableViewCell")
        
        let nibVolleyball = UINib(nibName: "VolleyballTableViewCell", bundle: nil)
        self.tvProfile.register(nibVolleyball, forCellReuseIdentifier: "VolleyballTableViewCell")
        
        let nibLacrosse = UINib(nibName: "LacrosseTableViewCell", bundle: nil)
        self.tvProfile.register(nibLacrosse, forCellReuseIdentifier: "LacrosseTableViewCell")
        
        let nibHockey = UINib(nibName: "HockeyTableViewCell", bundle: nil)
        self.tvProfile.register(nibHockey, forCellReuseIdentifier: "HockeyTableViewCell")
        
        let nibRowing = UINib(nibName: "RowingTableViewCell", bundle: nil)
        self.tvProfile.register(nibRowing, forCellReuseIdentifier: "RowingTableViewCell")
        
        let nibWaterpolo = UINib(nibName: "WaterpoloTableViewCell", bundle: nil)
        self.tvProfile.register(nibWaterpolo, forCellReuseIdentifier: "WaterpoloTableViewCell")
        
        let nibGymnastics = UINib(nibName: "GymnasticsTableViewCell", bundle: nil)
        self.tvProfile.register(nibGymnastics, forCellReuseIdentifier: "GymnasticsTableViewCell")
        
        let nibSkiing = UINib(nibName: "SkiingTableViewCell", bundle: nil)
        self.tvProfile.register(nibSkiing, forCellReuseIdentifier: "SkiingTableViewCell")
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Button actions
    @IBAction func btnSaveTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let message = self.isEmptyFields()
        if message != "" {
            showAlert(title: nil, message: message, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }
        // Save profile in Firebase DB
        self.startAnimating()
        self.user.firstName = trimmedStringFromString(string: self.tfFirstName.text!)
        self.user.lastName = trimmedStringFromString(string: self.tfLastName.text!)
        self.user.category = trimmedStringFromString(string: self.tfCategory.text!)
        self.user.city = trimmedStringFromString(string: self.tfCity.text!)
        self.user.province = trimmedStringFromString(string: self.tfState.text!)
        FirebaseUtil.shared.updateUser(user: self.user, completion: { (error) in
            self.stopAnimating()
            if error != nil{
                print(">>>Failed to update profile. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                // Update imageURL and imageData in UserDefaults
                if self.imageData != nil{
                    UserDefaults.standard.set(self.user.imageURL, forKey: "imageURL")
                    UserDefaults.standard.set(self.imageData, forKey:"imageData")
                }
                
                self.user.saveToUserDefaults()
                
                self.oldUser.initWithUser(user: self.user)
                self.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    func isEmptyFields()->String{
        
        var result:String = ""
        if (self.tfFirstName.text?.isEmpty)! {
            result = AlertMessage.firstNameEmpty
            return result
        }
        if (self.tfLastName.text?.isEmpty)! {
            result = AlertMessage.lastNameEmpty
            return result
        }
        if (self.tfCategory.text?.isEmpty)! {
            result = AlertMessage.emailEmpty
            return result
        }
        if (self.tfCity.text?.isEmpty)! {
            result = AlertMessage.cityEmpty
            return result
        }
        if (self.tfState.text?.isEmpty)! {
            result = AlertMessage.stateEmpty
            return result
        }
        return result
    }
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUpdatePhotoTapped(_ sender: UIButton) {
        
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


}

//MARK: ExpyTableViewDataSourceMethods
extension AthleteEditProfileViewController: ExpyTableViewDataSource {
    func canExpand(section: Int, inTableView tableView: ExpyTableView) -> Bool {
        return true
    }
    
    func expandableCell(forSection section: Int, inTableView tableView: ExpyTableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileAboutTableViewCell") as! ProfileAboutTableViewCell
        cell.lblTitle.text = self.aboutCellTitles[section]
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
}

//MARK: ExpyTableView delegate methods
extension AthleteEditProfileViewController: ExpyTableViewDelegate {
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

//MARK: UITableView Data Source Methods
extension AthleteEditProfileViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.aboutCellTitles.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 65.0
        }
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileBioTableViewCell") as! AthleteProfileBioTableViewCell
            
            cell.tfHeight.text = self.user.athleteProfile?.height
            cell.tfWeight.text = self.user.athleteProfile?.weight
            cell.tfState.text = self.user.province
            cell.tfCity.text = self.user.city
            cell.tfClassOf.text = self.user.athleteProfile?.classOf
            cell.tfPhone.text = self.user.athleteProfile?.phone
            
            cell.tfHeight.delegate = self
            cell.tfWeight.delegate = self
            cell.tfState.delegate = self
            cell.tfCity.delegate = self
            cell.tfClassOf.delegate = self
            cell.tfPhone.delegate = self
            
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileHonorsTableViewCell") as! AthleteProfileHonorsTableViewCell
            
            cell.textView.text = self.user.athleteProfile?.honorsAwards
            cell.textView.delegate = self
            
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileSchoolTableViewCell") as! AthleteProfileSchoolTableViewCell
            
            cell.tfSchoolName.text = self.user.athleteProfile?.schoolName
            cell.tfZipcode.text = self.user.athleteProfile?.schoolZipCode
            cell.tfGpa.text = self.user.athleteProfile?.gpa
            cell.tfActScore.text = self.user.athleteProfile?.actScore
            cell.tfSatScore.text = self.user.athleteProfile?.satScore
            cell.tfApCredits.text = self.user.athleteProfile?.apCredits
            
            cell.tfSchoolName.delegate = self
            cell.tfZipcode.delegate = self
            cell.tfGpa.delegate = self
            cell.tfActScore.delegate = self
            cell.tfSatScore.delegate = self
            cell.tfApCredits.delegate = self
            
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileVolunteeringTableViewCell") as! AthleteProfileVolunteeringTableViewCell
            
            cell.textView.text = self.user.athleteProfile?.volunteering
            cell.textView.delegate = self
            
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        case 4: // Sports stats
            let category = self.user.category
            switch category {
            case "Soccer":
                let cell = tableView.dequeueReusableCell(withIdentifier: "SoccerTableViewCell") as! SoccerTableViewCell
               
                cell.tfStat1.text = self.user.athleteProfile?.stat1
                cell.tfStat2.text = self.user.athleteProfile?.stat2
                cell.tfStat3.text = self.user.athleteProfile?.stat3
                cell.tfStat4.text = self.user.athleteProfile?.stat4
                cell.tfStat5.text = self.user.athleteProfile?.stat5
                cell.tfStat6.text = self.user.athleteProfile?.stat6
                cell.tfStat7.text = self.user.athleteProfile?.stat7
                cell.tfStat8.text = self.user.athleteProfile?.stat8
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Basketball":
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasketballTableViewCell") as! BasketballTableViewCell
                
                cell.tfStat1.text = self.user.athleteProfile?.stat1
                cell.tfStat2.text = self.user.athleteProfile?.stat2
                cell.tfStat3.text = self.user.athleteProfile?.stat3
                cell.tfStat4.text = self.user.athleteProfile?.stat4
                cell.tfStat5.text = self.user.athleteProfile?.stat5
                cell.tfStat6.text = self.user.athleteProfile?.stat6
                cell.tfStat7.text = self.user.athleteProfile?.stat7
                cell.tfStat8.text = self.user.athleteProfile?.stat8
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Swimming":
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwimmingTableViewCell") as! SwimmingTableViewCell
                
                cell.tfStat1.text = self.user.athleteProfile?.stat1
                cell.tfStat2.text = self.user.athleteProfile?.stat2
                cell.tfStat3.text = self.user.athleteProfile?.stat3
                cell.tfStat4.text = self.user.athleteProfile?.stat4
                cell.tfStat5.text = self.user.athleteProfile?.stat5
                cell.tfStat6.text = self.user.athleteProfile?.stat6
                cell.tfStat7.text = self.user.athleteProfile?.stat7
                cell.tfStat8.text = self.user.athleteProfile?.stat8
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Track & Field":
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell") as! TrackTableViewCell
                
                cell.tfStat1.text = self.user.athleteProfile?.stat1
                cell.tfStat2.text = self.user.athleteProfile?.stat2
                cell.tfStat3.text = self.user.athleteProfile?.stat3
                cell.tfStat4.text = self.user.athleteProfile?.stat4
                cell.tfStat5.text = self.user.athleteProfile?.stat5
                cell.tfStat6.text = self.user.athleteProfile?.stat6
                cell.tfStat7.text = self.user.athleteProfile?.stat7
                cell.tfStat8.text = self.user.athleteProfile?.stat8
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Tennis":
                let cell = tableView.dequeueReusableCell(withIdentifier: "TennisTableViewCell") as! TennisTableViewCell
                
                cell.tfStat1.text = self.user.athleteProfile?.stat1
                cell.tfStat2.text = self.user.athleteProfile?.stat2
                cell.tfStat3.text = self.user.athleteProfile?.stat3
                cell.tfStat4.text = self.user.athleteProfile?.stat4
                cell.tfStat5.text = self.user.athleteProfile?.stat5
                cell.tfStat6.text = self.user.athleteProfile?.stat6
                cell.tfStat7.text = self.user.athleteProfile?.stat7
                cell.tfStat8.text = self.user.athleteProfile?.stat8
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Softball":
                let cell = tableView.dequeueReusableCell(withIdentifier: "SoftballTableViewCell") as! SoftballTableViewCell
                
                cell.tfStat1.text = self.user.athleteProfile?.stat1
                cell.tfStat2.text = self.user.athleteProfile?.stat2
                cell.tfStat3.text = self.user.athleteProfile?.stat3
                cell.tfStat4.text = self.user.athleteProfile?.stat4
                cell.tfStat5.text = self.user.athleteProfile?.stat5
                cell.tfStat6.text = self.user.athleteProfile?.stat6
                cell.tfStat7.text = self.user.athleteProfile?.stat7
                cell.tfStat8.text = self.user.athleteProfile?.stat8
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Golf":
                let cell = tableView.dequeueReusableCell(withIdentifier: "GolfTableViewCell") as! GolfTableViewCell
                
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
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                cell.tfStat9.delegate = self
                cell.tfStat10.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Volleyball":
                let cell = tableView.dequeueReusableCell(withIdentifier: "VolleyballTableViewCell") as! VolleyballTableViewCell
                
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
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                cell.tfStat9.delegate = self
                cell.tfStat10.delegate = self
                cell.tfStat11.delegate = self
                cell.tfStat12.delegate = self
                cell.tfStat13.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Lacrosse":
                let cell = tableView.dequeueReusableCell(withIdentifier: "LacrosseTableViewCell") as! LacrosseTableViewCell
                
                cell.tfStat1.text = self.user.athleteProfile?.stat1
                cell.tfStat2.text = self.user.athleteProfile?.stat2
                cell.tfStat3.text = self.user.athleteProfile?.stat3
                cell.tfStat4.text = self.user.athleteProfile?.stat4
                cell.tfStat5.text = self.user.athleteProfile?.stat5
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Hockey":
                let cell = tableView.dequeueReusableCell(withIdentifier: "HockeyTableViewCell") as! HockeyTableViewCell
                
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
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                cell.tfStat9.delegate = self
                cell.tfStat10.delegate = self
                cell.tfStat11.delegate = self
                cell.tfStat12.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Rowing":
                let cell = tableView.dequeueReusableCell(withIdentifier: "RowingTableViewCell") as! RowingTableViewCell
                
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
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                cell.tfStat9.delegate = self
                cell.tfStat10.delegate = self
                cell.tfStat11.delegate = self
                cell.tfStat12.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Water Polo":
                let cell = tableView.dequeueReusableCell(withIdentifier: "WaterpoloTableViewCell") as! WaterpoloTableViewCell
                
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
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                cell.tfStat9.delegate = self
                cell.tfStat10.delegate = self
                cell.tfStat11.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            case "Gymnastics":
                let cell = tableView.dequeueReusableCell(withIdentifier: "GymnasticsTableViewCell") as! GymnasticsTableViewCell
                
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
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                cell.tfStat9.delegate = self
                cell.tfStat10.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            default: // skiing
                let cell = tableView.dequeueReusableCell(withIdentifier: "SkiingTableViewCell") as! SkiingTableViewCell
                
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
                
                cell.tfStat1.delegate = self
                cell.tfStat2.delegate = self
                cell.tfStat3.delegate = self
                cell.tfStat4.delegate = self
                cell.tfStat5.delegate = self
                cell.tfStat6.delegate = self
                cell.tfStat7.delegate = self
                cell.tfStat8.delegate = self
                cell.tfStat9.delegate = self
                cell.tfStat10.delegate = self
                
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            }
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteProfileHighlightsTableViewCell") as! AthleteProfileHighlightsTableViewCell
            
            cell.textView.text = self.user.athleteProfile?.other
            cell.textView.delegate = self
            
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
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
                let vc:AthleteEditProfileViewController = picker.delegate as! AthleteEditProfileViewController
                vc.presentCropViewController(image)
                
            }
        }
        
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    // MARK: - Crop Image
    func presentCropViewController(_ image:UIImage){
        
        let cropViewController:TOCropViewController = TOCropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self;
        self.present(cropViewController, animated: true, completion: nil)
    }
    public func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int){
        print(">>>didCrop called")
        let newImage = ImageUtil.shared.resizeImage(image: image, compressionQuality: 0.5, targetSize: CGSize(width: 80, height: 80))
        self.dismiss(animated: true) {
            FirebaseUtil.shared.sendImage(newImage, showHUD: true, view: self.view, completion: { (metadata) in
                let link = metadata.downloadURL()!.absoluteString
                print(">>>download link: \(link)")
                self.user.imageURL = link
                self.ivPhoto.image = image
                // Save image data locally
                self.imageData = UIImageJPEGRepresentation(image, 0.8)
                // Update imageURL in Firebase DB
                FirebaseUtil.shared.updateUserPhoto(imageURL: link, completion: { (error) in
                    if error != nil{
                        print(">>>Failed to update user photo. Error:\(String(describing: error?.localizedDescription))")
                    }else{
                        // Update imageURL and imageData in UserDefaults
                        if self.imageData != nil{
                            UserDefaults.standard.set(self.user.imageURL, forKey: "imageURL")
                            UserDefaults.standard.set(self.imageData, forKey:"imageData")
                        }
                        
                        self.oldUser.imageURL = self.user.imageURL
                        self.showSuccessSnackBar(message: "Photo updated!")
                    }
                })
            })
        }
    }
    public func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool){
        print(">>>didFinishCancelled called")
        self.dismiss(animated: true, completion: nil)
    }
    
    //MAKR: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let trimmedText = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        switch textField.tag {
        case 0:
            self.user.athleteProfile?.height = trimmedText!
        case 1:
            self.user.athleteProfile?.weight = trimmedText!
        case 2:
            self.user.province = trimmedText!
        case 3:
            self.user.city = trimmedText!
        case 4:
            self.user.athleteProfile?.classOf = trimmedText!
        case 5:
            self.user.athleteProfile?.phone = trimmedText!
            
            
        case 7:
            self.user.athleteProfile?.schoolName = trimmedText!
        case 8:
            self.user.athleteProfile?.schoolZipCode = trimmedText!
        case 9:
            self.user.athleteProfile?.gpa = trimmedText!
        case 10:
            self.user.athleteProfile?.actScore = trimmedText!
        case 11:
            self.user.athleteProfile?.satScore = trimmedText!
        case 12:
            self.user.athleteProfile?.apCredits = trimmedText!
            
            
        case 15:
            self.user.athleteProfile?.stat1 = trimmedText!
        case 16:
            self.user.athleteProfile?.stat2 = trimmedText!
        case 17:
            self.user.athleteProfile?.stat3 = trimmedText!
        case 18:
            self.user.athleteProfile?.stat4 = trimmedText!
        case 19:
            self.user.athleteProfile?.stat5 = trimmedText!
        case 20:
            self.user.athleteProfile?.stat6 = trimmedText!
        case 21:
            self.user.athleteProfile?.stat7 = trimmedText!
        case 22:
            self.user.athleteProfile?.stat8 = trimmedText!
        case 23:
            self.user.athleteProfile?.stat9 = trimmedText!
        case 24:
            self.user.athleteProfile?.stat10 = trimmedText!
        case 25:
            self.user.athleteProfile?.stat11 = trimmedText!
        case 26:
            self.user.athleteProfile?.stat12 = trimmedText!
        case 27:
            self.user.athleteProfile?.stat13 = trimmedText!
            
        default:
            break
        }
    }
    
    // MARK: - TextViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {
        let trimmedText = textView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        switch textView.tag {
        case 6:
            self.user.athleteProfile?.honorsAwards = trimmedText!
            
        case 13:
            self.user.athleteProfile?.volunteering = trimmedText!
            
        case 14:
            self.user.athleteProfile?.other = trimmedText!
            
        default:
            break
        }

    }
    // MARK: - UIPickerViewDataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tfCategory.text = myPickerData[row]
        self.user.category = myPickerData[row]
        self.tvProfile.reloadData()
        
    }
}
