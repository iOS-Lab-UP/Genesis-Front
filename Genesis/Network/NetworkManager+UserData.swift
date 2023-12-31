//
//  NetworkManager+UserData.swift
//  Genesis
//
//  Created by Luis Cedillo M on 17/10/23.
//

import Foundation
import Alamofire

extension NetworkManager {
    
    func getUserData(completion: @escaping (Result<User, Error>) -> Void) {
        
        // Check if the token exists
        guard let token = retrieveToken() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication token is missing"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-access-token": token // Here we're using the non-optional token
            
            
        ]
        
        AF.request(APIEndpoints.getUserData, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Response<User>.self) { response in
                switch response.result {
                case .success(let userDataResponse):
                    completion(.success(userDataResponse.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    func getUser2UserRelations(completion: @escaping (Result<[User], Error>) -> Void) {
        
        // Check if the token exists
        guard let token = retrieveToken() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication token is missing"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-access-token": token // Here we're using the non-optional token
            
        ]
        
        
        AF.request(APIEndpoints.getUser2UserRelations, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Response<[User]>.self) { response in
                switch response.result {
                case .success(let userDataResponse):
                    completion(.success(userDataResponse.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func getUserImages(completion: @escaping (Result<[ImageData], Error>) -> Void) {
        // Check if the token exists
        guard let token = retrieveToken() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication token is missing"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-access-token": token // Here we're using the non-optional token
        ]
        
        // Use Alamofire to make a network request
        AF.request(APIEndpoints.getUserImages, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Response<Dictionary<String, [ImageData]>>.self) { response in
                switch response.result {
                case .success(let responseData):
                    // Assuming 'images' is the key for the array of ImageData within the 'data' dictionary
                    if let images = responseData.data["images"] {
                        completion(.success(images))
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data parsing error: 'images' key not found"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchMedicalHistory(completion: @escaping (Result<[MedicalHistoryItem], Error>) -> Void) {
        guard let token = retrieveToken() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication token is missing"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-access-token": token // Here we're using the non-optional token
        ]
        
        
        // Replace with your actual medical history endpoint URL
        
        AF.request(APIEndpoints.getMyMedicalHistory, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of:Response<[MedicalHistoryItem]>.self) { response in
                switch response.result {
                case .success(let historyResponse):
                    completion(.success(historyResponse.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    func fetchAllUserData(completion: @escaping (Result<(User?, [User]?, [ImageData]?, [MedicalHistoryItem]?, [Error]), Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var userData: User?
        var userRelations: [User]?
        var userImages: [ImageData]?
        var medicalHistory: [MedicalHistoryItem]?
        var userProfilePicture: String?
        var errors: [Error] = []  // Declare the errors array
        var firstError: Error?
        
        // Fetch User Data
        dispatchGroup.enter()
            getUserData { result in
                switch result {
                case .success(let user):
                    userData = user
                case .failure(let error):
                    errors.append(error)
                }
                dispatchGroup.leave()
            }
        
        // Fetch User Relations
        dispatchGroup.enter()
        getUser2UserRelations { result in
            switch result {
            case .success(let relations):
                userRelations = relations
            case .failure(let error):
                if firstError == nil {
                    firstError = error
                }
            }
            dispatchGroup.leave()
        }
        
        // Fetch User Images
        dispatchGroup.enter()
        getUserImages { result in
            switch result {
            case .success(let images):
                userImages = images
            case .failure(let error):
                if firstError == nil {
                    firstError = error
                }
            }
            dispatchGroup.leave()
        }
        
        // Fetch Medical History
        dispatchGroup.enter()
        fetchMedicalHistory { result in
            switch result {
            case .success(let historyItems):
                medicalHistory = historyItems
                print(historyItems)
            case .failure(let error):
                if firstError == nil {
                    firstError = error
                }
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
            getUserData { result in
                switch result {
                case .success(let user):
                    userData = user
                    FirebaseManager.shared.fetchUserProfilePicture(userID: String( user.id)) { urlProfile, error in
                        if let url = urlProfile {
                            userProfilePicture = urlProfile
                        } else if let error = error {
                            firstError = error
                        }
                        dispatchGroup.leave()
                    }
                case .failure(let error):
                    firstError = error
                    dispatchGroup.leave()
                }
            }
        
        // Final aggregation
        dispatchGroup.notify(queue: .main) {
               
            
            GlobalDataModel.shared.user = userData
            GlobalDataModel.shared.userRelations = userRelations ?? []
            GlobalDataModel.shared.userImages = userImages ?? []
            GlobalDataModel.shared.medicalHistory = medicalHistory ?? []
            if let profileUrl = userProfilePicture {
                GlobalDataModel.shared.userProfileImageUrl = profileUrl
            }

            // Check if at least one data point is non-nil
            if userData != nil || userRelations != nil || userImages != nil || medicalHistory != nil {
                // Return all available data, and errors if any
                completion(.success((userData, userRelations, userImages, medicalHistory, errors)))
            } else if !errors.isEmpty {
                // Handle the case where all requests failed but there are error messages to convey
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch all user data. Errors: \(errors)"])))
            } else {
                // Handle an unexpected scenario where no data was fetched and no errors were recorded
                let unexpectedError = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "An unexpected error occurred"])
                completion(.failure(unexpectedError))
            }
        }
        
        print("fetching all user data")
    }
    
}
