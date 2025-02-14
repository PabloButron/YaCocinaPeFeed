//
//  HomeView.swift
//  YaCocinaPeFeediOSApp
//
//  Created by Pablo Butron on 14/2/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isSearchVisible = false
    
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
                
                if isSearchVisible && viewModel.isNotFound {
                    VStack(spacing: 32) {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Text("Nothing Found")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "fork.knife")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button {
                            Task {
                                await viewModel.loadMeals()
                                isSearchVisible = false
                            }
                        } label: {
                            Text("Back")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                    .padding()
                    
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
            .task {
                await viewModel.loadMeals()
            }
        }
    }
}

#Preview {
    HomeView()
}
