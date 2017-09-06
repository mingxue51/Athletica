//
//  Constants.swift
//  ListMeds
//
//  Created by My Star on 2/3/17.
//  Copyright © 2017 Silver Star. All rights reserved.
//

import UIKit

struct AlertMessage {    
    static let firstNameEmpty = "Please enter First name"
    static let lastNameEmpty = "Please enter Last name"
    static let emailEmpty = "Please enter Email"
    static let emailInvalid = "Please enter valid Email"
    static let passwordEmpty = "Please enter Password"
    static let categoryEmpty = "Please select Sport category"
    static let happeningEmpty = "Please enter what's happening"
    static let cityEmpty = "Please enter city"
    static let stateEmpty = "Please enter state"
    static let companyEmpty = "Please enter company"
    static let noInternet = "Internet Connection not Available!"
    
    static let maxNumOfYourSavedStreams = "Max number of saved streams reached. Please download 1 or more saved streams to your phone's photo library. Then, delete the stream(s) from your Athletica profile to free up space."
    static let maxNumOfHerSavedStreams = "The athlete you are on behalf of reached Max number of saved streams. The athlete might need to download 1 or more saved streams to the phone's photo library and then, delete the stream(s) from the Athletica profile to free up space."
}

struct SnackbarMessage {
    static let noConnection = "Failed to connect server. Please check the Internet connection."
}

enum UserType:String {
    case athlete
    case proAthlete
    case coach
    case fan
}

enum HomeState:String {
    case created
    case approved
}

// TODO: - Replace the following credentials with your own if you want to see how it works
// Iris credentials
struct Iris {
    static let appId = "YOUR_IRIS_APP_KEY"//"XnHpYiQbI8ccHdMPBVRJkg"
    static let apiKey = "YOUR_IRIS_API_KEY"//"57h30lqzakcezq5wsr1gywxy2"
}

// Subscription types
// Used in AthleteProfileVC, ViewAthleteVC, AthleteMenuVC
enum SubscriptionType:String{
    case OneMonthOfBasicPlus
    case OneYearOfBasicPlus
}

// Shared secrets for subscriptions
let sharedSecrets = "YOUR_SHARED_SECRETS"

// Maximum number of saved streams
let maxNSavedStreams = 5

// Base URL for requests
let baseUrl = "YOUR_BASE_URL"

// Identity pool ID for AWS Storage
let identityPoolId = "YOUR_IDENTITY_POOL_ID"
