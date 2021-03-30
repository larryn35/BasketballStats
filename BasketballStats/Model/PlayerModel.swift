//
//  PlayerModel.swift
//  BasketballStats
//
//  Created by Larry N on 3/25/21.
//

import Foundation

struct PlayerContainer: Decodable, Hashable {
  let data: [PlayerInfo]
}

struct PlayerInfo: Decodable, Hashable {
  let id: Int
  let firstName: String
  let lastName: String
  let position: String
  let team: Team

  private enum CodingKeys: String, CodingKey {
    case id
    case firstName = "first_name"
    case lastName = "last_name"
    case position
    case team
  }
}

extension PlayerInfo {
  var stringID: String {
    String(id)
  }
  
  var fullName: String {
    firstName + " " + lastName
  }
  
  var infoText: String {
    fullName + " · " + team.abbreviation
  }
}

struct Team: Decodable, Hashable {
  let id: Int
  let abbreviation: String
  let city: String
  let conference: String
  let division: String
  let fullName: String
  let name: String

  private enum CodingKeys: String, CodingKey {
    case id
    case abbreviation
    case city
    case conference
    case division
    case fullName = "full_name"
    case name
  }
}
