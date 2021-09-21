//
//  InstagramError.swift
//  Instagram
//
//  Created by Maxim Soroka on 17.04.2021.
//

import Foundation

enum InstagramError: LocalizedError {
    case auth(description: String)
    case `default`(description: String? = nil)
    
    var errorDescription: String? {
        switch self {
        case let .auth(description):
            return description
        case let .default(description):
            return description ?? "Something went wrong"
        }
    }
}
