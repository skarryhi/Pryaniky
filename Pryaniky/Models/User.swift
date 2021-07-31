//
//  User.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 31.07.2021.
//

import Foundation

struct Variants: Decodable {
    let id: Int
    let text: String
}

struct Information: Decodable {
    let text: String?
    let url: String?
    let selectedId: Int?
    let variants: [Variants]?
}

struct Block: Decodable {
    let name: String
    let data: Information
}

struct User: Decodable {
    let data: [Block]
    let view: [String]
}
