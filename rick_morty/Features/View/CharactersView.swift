//
//  CharactersView.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import SwiftUI

struct CharactersView: View {
    @StateObject var viewModel: CharactersViewModel
    @StateObject var searchContext = SearchContext()
    
    var body: some View {
        NavigationStack {
            ZStack {
                picker
                content
            }
                .navigationTitle("Rick and Morty")
                .navigationSubtitle("Characters")
                .navigationBarTitleDisplayMode(.large)
        }
        .searchable(text: $searchContext.query, placement: .sidebar, prompt: "Search by name")
        .onChange(of: searchContext.debouncedQuery) { _, newValue in
            viewModel.updateSearchText(newValue)
        }
        .onChange(of: viewModel.status) { _, newValue in
            viewModel.updateStatus(newValue.rawValue)
        }
        .task {
            await viewModel.getCharacters()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.errorMessage != nil {
            errorView
        } else {
            characterList
        }
    }
    
    @ViewBuilder
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
        private var characterList: some View {
            List {
                ForEach(viewModel.characters) { character in
                    NavigationLink(destination: CharacterDetailView(viewModel: viewModel, characterId: character.id)) {
                        CharacterListItem(character: character)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .onAppear {
                           Task {
                               await viewModel.loadNextPage(currentCharacter: character)
                           }
                       }
                }
                if viewModel.isLoadingNextPage {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
        }
        
        @ViewBuilder
        private var picker: some View {
            Picker("Status", selection: $viewModel.status) {
                ForEach(CharacterStatus.allCases) { status in
                    Text(status.rawValue.capitalized).tag(status)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
}

#Preview {
    let viewModel = CharactersViewModel(characterService: CharacterService())
    CharactersView(viewModel: viewModel)
}
