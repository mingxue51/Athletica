//
//  CoachScheduleStreamViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/24/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class CoachScheduleStreamViewController: BaseViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var viewHappening: UIView!
    @IBOutlet weak var viewCategory: UIView!
    
    var tfHappening:MyFloatingLabelTextField!
    var tfCategory:MyFloatingLabelTextField!
    
    let myPickerData = [String](arrayLiteral: "Soccer", "Basketball", "Swimming", "Track & Field", "Tennis", "Softball", "Golf", "Volleyball", "Lacrosse", "Hockey", "Rowing", "Water Polo", "Gymnastics", "Skiiing")
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lblDifference: UILabel!
    
    

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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LiveStreamViewController") as! LiveStreamViewController
        let firstName = UserDefaults.standard.string(forKey: "firstName")
        let lastName = UserDefaults.standard.string(forKey: "lastName")
        let userName = firstName! + " " + lastName!
        vc.userName = userName
        print(vc.userName)
        vc.category = self.tfCategory.text!
        vc.happening = trimmedStringFromString(string: self.tfHappening.text!)
        self.navigationController?.pushViewController(vc, animated: true)
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
