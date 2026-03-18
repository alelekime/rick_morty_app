//
//  CharacterListItem.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import SwiftUI

struct CharacterListItem: View {
    var character: Character
    var body: some View {
        VStack {
            Text(character.name)
            Image("rick")
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    let character = Character(
        id: 0,
        image: "rick", name: "Rick Sanchez",
        status: "Alive",
        species: "Human",
        gender: "Male",
        origin: LocationInfo(name: "Earth (C-137)", url: "https://rickandmortyapi.com/api/location/1"),
        location: LocationInfo(name: "Citadel of Ricks", url: "https://rickandmortyapi.com/api/location/3"),
        episode: [
            "https://rickandmortyapi.com/api/episode/1",
            "https://rickandmortyapi.com/api/episode/2"
        ]
    )
    CharacterListItem(character: character)
}
