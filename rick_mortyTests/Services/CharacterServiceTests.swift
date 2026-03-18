//
//  CharacterServiceTests.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 18/03/26.
//

import Testing
import Foundation
@testable import rick_morty

@Suite(.serialized)
struct CharacterServiceTests {

    @Test
    func getCharacters_decodesResponseSuccessfully() async throws {
        let json = """
        {
          "info": {
            "count": 1,
            "pages": 1,
            "next": null,
            "prev": null
          },
          "results": [
            {
              "id": 1,
              "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
              "name": "Rick Sanchez",
              "status": "Alive",
              "species": "Human",
              "gender": "Male",
              "origin": {
                "name": "Earth",
                "url": "https://rickandmortyapi.com/api/location/1"
              },
              "location": {
                "name": "Citadel of Ricks",
                "url": "https://rickandmortyapi.com/api/location/3"
              },
              "episode": [
                "https://rickandmortyapi.com/api/episode/1"
              ]
            }
          ]
        }
        """

        let data = try #require(json.data(using: .utf8))
        let session = makeMockSession(data: data, statusCode: 200)
        let service = await CharacterService(urlSession: session)

        let response = try await service.getCharacters(page: 1, name: nil, status: nil)

        #expect(response.results.count == 1)
        await #expect(response.results.first?.name == "Rick Sanchez")
        await #expect(response.results.first?.origin.name == "Earth")
        await #expect(response.info.next == nil)
    }

    @Test
    func getCharacters_throwsHTTPStatusError_whenResponseIs404() async throws {
        let session = makeMockSession(data: Data(), statusCode: 404)
        let service = await CharacterService(urlSession: session)

        await #expect(throws: CharacterServiceError.httpStatus(404)) {
            try await service.getCharacters(page: 1, name: nil, status: nil)
        }
    }
}
