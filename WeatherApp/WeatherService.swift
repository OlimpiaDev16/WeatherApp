//
//  LocationService.swift
//  WeatherApp
//
//  Created by Olimpia Compean on 3/20/25.
//

import Foundation

// MARK: - Models
struct Location: Codable, Identifiable {
    var id: String { "\(lat),\(lon)" }
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}

struct Weather: Codable {
    let main: MainWeather
}

struct MainWeather: Codable {
    let temp: Double
    let pressure: Int
    let humidity: Int
    let tempMin: Double
    let tempMax: Double
    
    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
    
    var tempCelsius: Double { temp - 273.15 }
    var tempFahrenheit: Double { (temp - 273.15) * 9/5 + 32 }
}

// MARK: - Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(Int)
    case decodingError
    case noResult
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .decodingError:
            return "Failed to decode server response."
        case .noResult:
            return "No matching result found."
        }
    }
}

// MARK: - Service
@MainActor
class WeatherService: ObservableObject {
    private let apiKey = "c38924c0318c4ee4bf46d48806398ad9"
    private let session: URLSession
    
    @Published private(set) var locations: [Location] = []
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Public API
    func fetchLocations(for city: String) async {
        do {
            let results = try await fetchLocationsHelper(for: city)
            locations = results
        } catch {
            print("Error fetching location: \(error.localizedDescription)")
        }
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> Weather {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        try validate(response: response)
        
        do {
            return try JSONDecoder().decode(Weather.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Helpers
    
    private func fetchLocationsHelper(for city: String) async throws -> [Location] {
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(city)&limit=5&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        try validate(response: response)
        
        do {
            let decodedData = try JSONDecoder().decode([Location].self, from: data)
            guard !decodedData.isEmpty else {
                throw NetworkError.noResult
            }
            return decodedData
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    private func validate(response: URLResponse?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.requestFailed(-1)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
    }
}

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler not set.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}


