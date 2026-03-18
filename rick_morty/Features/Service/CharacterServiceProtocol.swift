//
//  CharacterServiceProtocol.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation

protocol CharacterServiceProtocol {
    func getCharacters(page: Int) async throws -> CharacterResponse
    func getCharacter(id: Int) async throws -> Character
}
