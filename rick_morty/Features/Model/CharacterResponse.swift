//
//  CharacterResponse.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

// API Resposnse
struct CharacterResponse: Decodable {
    let info: CharacterResponseInfo
    let results: [Character]
}

struct CharacterResponseInfo: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
