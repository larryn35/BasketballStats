//
//  ModelTests.swift
//  BasketballStatsTests
//
//  Created by Larry N on 3/25/21.
//

import XCTest
@testable import BasketballStats

class ModelTests: XCTestCase {

  func testBlankStats() {
    let stats = GameStats()
    XCTAssertEqual(stats.ast, 0, "Default stat did not return zero")
  }
  
  func testParsingJSONIsWorkingForPlayer() throws {
    let mockPlayerJSON = MockData().playerJSON.data(using: .utf8)!
    
    let playerContainer = try JSONDecoder().decode(PlayerContainer.self, from: mockPlayerJSON)
    XCTAssertNotNil(playerContainer, "PlayerContainer returned nil")
    
    let player = playerContainer.data.first!
    XCTAssertEqual(player.firstName, "LeBron", "Parsed result did not return Lebron for first name")
    XCTAssertFalse(player.team.abbreviation == "LAC", "Parsed result returned LAC for team when expecting LAL")
  }
  
  func testParsingJSONIsWorkingForStats() throws {
    let mockStatsJSON = MockData().statsJSON.data(using: .utf8)!
    
    let statsContainer = try JSONDecoder().decode(StatsContainer.self, from: mockStatsJSON)
    XCTAssertNotNil(statsContainer)
    
    let stats = statsContainer.data.first!
    XCTAssertEqual(stats.gamesPlayed, 37, "Parsed results did not return 37 for games played")
    XCTAssertTrue(stats.season == 2018, "Parsed results did not return 2018 for season")
  }
}
