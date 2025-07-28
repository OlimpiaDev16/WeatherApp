//
//  ContentView.swift
//  WeatherApp
//
//  Created by Olimpia Compean on 3/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var weatherService = WeatherService(session: .shared)
    
    @State private var searchQuery = ""
    @State private var selectedWeather: Weather?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // MARK: Search Field
                TextField("Enter city name", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .onSubmit {
                        fetchLocations()
                    }
                
                // MARK: Search Button
                Button(action: fetchLocations) {
                    Text("Search")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // MARK: Loading State
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                }
                
                // MARK: Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                // MARK: Results
                if !weatherService.locations.isEmpty {
                    List(weatherService.locations) { location in
                        Button {
                            fetchWeather(for: location)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(location.name)
                                    .font(.headline)
                                Text(location.country)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                    }
                }
                
                // MARK: Weather Details
                if let weather = selectedWeather {
                    VStack(spacing: 8) {
                        Text("🌡 \(String(format: "%.1f", weather.main.tempCelsius))°C")
                            .font(.title)
                            .bold()
                        Text("Min: \(String(format: "%.1f", weather.main.tempMin - 273.15))°C")
                        Text("Max: \(String(format: "%.1f", weather.main.tempMax - 273.15))°C")
                        Text("Pressure: \(weather.main.pressure) hPa")
                        Text("Humidity: \(weather.main.humidity)%")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Weather Search")
        }
    }
    
    // MARK: - Actions
    private func fetchLocations() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a valid city name."
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        Task {
            await weatherService.fetchLocations(for: searchQuery)
            isLoading = false
        }
    }
    
    private func fetchWeather(for location: Location) {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                selectedWeather = try await weatherService.fetchWeather(lat: location.lat, lon: location.lon)
            } catch {
                errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}

