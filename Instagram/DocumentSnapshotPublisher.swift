//
//  DocumentSnapshotPublisher.swift
//  Instagram
//
//  Created by Maxim Soroka on 01.05.2021.
//

import Foundation
import Firebase
import Combine

extension Publishers {
    struct DocumentSnapshotPublisher: Publisher {
        typealias Output = DocumentSnapshot
        typealias Failure = InstagramError
        
        private let listenerPath: DocumentReference
        
        init(listenerPath: DocumentReference) {
            self.listenerPath = listenerPath
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, InstagramError == S.Failure, DocumentSnapshot == S.Input {
            let documentSnapshotSubscription = DocumentSnapshotSubscription(subscriber: subscriber, listenerPath: listenerPath)
            
            subscriber.receive(subscription: documentSnapshotSubscription)
        }
    }
}

final class DocumentSnapshotSubscription<S: Subscriber>: Subscription where S.Failure == InstagramError, S.Input == DocumentSnapshot {
    private var subscriber: S?
    private var listener: ListenerRegistration?
    
    init(subscriber: S, listenerPath: DocumentReference) {
        self.subscriber = subscriber
        
        listener = listenerPath.addSnapshotListener({ documentSnapshot, error in
            if let error = error {
                subscriber.receive(completion: .failure(.default(description: error.localizedDescription)))
            } else if let documentSnapshot = documentSnapshot {
                _ = subscriber.receive(documentSnapshot)
            } else {
                subscriber.receive(completion: .failure(.default()))
            }
        })
        
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
    }
}
