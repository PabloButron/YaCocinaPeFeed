//
//  HomeView.swift
//  YaCocinaPeFeediOSApp
//
//  Created by Pablo Butron on 14/2/25.
//

import SwiftUI

struct HomeView: View {
    @State private var isSearchVisible = false
    @StateObject private var viewModel = HomeViewModel()

    
    
    var body: some View {
        NavigationView {
            VStack {
                if isSearchVisible {
                    Picker("Search by", selection: $viewModel.searchType) {
                        Text("Recipe Name").tag(SearchType.recipeName)
                        Text("Ingredient").tag(SearchType.ingredient)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    TextField(viewModel.searchType == .ingredient ? "Try: Chicken" : "Try: Pizza",
                              text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        Task {
                            await viewModel.searchMeals()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Recipes")
                        .font(.largeTitle)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation {
                            isSearchVisible.toggle()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
