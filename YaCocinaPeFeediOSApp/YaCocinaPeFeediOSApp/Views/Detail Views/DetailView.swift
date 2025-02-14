//
//  DetailView.swift
//  YaCocinaPeFeediOSApp
//
//  Created by Pablo Butron on 14/2/25.
//

import SwiftUI

struct DetailView: View {
    let mealId: String
    @StateObject private var viewModel = DetailViewModel()
    @State private var selectedTab: Tab = .instructions
    
    enum Tab: String, CaseIterable {
        case instructions = "Instructions"
        case ingredients = "Ingredients"
    }
    
    var body: some View {
        ScrollView {
            if let meal = viewModel.meal {
                AsyncImage(url: meal.imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                
                Text(meal.strMeal)
                    .font(.largeTitle)
                    .bold()
                
                NavigationLink(destination: MapView(regionName: meal.strArea)) {
                    Text("Display recipe country")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Picker("Select", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    if selectedTab == .ingredients {
                        Text("Ingredients")
                            .font(.headline)
                        ForEach(meal.ingredients, id: \..self) { ingredient in
                            Text("• \(ingredient)")
                                .font(.body)
                        }
                    } else {
                        Text("Instructions")
                            .font(.headline)
                        Text(meal.strDescription)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.loadMealDetails(id: mealId)
        }
    }
}

#Preview {
    DetailView(mealId: "52771")
}


#Preview {
    DetailView(mealId: "52771")
}
