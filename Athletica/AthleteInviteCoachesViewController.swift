//
//  AthleteInviteCoachesViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/27/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class AthleteInviteCoachesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var lblInvites: UILabel!
    @IBOutlet weak var tvCoaches: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var coaches:[User] = []
    var filteredCoaches:[User] = []
    var selected:[Bool] = []
    var filteredSelected:[Bool] = []
    
    var nInvites:Int = 0{
        didSet{
            self.lblInvites.text = String(self.nInvites) + " Invites"
        }
    }
    
    var delegate:AthleteScheduleStreamViewController! // Used to pass selected coaches to AthleteScheduleStreamVC
    var isRemovingTextWithBackspace = false
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tvCoaches.tableFooterView = UIView()
        self.searchBar.delegate = self
        
        self.getCoaches()
        
    }
    func getCoaches(){
        self.startAnimating()
        FirebaseUtil.shared.getCoaches { (coaches, selected, error) in
            self.stopAnimating()
            if error == nil{
                self.coaches = coaches
                self.filteredCoaches = coaches
                self.selected = selected
                self.filteredSelected = selected
                self.tvCoaches.reloadData()
            }else{
                print(">>>Failed to get coaches. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: { 
                    self.getCoaches()
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
        delegate.invitedCoaches = []
        for index in 0...self.filteredSelected.count-1 {
            if self.filteredSelected[index] == true{
                delegate.invitedCoaches.append(self.filteredCoaches[index])
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSelectAllTapped(_ sender: UIButton) {
        if self.filteredSelected.count == 0 {
            return
        }
        for index in 0...self.filteredSelected.count-1 {
            self.filteredSelected[index] = true
        }
        self.tvCoaches.reloadData()
        self.nInvites = self.filteredSelected.count
    }
    @IBAction func btnClearTapped(_ sender: UIButton) {
        if self.filteredSelected.count == 0 {
            return
        }
        for index in 0...self.filteredSelected.count-1 {
            self.filteredSelected[index] = false
        }
        self.tvCoaches.reloadData()
        self.nInvites = 0
    }
    
    
    
    //  MARK: - UITableViewDataSource and Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.filteredCoaches.count
        
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCoachesTableViewCell") as! InviteCoachesTableViewCell
        let coach = self.filteredCoaches[indexPath.row]
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
            self.nInvites += 1
        }else{
            cell.btnCheckBox.setImage(UIImage(named: "unchecked"), for: .normal)
            self.nInvites -= 1
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 && !isRemovingTextWithBackspace {
            self.filteredCoaches = self.coaches
            self.filteredSelected = self.selected
            self.tvCoaches.reloadData()
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            return
        }
        
        if searchText == ""{
            self.filteredCoaches = self.coaches
            self.filteredSelected = self.selected
            self.tvCoaches.reloadData()
            return
        }
        
        self.filteredCoaches.removeAll()
        self.filteredSelected.removeAll()
        for item in self.coaches {
            let name = item.firstName + " " + item.lastName
            if name.lowercased().contains(searchText.lowercased()){
                self.filteredCoaches.append(item)
                self.filteredSelected.append(false)
            }
        }
        self.nInvites = self.filteredCoaches.count
        self.tvCoaches.reloadData()
        
    }
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.isRemovingTextWithBackspace = (NSString(string: searchBar.text!).replacingCharacters(in: range, with: text).characters.count == 0)
        return true
    }
}
