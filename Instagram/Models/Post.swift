//
//  Post.swift
//  Instagram
//
//  Created by Maxim Soroka on 25.04.2021.
//

import FirebaseFirestoreSwift
import Firebase

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var image: String
    var caption: String?
    var timestamp: Timestamp
    var likes: Int
    var ownerID: String
}
