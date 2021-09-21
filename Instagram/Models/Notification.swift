//
//  Notification.swift
//  Instagram
//
//  Created by Maxim Soroka on 04.05.2021.
//

import FirebaseFirestoreSwift
import Firebase

struct Notification: Identifiable, Codable {
    @DocumentID var id: String?
    let postID: String?
    let sender: User
    let timestamp: Timestamp
    let type: NotificationType
    
    enum NotificationType: Int, Codable {
        case like
        case comment
        case follow
        
        var message: String {
            switch self {
            case .like:
                return " liked one of your posts."
            case .comment:
                return " commented one of your posts."
            case .follow:
                return " started following you."
            }
        }
    }
}

