//
//  CharacterListItem.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 17/03/26.
//

import SwiftUI

/// Displays a single character row in the list.
struct CharacterListItem: View {
    var character: Character

    var body: some View {
        HStack(spacing: 12) {
            characterImage
            
            VStack(alignment: .leading, spacing: 8) {
                Text(character.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(character.species)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(character.status.capitalized)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(statusColor, in: Capsule())
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    /// Displays the character image at the top of the screen.
    private var characterImage: some View {
        AsyncImage(url: URL(string: character.image)) { phase in
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
        .frame(width: 80, height: 80)
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
    
    /// Returns the badge color that matches the character status.
    private var statusColor: Color {
        switch character.status.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        default:
            return .gray
        }
    }
}
