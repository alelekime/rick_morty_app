//
//  MockCharacterService.swift
//  rick_mortyTests
//
//  Created by Alessandra Souza da Silva on 18/03/26.
//

import Foundation
@testable import rick_morty

final class MockCharacterService: CharacterServiceProtocol {
    var getCharactersResult: Result<CharacterResponse, Error> = .success(.mock())
    var getCharacterResult: Result<Character, Error> = .success(.mock())

    func getCharacters(page: Int, name: String?, status: String?) async throws -> CharacterResponse {
        try getCharactersResult.get()
    }

    func getCharacter(id: Int) async throws -> Character {
        try getCharacterResult.get()
    }
}
