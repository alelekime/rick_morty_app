//
//  SearchContext.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 18/03/26.
//

import SwiftUI
import Combine

class SearchContext: ObservableObject {
    
    init() {
        $query
            .debounce(for: .seconds(0.25), scheduler: RunLoop.main)
            .assign(to: &$debouncedQuery)
    }
    
    @Published var query = ""
    @Published var debouncedQuery = ""
}
