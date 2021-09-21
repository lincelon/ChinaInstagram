//
//  WebService.swift
//  Instagram
//
//  Created by Maxim Soroka on 18.04.2021.
//

import UIKit
import Combine
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

protocol WebServiceProtocol {
    var currentUserPublisher: AnyPublisher<FirebaseAuth.User?, Never> { get }
    func fetchUser(documentID: String) -> AnyPublisher<User, InstagramError>
    func observeUsers() -> AnyPublisher<[User], InstagramError>
    func uploadPost(uiImage: UIImage, caption: String) -> AnyPublisher<Void, InstagramError>
    func observeUserPosts(userID: String) -> AnyPublisher<[Post], InstagramError>
    func observePosts() -> AnyPublisher<[Post], InstagramError>
    func likePost(post: Post) -> AnyPublisher<Void, InstagramError>
    func unlikePost(post: Post) -> AnyPublisher<Void, InstagramError>
    func isPostLiked(post: Post) -> AnyPublisher<Bool, InstagramError>
}

final class WebService: WebServiceProtocol {
    var currentUserPublisher: AnyPublisher<FirebaseAuth.User?, Never> {
        Just(Auth.auth().currentUser)
            .eraseToAnyPublisher()
    }
    
    private let db = Firestore.firestore()
    private let userService = UserService()
    
