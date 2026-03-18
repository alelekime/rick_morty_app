//
//  CharacterService.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation
import OSLog

enum CharacterServiceError: Error, Equatable, LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpStatus(let statusCode):
            return "The request failed with status code \(statusCode)."
        }
    }
}

class CharacterService: CharacterServiceProtocol {
    
    private let logger = Logger(subsystem: "rick_morty", category: "CharacterService")
    private let urlSession: URLSession
    private let emptyCharacterResponse = CharacterResponse(
        info: CharacterResponseInfo(count: 0, pages: 0, next: nil, prev: nil),
        results: []
    )
    
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

        guard let data = try await fetchData(from: url, noFoundCharacters: true) else {
            logger.info("No characters found for \(url.absoluteString, privacy: .public)")
            return emptyCharacterResponse
        }

        let characterResponse = try JSONDecoder().decode(CharacterResponse.self, from: data)
        logger.info("Decoded \(characterResponse.results.count) characters from \(url.absoluteString, privacy: .public)")
        return characterResponse
    }
    
    func getCharacter(id: Int) async throws -> Character {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character/\(id)") else {
            throw URLError(.badURL)
        }

        guard let data = try await fetchData(from: url) else {
            throw CharacterServiceError.invalidResponse
        }

        let character = try JSONDecoder().decode(Character.self, from: data)
        logger.info("Decoded character \(character.name, privacy: .public) from \(url.absoluteString, privacy: .public)")
        return character
    }

    private func fetchData(from url: URL, noFoundCharacters: Bool = false) async throws -> Data? {
        logger.info("Requesting \(url.absoluteString, privacy: .public)")

        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response for \(url.absoluteString, privacy: .public)")
            throw CharacterServiceError.invalidResponse
        }

        if noFoundCharacters && httpResponse.statusCode == 404 {
            return nil
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            logger.error("Request failed with status \(httpResponse.statusCode) for \(url.absoluteString, privacy: .public)")
            throw CharacterServiceError.httpStatus(httpResponse.statusCode)
        }

        logger.info("Received status \(httpResponse.statusCode) with \(data.count) bytes")
        return data
    }
}
