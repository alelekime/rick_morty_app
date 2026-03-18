//
//  Character.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation

struct Character: Identifiable, Codable {
    let id: String
    let image: String
    let name: String
    let status: String
    let species: String
    let gender: String
    let origin: [String: String]
    let location: [String: String]
    let episode: [String]
}
