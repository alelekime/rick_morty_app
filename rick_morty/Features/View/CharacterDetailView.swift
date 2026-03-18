//
//  CharacterDetailView.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import SwiftUI

struct CharacterDetailView: View {
    @ObservedObject var viewModel: CharactersViewModel
    var characterId: Int
    
    var body: some View {
        ScrollView {
            VStack {
                content
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(viewModel.character.name)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.getcharacter(id: characterId)
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
            character
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
                    await viewModel.getcharacter(id: characterId)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
    
    @ViewBuilder
    private var character: some View {
        VStack(spacing: 16){
            
            AsyncImage(url: URL(string: viewModel.character.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .center, spacing: 8) {
                
                Text(viewModel.character.status.capitalized)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(statusColor, in: Capsule())
                
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.headline)
                Divider()
                Text("Species: \(viewModel.character.species)")
                Text("Gender: \(viewModel.character.gender)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Locations")
                    .font(.headline)
                Divider()
                Text("Origin: \(viewModel.character.origin.name)")
                Text("Last known location: \(viewModel.character.location.name)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Episodes")
                    .font(.headline)
                Divider()
                ForEach(viewModel.character.episode.indices, id: \.self) { index in
                    Text(viewModel.character.episode[index])
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .padding()
    }
    
    private var statusColor: Color {
        switch viewModel.character.status.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        default:
            return .gray
        }
    }
}

