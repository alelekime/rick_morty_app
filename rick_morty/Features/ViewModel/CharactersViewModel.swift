//
//  CharactersViewModel.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import Foundation
import Combine

@MainActor
/// Manages character list state, filters, and pagination.
class CharactersViewModel: ObservableObject {
    
    private let characterService: CharacterServiceProtocol
    // Keeps track of the page that should be retried after a rate-limit error.
    private var pendingRetryPage: Int?
    
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
    @Published var showRateLimitAlert = false
    @Published var rateLimitMessage = "The API rate limit was reached. Please try again."

    /// Message shown when the current filters return no results.
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
    
    /// Loads characters for the current page and active filters.
    func getCharacters() async {
        let requestedPage = currentPage

        if currentPage == 1 {
            isLoading = true
        } else {
            isLoadingNextPage = true
        }
        
        errorMessage = nil
        do {
            charactersResponse = try await characterService.getCharacters(
                page: requestedPage,
                name: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
                status: status.rawValue.lowercased()
            )
            guard let charactersResponse else { return }
            if requestedPage == 1 {
                characters = charactersResponse.results
            } else {
                characters.append(contentsOf: charactersResponse.results)
            }
            
            hasNextPage = requestedPage < charactersResponse.info.pages
            pendingRetryPage = nil
        } catch {
            let isRateLimitError = caseMatchesRateLimit(error)

            if isRateLimitError {
                // Shows a specific alert instead of the generic error state.
                rateLimitMessage = requestedPage > 1
                    ? "The API rate limit was reached while loading more characters."
                    : "The API rate limit was reached while loading characters."
                showRateLimitAlert = true
            }

            if requestedPage > 1 {
                currentPage = requestedPage - 1
                pendingRetryPage = isRateLimitError ? requestedPage : nil
            } else {
                errorMessage = isRateLimitError ? nil : error.localizedDescription
            }
        }
        isLoading = false
        isLoadingNextPage = false
    }
    
    /// Loads one character for the detail screen.
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
    
    /// Loads the next page when more results are available.
    func loadMoreCharacters() async {
        guard hasNextPage else { return }
        guard !isLoading else { return }
        guard !isLoadingNextPage else { return }
        
        currentPage += 1
        await getCharacters()
    }
    
    /// Applies a new search term and restarts pagination.
    func updateSearchText(_ text: String) {
        searchText = text
        currentPage = 1
        resetPagination()
        
        Task {
            await getCharacters()
        }
    }

    /// Retries the request that failed because of rate limiting.
    func retryRateLimitedRequest() async {
        showRateLimitAlert = false
        
        if let pendingRetryPage {
            currentPage = pendingRetryPage
        }

        await getCharacters()
    }

    /// Closes the rate-limit alert without retrying.
    func dismissRateLimitAlert() {
        showRateLimitAlert = false
    }

    // Only the 429 response is treated as a rate-limit case in the UI.
    private func caseMatchesRateLimit(_ error: Error) -> Bool {
        if case CharacterServiceError.httpStatus(429) = error {
            return true
        }

        return false
    }
    
    // Clears pagination state before running a new filtered search.
    private func resetPagination() {
        currentPage = 1
        hasNextPage = true
        charactersResponse = nil
        pendingRetryPage = nil
        showRateLimitAlert = false
        characters = []
    }

    // Converts the UI filter into the enum used by the view model.
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
