//
//  StatsModel.swift
//  BasketballStats
//
//  Created by Larry N on 3/25/21.
//

import Foundation

struct StatsContainer: Decodable {
  let data: [GameStats]
}

struct GameStats: Decodable {
  var gamesPlayed: Int = 0
  var playerID: Int = 0
  var season: Int = 0
  var min: String = "0"
  var fgm: Double = 0
  var fga: Double = 0
  var fg3m: Double = 0
  var fg3a: Double = 0
  var ftm: Double = 0
  var fta: Double = 0
  var oreb: Double = 0
  var dreb: Double = 0
  var reb: Double = 0
  var ast: Double = 0
  var stl: Double = 0
  var blk: Double = 0
  var turnover: Double = 0
  var pf: Double = 0
  var pts: Double = 0
  var fgPct: Double = 0
  var fg3Pct: Double = 0
  var ftPct: Double = 0

  private enum CodingKeys: String, CodingKey {
    case gamesPlayed = "games_played"
    case playerID = "player_id"
    case season
    case min
    case fgm
    case fga
    case fg3m
    case fg3a
    case ftm
    case fta
    case oreb
    case dreb
    case reb
    case ast
    case stl
    case blk
    case turnover
    case pf
    case pts
    case fgPct = "fg_pct"
    case fg3Pct = "fg3_pct"
    case ftPct = "ft_pct"
  }
}

extension Double {
  var formattedPercent: String {
    String(format: "%.2f", self * 100)
  }
}
