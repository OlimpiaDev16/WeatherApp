//
//  WeatherServiceTests.swift
//  WeatherAppTests
//
//  Created by Olimpia Compean on 7/28/25.
//

import Foundation
import XCTest
@testable import WeatherApp

@MainActor
final class WeatherServiceTests: XCTestCase {
    var service: WeatherService!
    
    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        service = WeatherService(session: session)
    }
    
    func testFetchLocationsSuccess() async throws {
        // Mock JSON Response
        let mockJSON = """
        [
            {"name":"London","lat":51.5072,"lon":-0.1276,"country":"GB"}
        ]
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                           statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockJSON)
        }
        
        await service.fetchLocations(for: "London")
        XCTAssertEqual(service.locations.first?.name, "London")
    }
    
    func testFetchWeatherSuccess() async throws {
        // Mock JSON Response
        let mockJSON = """
        {
            "main": {
                "temp": 280.0,
                "pressure": 1000,
                "humidity": 80,
                "temp_min": 275.0,
                "temp_max": 285.0
            }
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                           statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockJSON)
        }
        
        let weather = try await service.fetchWeather(lat: 51.5072, lon: -0.1276)
        XCTAssertEqual(weather.main.pressure, 1000)
        XCTAssertEqual(weather.main.humidity, 80)
    }
    
    func testFetchLocationsFailureInvalidJSON() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                           statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data()) // Empty data
        }
        
        await service.fetchLocations(for: "London")
        XCTAssertTrue(service.locations.isEmpty)
    }
}

