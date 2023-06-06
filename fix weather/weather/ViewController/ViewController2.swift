//
//  ViewController2.swift
//  weather
//
//  Created by 薛博安 on 2023/4/25.
//

import UIKit

class ViewController2: UIViewController {

    var delegate: ViewController2Delegate?
    
    @IBOutlet weak var cityTableView: UITableView!
    
    var citys: [City] = []
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityTableView.delegate = self
        self.cityTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let loveList  = UserDefaults.standard.stringArray(forKey: "123") {
            print(loveList)
            citys = loveList.map { name in
                let city = City()
                city.cityName = name
                return city
            }
            loading(citys: citys) { (isSuccess) in
                if isSuccess {
                    DispatchQueue.main.async {
                        self.cityTableView.reloadData()
                    }
                } else {
                    self.showErrorAlert(title: "Error", message: self.loadingError?.localizedDescription ?? "Api Error.")
                }
            }
//            loading(locations: loveList) { (isSuccess) in
//                if isSuccess {
//                    DispatchQueue.main.async {
//                        self.cityTableView.reloadData()
//                    }
//                } else {
//                    self.showErrorAlert(title: "Error", message: "api error.")
//                }
//            }
        }
    }
    
    private var loadingError: Error? = nil
    func loading(citys: [City], isSuccess: @escaping (Bool) -> Void) {
        let dispatch = DispatchGroup()
        for city in citys {
            dispatch.enter()
            WeatherAPI.loadWeatherApi(locationName: city.cityName) { (weatherData) in
                guard let weatherData = weatherData else { return }
                var weatherParam = WeatherParam()
                for data in weatherData {
                    if let target = WeatherParameters(rawValue: data.elementName) {
                        switch target {
                        case .weatherPhenomenon:
                            weatherParam.wx = data.time[0].parameter.parameterName
                        case .minTemperature:
                            weatherParam.minT = data.time[0].parameter.parameterName + "°C"
                        case .Comfort:
                            weatherParam.ci = data.time[0].parameter.parameterName
                        case .maxTemperature:
                            weatherParam.maxT = data.time[0].parameter.parameterName + "°C"
                        default:
                            break
                        }
                    }
                }
                city.weatherImage = weatherParam.image
                city.temperatureNumber = weatherParam.temp
                city.comfortText = weatherParam.ci
                dispatch.leave()
            } failedHandler: { error in
                print("失敗")
                self.loadingError = error
                dispatch.leave()
            }
        }
        dispatch.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if self.loadingError != nil {
                isSuccess(false)
            } else {
                isSuccess(true)
            }
        }
    }
    
//    func loading(locations: [String], isSuccess: @escaping (Bool) -> Void) {
//        let dispatch = DispatchGroup()
//        let queue = DispatchQueue(label: "", attributes: .concurrent)
//        let semaphore = DispatchSemaphore(value: 0)
//        queue.async {
//            for location in locations {
//                dispatch.enter()
//                WeatherAPI.loadWeatherApi(locationName: location) { (weatherData) in
//                    guard let weatherData = weatherData else { return }
//                    var weatherParam = WeatherParam()
//                    for data in weatherData {
//                        if let target = WeatherParameters(rawValue: data.elementName) {
//                            switch target {
//                            case .weatherPhenomenon:
//                                weatherParam.wx = data.time[0].parameter.parameterName
//                            case .minTemperature:
//                                weatherParam.minT = data.time[0].parameter.parameterName + "°C"
//                            case .Comfort:
//                                weatherParam.ci = data.time[0].parameter.parameterName
//                            case .maxTemperature:
//                                weatherParam.maxT = data.time[0].parameter.parameterName + "°C"
//                            default:
//                                break
//                            }
//                        }
//                    }
//                    self.citys.append(City(cityName: location, weatherImage: weatherParam.image, temperatureNumber: weatherParam.temp, comfortText: weatherParam.ci))
//                    print(self.citys)
//                    semaphore.signal()
//                    dispatch.leave()
//                } failedHandler: { error in
//                    isSuccess(false)
//                    print("失敗")
//                    semaphore.signal()
//                    dispatch.leave()
//                }
//                semaphore.wait()
//            }
//            dispatch.notify(queue: queue) { [weak self] in
//                isSuccess(true)
//            }
//        }
//    }

 
    // MARK: 搜尋欄
    
//    let fruitArray = ["apple","banana","pineapple","orange","peach","cherry","mango"]
        
        //創建一個陣列存搜尋的結果
//        var resultArray = [String]()
//
//        let searchResultsController = UITableViewController()
//        var searchController:UISearchController?
//
//
//    func updateSearchResults(for searchController: UISearchController) {
//            //使用者輸入要查詢的
//            if let searchWord = searchController.searchBar.text{
//                let loveCityList: [String: Int] = (UserDefaults.standard.dictionary(forKey: "love") as? [String: Int])!
//                print(loveCityList)
//                let cityKeys = loveCityList.filter{ $0.value == 1 }.map { $0.key }
//                resultArray = cityKeys.filter({ (filterFruit) -> Bool in
//                    if filterFruit.lowercased().contains(searchWord.lowercased()){
//                        return true
//                    }else{
//                        return false
//                    }
//                })
//                //讓顯示結果的tableView去reloadData
//                self.searchResultsController.tableView.reloadData()
//            }
//        }
}

extension ViewController2: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath) as! LoveCitysTableViewCell
        cell.initCell(citys[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citys.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LoveCitysTableViewCell
        let location = cell.locationLabel.text ?? ""
        print("A : \(location)")
        delegate?.didSelectLocation(location)
        navigationController?.popViewController(animated: true)
    }
}
