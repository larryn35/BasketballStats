//
//  PlayerDetailViewModel.swift
//  BasketballStats
//
//  Created by Larry N on 3/25/21.
//

import Foundation

final class PlayerDetailViewModel: ObservableObject {
  private let apiService: ServiceProtocol
  @Published var stats = GameStats()
  @Published var nameSearch = ""
  @Published var showFetchErrorMessage = false // Display alert/error message in PlayerDetail view if fetch fails (not done in this app)
  
  let playerID: String
  
  init(playerID: String, apiService: ServiceProtocol = APIServiceCombine()) {
    self.playerID = playerID
    self.apiService = apiService
  }
  
  var season: String {
    stats.season == 0 ? "Current" : "\(stats.season) - \(stats.season + 1)"
  }
  
  var fieldGoalPercent: String {
    "FG%: \(stats.fgPct.formattedPercent)%"
  }
  
  var points: String {
    "PPG: \(stats.pts)"
  }
  
  var rebounds: String {
    "RPG: \(stats.reb)"
  }
  
  var assists: String {
    "APG: \(stats.ast)"
  }
  
  var threePtPercent: String {
    "3P%: \(stats.fg3Pct.formattedPercent)%"
  }
  
  var freeThrowPercent: String {
    "FT%: \(stats.ftPct)"
  }
  
  var steals: String {
    "STL: \(stats.stl)"
  }
  
  var blocks: String {
    "BLK: \(stats.blk)"
  }
  
  var turnovers: String {
    "TO: \(stats.turnover)"
  }
  
  var statsURL: URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "www.balldontlie.io"
    components.path = "/api/v1/season_averages"
    components.queryItems = [
      URLQueryItem(name: "player_ids[]", value: playerID)
    ]
    return components
  }
  
  
  func fetchStats() {
    guard let url = statsURL.url else {
      print("error getting url")
      return
    }

    apiService.getJSON(url: url) { [weak self] (result: Result<StatsContainer, APIError>) in
      switch result {
      case .success(let fetchedStats):
        guard let stats = fetchedStats.data.first else {
          print("fetched stats empty")
          return
        }
        self?.stats = stats
        
      case .failure(let apiError):
        switch apiError {
        case .error(let errorString):
          print(errorString)
          self?.showFetchErrorMessage = true
        }
      }
    }
  }
}
