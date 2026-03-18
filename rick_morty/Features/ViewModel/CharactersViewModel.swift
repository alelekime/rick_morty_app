//
//  CharactersViewModel.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation
import Combine

@MainActor
class CharactersViewModel: ObservableObject {
    
    private let characterService: CharacterServiceProtocol
    
    @Published var characters: [Character] = []
    @Published var character: Character = Character(id: 0, image: "", name: "", status: "", species: "", gender: "", origin: LocationInfo(name: "", url: ""), location: LocationInfo(name: "", url: ""), episode: [""])
    @Published var charactersResponse: CharacterResponse?
    @Published var isLoading: Bool = false
    @Published var isLoadingNextPage = false
    @Published var errorMessage: String?
    @Published var currentPage: Int = 1
    @Published var hasNextPage: Bool = true
    
    @Published var searchText: String = ""
    @Published var status: CharacterStatus = .all

    var emptyStateMessage: String {
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Try a different name or clear your search."
        }

        if status != .all {
            return "Try another status filter to see more characters."
        }

        return "There are no characters with your filters."
    }
    
    init(characterService: CharacterServiceProtocol) {
        self.characterService = characterService
    }
    
    func getCharacters() async {
        if currentPage == 1 {
            isLoading = true
        } else {
            isLoadingNextPage = true
        }
        
        errorMessage = nil
        do {
            charactersResponse = try await characterService.getCharacters(
                page: currentPage,
                name: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
                status: status.rawValue.lowercased()
            )
            guard let charactersResponse else { return }
            if currentPage == 1 {
                
                characters = charactersResponse.results
            } else {
                characters.append(contentsOf: charactersResponse.results)
            }
            
            hasNextPage = charactersResponse.info.next != nil
        } catch {
            errorMessage = error.localizedDescription
            
            if currentPage > 1 {
                currentPage -= 1
            }
        }
        isLoading = false
        isLoadingNextPage = false
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
    
    func loadNextPage(currentCharacter: Character) async {
        guard hasNextPage else { return }
        guard !isLoading else { return }
        guard !isLoadingNextPage else { return }
        guard !characters.isEmpty else { return }
        
        let thresholdIndex = max(characters.count - 5, 0)
        
        if let currentIndex = characters.firstIndex(where: { $0.id == currentCharacter.id }),
           currentIndex >= thresholdIndex {
            currentPage += 1
            await getCharacters()
        }
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
        currentPage = 1
        resetPagination()
        
        Task {
            await getCharacters()
        }
    }
    
    private func resetPagination() {
        currentPage = 1
        hasNextPage = true
        characters = []
    }

    func updateStatus(_ status: String) {
        
        switch status {
        case "alive":
            self.status = .alive
        case "dead":
            self.status = .dead
        case "unknown":
            self.status = .unknown
        default:
            self.status = .all
        }
        resetPagination()
        currentPage = 1
        
        Task {
            await getCharacters()
        }
    }
}
