//
//  QuerySnapshotPublisher.swift
//  Instagram
//
//  Created by Maxim Soroka on 21.04.2021.
//

import Combine
import Firebase

extension Publishers {
    struct QuerySnapshotPublisher: Publisher {
        typealias Output = QuerySnapshot
        typealias Failure = InstagramError
        
        private let listenerPath: ListenerPath
        private let collectionReference: CollectionReference?
        private let query: Query?
        
        init(listenerPath: ListenerPath) {
            self.listenerPath = listenerPath
            
            switch listenerPath {
            case let .collection(reference):
                self.collectionReference = reference
                self.query = nil
                
            case let .query(query):
                self.query = query
                self.collectionReference = nil
                
            }
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let querySnapshotSucbscription: QuerySnapshotSubscription<S>
            
            switch listenerPath {
            case let .collection(reference):
                querySnapshotSucbscription = QuerySnapshotSubscription(subscriber: subscriber, listenerPath: .collection(reference))
                
            case let .query(query):
                querySnapshotSucbscription = QuerySnapshotSubscription(subscriber: subscriber, listenerPath: .query(query))
            }
         
            subscriber.receive(subscription: querySnapshotSucbscription)
        }
        
        enum ListenerPath {
            case collection(CollectionReference)
            case query(Query)
        }
    }
}

final class QuerySnapshotSubscription<S: Subscriber>: Subscription where S.Input == QuerySnapshot, S.Failure == InstagramError {
    private var subscriber: S?
    private var listener: ListenerRegistration?
    
    init(subscriber: S, listenerPath: Publishers.QuerySnapshotPublisher.ListenerPath) {
        self.subscriber = subscriber
        
        let action: (QuerySnapshot?, Error?) -> () = { querySnapshot, error in
            if let error = error {
                subscriber.receive(completion: .failure(.default(description: error.localizedDescription)))
            } else if let querySnapshot = querySnapshot {
                _ = subscriber.receive(querySnapshot)
            } else {
                subscriber.receive(completion: .failure(.default()))
            }
        }
        
        switch listenerPath {
        case let .collection(reference):
            listener = reference.addSnapshotListener({ querySnapshot, error in
                action(querySnapshot, error)
            })
            
        case let .query(query):
            listener = query.addSnapshotListener({ querySnapshot, error in
                action(querySnapshot, error)
            })
        }
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
    }
}
