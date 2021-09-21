//
//  UserService.swift
//  Instagram
//
//  Created by Maxim Soroka on 17.04.2021.
//

import UIKit
import Combine
import FirebaseAuth
import FirebaseFirestore

protocol UserServiceProtocol {
    var isLoading: Bool { get set }
    var currentUser: FirebaseAuth.User? { get }
    func observeAuthChanges() -> AnyPublisher<FirebaseAuth.User?, Never>
    func signup(email: String, password: String, username: String, fullname: String, image: UIImage) -> AnyPublisher<FirebaseAuth.User, InstagramError>
    func logout() -> AnyPublisher<Void, InstagramError>
    func login(email: String, password: String) -> AnyPublisher<Void, InstagramError>
    func followUser(userID: String) -> AnyPublisher<Void, InstagramError>
}

final class UserService: UserServiceProtocol {
    let db = Firestore.firestore()
    var isLoading: Bool = false
    
    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }
    
    func isUserFollowed(userID: String) -> AnyPublisher<Bool, InstagramError> {
        guard let currentUserUid = currentUser?.uid else {
            return Fail(error: .default())
                .eraseToAnyPublisher()
            
        }
        let listenerPath = db.collection("users").document(userID).collection("followers").document(currentUserUid)
        
        return Publishers.DocumentSnapshotPublisher(listenerPath: listenerPath)
            .flatMap { documentSnapshot -> AnyPublisher<Bool, InstagramError> in
                Just(documentSnapshot.exists)
                    .setFailureType(to: InstagramError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func observeAuthChanges() -> AnyPublisher<FirebaseAuth.User?, Never> {
        isLoading = true
        return Publishers.AuthPublisher()
            .eraseToAnyPublisher()
    }
    
    func followUser(userID: String) -> AnyPublisher<Void, InstagramError> {
        Empty()
            .eraseToAnyPublisher()
//        webService.uploadNotification(to: userID, type: .follow)
//            .flatMap { () -> AnyPublisher<Void, InstagramError> in
//
//                Future<Void, InstagramError> { [weak self] promise in
//                    guard let self = self, let currentUserUid = self.currentUser?.uid else { promise(.failure(.default())); return }
//
//                    self.db.collection("users").document(currentUserUid).collection("following").document(userID)
//                        .setData([:]) { error in
//                            if let error = error {
//                                promise(.failure(.default(description: error.localizedDescription)))
//                            }
//
//                            self.db.collection("users").document(userID).collection("followers").document(currentUserUid)
//                                .setData([:]) { error in
//                                    if let error = error {
//                                        promise(.failure(.default(description: error.localizedDescription)))
//                                    } else { promise(.success(())) }
//                                }
//                        }
//                }
//                .eraseToAnyPublisher()
//            }
//            .eraseToAnyPublisher()
    }
    
    func unfollowUser(userID: String) -> AnyPublisher<Void, InstagramError> {
        Future<Void, InstagramError> { [weak self] promise in
            guard let self = self, let currentUserUid = self.currentUser?.uid else { promise(.failure(.default())); return }
            
            self.db.collection("users").document(currentUserUid).collection("following").document(userID)
                .delete{ error in
                    if let error = error {
                        promise(.failure(.default(description: error.localizedDescription)))
                    }
                    
                    self.db.collection("users").document(userID).collection("followers").document(currentUserUid)
                        .delete { error in
                            if let error = error {
                                promise(.failure(.default(description: error.localizedDescription)))
                            } else { promise(.success(())) }
                        }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func signup(email: String, password: String,
                username: String, fullname: String, image: UIImage) -> AnyPublisher<FirebaseAuth.User, InstagramError> {
        
        return Publishers.UploadImagePublisher(uiImage: image, path: "/images_profile/")
            .flatMap { urlString -> AnyPublisher<FirebaseAuth.User, InstagramError> in
                
                return Future<FirebaseAuth.User, InstagramError> { promise in
                    Auth.auth().createUser(withEmail: email, password: password) { result, error in
                        if let error = error {
                            promise(.failure(.default(description: error.localizedDescription)))
                            
                        } else if let user = result?.user {
                            Firestore.firestore().collection("users").document(user.uid)
                                .setData( [
                                    "email": email,
                                    "username": username,
                                    "fullname": fullname,
                                    "profileImageURL": urlString,
                                    "uid": user.uid
                                ]) { error in
                                    if let error = error {
                                        promise(.failure(.default(description: error.localizedDescription)))
                                    }
                                }
                            
                            promise(.success(user))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, InstagramError> {
        return Future<Void, InstagramError> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
                
            }  catch  { promise(.failure(.default(description: error.localizedDescription))) }
        }
        .eraseToAnyPublisher()
    }
    
    func login(email: String, password: String) -> AnyPublisher<Void, InstagramError> {
        let authCredentional = EmailAuthProvider.credential(withEmail: email, password: password)
        
        return Future <Void, InstagramError> { promise in
            Auth.auth().signIn(with: authCredentional) { result, error in
                if let error = error {
                    promise(.failure(.auth(description: error.localizedDescription)))
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
