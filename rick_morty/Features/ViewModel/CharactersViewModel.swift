//
//  CharactersViewModel.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation
import Combine


class CharactersViewModel: ObservableObject {
    
    private let characterService: CharacterService
    
    @Published var characters: [Character] = []
    @Published var character: Character = Character(id: 0, image: "", name: "", status: "", species: "", gender: "", origin: LocationInfo(name: "", url: ""), location: LocationInfo(name: "", url: ""), episode: [""])
    @Published var charactersResponse: CharacterResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentPage: Int = 1
    
    init(characterService: CharacterService) {
        self.characterService = characterService
    }
    
    func getCharacters() async {
        isLoading = true
        errorMessage = nil
        do {
            charactersResponse = try await characterService.getCharacters(page: currentPage, name: nil, status: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
        
        guard let charactersResponse else { return }
        characters = charactersResponse.results
    }
    
    func getcharacter(id: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            character = try await characterService.getCharacter(id: id)
            
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
