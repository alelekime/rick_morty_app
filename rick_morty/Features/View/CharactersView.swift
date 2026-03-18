//
//  CharactersView.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import SwiftUI

/// Shows the searchable, filterable list of characters.
struct CharactersView: View {
    @StateObject var viewModel: CharactersViewModel
    @StateObject var searchContext = SearchContext()
    
    var body: some View {
        NavigationStack {
            ZStack {
                content
            }
            .navigationTitle("Rick and Morty")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Status", selection: $viewModel.status) {
                            ForEach(CharacterStatus.allCases) { status in
                                Text(status.rawValue.capitalized).tag(status)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .searchable(text: $searchContext.query, placement: .sidebar, prompt: "Search by name")
        .onChange(of: searchContext.debouncedQuery) { _, newValue in
            viewModel.updateSearchText(newValue)
        }
        .onChange(of: viewModel.status) { _, newValue in
            viewModel.updateStatus(newValue.rawValue)
        }
        .alert("Rate limit reached", isPresented: $viewModel.showRateLimitAlert) {
            Button("Retry") {
                Task {
                    await viewModel.retryRateLimitedRequest()
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.dismissRateLimitAlert()
            }
        } message: {
            Text(viewModel.rateLimitMessage)
        }
        .task {
            await viewModel.getCharacters()
        }
    }
    
    @ViewBuilder
    // Chooses the right screen state for loading, errors, empty results, or content.
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.errorMessage != nil {
            errorView
        } else if viewModel.characters.isEmpty {
            emptyView
        } else {
            characterList
        }
    }
    
    @ViewBuilder
    // Shown when the initial request fails with a non-rate-limit error.
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(viewModel.errorMessage ?? "error")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await viewModel.getCharacters()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    @ViewBuilder
    // Shown when the filters return no characters.
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No characters found")
                .font(.title3)
                .fontWeight(.semibold)

            Text(viewModel.emptyStateMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    @ViewBuilder
    // Renders the current page of characters and the pagination footer.
    private var characterList: some View {
        List {
            ForEach(viewModel.characters) { character in
                NavigationLink(destination: CharacterDetailView(viewModel: viewModel, characterId: character.id)) {
                    CharacterListItem(character: character)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }
            if viewModel.hasNextPage {
                loadMoreFooter
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // Lets the user manually load the next page.
    private var loadMoreFooter: some View {
        HStack {
            Spacer()
            Button {
                Task {
                    await viewModel.loadMoreCharacters()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isLoadingNextPage {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(viewModel.isLoadingNextPage ? "Loading..." : "Load More")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoadingNextPage)
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    let viewModel = CharactersViewModel(characterService: CharacterService())
    CharactersView(viewModel: viewModel)
}
