//
//  ContentView.swift
//  WeatherApp-SwiftUI
//
//  Created by Akbar Eka Putra on 22/04/24.
//

import Foundation
import SwiftUI

struct ContentView: View {
  @State private var isNight: Bool = false
  @State private var weatherData: WeatherData? = nil

  var weatherForecastArray: [WeatherModel] {
    if let weatherData = weatherData {
      let day1 = dayOfWeekFormatter(from: weatherData.forecast.forecastday[0].date) ?? "nil"
      let day2 = dayOfWeekFormatter(from: weatherData.forecast.forecastday[1].date) ?? "nil"
      let day3 = dayOfWeekFormatter(from: weatherData.forecast.forecastday[2].date) ?? "nil"
      return [
        WeatherModel(
          dayOfWeek: day1,
          imageName: "sun.max.fill",
          temperature: Int(weatherData.forecast.forecastday[0].day.avgtemp_c)),
        WeatherModel(
          dayOfWeek: day2,
          imageName: "cloud.sun.fill",
          temperature: Int(weatherData.forecast.forecastday[1].day.avgtemp_c)),
        WeatherModel(
          dayOfWeek: day3,
          imageName: "cloud.drizzle.fill",
          temperature: Int(weatherData.forecast.forecastday[2].day.avgtemp_c)),
      ]
    } else {
      return [
        WeatherModel(dayOfWeek: "nil", imageName: "nil", temperature: 0)
      ]
    }
  }

  var body: some View {

    ZStack {
      BackgroundView(isNight: $isNight)

      VStack {
        let locationName: String = weatherData?.location.name ?? "nil"
        let locationRegion: String = weatherData?.location.region ?? "nil"
        CityNameTextView(
          cityName: "\(locationName), \(locationRegion)")

        let mainTemp: Int = Int(weatherData?.current.temp_c ?? 0)
        MainWeatherStatusView(
          imageName: isNight ? "moon.stars.fill" : "cloud.sun.fill",
          temperature: mainTemp
        )

        .padding(.bottom, 40)

        HStack(spacing: 40) {
          ForEach(weatherForecastArray) {
            weatherForecastData in
            WeatherForecastView(
              data: weatherForecastData)
          }
        }

        Spacer()

        Button {
          isNight.toggle()
        } label: {
          LabelButtonWeather(title: "Change Theme", bgColor: .white, textColor: .blue)
        }

        Spacer()
      }
    }
    .onAppear {
      fetchWeatherData()
      print("this onappear")
    }
  }

  func fetchWeatherData() {
    guard
      let url = URL(string: "https://weatherapi-com.p.rapidapi.com/forecast.json?q=Bekasi&days=3")
    else {
      print("Invalid URL")
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue(
      "f91e9bfb47mshb40260086f5a504p180445jsn3ca5035f7ac8", forHTTPHeaderField: "X-RapidAPI-Key")
    request.addValue(
      "weatherapi-com.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")

    URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data, error == nil else {
        print("Error: \(error?.localizedDescription ?? "Unknown error")")
        return
      }

      do {
        let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
        DispatchQueue.main.async {
          self.weatherData = decodedData
        }
      } catch {
        print("Error decoding JSON: \(error)")
      }
    }.resume()
  }

  func dayOfWeekFormatter(from dateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    if let date = dateFormatter.date(from: dateString) {
      let calendar = Calendar.current
      let weekday = calendar.component(.weekday, from: date)

      switch weekday {
      case 1:
        return "Sun"
      case 2:
        return "Mon"
      case 3:
        return "Tue"
      case 4:
        return "Wed"
      case 5:
        return "Thu"
      case 6:
        return "Fri"
      case 7:
        return "Sat"
      default:
        return nil
      }
    } else {
      return nil
    }
  }

}

#Preview{
  ContentView()
}

struct WeatherModel: Identifiable {
  let id = UUID()
  let dayOfWeek: String
  let imageName: String
  let temperature: Int
}

struct BackgroundView: View {
  @Binding var isNight: Bool
  var body: some View {
    //      cara 1
    //        LinearGradient(gradient: Gradient(colors: [isNight ? .black : .blue, isNight ? .gray : Color("lightBlue")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    //            .ignoresSafeArea()

    //      cara 2
    ContainerRelativeShape()
      .fill(isNight ? Color.black.gradient : Color.blue.gradient)
      .ignoresSafeArea()
  }
}

struct CityNameTextView: View {
  var cityName: String
  var body: some View {
    Text(cityName)
      .font(.system(size: 32, weight: .medium, design: .default))
      .foregroundColor(.white)
      .padding()
  }
}

struct MainWeatherStatusView: View {
  var imageName: String
  var temperature: Int

  var body: some View {
    VStack {
      Image(systemName: imageName)
        .symbolRenderingMode(.multicolor)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 180, height: 180)
      Text("\(temperature)°C")
        .font(.system(size: 70, weight: .medium))
        .foregroundColor(.white)
    }
  }
}

struct WeatherForecastView: View {
  var data: WeatherModel

  var body: some View {
    VStack {
      Text(data.dayOfWeek)
        .font(.system(size: 16, weight: .medium, design: .default))
        .foregroundColor(.white)
      Image(systemName: data.imageName)
        .symbolRenderingMode(.hierarchical)
        .resizable()
        .foregroundColor(.white)
        .frame(width: 40, height: 40)
        .aspectRatio(contentMode: .fit)

      Text("\(data.temperature)°C")
        .font(.system(size: 28, weight: .medium))
        .foregroundColor(.white)
    }
  }
}

struct WeatherData: Codable {
  let location: Location
  let current: Current
  let forecast: Forecast
}

struct Location: Codable {
  let name: String
  let region: String
}

struct Current: Codable {
  let temp_c: Double
}

struct Forecast: Codable {
  let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
  let date: String
  let day: Day
}

struct Day: Codable {
  let avgtemp_c: Double
}
