//
//  MockService.swift
//  BasketballStats
//
//  Created by Larry N on 3/26/21.
//

import Foundation

enum MockModelType {
  case player
  case stats
}

struct MockService: ServiceProtocol {
  let model: MockModelType
  let completeWithFailure: Bool

  init(model: MockModelType, completeWithFailure: Bool = false) {
    self.model = model
    self.completeWithFailure = completeWithFailure
  }
    
  func getJSON<T>(url: URL, completion: @escaping (Result<T, APIError>) -> Void) where T : Decodable {
    
    guard completeWithFailure == false else {
      return completion(.failure(.error("Error getting mock JSON")))
    }
    
    if model == .player {
      let mockPlayerJSON = MockData().playerJSON.data(using: .utf8)!
      let playerContainer = try? JSONDecoder().decode(PlayerContainer.self, from: mockPlayerJSON)
      print("mock", playerContainer ?? [])
      completion(.success(playerContainer as! T))
    } else {
      let mockStatsJSON = MockData().statsJSON.data(using: .utf8)!
      let statsContainer = try? JSONDecoder().decode(StatsContainer.self, from: mockStatsJSON)
      print("mock", statsContainer ?? [])
      completion(.success(statsContainer as! T))
    }
  }
}

struct MockData {
  
  // LeBron James (id: 237) season stats
  let statsJSON = """
   {
     "data": [
       {
         "games_played":37,
         "player_id":237,
         "season":2018,
         "min":"34:46",
         "fgm":9.92,
         "fga":19.22,
         "fg3m":2.05,
         "fg3a":5.73,
         "ftm":5.08,
         "fta":7.54,
         "oreb":0.95,
         "dreb":7.59,
         "reb":8.54,
         "ast":7.38,
         "stl":1.32,
         "blk":0.65,
         "turnover":3.49,
         "pf":1.59,
         "pts":26.97,
         "fg_pct":0.516,
         "fg3_pct":0.358,
         "ft_pct":0.674
       }
     ]
   }
  """
  
  // LeBron James info
  let playerJSON = """
   {
     "data":[
       {
         "id":237,
         "first_name":"LeBron",
         "last_name":"James",
         "position":"F",
         "height_feet": 6,
         "height_inches": 8,
         "weight_pounds": 250,
         "team":{
           "id":14,
           "abbreviation":"LAL",
           "city":"Los Angeles",
           "conference":"West",
           "division":"Pacific",
           "full_name":"Los Angeles Lakers",
           "name":"Lakers"
         }
       }
    ]
   }
  """
}
