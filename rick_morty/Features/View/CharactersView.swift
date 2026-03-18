//
//  CharactersView.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import SwiftUI

struct CharactersView: View {
    @StateObject var viewModel: CharactersViewModel
    var body: some View {
        NavigationStack {
            content
        }
        .task {
            await viewModel.getCharacters()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.errorMessage != nil {
            errorView
        } else {
            characterList
        }
    }
    
    @ViewBuilder
    private var errorView: some View {
        VStack {
            Text("Error: \(viewModel.errorMessage ?? "Unknown error")")
                .font(.largeTitle)
            
            Button("Retry") {
                Task {
                    await viewModel.getCharacters()
                }
            }
        }
    }
    
    @ViewBuilder
    private var characterList: some View {
        List {
            ForEach(viewModel.characters) { character in
                NavigationLink(destination: CharacterDetailView(viewModel: viewModel, characterId: character.id)) {
                    CharacterListItem(character: character)
                }
            }
        }
    }
}

#Preview {
    let viewModel = CharactersViewModel(characterService: CharacterService())
    CharactersView(viewModel: viewModel)
}
