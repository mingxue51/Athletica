//
//  AuthorizedUsersViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/13/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class AuthorizedUsersViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var lblAuthorizedUsers: UILabel!
    @IBOutlet weak var tvUsers: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users:[User] = []
    var filteredUsers:[User] = []
    var selected:[Bool] = []
    var filteredSelected:[Bool] = []
    
    var nAuthUsers:Int = 0{
        didSet{
            self.lblAuthorizedUsers.text = String(self.nAuthUsers) + " Authorized Users"
        }
    }
    
    var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tvUsers.tableFooterView = UIView()
        self.searchBar.delegate = self
        
        // Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tvUsers.addSubview(refreshControl)
        
        self.getUsers()
        
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.getUsers()
    }
    func getUsers(){
        self.startAnimating()
        FirebaseUtil.shared.getAuthorizedUsers { (users, selected, nAuthUsers, error) in
            self.stopAnimating()
            if error == nil{
                self.users = users
                self.filteredUsers = users
                self.selected = selected
                self.filteredSelected = selected
                self.nAuthUsers = nAuthUsers
                self.tvUsers.reloadData()
                self.refreshControl.endRefreshing()
            }else{
                print(">>>Failed to get users. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                    self.getUsers()
                }, cancelAction: nil)
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
    
    // MARK: - Button Actions
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        var authUsers:[String:String] = [:]
        let myFullName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
        let myUserType = UserDefaults.standard.string(forKey: "userType")!
        for index in 0...self.filteredSelected.count-1 {
            if self.filteredSelected[index] == true{
                let user = self.filteredUsers[index]
                authUsers[user.userId] = myFullName + "_" + myUserType
            }
        }
        
        FirebaseUtil.shared.uploadAuthorizedUsers(authorizedUsers: authUsers, completion: { (error) in
            if error != nil{
                print(">>>Failed to upload authorized users. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                return
            }else{
                // Upload success, save the auth users to UserDefaults
                UserDefaults.standard.set(authUsers, forKey: "authorizedUsers")
                UserDefaults.standard.synchronize()
            }
        })
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSelectAllTapped(_ sender: UIButton) {
        if self.filteredSelected.count == 0 {
            return
        }
        for index in 0...self.filteredSelected.count-1 {
            self.filteredSelected[index] = true
        }
        self.tvUsers.reloadData()
        self.nAuthUsers = self.filteredSelected.count
    }
    @IBAction func btnClearTapped(_ sender: UIButton) {
        if self.filteredSelected.count == 0 {
            return
        }
        for index in 0...self.filteredSelected.count-1 {
            self.filteredSelected[index] = false
        }
        self.tvUsers.reloadData()
        self.nAuthUsers = 0
    }
    
    
    
    //  MARK: - UITableViewDataSource and Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.filteredUsers.count
        
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCoachesTableViewCell") as! InviteCoachesTableViewCell
        let coach = self.filteredUsers[indexPath.row]
        cell.lblCoachName.text = coach.firstName + " " + coach.lastName
        if self.filteredSelected[indexPath.row] == true {
            cell.btnCheckBox.setImage(UIImage(named: "checked"), for: .normal)
        }else{
            cell.btnCheckBox.setImage(UIImage(named: "unchecked"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.filteredSelected[indexPath.row] = !self.filteredSelected[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath) as! InviteCoachesTableViewCell
        if self.filteredSelected[indexPath.row] == true {
            cell.btnCheckBox.setImage(UIImage(named: "checked"), for: .normal)
            self.nAuthUsers += 1
        }else{
            cell.btnCheckBox.setImage(UIImage(named: "unchecked"), for: .normal)
            self.nAuthUsers -= 1
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""
        {
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            return
        }
        if searchText == ""{
            self.filteredUsers = self.users
            self.filteredSelected = self.selected
            
            return
        }
        
        self.filteredUsers.removeAll()
        self.filteredSelected.removeAll()
        for item in self.users {
            let name = item.firstName + " " + item.lastName
            if name.lowercased().contains(searchText.lowercased()){
                self.filteredUsers.append(item)
                self.filteredSelected.append(false)
            }
        }
        self.nAuthUsers = self.filteredUsers.count
        self.tvUsers.reloadData()
        
    }
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }

}
