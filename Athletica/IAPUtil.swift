//
//  IAPUtil.swift
//  Athletica
//
//  Created by SilverStar on 8/31/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import Foundation

class IAPUtil {
    
    static let shared = IAPUtil()
    
    var currentSubscription: PaidSubscription?
    
    func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
        if let receiptData = loadReceipt() {
//            SelfieService.shared.upload(receipt: receiptData) { [weak self] (result) in
//                guard let strongSelf = self else { return }
//                switch result {
//                case .success(let result):
//                    strongSelf.currentSessionId = result.sessionId
//                    strongSelf.currentSubscription = result.currentSubscription
//                    completion?(true)
//                case .failure(let error):
//                    print("🚫 Receipt Upload Failed: \(error)")
//                    completion?(false)
//                }
//            }
        }
    }
    
    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
}
