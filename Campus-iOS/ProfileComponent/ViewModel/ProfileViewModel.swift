//
//  ProfileViewModel.swift
//  Campus-iOS
//
//  Created by Milen Vitanov on 07.02.22.
//

import Foundation
import Alamofire
import XMLCoder
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profileState: APIState<Profile> = .na
    @Published var profileHasError: Bool = false
    @Published var tuitionState: APIState<Tuition> = .na
    @Published var tuitionHasError: Bool = false
    
    @Published var profile: Profile?
    @Published var tuition: Tuition?
    @Published var profileImage = Image(systemName: "person.crop.circle.fill")
    @Published var profileImageUI: UIImage?
    var model: Model
    let service: ProfileService
    
    static let defaultProfile = Profile(
        firstname: nil,
        surname: "TUM Student".localized,
        tumId: "TUM ID",
        obfuscatedID: nil,
        obfuscatedIDEmployee: nil,
        obfuscatedIDExtern: nil,
        obfuscatedIDStudent: nil,
        image: nil
    )
    
    init(model: Model, service: ProfileService) {
        self.model = model
        self.service = service
        self.load(fileName: "ProfileImage")
    }
    
    func getProfile(forcedRefresh: Bool) async {
        if !forcedRefresh {
            self.profileState = .loading
        }
        self.profileHasError = false
        
        guard let token = self.model.token else {
            self.profileState = .failed(error: NetworkingError.unauthorized)
            self.profileHasError = true
            return
        }
        
        do {
            guard var profile: Profile = try await service.fetch(token: token, forcedRefresh: forcedRefresh) else {
                self.profileState = .failed(error: TUMOnlineAPIError(message: "No profile found"))
                return
            }
            
            if let personGroup = profile.personGroup, let id = profile.id, let obfuscatedID = profile.obfuscatedID, let image = await downloadProfileImage(personGroup: personGroup, personId: id, obfuscatedID: obfuscatedID, forcedRefresh: forcedRefresh) {
                profile.image = image
            }
            self.profileState = .success(data: profile)
        } catch {
            self.profileState = .failed(error: error)
            self.profileHasError = true
        }
    }
    
    func getTuition(forcedRefresh: Bool) async {
        if !forcedRefresh {
            self.tuitionState = .loading
        }
        self.tuitionHasError = false
        
        guard let token = self.model.token else {
            self.tuitionState = .failed(error: NetworkingError.unauthorized)
            self.tuitionHasError = true
            return
        }
        
        do {
            guard let tuition: Tuition = try await service.fetch(token: token, forcedRefresh: forcedRefresh) else {
                self.tuitionState = .failed(error: TUMOnlineAPIError(message: "No profile found"))
                return
            }
            
            self.tuitionState = .success(data: tuition)
        } catch {
            self.tuitionState = .failed(error: error)
            self.tuitionHasError = true
        }
    }
    
    func downloadProfileImage(personGroup: String, personId: String, obfuscatedID: String, forcedRefresh: Bool = false) async -> Image? {
        // Neu machen mit Alamofire (not async)
        guard let token = self.model.token else {
            return nil
        }
        
        let endpoint = TUMOnlineAPI.profileImage(personGroup: personGroup, id: personId)
        
        if !forcedRefresh, let imageData = TUMOnlineAPI.imageCache.value(forKey: endpoint.basePathsParametersURL), let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        } else {
            var image: Image?
            
            TUMOnlineAPI.profileImage(personGroup: personGroup, id: personId).asRequest(token: token).responseData { response in
                if let imageData = response.value, let uiImage = UIImage(data: imageData) {
                    TUMOnlineAPI.imageCache.setValue(imageData, forKey: endpoint.basePathsParametersURL, cost: imageData.count)
                    image = Image(uiImage: uiImage)
                    return
                }
            }
            
            if image != nil {
                return image
            }
            
            do {
                let personDetails = try await PersonDetailedService().fetch(for: obfuscatedID, token: token, forcedRefresh: forcedRefresh)
                guard let uiImage = personDetails.image else {
                    return nil
                }
                return Image(uiImage: uiImage)
            } catch {
                print(error)
                return nil
            }
        }
    }
    
    //Source: https://stackoverflow.com/questions/37574689/how-to-load-image-from-local-path-ios-swift-by-path
    //saves Image to local storage
    func save(image: UIImage) -> String? {
        let fileName = "ProfileImage"
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }
    
    //loads Image to local storage
    func load(fileName: String) {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            self.profileImageUI = UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
    }
    
    //helper property to get FilePath for local storage
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
}
