//
//  WeatherViewController.swift
//  weather
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var direction: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var thermSymbol: UIImageView!
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var detailButton: UIButton!
    
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherManager.delegate = self
        searchField.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        symbol.isHidden = true
        thermSymbol.isHidden = true
        activity.startAnimating()
        detailButton.isHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        searchField.endEditing(true)
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        if searchField.text != "" {
            searchField.endEditing(true)
        }
        else {
             let alert = UIAlertController(title: "Alert", message: "Enter a  city!", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title:"Okay", style: .default, handler: nil))
             DispatchQueue.main.async {
                 self.present(alert, animated: true)
        }
        }
    }
    
    @IBAction func locationPressed(_ sender: Any) {
        locationManager.requestLocation()
        activity.isHidden = false
        activity.startAnimating()
    }
    
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate{
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async{
            self.descriptionLabel.text = weather.description
            self.cityLabel.text = weather.cityName
            self.weatherIcon.image = UIImage(systemName: weather.conditionName)
            self.currentTemp.text = "\(weather.temperatureString)??C"
            self.minTemp.text = "\(weather.min_temperatureString)??C"
            self.maxTemp.text = "\(weather.max_temperatureString)??C"
            self.speed.text = "\(weather.windSpeed) m/s, "
            self.direction.text = "\(weather.windDirection) direction"
            self.symbol.isHidden = false
            self.thermSymbol.isHidden = false
            if self.activity.isHidden == false {
                self.activity.stopAnimating()
                self.activity.isHidden = true
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
        let alert = UIAlertController(title: "Error", message: "Enter a valid city!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Okay", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
            self.activity.isHidden = true
        }
    }
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.endEditing(true)
        return true
    }
    
    /*func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }
        else {
            textField.placeholder = "Type something..."
            return false
        }
    }
    */
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var city = searchField.text
        if city != "" {
            weatherManager.fetchWeather(cityName: city!)
            activity.isHidden = false
            activity.startAnimating()
        }
        searchField.text = ""
        
    
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
            activity.isHidden = false
            activity.startAnimating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
