//
//  StartLiveStreamViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/4/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class StartLiveStreamViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var viewHappening: UIView!
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var viewOnBehalfOf: UIView!
   
    @IBOutlet weak var lblSave: UILabel!
    
    var tfHappening:MyFloatingLabelTextField!
    var tfCategory:MyFloatingLabelTextField!
    var tfOnBehalfOf:MyFloatingLabelTextField!
    @IBOutlet weak var svInput: UIStackView!
    @IBOutlet weak var switchSaveStream: UISwitch!
    
    let pickerCategory = UIPickerView()
    let pickerOnBehalfOf = UIPickerView()
    
    let pickerCategoryData = [String](arrayLiteral: "Soccer", "Basketball", "Swimming", "Track & Field", "Tennis", "Softball", "Golf", "Volleyball", "Lacrosse", "Hockey", "Rowing", "Water Polo", "Gymnastics", "Skiiing")
    var pickerOnBehalfOfData:[String] = [] // An array of userName_userType
    var pickerOnBehalfOfUserIds:[String] = [] // An array of userId's
    var onBehalfOfUsers:[String:String] = [:]
    
    var onBehalfOfUserId:String? // Used when the user is going to start the stream on behalf of an athlete
    var nSavedStreams:Int! // Passed to LiveStreamVC
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getOnBehalfOfUsers()
        
        // Hide switch if not an athlete
        let userType = UserDefaults.standard.string(forKey: "userType")!
        if userType != UserType.athlete.rawValue{
            self.lblSave.isHidden = true
            self.switchSaveStream.isHidden = true
        }
    }
    func getOnBehalfOfUsers(){
        self.startAnimating()
        FirebaseUtil.shared.getOnBehalfOfUsers { (users, error) in
            self.stopAnimating()
            // Disable tfOnBehalfOf if no onBehalfOfUsers
            if users.count < 1{
                self.tfOnBehalfOf.isHidden = true
            }
            ///
            
            if error != nil{
                print(">>>Failed to get onBehalfOfUsers. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.onBehalfOfUsers = users
                for key in self.onBehalfOfUsers.keys{
                    self.pickerOnBehalfOfUserIds.append(key)
                    self.pickerOnBehalfOfData.append(self.onBehalfOfUsers[key]!)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupUI()
    }
    func setupUI(){
        
        if tfHappening != nil {
            tfHappening.removeFromSuperview()
        }
        if tfCategory != nil {
            tfCategory.removeFromSuperview()
        }
        if tfOnBehalfOf != nil {
            tfOnBehalfOf.removeFromSuperview()
        }
        
        tfHappening = MyFloatingLabelTextField(frame: self.viewHappening.frame.insetBy(dx: 0, dy: 5))
        tfHappening.placeholder = "WHAT'S HAPPENING NOW?"
        tfHappening.title = "WHAT'S HAPPENING NOW?"
        self.svInput.addSubview(tfHappening)
        
        
        tfCategory = MyFloatingLabelTextField(frame: self.viewCategory.frame.insetBy(dx: 0, dy: 5))
        tfCategory.placeholder = "WHAT CATEGORY?"
        tfCategory.title = "WHAT CATEGORY?"
        self.svInput.addSubview(tfCategory)
        
        
        tfOnBehalfOf = MyFloatingLabelTextField(frame: self.viewOnBehalfOf.frame.insetBy(dx: 0, dy: 5))
        tfOnBehalfOf.placeholder = "STREAM ON BEHALF OF?"
        tfOnBehalfOf.title = "STREAM ON BEHALF OF?"
        self.svInput.addSubview(tfOnBehalfOf)
        
        
        tfHappening.textColor = UIColor.white
        tfHappening.lineColor = UIColor.white
        tfHappening.font = UIFont(name:"AvenirNext-Bold", size: 14.0)
        tfHappening.lineHeight = 2.0
        tfHappening.titleColor = UIColor.white
        tfHappening.tintColor = UIColor.white // the color of the blinking cursor
        tfHappening.selectedTitleColor = UIColor.white
        tfHappening.selectedLineColor = UIColor.white
        tfHappening.placeholderColor = UIColor.white
        
        
        tfCategory.textColor = UIColor.white
        tfCategory.lineColor = UIColor.white
        tfCategory.font = UIFont(name:"AvenirNext-Bold", size: 14.0)
        tfCategory.lineHeight = 2.0
        tfCategory.titleColor = UIColor.white
        tfCategory.tintColor = UIColor.white // the color of the blinking cursor
        tfCategory.selectedTitleColor = UIColor.white
        tfCategory.selectedLineColor = UIColor.white
        tfCategory.placeholderColor = UIColor.white
        
        
        tfOnBehalfOf.textColor = UIColor.white
        tfOnBehalfOf.lineColor = UIColor.white
        tfOnBehalfOf.font = UIFont(name:"AvenirNext-Bold", size: 14.0)
        tfOnBehalfOf.lineHeight = 2.0
        tfOnBehalfOf.titleColor = UIColor.white
        tfOnBehalfOf.tintColor = UIColor.white // the color of the blinking cursor
        tfOnBehalfOf.selectedTitleColor = UIColor.white
        tfOnBehalfOf.selectedLineColor = UIColor.white
        tfOnBehalfOf.placeholderColor = UIColor.white
        
        
        tfCategory.inputView = self.pickerCategory
        self.pickerCategory.delegate = self
        
        tfOnBehalfOf.inputView = self.pickerOnBehalfOf
        self.pickerOnBehalfOf.delegate = self
        
        tfHappening.becomeFirstResponder()
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
    
    // MARK: Button Actions
    @IBAction func btnStartTapped(_ sender: UIButton) {
        let message = self.isEmptyFields()
        if message != "" {
            showAlert(title: nil, message: message, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
        } else {
            
            // If the user sets the Save Stream switch on,
            // check if maximum number has been reached
            if self.switchSaveStream.isOn{
                if (self.tfOnBehalfOf.text?.isEmpty)!{
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
                                self.nSavedStreams = nSavedStreams
                                self.startLiveStream()
                            }
                        }
                    })
                }else{
                    // The user is on behalf of an athlete
                    // Get nSavedStreams of the athlete
                    self.startAnimating()
                    FirebaseUtil.shared.getNSavedStreams(userId: self.onBehalfOfUserId!, completion: { (nSavedStreams, error) in
                        self.stopAnimating()
                        if error != nil{
                            print(">>>Failed to get nSavedStreams. Error: \(String(describing: error?.localizedDescription))")
                            showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                        }else{
                            if nSavedStreams > 4{
                                showAlert(title: nil, message: AlertMessage.maxNumOfHerSavedStreams, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                                
                            }else{
                                self.nSavedStreams = nSavedStreams
                                self.startLiveStream()
                            }
                        }
                    })
                }
                
            }else{
                startLiveStream()
            }
        }
    }
    func isEmptyFields()->String{
        
        var result:String = ""
        if (self.tfHappening.text?.isEmpty)! {
            result = AlertMessage.happeningEmpty
            return result
        }
        if (self.tfCategory.text?.isEmpty)! {
            result = AlertMessage.categoryEmpty
            return result
        }
        
        
        return result
    }
    func startLiveStream(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LiveStreamViewController") as! LiveStreamViewController
        if (self.tfOnBehalfOf.text?.isEmpty)!{
            vc.creatorId = UserDefaults.standard.string(forKey: "userId")!
            vc.creatorName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
        }else{
            vc.creatorName = self.tfOnBehalfOf.text!
            vc.creatorId = self.onBehalfOfUserId
        }
        
        vc.category = self.tfCategory.text!
        vc.happening = trimmedStringFromString(string: self.tfHappening.text!)
        vc.isSaveStream = self.switchSaveStream.isOn
        vc.nSavedStreams = self.nSavedStreams
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    
    // MARK: UIPickerViewDataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerCategory {
            return pickerCategoryData.count
        }else{
            return pickerOnBehalfOfData.count
        }
        
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == self.pickerCategory {
            return pickerCategoryData[row]
        }else{
            let arr = pickerOnBehalfOfData[row].components(separatedBy: "_")
            return arr[0]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == self.pickerCategory {
            self.tfCategory.text = pickerCategoryData[row]
        }else{
            let arr = pickerOnBehalfOfData[row].components(separatedBy: "_")
            self.tfOnBehalfOf.text = arr[0]
            if arr[1] == UserType.athlete.rawValue{
                self.lblSave.isHidden = false
                self.switchSaveStream.isHidden = false
            }else{
                self.lblSave.isHidden = true
                self.switchSaveStream.isHidden = true
            }
            self.onBehalfOfUserId = self.pickerOnBehalfOfUserIds[row]
        }
        
    }
}

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.0
    }
}

