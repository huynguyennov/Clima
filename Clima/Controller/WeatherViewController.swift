//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self     // make sure that you set the WeatherViewController as the delegate before requesting the location
        locationManager.requestWhenInUseAuthorization() // request permission for the app to get location information (GPS)
        locationManager.requestLocation()       // lấy vị trí chỉ 1 lần duy nhất, còn có một số hàm khác có thể lấy vị trí liên tục <startUpdatingLocation()>
        
        searchTextField.delegate = self     // setting the WeatherViewController as delegate
        //Here what this line of code is saying is the text field should report back to our view controller.
        weatherManager.delegate = self
    }
    
    
    @IBAction func getLocationWeather(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)    // đóng bàn phím
        print(searchTextField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {  // hàm tương tác với nút return/enter
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  // hàm triển khai khi user ấn nút go/return để kết thúc typing. Nếu VC có nhiều textField thì cần phải check loại trước khi thực hiện lệnh
        if textField.text != "" {   // if users did type something
            return true
        } else {        // if users didn't type anything
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {  // hàm triển khai khi user stop editing-typing
        // get the city name from textField
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {      // UILabel.text must be used from main thread only -> use DispatchQueue.main.async
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {      // get the last location
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {     // make sure you've implement the required didFailWithErrorDelegate
        print(error)
    }
}
