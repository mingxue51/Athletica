//
//  UpgradeViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/19/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class UpgradeViewController: BaseViewController {
    
    let appBundleId = Bundle.main.bundleIdentifier!
    var isPurchasing:Bool = false // Used to prevent user interactions while purchasing

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.isPurchasing = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Button actions
    
    @IBAction func btnMonthTapped(_ sender: UIButton) {
        if self.isPurchasing{
            self.showErrorSnackBar(message: "Please wait while another purchase is being processed.")
            return
        }
        self.purchase(SubscriptionType.OneMonthOfBasicPlus)
    }

    @IBAction func btnYearTapped(_ sender: UIButton) {
        if self.isPurchasing{
            self.showErrorSnackBar(message: "Please wait while another purchase is being processed.")
            return
        }
        self.purchase(SubscriptionType.OneYearOfBasicPlus)
    }

    func purchase(_ purchase: SubscriptionType) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        self.isPurchasing = true
        
        let productId = appBundleId + "." + purchase.rawValue
        
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in
            
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                let appleValidator = AppleReceiptValidator(service: .production)
                SwiftyStoreKit.verifyReceipt(using: appleValidator, password: sharedSecrets) { result in
                    
                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            type: .autoRenewable,
                            productId: productId,
                            inReceipt: receipt)
                        
                        NetworkActivityIndicatorManager.networkOperationFinished()
                        self.isPurchasing = false
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let receiptItems):
                            print("Product is valid until \(expiryDate)")
                            
                            // Save the expiryTimestamp in UserDefaults and Firebase DB
                            self.setExpiryTimestamp(expiryDate: expiryDate)
                            UserDefaults.standard.set(expiryDate.timeIntervalSince1970, forKey: "expiryTimestamp")
                            self.navigationController?.popViewController(animated: true)
                            
                        case .expired(let expiryDate, let receiptItems):
                            print("Product is expired since \(expiryDate)")
                            
                        case .notPurchased:
                            print("This product has never been purchased")
                            
                        }
                        
                    } else {
                        // receipt verification error
                        NetworkActivityIndicatorManager.networkOperationFinished()
                        self.isPurchasing = false
                    }
                }
            } else {
                // purchase error
                NetworkActivityIndicatorManager.networkOperationFinished()
                self.isPurchasing = false
                showAlert(title: nil, message: "Purchase failed", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }
        }

    }
 
    func setExpiryTimestamp(expiryDate:Date){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        FirebaseUtil.shared.setExpiryTimestamp(userId: myUserId, expiryTimestamp: expiryDate.timeIntervalSince1970) { (error) in
            if error != nil{
                print(">>>Failed to set expiryTimestamp. Error: \(String(describing: error?.localizedDescription))")
                self.setExpiryTimestamp(expiryDate: expiryDate)
            }else{
                print(">>>Success to set expiryTimestamp")
            }
        }
    }
}


/*
// MARK: User facing alerts
extension UpgradeViewController {
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
        
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return alertWithTitle("Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: error.localizedDescription)
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            }
        }
    }
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }
    
    func alertForVerifySubscription(_ result: VerifySubscriptionResult) -> UIAlertController {
        
        switch result {
        case .purchased(let expiryDate):
            print("Product is valid until \(expiryDate)")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate):
            print("Product is expired since \(expiryDate)")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func alertForVerifyPurchase(_ result: VerifyPurchaseResult) -> UIAlertController {
        
        switch result {
        case .purchased:
            print("Product is purchased")
            return alertWithTitle("Product is purchased", message: "Product will not expire")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
}
 */
