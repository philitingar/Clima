//
//  WeatherManager.swift
//  Clima
//
//  Created by Timi on 2/9/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weaterManager: WeatherManager, weater: WeatherModel)
    func didFailWithError (error: Error)
}

struct WeatherManager {
    let weatherURL =  "https://api.openweathermap.org/data/2.5/weather?appid=96064130994842c034465158a2ff86af&units=metric"
    //this code is from the weather api that we looked up, we just put it in a string and removed?q=London (city name )because we will add it later
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather (cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        //1. create URL
        if let url = URL(string: urlString) {
            
            
            //2. create url session
            let session = URLSession(configuration: .default)
            
            //3. give the session a task
            
            
            let task = session.dataTask(with: url) { data, response, error in // anonymous struct
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather =  self.parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(self, weater: weather)
                    }
                }
            }
            //4. start the task
            task.resume()
        }
    }
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData =  try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
            return weather
            
        } catch  {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
    
}
