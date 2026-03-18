//
//  rick_mortyApp.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import SwiftUI

@main
struct rick_mortyApp: App {
    var body: some Scene {
        WindowGroup {
            let characterService = CharacterService()
            let viewModel = CharactersViewModel(characterService: characterService)
            CharactersView(viewModel: viewModel)
        }
    }
}
