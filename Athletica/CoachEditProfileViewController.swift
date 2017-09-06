//
//  CoachEditProfileViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/18/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Kingfisher
import TOCropViewController
import Photos

class CoachEditProfileViewController: BaseViewController, UIImagePickerControllerDelegate, TOCropViewControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfCategory: UITextField!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfCompany: UITextField!
    
    @IBOutlet weak var btnSave: UIButton!
    
    var user:User!// Inited by CoachProfileVC
    var imageData:Data? // Assigned after user uploads her photo
    var imageURL:String = "" // Assigned after user uploads her photo
    
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
        self.tfCompany.layer.borderColor = UIColor.lightGray.cgColor
        
        self.tfFirstName.adjustsFontSizeToFitWidth = true
        self.tfLastName.adjustsFontSizeToFitWidth = true
        self.tfCategory.adjustsFontSizeToFitWidth = true
        self.tfCity.adjustsFontSizeToFitWidth = true
        self.tfState.adjustsFontSizeToFitWidth = true
        self.tfCompany.adjustsFontSizeToFitWidth = true
        
        let thePicker = UIPickerView()
        tfCategory.inputView = thePicker
        thePicker.delegate = self
        
        // Hide tfCompany if the user is a fan
        if self.user.userType == UserType.fan.rawValue{
            self.tfCompany.isHidden = true
        }
        
        //----- Show profile info -----
        self.tfFirstName.text = self.user.firstName
        self.tfLastName.text = self.user.lastName
        self.tfCategory.text = self.user.category
        self.ivPhoto.layer.cornerRadius = 64.0
        self.imageURL = self.user.imageURL
        
        let imageData = UserDefaults.standard.data(forKey: "imageData")
        if imageData != nil{
            self.ivPhoto.image = UIImage(data: imageData!)
        }else if self.user.imageURL != ""{
            let url = URL(string: self.user.imageURL)
            self.ivPhoto.kf.setImage(with: url)
        }
        self.tfCity.text = self.user.city
        self.tfState.text = self.user.province
        self.tfCompany.text = self.user.extra
        //------------------------------
        
        // Set placeholder text of tfCompany according to the user type
        if self.user.userType == UserType.proAthlete.rawValue{
            self.tfCompany.placeholder = "Team"
        }else if self.user.userType == UserType.coach.rawValue{
            self.tfCompany.placeholder = "Team/Company"
        }
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
        let firstName = trimmedStringFromString(string: self.tfFirstName.text!)
        let lastName = trimmedStringFromString(string: self.tfLastName.text!)
        let category = trimmedStringFromString(string: self.tfCategory.text!)
        let city = trimmedStringFromString(string: self.tfCity.text!)
        let province = trimmedStringFromString(string: self.tfState.text!)
        let extra = trimmedStringFromString(string: self.tfCompany.text!)
        
//        if city=="" && province=="" && extra=="" && self.imageURL==""{
//            self.showErrorSnackBar(message: "Nothing to save!")
//            return
//        }
        
        self.startAnimating()
        FirebaseUtil.shared.updateCoach(firstName:firstName, lastName:lastName, category: category, imageURL: self.imageURL, city: city, province: province, extra: extra) { (error) in
            self.stopAnimating()
            if error != nil{
                print(">>>Failed to update profile. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                // Update info in UserDefaults
                if self.imageData != nil{
                    UserDefaults.standard.set(self.imageURL, forKey: "imageURL")
                    UserDefaults.standard.set(self.imageData, forKey:"imageData")
                }
                UserDefaults.standard.set(firstName, forKey: "firstName")
                UserDefaults.standard.set(lastName, forKey: "lastName")
                UserDefaults.standard.set(category, forKey: "category")
                UserDefaults.standard.set(city, forKey: "city")
                UserDefaults.standard.set(province, forKey: "province")
                UserDefaults.standard.set(extra, forKey: "extra")
                
                // Update the user object
                self.user.firstName = firstName
                self.user.lastName = lastName
                self.user.category = category
                self.user.city = city
                self.user.province = province
                self.user.extra = extra
                self.user.imageURL = self.imageURL
                
                self.showSuccessSnackBar(message: "Profile Saved!")
                
                self.navigationController?.popViewController(animated: true)
            }
        }
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
        if self.user.userType == UserType.coach.rawValue{
            if (self.tfCompany.text?.isEmpty)! {
                result = AlertMessage.companyEmpty
                return result
            }
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
        let newImage = ImageUtil.shared.resizeImage(image: image, compressionQuality: 0.5, targetSize: CGSize(width: 128, height: 128))
        self.dismiss(animated: true) {
            FirebaseUtil.shared.sendImage(newImage, showHUD: true, view: self.view, completion: { (metadata) in
                let link = metadata.downloadURL()!.absoluteString
                print(">>>download link: \(link)")
                self.imageURL = link
                self.user.imageURL = link
                self.ivPhoto.image = image
                // Save image data locally
                self.imageData = UIImageJPEGRepresentation(image, 100)
                
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
        
        
    }
}
