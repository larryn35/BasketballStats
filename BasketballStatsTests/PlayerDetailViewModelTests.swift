//
//  PlayerDetailViewModelTests.swift
//  BasketballStatsTests
//
//  Created by Larry N on 3/26/21.
//

import XCTest
@testable import BasketballStats

class PlayerDetailViewModelTests: XCTestCase {

  // Test generated URL for fetching stats
  func testPlayerListViewModelURL() {
    let viewModel = PlayerDetailViewModel(
      playerID: "237", apiService: MockService(model: .stats)
    )
    
    XCTAssertEqual(viewModel.statsURL.string, "https://www.balldontlie.io/api/v1/season_averages?player_ids%5B%5D=237", "Incorrect URL for stats data")
  }
  
  // Test if stats are being fetched and loaded
  func testPlayerListViewModelFetchPlayers() {
    let viewModel = PlayerDetailViewModel(
      playerID: "237", apiService: MockService(model: .stats)
    )
    
    // Stats before fetching and loading
    XCTAssertEqual(viewModel.stats.gamesPlayed, 0, "Default stat should be 0 before fetch")
    
    // Mock service should use test JSON for stats (Lebron playerID = 237)
    viewModel.fetchStats()
    
    // Stats after fetching and loading
    XCTAssertEqual(viewModel.stats.gamesPlayed, 37, "Could not load players into view model")
    XCTAssertEqual(viewModel.stats.fgPct, 0.516, "Could not load players into view model")

  }
  
  // Test fetchStats error handling
  func testGetPlayerResultsInFailure() {
    let mockService = MockService(model: .stats, completeWithFailure: true)
    let viewModel = PlayerListViewModel(apiService: mockService)
    
    // showFetchErrorMessage before fetch
    XCTAssertFalse(viewModel.showFetchErrorMessage)
    
    viewModel.fetchPlayers()
    
    // showFetchErrorMessage after fetch failure
    XCTAssertTrue(viewModel.showFetchErrorMessage)
  }
}
