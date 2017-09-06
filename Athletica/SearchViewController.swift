//
//  SearchViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/17/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    let categories = ["1_track_field", "2_volleyball", "3_tennis",
                      "4_swimming", "5_golf", "6_skiing",
                      "7_softball", "8_basketball", "9_gymnastics",
                      "10_soccer", "11_lacrosse", "12_ice_hockey",
                      "13_water polo", "14_rowing", "15_football"]
    let categoryNames = ["Track & Field", "Volleyball", "Tennis",
                         "Swimming",  "Golf", "Skiiing",
                         "Softball", "Basketball", "Gymnastics",
                         "Soccer", "Lacrosse", "Hockey",
                         "Water Polo", "Rowing", "Football"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPeople: UIButton!
    @IBOutlet weak var barPeople: UIView!
    @IBOutlet weak var btnStreams: UIButton!
    @IBOutlet weak var barStreams: UIView!
    @IBOutlet weak var tvPeople: UITableView!
    @IBOutlet weak var tvCategories: UITableView!
    @IBOutlet weak var tvStreams: UITableView!
    
    var refreshControlPeople: UIRefreshControl!
    var refreshControlCategories: UIRefreshControl!
    
    
    @IBOutlet weak var indicatorPeople: UIActivityIndicatorView!
    @IBOutlet weak var indicatorCategories: UIActivityIndicatorView!
    
    
    var users:[User] = []
    var filteredUsers:[User] = []
    var streams:[String:[Stream]] = [:] // Dictionary
    var filteredStreams:[String:[Stream]] = [:]
    var streamsInCategory:[Stream] = [] // Streams in a selected category
    var filteredStreamsInCategory:[Stream] = []// Filtered streams in a selected category
    var selectedCategory:String = "" // Used to filter streams by category
    var peopleDownloaded:Bool = false
    var streamsDownloaded:Bool = false
    
    var isRemovingTextWithBackspace = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.showFirstView()
        
        self.indicatorPeople.startAnimating()
        self.indicatorPeople.isHidden = false
        self.indicatorCategories.isHidden = true
        self.tvPeople.tableFooterView = UIView()
        self.tvCategories.tableFooterView = UIView()
        self.tvStreams.tableFooterView = UIView()
        self.tvStreams.dataSource = self
        self.tvStreams.delegate = self
        
        // Refresh control
        refreshControlPeople = UIRefreshControl()
        refreshControlPeople.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlPeople.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tvPeople.addSubview(refreshControlPeople)
        
        refreshControlCategories = UIRefreshControl()
        refreshControlCategories.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlCategories.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tvCategories.addSubview(refreshControlCategories)
        
        // Dismiss keyboard when scrolling table views
        tvPeople.keyboardDismissMode = .onDrag
        tvCategories.keyboardDismissMode = .onDrag
        tvStreams.keyboardDismissMode = .onDrag
        
        self.getUsers()
        
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        if sender as! NSObject == self.refreshControlPeople{
            self.getUsers()
        }else{ // refreshControlCategories
            self.getStreams()
        }
        
    }
    func getUsers(){
        FirebaseUtil.shared.getUsers(completion: { (users, error) in
            if error != nil{
                DispatchQueue.main.async {
                    if self.indicatorPeople.isHidden == false{
                        self.indicatorPeople.isHidden = true
                        self.indicatorPeople.stopAnimating()
                    }
                }
                print(">>>Failed to get users. Error: \(String(describing: error))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.peopleDownloaded = true
                self.users = users
                self.filteredUsers = users
                DispatchQueue.main.async {
                    if self.indicatorPeople.isHidden == false{
                        self.indicatorPeople.isHidden = true
                        self.indicatorPeople.stopAnimating()
                    }
                    self.tvPeople.reloadData()
                    self.refreshControlPeople.endRefreshing()
                }
            }
        })
    }
    func showFirstView(){
        self.firstView.isHidden = false
        self.secondView.isHidden = true
        self.btnMenu.isHidden = false
        self.btnBack.isHidden = true
    }
    func showSecondView(){
        self.firstView.isHidden = true
        self.secondView.isHidden = false
        self.btnMenu.isHidden = true
        self.btnBack.isHidden = false
        
        self.showPeople()
    }
    func showPeople(){
        self.barPeople.isHidden = false
        self.barStreams.isHidden = true
        self.btnPeople.titleLabel?.font = UIFont(name:"AvenirNext-Bold", size: 18.0)
        self.btnStreams.titleLabel?.font = UIFont(name:"AvenirNext-Medium", size: 18.0)
        self.tvPeople.isHidden = false
        self.tvCategories.isHidden = true
        self.indicatorCategories.isHidden = true
        self.tvStreams.isHidden = true
    }
    func showCategories(){
        self.barPeople.isHidden = true
        self.barStreams.isHidden = false
        self.btnStreams.titleLabel?.font = UIFont(name:"AvenirNext-Bold", size: 18.0)
        self.btnPeople.titleLabel?.font = UIFont(name:"AvenirNext-Medium", size: 18.0)
        self.tvPeople.isHidden = true
        self.tvCategories.isHidden = false
        self.indicatorPeople.isHidden = true
        self.tvStreams.isHidden = true
    }
    func showStreams(){
        self.tvStreams.isHidden = false
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

    // MARK: - CollectionView DataSource and Delegate
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.categories.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        cell.ivCategory.image = UIImage(named: self.categories[indexPath.row])
        cell.ivCategory.contentMode = .scaleAspectFit
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
       
        self.selectedCategory = self.categoryNames[indexPath.row]
        print(">>>Selected category: \(self.selectedCategory)")
        
        
        if self.streamsDownloaded != true{ // Download streams
            self.startAnimating()
            FirebaseUtil.shared.getStreamsOnce { (streams, error) in
                self.stopAnimating()
                if error != nil{
                    print(">>>Failed to get streams. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                    return
                }
                
                self.streamsDownloaded = true
                // Init self.streams with streams
                for stream in streams{
                    if self.streams[stream.category] == nil{
                        self.streams[stream.category] = []
                    }
                    self.streams[stream.category]?.append(stream)
                }
                self.filteredStreams = self.streams
                self.tvCategories.reloadData()
                
                // Show streams in the category
                if self.streams[self.selectedCategory] == nil{
//                    showAlert(title: nil, message: "No streams for the category", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                    self.showErrorSnackBar(message: "No streams for the category")
                    return
                }
                self.showSecondView()
                self.showCategories()
                self.streamsInCategory = self.streams[self.selectedCategory]!
                self.filteredStreamsInCategory = self.streamsInCategory
                self.tvStreams.reloadData()
                self.showStreams()
            }
        }else{
            // Show streams in the category
            if self.streams[self.selectedCategory] == nil{
//                showAlert(title: nil, message: "No streams for the category", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                self.showErrorSnackBar(message: "No streams for the category")
                return
            }
            self.showSecondView()
            self.showCategories()
            self.streamsInCategory = self.streams[self.selectedCategory]!
            self.filteredStreamsInCategory = self.streamsInCategory
            self.tvStreams.reloadData()
            self.showStreams()
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = (self.collectionView.frame.width - 30.0) / 3.0
        let height = width * 124.0 / 108.0
        let size = CGSize(width: width, height: height)
        return size
    }
    
    // MARK: - UISearchBarDelegate
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        if self.firstView.isHidden == false{
            self.showSecondView()
        }
    }
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.isRemovingTextWithBackspace = (NSString(string: searchBar.text!).replacingCharacters(in: range, with: text).characters.count == 0)
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 && !isRemovingTextWithBackspace {
            self.filteredUsers = self.users
            self.tvPeople.reloadData()
            self.filteredStreams = self.streams
            self.tvCategories.reloadData()
            self.filteredStreamsInCategory = self.streamsInCategory
            self.tvStreams.reloadData()
            
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            return
        }
        
        if searchText == ""{
            self.filteredUsers = self.users
            self.tvPeople.reloadData()
            self.filteredStreams = self.streams
            self.tvCategories.reloadData()
            self.filteredStreamsInCategory = self.streamsInCategory
            self.tvStreams.reloadData()
            return
        }
        
        self.filteredUsers.removeAll()
        for item in self.users {
            let name = item.firstName + " " + item.lastName
            if name.lowercased().contains(searchText.lowercased()){
                self.filteredUsers.append(item)
            }
        }
        self.tvPeople.reloadData()
        
        self.filteredStreams.removeAll()
        for item in self.streams {
            let name = item.key
            if name.lowercased().contains(searchText.lowercased()){
                self.filteredStreams[name] = item.value
            }
        }
        self.tvCategories.reloadData()
        
        self.filteredStreamsInCategory.removeAll()
        for item in self.streamsInCategory {
            let name = item.title
            if name.lowercased().contains(searchText.lowercased()){
                self.filteredStreamsInCategory.append(item)
            }
        }

        self.tvStreams.reloadData()
        
    }
    
    // MARK: - Button Actions
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.showFirstView()
        self.searchBar.resignFirstResponder()
    }
    @IBAction func btnPeopleTapped(_ sender: UIButton) {
        self.searchBar.resignFirstResponder()
        self.showPeople()
    }
    @IBAction func btnStreamsTapped(_ sender: UIButton) {
        self.searchBar.resignFirstResponder()
        self.showCategories()
        
        if self.streamsDownloaded == true {return}
        self.getStreams()
    }
    func getStreams(){
        
        self.indicatorCategories.isHidden = false
        self.indicatorCategories.startAnimating()
        FirebaseUtil.shared.getStreamsOnce { (streams, error) in
            self.indicatorCategories.stopAnimating()
            self.indicatorCategories.isHidden = true
            if error != nil{
                print(">>>Failed to get streams. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                return
            }
            
            self.streamsDownloaded = true
            // Init self.streams with streams
            for stream in streams{
                if self.streams[stream.category] == nil{
                    self.streams[stream.category] = []
                }
                self.streams[stream.category]?.append(stream)
            }
            self.filteredStreams = self.streams
//            dump(self.streams)
            self.tvCategories.reloadData()
            self.refreshControlCategories.endRefreshing()
        }
    }
    
    
    //  MARK: - UITableViewDataSource and Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if tableView == self.tvPeople {
            return self.filteredUsers.count
        }else if tableView == self.tvCategories{
            return self.filteredStreams.count
        }else{ // tvStreams
            return self.filteredStreamsInCategory.count
        }
        
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView == self.tvPeople {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPeopleTableViewCell") as! SearchPeopleTableViewCell
            let user = self.filteredUsers[indexPath.row]
            if user.imageURL != ""{
                let url = URL(string:user.imageURL)
                cell.ivPhoto.kf.setImage(with: url)
                cell.ivPhoto.kf.indicatorType = .activity
            }
            cell.ivPhoto.layer.cornerRadius = 19.0
            cell.lblName.text = user.firstName + " " + user.lastName
            cell.lblCategory.text = user.category + " " + user.userType
            return cell
        }else if tableView == self.tvCategories{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchStreamsTableViewCell") as! SearchStreamsTableViewCell
            let keys = self.filteredStreams.keys.sorted()
            cell.textLabel?.text = keys[indexPath.row]
            return cell
        }else{ // tvStreams
            let cell = tableView.dequeueReusableCell(withIdentifier: "StreamTableViewCell", for: indexPath) as! StreamTableViewCell
            let stream = self.filteredStreamsInCategory[indexPath.row]
            
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
            
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tvPeople{
            return 75
        }else if tableView == self.tvCategories{
            return 50
        }else{ // streams by sport
            return 260
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tvCategories{
            tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: indexPath)
            self.selectedCategory = (cell?.textLabel?.text)!
//            print(">>>Selected category: \(self.selectedCategory)")
            if self.selectedCategory != ""{
                self.streamsInCategory = self.streams[self.selectedCategory]!
                self.filteredStreamsInCategory = self.streamsInCategory
                self.tvStreams.reloadData()
            }
            self.showStreams()
        }else if tableView == self.tvPeople{
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            let user = self.filteredUsers[indexPath.row]
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
            
        }else{ // tvStreams
            // Go to PlayerVC
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            vc.stream = self.filteredStreamsInCategory[indexPath.row]
            self.present(vc, animated: true, completion: nil)
        }
    }
}