    func uploadNotification(to uid: String,
                            type: Notification.NotificationType,
                            post: Post? = nil) -> AnyPublisher<Void, InstagramError> {
        
        return currentUserPublisher
            .flatMap { [weak self] userAuth -> AnyPublisher<User, InstagramError> in
                guard let self = self, let userID = userAuth?.uid else {
                    return Empty()
                        .eraseToAnyPublisher()
                }
                return self.fetchUser(documentID: userID)
            }
            .flatMap { user -> AnyPublisher<Void, InstagramError> in
                Future<Void, InstagramError> { promise in
                    var data: [String: Any] = [
                        "sender": [
                            "email": user.email,
                            "username": user.username,
                            "fullname": user.fullname,
                            "profileImageURL": user.profileImageURL,
                            "uid": user.id
                        ],
                        "timestamp": Timestamp(date: Date()),
                        "type": type.rawValue
                    ]
                    
                    if let post = post, let postID = post.id {
                        data["postID"] = postID
                    }
                    Firestore.firestore().collection("notifications").addDocument(data: data) { error in
                        if let error = error {
                            promise(.failure(.default(description: error.localizedDescription)))
                        }
                        
                        promise(.success(()))
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    
    func fetchNotification() -> AnyPublisher<Void, InstagramError> {
        return Future<Void, InstagramError> { promise in
            
        }
        .eraseToAnyPublisher()
    }
    
    func uploadComment(for post: Post, text: String, user: User) -> AnyPublisher<Void, InstagramError> {
        
        uploadNotification(to: post.ownerID, type: .comment)
            .flatMap { () -> AnyPublisher<Void, InstagramError> in
                Future<Void, InstagramError> { promise in
                    guard let postID = post.id else { promise(.failure(.default())); return }
                    
                    Firestore.firestore().collection("posts").document(postID).collection("comments")
                        .addDocument(data: [
                            "postOwnerID" : post.ownerID,
                            "owner": [
                                "email": user.email,
                                "username": user.username,
                                "fullname": user.fullname,
                                "profileImageURL": user.profileImageURL,
                                "uid": user.id
                            ],
                            "timestamp": Timestamp(date: Date()),
                            "likes": 0,
                            "text": text
                        ]) {  error in
                            if let error = error {
                                promise(.failure(.default(description: error.localizedDescription)))
                                
                            }
                            
                            promise(.success(()))
                        }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func observePostComments(postID: String) -> AnyPublisher<[Comment], InstagramError> {
        let collectionReference = Firestore.firestore().collection("posts").document(postID).collection("comments")
        
        return Publishers.QuerySnapshotPublisher(listenerPath: .collection(collectionReference))
            .flatMap { querySnapshot -> AnyPublisher<[Comment], InstagramError> in
                do {
                    let comments =  try querySnapshot.documents
                        .compactMap { try $0.data(as: Comment.self) }
                    
                    return Just(comments)
                        .setFailureType(to: InstagramError.self)
                        .eraseToAnyPublisher()
                    
                } catch {
                    return Fail(error: .default(description: "Parse error"))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func isPostLiked(post: Post) -> AnyPublisher<Bool, InstagramError> {
        guard let uid = userService.currentUser?.uid,
              let postID = post.id else {
            return Fail(error: .default())
                .eraseToAnyPublisher()
            
        }
        let listenerPath = db.collection("users").document(uid).collection("user-likes").document(postID)
        
        return Publishers.DocumentSnapshotPublisher(listenerPath: listenerPath)
            .flatMap { documentSnapshot -> AnyPublisher<Bool, InstagramError> in
                Just(documentSnapshot.exists)
                    .setFailureType(to: InstagramError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func likePost(post: Post) -> AnyPublisher<Void, InstagramError> {
        
        uploadNotification(to: post.ownerID, type: .like)
            .flatMap { _ -> AnyPublisher<Void, InstagramError> in
               return Future<Void, InstagramError> { [weak self] promise in
                    guard let uid = self?.userService.currentUser?.uid,
                          let postID = post.id
                    else { promise(.failure(.default(description: "suck"))); return }
                    
                    Firestore.firestore().collection("posts").document(postID)
                        .collection("users-likes").document(uid)
                        .setData([:]) { error in
                            if let error = error {
                                promise(.failure(.default(description: error.localizedDescription)))
                            }
                            Firestore.firestore().collection("users").document(uid)
                                .collection("user-likes").document(postID)
                                .setData([:]) { error in
                                    if let error = error {
                                        promise(.failure(.default(description: error.localizedDescription)))
                                    }
                                    
                                    Firestore.firestore().collection("posts").document(postID).updateData(["likes" : post.likes + 1]) { error in
                                        if let error = error {
                                            promise(.failure(.default(description: error.localizedDescription)))
                                        }
                                        promise(.success(()))
                                    }
                                }
                        }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func unlikePost(post: Post) -> AnyPublisher<Void, InstagramError> {
        Future<Void, InstagramError> { [weak self] promise in
            guard let uid = self?.userService.currentUser?.uid,
                  let postID = post.id
            else { promise(.failure(.default())); return }
            
            Firestore.firestore().collection("posts").document(postID)
                .collection("users-likes").document(uid).delete { error in
                    if let error = error {
                        promise(.failure(.default(description: error.localizedDescription)))
                    }
                    
                    Firestore.firestore().collection("posts")
                        .document(postID).updateData(["likes" : post.likes - 1]) { error in
                            if let error = error {
                                promise(.failure(.default(description: error.localizedDescription)))
                            }
                            
                            Firestore.firestore().collection("users").document(uid)
                                .collection("user-likes").document(postID)
                                .delete { error in
                                    if let error = error {
                                        promise(.failure(.default(description: error.localizedDescription)))
                                    }
                                    
                                    promise(.success(()))
                                }
                        }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func observeUserPosts(userID: String) -> AnyPublisher<[Post], InstagramError> {
        let query = db.collection("posts").whereField("ownerID", isEqualTo: userID)
        
        return Publishers.QuerySnapshotPublisher(listenerPath: .query(query))
            .flatMap { querySnapshot -> AnyPublisher<[Post], InstagramError> in
                do {
                    let posts =  try querySnapshot.documents
                        .compactMap { try $0.data(as: Post.self) }
                    
                    return  Just(posts)
                        .setFailureType(to: InstagramError.self)
                        .eraseToAnyPublisher()
                    
                } catch {
                    return Fail(error: .default(description: "Parse error"))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func observePosts() -> AnyPublisher<[Post], InstagramError> {
        
        let ref = Firestore.firestore().collection("posts")
        
        return Publishers.QuerySnapshotPublisher(listenerPath: .collection(ref))
            .flatMap { querySnapshot -> AnyPublisher<[Post], InstagramError> in
                do {
                    let posts =  try querySnapshot.documents
                        .compactMap { try $0.data(as: Post.self) }
                    
                    return  Just(posts)
                        .setFailureType(to: InstagramError.self)
                        .eraseToAnyPublisher()
                    
                } catch {
                    return Fail(error: .default(description: "Parse error"))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func uploadPost(uiImage: UIImage, caption: String) -> AnyPublisher<Void, InstagramError> {
        
        Publishers.UploadImagePublisher(uiImage: uiImage, path: "/images_profile/")
            .flatMap { [weak self] urlString -> AnyPublisher<Void, InstagramError> in
                Future<Void, InstagramError> { promise in
                    guard let self = self,
                          let currentUserUid = self.userService.currentUser?.uid
                    else { promise(.failure(.default())); return }
                    
                    let postID = UUID().uuidString
                    let ref = self.db.collection("posts").document(postID)
                    
                    ref.setData([
                        "postID": postID,
                        "ownerID": currentUserUid,
                        "image": urlString,
                        "caption": caption,
                        "likes" : 0,
                        "timestamp": Timestamp(date: Date()),
                        "comments":  []
                    ]) { error in
                        if let error = error {
                            promise(.failure(.default(description: error.localizedDescription)))
                        }
                        promise(.success(()))
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func observeUsers() -> AnyPublisher<[User], InstagramError> {
        Future<[User], InstagramError> { [weak self] promise in
            self?.db.collection("users").addSnapshotListener({ querySnapshot, error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else if let querySnapshot = querySnapshot {
                    do {
                        let users  = try querySnapshot.documents.compactMap {
                            try $0.data(as: User.self)
                        }
                        promise(.success(users))
                        
                    } catch { promise(.failure(.default(description: error.localizedDescription)))}
                    
                } else { promise(.failure(.default())) }
            })
        }
        .eraseToAnyPublisher()
    }
    
    func fetchUser(documentID: String) -> AnyPublisher<User, InstagramError> {
        return Future<User, InstagramError> { [weak self] promise in
            self?.db.collection("users").document(documentID).getDocument { snapshot, error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                }
                do {
                    guard let user =  try snapshot?.data(as: User.self) else {
                        promise(.failure(.default(description: "Feild to unwarp user")))
                        return
                    }
                    promise(.success(user))
                }
                catch { promise(.failure(.default(description: error.localizedDescription))) }
            }
        }
        .eraseToAnyPublisher()
    }
}
