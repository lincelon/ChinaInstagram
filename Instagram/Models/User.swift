//
//  User.swift
//  Instagram
//
//  Created by Maxim Soroka on 18.04.2021.
//

import FirebaseFirestoreSwift
import Foundation

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    let username: String
    let fullname: String
    let profileImageURL: String

}

