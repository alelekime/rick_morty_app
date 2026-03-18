//
//  Character+Mock.swift
//  rick_mortyTests
//
//  Created by Alessandra Souza da Silva on 18/03/26.
//

@testable import rick_morty

extension Character {
    static func mock(
        id: Int = 1,
        image: String = "https://example.com/rick.png",
        name: String = "Rick Sanchez",
        status: String = "Alive",
        species: String = "Human",
        gender: String = "Male",
        origin: LocationInfo = .mock(name: "Earth"),
        location: LocationInfo = .mock(name: "Citadel of Ricks"),
        episode: [String] = ["https://example.com/episode/1"]
    ) -> Character {
        Character(
            id: id,
            image: image,
            name: name,
            status: status,
            species: species,
            gender: gender,
            origin: origin,
            location: location,
            episode: episode
        )
    }
}

extension LocationInfo {
    static func mock(
        name: String = "Earth",
        url: String = "https://example.com/location/1"
    ) -> LocationInfo {
        LocationInfo(name: name, url: url)
    }
}

extension CharacterResponseInfo {
    static func mock(
        count: Int = 1,
        pages: Int = 1,
        next: String? = nil,
        prev: String? = nil
    ) -> CharacterResponseInfo {
        CharacterResponseInfo(
            count: count,
            pages: pages,
            next: next,
            prev: prev
        )
    }
}

extension CharacterResponse {
    static func mock(
        info: CharacterResponseInfo = .mock(),
        results: [Character] = [.mock()]
    ) -> CharacterResponse {
        CharacterResponse(info: info, results: results)
    }
}
