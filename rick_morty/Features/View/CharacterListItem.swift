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
            AsyncImage(url: URL(string: character.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(character.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(character.species)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(character.status)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(statusColor, in: Capsule())
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
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
