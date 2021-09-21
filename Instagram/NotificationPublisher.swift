//
//  NotificationPublisher.swift
//  Instagram
//
//  Created by Maxim Soroka on 04.05.2021.
//

import Combine
import Firebase

extension Publishers {
    struct NotificationPublisher: Publisher {
        typealias Output = Void
        typealias Failure = InstagramError
        
        private let userID: String
        private let type: Int
        private let post: Post?
        
        init(for userID: String,
             type: Notification.NotificationType,
             post: Post? = nil) {
            self.userID = userID
            self.type = type.rawValue
            self.post = post
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, InstagramError == S.Failure, Void == S.Input {
            let notificationSubscription: NotificationSubscription = .init(subscriber: subscriber)
            
            subscriber.receive(subscription: notificationSubscription)
        }
    }
}

final class NotificationSubscription<S: Subscriber>: Subscription where S.Failure == InstagramError, S.Input == Void {
    private var subscriber: S?
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
    }
    
    private func uploadNotification() {
        
    }
    
    
}
