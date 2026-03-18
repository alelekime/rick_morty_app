//
//  CharacterService.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation

enum CharacterServiceError: Error, Equatable {
    case invalidResponse
    case httpStatus(Int)
}

class CharacterService: CharacterServiceProtocol {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func getCharacters(page: Int = 1, name: String?, status: String?) async throws -> CharacterResponse {
        
        var components = URLComponents(string: "https://rickandmortyapi.com/api/character")!
        
        var queryItems: [URLQueryItem] = []
        
        if page > 1 {
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        
        if let name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        
        if let status, !status.isEmpty, status != "all" {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let data = try await fetchData(from: url)
        
        return try JSONDecoder().decode(CharacterResponse.self, from: data)
    }
    
    func getCharacter(id: Int) async throws -> Character {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character/\(id)") else {
            throw URLError(.badURL)
        }
        
        let data = try await fetchData(from: url)
        
        return try JSONDecoder().decode(Character.self, from: data)
    }

    private func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CharacterServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw CharacterServiceError.httpStatus(httpResponse.statusCode)
        }

        return data
    }
}
