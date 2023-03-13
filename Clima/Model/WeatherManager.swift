//
//  WeatherManager.swift
//  Clima
//
//  Created by Macmini on 02/02/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=05f5d02f7af03a133ee9b2d261ebfd30&units=metric"  // the url of weather api
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {        // thực thiện networking, sử dụng external parameter để code trở nên tường minh hơn
        //1. create a URL
        if let url = URL(string: urlString) {
            //2. create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {       // if there is any error
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {     // thực hiện parse JSON ở code này, thu về được object weather từ parseJSON
                        // we want to send object 'weather' back to WeatherVC -> sau này phục vụ cho việc update UI
                        delegate?.didUpdateWeather(self, weather: weather)    // triển khai func didUpdateWeather trên các delegate
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {        // parse JSON code -> lấy data để thu được và return 1 object của WeatherModel
        let decoder = JSONDecoder()
        do {            // do -- catch: handle error
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData) // try for functions that throw error
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather      // return object WeatherModel
        } catch {
            delegate?.didFailWithError(error: error)
            return nil      // nếu bị lỗi thì return nil
        }
    }
    
}
