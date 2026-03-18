//
//  CharacterStatus.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 18/03/26.
//

enum CharacterStatus: String, CaseIterable, Identifiable {
    case all
    case alive
    case dead
    case unknown

    var id: String { rawValue }
}
