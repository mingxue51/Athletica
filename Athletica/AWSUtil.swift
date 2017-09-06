//
//  AWSUtil.swift
//  Athletica
//
//  Created by SilverStar on 8/12/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognito
import AWSS3

class AWSUtil {
    
    static let shared = AWSUtil()
    
    // Download a stream from the athletica bucket on AWS S3
    func downloadStream(stream:Stream, completion:@escaping (Error?, URL)->()){
        // Initialize the Amazon Cognito credentials provider
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2,
                                                                identityPoolId:identityPoolId)
        let configuration = AWSServiceConfiguration(region:.USEast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
       
        let transferManager = AWSS3TransferManager.default()
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video.mp4")
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()!
        downloadRequest.bucket = "athletica"
        downloadRequest.key = "\(stream.id).mp4"
        downloadRequest.downloadingFileURL = downloadingFileURL
        
        transferManager.download(downloadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error downloading: \(String(describing: downloadRequest.key)) Error: \(error)")
                    }
                } else {
                    print("Error downloading: \(String(describing: downloadRequest.key)) Error: \(error)")
                }
                completion(error, downloadingFileURL)
            }else{
                print("Download complete for: \(String(describing: downloadRequest.key))")
//                let downloadOutput = task.result
                completion(nil, downloadingFileURL)
            }
            return nil
        })
        
    }
    
    // Delete a stream from the athletica bucket on AWS S3
    func deleteStream(streamId:String, completion:@escaping (Error?)->()){
        // Initialize the Amazon Cognito credentials provider
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2,
                                                                identityPoolId:identityPoolId)
        let configuration = AWSServiceConfiguration(region:.USEast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let deleteObjectRequest = AWSS3DeleteObjectRequest()!
        deleteObjectRequest.bucket = "athletica"
        deleteObjectRequest.key = "\(streamId).mp4"
        
        AWSS3.default().deleteObject(deleteObjectRequest) { (deleteObjectOutput, error) in
            completion(error)
        }
        
    }
}
