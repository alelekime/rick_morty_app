//
//  CharactersViewModelTests.swift
//  rick_mortyTests
//
//  Created by Alessandra Souza da Silva on 18/03/26.
//

@testable import rick_morty
import Testing

@MainActor
struct CharactersViewModelTests {
    
    @Test
    func updateSearchText_resetsPaginationState() async throws {
        let service = MockCharacterService()
        let viewModel = CharactersViewModel(characterService: service)
        
        viewModel.currentPage = 3
        viewModel.hasNextPage = false
        viewModel.characters = [
            Character.mock(id: 1, name: "Rick Sanchez")
        ]
        
        viewModel.updateSearchText("morty")
        
        #expect(viewModel.searchText == "morty")
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.hasNextPage == true)
        #expect(viewModel.characters.isEmpty)
    }
}
