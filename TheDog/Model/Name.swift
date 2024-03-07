//
//  name.swift
//  TheDog
//
//  Created by 山本雅浩 on 2024/02/03.
//

import Foundation

struct PhotoResponse: Codable {
    let message: [String]
}

struct DogResponse: Codable {
    let message: [String: [String]]
}

enum DogError: Error {
    case invalidURL
    case networkError
    case decodingError
}
