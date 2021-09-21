//
//  UploadImagePublisher.swift
//  Instagram
//
//  Created by Maxim Soroka on 18.04.2021.
//

import Combine
import UIKit
import FirebaseStorage

extension Publishers {
    struct UploadImagePublisher: Publisher {
        
        typealias Output = String
        typealias Failure = InstagramError
        
        private let image: UIImage
        private let path: String
        
        init(uiImage: UIImage, path: String) {
            self.image = uiImage
            self.path = path
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let uploadImageSubscription = UploadImageSubscription(subscriber: subscriber, uiImage: image, path: path)
            subscriber.receive(subscription: uploadImageSubscription)
        }
    }
    
    class UploadImageSubscription<S: Subscriber>: Subscription where S.Failure == InstagramError, S.Input == String {
        private let storage = Storage.storage()
        
        private var subscriber: S?
        private var image: UIImage?
        private var path: String?
        
        init(subscriber: S, uiImage: UIImage, path: String) {
            self.subscriber = subscriber
            self.image = uiImage
            self.path = path
            
            uploadImage { string in
                _ = subscriber.receive(string)
            }
        }
        
        private func uploadImage(completion: @escaping (String) -> ()) {
            guard let subscriber = subscriber, let path = path, let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
            
            let filename = NSUUID().uuidString
            let reference = storage.reference(withPath: "\(path + filename)")
            
            
            reference
                .putData(imageData, metadata: nil) {  metadata, error in
                    if let error = error {
                        subscriber.receive(completion: .failure(.default(description: error.localizedDescription)))
                        return
                    }
                    
                    reference
                        .downloadURL { url, error in
                            if let error = error {
                                subscriber.receive(completion: .failure(.default(description: error.localizedDescription)))
                                return
                                
                            } else if let urlString = url?.absoluteString {
                                completion(urlString)
                            }
                        }
                }
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() {
            subscriber = nil
            image = nil
            path = nil
        }
    }
}
