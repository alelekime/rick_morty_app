//
//  CharacterService.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation

class CharacterService: CharacterServiceProtocol {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func getCharacters(page: Int) async throws -> [CharacterResponse] {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character/?page=\(page)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await urlSession.data(from: url)
        
        return try JSONDecoder().decode([CharacterResponse].self, from: data)
    }
    
    func getCharacter(id: Int) async throws -> Character {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character/\(id)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await urlSession.data(from: url)
        
        return try JSONDecoder().decode(Character.self, from: data)
    }
    
    
}
