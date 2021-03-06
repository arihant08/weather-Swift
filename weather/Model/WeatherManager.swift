//
//  WeatherManager.swift
//  weather
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager,weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=65d00499677e59496ca2f318eb68c049&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let city = (cityName as NSString).replacingOccurrences(of: " ", with: "+")
        let urlString = "\(weatherURL)&q=\(city)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                else {
                    if let safeData = data {
                        if let weather = self.parseJSON(safeData){
                            self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id=decodedData.weather[0].id
            let description = decodedData.weather[0].description
            let temp = decodedData.main.temp
            let name = decodedData.name
            let temp_min = decodedData.main.temp_min
            let temp_max = decodedData.main.temp_max
            let speed = decodedData.wind.speed
            let deg = decodedData.wind.deg
            let hum = decodedData.main.humidity
            let pre = decodedData.main.pressure
            let vis = decodedData.visibility
            let country = decodedData.sys.country
            let sunrise = decodedData.sys.sunrise
            let sunset = decodedData.sys.sunset
            
            
            let weather = WeatherModel(conditionId: id, cityName: name, country: country, description: description, minTemperature: temp_min, temperature: temp, maxTemperature: temp_max, windSpeed: speed, windDegree: deg, humidity: hum, pressure: pre, visibility: vis,
                sunrise: sunrise, sunset: sunset)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
}


