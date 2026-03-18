//
//  CharacterService.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation
import OSLog

enum CharacterServiceError: Error, Equatable {
    case invalidResponse
    case httpStatus(Int)
}

class CharacterService: CharacterServiceProtocol {
    
    private let logger = Logger(subsystem: "rick_morty", category: "CharacterService")
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

        do {
            let data = try await fetchData(from: url)
            let response = try JSONDecoder().decode(CharacterResponse.self, from: data)
            logger.info("Decoded \(response.results.count) characters from \(url.absoluteString, privacy: .public)")
            return response
        } catch {
            logger.error("Failed to fetch characters: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
    
    func getCharacter(id: Int) async throws -> Character {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character/\(id)") else {
            throw URLError(.badURL)
        }

        do {
            let data = try await fetchData(from: url)
            let character = try JSONDecoder().decode(Character.self, from: data)
            logger.info("Decoded character \(character.name, privacy: .public) from \(url.absoluteString, privacy: .public)")
            return character
        } catch {
            logger.error("Failed to fetch character \(id): \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }

    private func fetchData(from url: URL) async throws -> Data {
        logger.info("Requesting \(url.absoluteString, privacy: .public)")

        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid response for \(url.absoluteString, privacy: .public)")
            throw CharacterServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            logger.error("Request failed with status \(httpResponse.statusCode) for \(url.absoluteString, privacy: .public)")
            throw CharacterServiceError.httpStatus(httpResponse.statusCode)
        }

        logger.info("Received status \(httpResponse.statusCode) with \(data.count) bytes")

        return data
    }
}
