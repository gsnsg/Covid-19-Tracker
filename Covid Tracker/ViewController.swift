//
//  ViewController.swift
//  Covid Tracker
//
//  Created by Nikhi on 10/07/20.
//  Copyright © 2020 nikit. All rights reserved.
//

import UIKit


class HomeViewController: UITableViewController, UISearchResultsUpdating {
   
    
   
    let fadeView = UIView()
    let searchController = UISearchController()
    var locationsData = [Location]()
    var filteredLocations = [Location]()
    var worldWideData = [GlobalData]()
    var pullToRefresh = UIRefreshControl()
    let feedbackGen = UIImpactFeedbackGenerator()
    let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.placeholder = "Search Country"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        pullToRefresh.addTarget(self, action: #selector(apiRequest), for: .allEvents)
        pullToRefresh.attributedTitle = NSAttributedString(string: "Refreshing Stats")
        tableView.refreshControl = pullToRefresh
    
        addActivity()
        apiRequest()
    
    }
        
    func addActivity() {
        fadeView.frame = self.view.frame
        fadeView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0)
        activityView.center = fadeView.center
        activityView.startAnimating()
        fadeView.addSubview(activityView)
        self.view.addSubview(fadeView)
        
    }
    
    @objc func apiRequest() {
        guard let url = URL(string: "https://api.covid19api.com/summary") else {return}
        URLSession.shared.dataTask(with: url) { (data, respone, error) in
            if error != nil {
                print("Error occured : \(error!.localizedDescription)}")
            } else {
                if let safeData = data {
                    self.parseJSON(safeData)
                }
            }
        }.resume()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func parseJSON(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CovidSummary.self, from: data)
            locationsData = decodedData.Countries
            worldWideData = [decodedData.Global]
        } catch {
            print(error.localizedDescription)
        }
        DispatchQueue.main.async {
            self.pullToRefresh.endRefreshing()
            self.feedbackGen.impactOccurred(intensity: 0.7)
            self.activityView.stopAnimating()
            self.tableView.reloadData()
            self.fadeView.removeFromSuperview()
        }
    }
    
    
    func isFiltering() -> Bool {
        return searchController.isActive &&  searchController.searchBar.text?.count != 0
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredLocations = locationsData.filter { $0.Country.lowercased().contains(searchText.lowercased())}
            tableView.reloadData()
        }
    }
    
    

}

//MARK: - Table View Delegates
extension HomeViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredLocations.count
        }
        return section == 0 ? worldWideData.count : locationsData.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            return nil
        }
        return section == 0 ? "World-Wide Cases" : "Cases by Country"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RowCell
        
        let index = indexPath.row
        let section = indexPath.section
        var location: Location!
        if isFiltering() {
            location = filteredLocations[index]
        }
        else if section == 1 {
            location = locationsData[index]
        }
        
        if section == 0 {
            let worldWide = worldWideData[0]
            cell.countryLabel.text = "Global 🌏"
            cell.infectedLabel.text = "👾 \(worldWide.TotalConfirmed / 1000)K "
            cell.recoveredLabel.text = "💚 \(worldWide.TotalRecovered / 1000)K "
            cell.deathsLabel.text = "💔 \(worldWide.TotalDeaths / 1000)K "
            
        }
        
        if let safeLocation = location {
            let infected = safeLocation.TotalConfirmed
            let recovered = safeLocation.TotalRecovered
            let deaths = safeLocation.TotalDeaths
            cell.countryLabel.text = safeLocation.Country + flag(country: safeLocation.CountryCode)
            cell.infectedLabel.text = "👾 \(infected) "
            cell.recoveredLabel.text = "💚 \(recovered) "
            cell.deathsLabel.text = "💔 \(deaths) "
        }
       
        cell.infectedLabel.layer.masksToBounds = true
        cell.recoveredLabel.layer.masksToBounds = true
        cell.deathsLabel.layer.masksToBounds = true
        
        
        cell.infectedLabel.layer.cornerRadius = 4.0
        cell.recoveredLabel.layer.cornerRadius = 4.0
        cell.deathsLabel.layer.cornerRadius = 4.0
        
        
        return cell
    }
    
    
    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }

}






//MARK: - Table Row View Cell
class RowCell: UITableViewCell {
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var infectedLabel: UILabel!
    @IBOutlet weak var recoveredLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
