//
//  Character.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation

struct Character: Identifiable, Decodable {
    let id: Int
    let image: String
    let name: String
    let status: String
    let species: String
    let gender: String
    let origin: LocationInfo
    let location: LocationInfo
    let episode: [String]
}

struct LocationInfo: Decodable {
    let name: String
    let url: String
}
