//
//  WeatherCollCellCollectionViewCell.swift
//  EarlyWarningSystem
//
//  Created by Eric Cha on 12/24/18.
//  Copyright © 2018 Eric Cha. All rights reserved.
//

import UIKit

class WeatherCollCell: UICollectionViewCell {
    
    @IBOutlet weak var highTemp: UILabel!
    @IBOutlet weak var lowTemp: UILabel!
    @IBOutlet weak var timezone: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var weatherImgView: UIImageView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCell(highTemp : Double, lowTemp : Double, timezone : String, date : String, weather : String) {
        self.highTemp.text = "H: \(highTemp)F"
        self.lowTemp.text = "L: \(lowTemp)F"
        self.timezone.text = timezone
        self.date.text = date
        getWeatherIcon(weather: weather)
    }
    
    func getWeatherIcon(weather: String) {
        switch weather {
        case "clear-day" :
            self.weatherImgView.image = UIImage(named: "sun")
        case "clear-night" :
            self.weatherImgView.image = UIImage(named: "sun")
        case "rain" :
            self.weatherImgView.image = UIImage(named: "rain")
        case "snow" :
            self.weatherImgView.image = UIImage(named: "snow")
        case "sleet" :
            self.weatherImgView.image = UIImage(named: "sleet")
        case "wind" :
            self.weatherImgView.image = UIImage(named: "windy")
        case "fog" :
            self.weatherImgView.image = UIImage(named: "fog")
        case "cloudy" :
            self.weatherImgView.image = UIImage(named: "cloud")
        case "partly-cloudy-day" :
            self.weatherImgView.image = UIImage(named: "partly-cloudy")
        case "partly-cloudy-night" :
            self.weatherImgView.image = UIImage(named: "partly-cloudy")
        default:
            self.weatherImgView.image = UIImage(named: "sun")
        }
    }
}
