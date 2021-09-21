//
//  AuthPublisher.swift
//  Instagram
//
//  Created by Maxim Soroka on 17.04.2021.
//

import Combine
import FirebaseAuth

extension Publishers {
    struct AuthPublisher: Publisher {
        typealias Output = FirebaseAuth.User?
        typealias Failure = Never
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let authSubscription = AuthSubscription(subscriber: subscriber)
            subscriber.receive(subscription: authSubscription) 
        }
    }
    
    class AuthSubscription<S: Subscriber>: Subscription where S.Input == FirebaseAuth.User?, S.Failure == Never {
        private var subscriber: S?
        private var handler: FirebaseAuth.AuthStateDidChangeListenerHandle?
        
        init(subscriber: S) {
            self.subscriber = subscriber
            handler = Auth.auth().addStateDidChangeListener { auth, user in
                let _ = subscriber.receive(user)
            }
        }
        
        func request(_ demand: Subscribers.Demand) { }
    
        func cancel() {
            subscriber = nil
            handler = nil
        }
    }
}
