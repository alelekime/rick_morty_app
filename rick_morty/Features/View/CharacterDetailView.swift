//
//  CharacterDetailView.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import SwiftUI

struct CharacterDetailView: View {
    @StateObject var viewModel: CharactersViewModel
    var characterId: Int
    
    var body: some View {
        if viewModel.errorMessage != nil {
            VStack {
                Text("Error: \(viewModel.errorMessage!)")
            }
        } else {
            VStack {
                Text(viewModel.character.name)
                Image("rick")
                    .resizable()
                    .scaledToFit()
                Text(viewModel.character.status)
                Text(viewModel.character.species)
                Text(viewModel.character.gender)
                HStack {
                    Text("Origin: ")
                    Text(viewModel.character.origin.name)
                }
                HStack {
                    Text("Location: ")
                    Text(viewModel.character.location.name)
                }
                VStack {
                    ForEach(viewModel.character.episode.indices, id: \.self) { index in
                        Text(viewModel.character.episode[index])
                    }
                }
            }.task {
                await viewModel.getcharacter(id: characterId)
            }
        }
        
    }
}

