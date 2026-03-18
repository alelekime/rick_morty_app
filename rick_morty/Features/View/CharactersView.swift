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
        List(viewModel.characters ?? []) { character in
            Text(character.name)
        }.task {
            await viewModel.getCharacters()
        }
    }
}

#Preview {
    let viewModel = CharactersViewModel(characterService: CharacterService())
    CharactersView(viewModel: viewModel)
}
