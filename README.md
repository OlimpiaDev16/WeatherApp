# 🌤 WeatherApp

An iOS Weather App built with **SwiftUI**, **async/await**, and **dependency injection** — designed to showcase modern iOS development best practices.

---

## 📱 Features
- 🔍 **City Search** – Fetch location coordinates using OpenWeather API.
- 🌡 **Weather Details** – Display current temperature, min/max temps, humidity, and pressure.
- ⚡ **Modern Concurrency** – Async/await with structured concurrency.
- 🧩 **Dependency Injection** – `URLSession` injected for easier testing and flexibility.
- 🧪 **Unit Tests** – Mocked network calls using `URLProtocol` for isolated async testing.
- 🎨 **SwiftUI UI** – Minimal, clean interface with `@StateObject` and `ObservableObject` integration.

---

## 🖼 Screenshots  
*(Coming)*
| Search Screen | Results List | Weather Details |
|---------------|--------------|-----------------|

---

## 🏗 Architecture
- **MVVM-lite** structure
- `WeatherService` handles all networking
- `ContentView` manages UI & state
- Testable with injected `URLSession`

---

## 🔑 API Key Setup
1. Sign up at [OpenWeather](https://openweathermap.org/api) to get an API key.
2. Replace `"<YOUR_API_KEY>"` in `WeatherService` with your key.  
*(For security, do not commit your real key to public repos — use a placeholder or `.xcconfig` file.)*

---

## 🧪 Running Tests
The project includes unit tests for `WeatherService`:
```bash
⌘ + U  // Run all tests in Xcode

---
##  🚀 Getting Started

```bash
git clone https://github.com/YOUR_USERNAME/WeatherApp.git
cd WeatherApp
open WeatherApp.xcodeproj
