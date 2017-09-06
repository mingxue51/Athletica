//
//  ScheduleStreamViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/24/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class ScheduleStreamViewController: BaseViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var viewHappening: UIView!
    @IBOutlet weak var viewCategory: UIView!
    var isTextFieldsShown:Bool = false // Used to preserve text fields' values
    
    var tfHappening:MyFloatingLabelTextField!
    var tfCategory:MyFloatingLabelTextField!
    
    let myPickerData = [String](arrayLiteral: "Soccer", "Basketball", "Swimming", "Track & Field", "Tennis", "Softball", "Golf", "Volleyball", "Lacrosse", "Hockey", "Rowing", "Water Polo", "Gymnastics", "Skiiing", "football")
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lblDifference: UILabel!
    
    var stream:Stream!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        datePicker.datePickerMode = .dateAndTime
        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        datePicker.minimumDate = Date()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tfHappening.becomeFirstResponder()
        self.isTextFieldsShown = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupUI()
    }
    
    func setupUI(){
        if self.isTextFieldsShown {
            return
        }
        
        if tfHappening != nil {
            tfHappening.removeFromSuperview()
        }
        if tfCategory != nil {
            tfCategory.removeFromSuperview()
        }
        
        tfHappening = MyFloatingLabelTextField(frame: self.viewHappening.frame.insetBy(dx: 0, dy: 5))
        tfHappening.placeholder = "WHAT'S HAPPENING NOW?"
        tfHappening.title = "WHAT'S HAPPENING NOW?"
        self.view.addSubview(tfHappening)
        
        
        tfCategory = MyFloatingLabelTextField(frame: self.viewCategory.frame.insetBy(dx: 0, dy: 5))
        tfCategory.placeholder = "WHAT CATEGORY?"
        tfCategory.title = "WHAT CATEGORY?"
        self.view.addSubview(tfCategory)
        
        
        let customGrayColor = UIColor(colorLiteralRed: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha: 1.0)
        
        tfHappening.textColor = customGrayColor
        tfHappening.lineColor = customGrayColor
        tfHappening.font = UIFont(name:"AvenirNext-Bold", size: 14.0)
        tfHappening.lineHeight = 2.0
        tfHappening.titleColor = customGrayColor
        tfHappening.tintColor = customGrayColor // the color of the blinking cursor
        tfHappening.selectedTitleColor = customGrayColor
        tfHappening.selectedLineColor = customGrayColor
        tfHappening.placeholderColor = customGrayColor
        
        
        tfCategory.textColor = customGrayColor
        tfCategory.lineColor = customGrayColor
        tfCategory.font = UIFont(name:"AvenirNext-Bold", size: 14.0)
        tfCategory.lineHeight = 2.0
        tfCategory.titleColor = customGrayColor
        tfCategory.tintColor = customGrayColor // the color of the blinking cursor
        tfCategory.selectedTitleColor = customGrayColor
        tfCategory.selectedLineColor = customGrayColor
        tfCategory.placeholderColor = customGrayColor
        
        
        let thePicker = UIPickerView()
        tfCategory.inputView = thePicker
        thePicker.delegate = self
        
    }
    
    
    @IBAction func valueChangedForPicker(sender: UIDatePicker) {
        let now = Date()
        let streamTime = sender.date
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: streamTime)
        
        // Get HH:MM PM string
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let timeString = formatter.string(from: streamTime)
        
        lblDifference.text = timeString + String(format: "(in %02d hours and %02d minutes)", components.hour!, components.minute!)
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnScheduleTapped(_ sender: UIButton) {
        let message = self.isEmptyFields()
        if message != "" {
            showAlert(title: nil, message: message, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
        } else {
            scheduleStream()
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
        if self.lblDifference.text == "Please set time for the stream" {
            return "Please set time for the stream."
        }
        return result
    }
    func scheduleStream(){
        let firstName = UserDefaults.standard.string(forKey: "firstName")
        let lastName = UserDefaults.standard.string(forKey: "lastName")
        let userName = firstName! + " " + lastName!
        let category = self.tfCategory.text!
        let happening = trimmedStringFromString(string: self.tfHappening.text!)
        
        
        self.stream = Stream()
        stream.creatorId = UserDefaults.standard.string(forKey: "userId")
        stream.creatorName = userName
        stream.title = happening
        stream.category = category
        stream.id = ""
        stream.type = "upcoming"
        stream.startAt = datePicker.date.timeIntervalSince1970
        let creatorImageURL = UserDefaults.standard.string(forKey: "imageURL")
        if creatorImageURL != nil {
            stream.creatorImageURL = creatorImageURL!
        }
        
        self.uploadStream()
        
    }
    func uploadStream(){
        self.startAnimating()
        FirebaseUtil.shared.uploadUpcomingStream(stream: self.stream) { (error) in
            self.stopAnimating()
            if error != nil {
                print(">>>Failded to upload the upcoming stream. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                    self.uploadStream()
                }, cancelAction: nil)
            }else{
                // Schedule push notifications using OneSignal
                self.sendNotification()
                navigateToVC(name: "UpcomingStreamsViewController", fromVC: self, animated: true)
            }
        }
    }
    // MARK: - OneSignal
    func sendNotification(){
        
        // Get string from date selected in datepicker
        // If the difference between the current date and selected date is smaller than 5 minutes
        // send a push notification right now.
        let date5minAgo = dateSubtracted(minutes: 5, from: self.datePicker.date)
        var date:Date!
        if date5minAgo.compare(Date()) ==  ComparisonResult.orderedAscending{ // Send a notificaion right away
            date = Date()
        }else{
            date = date5minAgo // Send a notification 5 mins before the start time
        }
        
        // Get OneSignal userIds to send push notifications to
        let myOneSignalUserId = UserDefaults.standard.string(forKey: "oneSignalUserId")
        var userIds:[String] = []
        // Send a notification to the user only if isScheduledStream is true
        let isScheduledStream = UserDefaults.standard.bool(forKey: "isScheduledStream")
        if isScheduledStream == true{
            userIds.append(myOneSignalUserId!)
        }
        
        let message = self.stream.creatorName + " will start a stream(" + self.stream.title + ") in 5 minutes."
        let heading = "Category: " + self.stream.category
        
        OneSignalUtil.shared.sendNotification(date: date, userIds: userIds, message: message, heading: heading)
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
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tfCategory.text = myPickerData[row]
    }

}
