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
            ForEach(viewModel.characters) { character in
                NavigationLink(destination: CharacterDetailView(viewModel: viewModel, characterId: character.id)) {
                    CharacterListItem(character: character)
                }
            }
        }.task {
            await viewModel.getCharacters()
        }
    }
}

#Preview {
    let viewModel = CharactersViewModel(characterService: CharacterService())
    CharactersView(viewModel: viewModel)
}
