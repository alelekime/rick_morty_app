//
//  CharacterDetailView.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import SwiftUI

/// Shows the details for a selected character.
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
    /// Chooses between loading, error, and detail states.
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
    /// Shown when loading the selected character fails.
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
    /// Displays the selected character information.
    private var character: some View {
        VStack(spacing: 16) {
            characterImage
            statusBadge
            detailsSection
            locationsSection
            episodesSection
        }
        .padding()
    }

    /// Displays the character image at the top of the screen.
    private var characterImage: some View {
        AsyncImage(url: URL(string: viewModel.character.image)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty, .failure:
                imagePlaceholder
            @unknown default:
                imagePlaceholder
            }
        }
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// Displays a placeholder while the image is loading.
    private var imagePlaceholder: some View {
        ZStack() {
           ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("rick_and_morty_silhouette")
                .resizable()
                .scaledToFill()
                .opacity(0.3)
        )
    }
    /// Displays the colored status badge.
    private var statusBadge: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(viewModel.character.status.capitalized)
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(statusColor, in: Capsule())
        }
    }

    /// Displays the main character details.
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            Divider()
            Text("Species: \(viewModel.character.species)")
            Text("Gender: \(viewModel.character.gender)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    /// Displays the character origin and current location.
    private var locationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Locations")
                .font(.headline)
            Divider()
            Text("Origin: \(viewModel.character.origin.name)")
            Text("Last known location: \(viewModel.character.location.name)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    /// Displays the episodes where the character appears.
    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Episodes")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.character.episode.count)")
                    .font(.caption)
                
            }
            Divider()
            ForEach(viewModel.character.episode.indices, id: \.self) { index in
                Text(formatEpisode(viewModel.character.episode[index]))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    /// Converts an episode URL into a shorter label for display.
    private func formatEpisode(_ episodeURL: String) -> String {
        guard
            let url = URL(string: episodeURL),
            let episodeId = url.pathComponents.last,
            !episodeId.isEmpty
        else {
            return episodeURL
        }

        return "Episode \(episodeId)"
    }
    
    /// Returns the badge color that matches the character status.
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

