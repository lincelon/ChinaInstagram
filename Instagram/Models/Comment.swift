//
//  Comment.swift
//  Instagram
//
//  Created by Maxim Soroka on 02.05.2021.
//

import Firebase
import FirebaseFirestoreSwift

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    let timestamp: Timestamp
    var text: String
    var likes: Int
    let owner: User
    let postOwnerID: String
}

