//
//  PlayerListViewModelTests.swift
//  BasketballStatsTests
//
//  Created by Larry N on 3/26/21.
//

import XCTest
@testable import BasketballStats

class PlayerListViewModelTests: XCTestCase {
  
  // Test generated URL for fetching players
  func testPlayerListViewModelURL() {
    let viewModel = PlayerListViewModel(
      apiService: MockService(model: .player)
    )
    
    XCTAssertEqual(viewModel.playerURL.string, "https://www.balldontlie.io/api/v1/players?per_page=100", "Incorrect URL for player data")
  }
  
  // Test generated URL for fetching players that matches user's search
  func testPlayerListViewModelURLWithNameSearch() {
    let viewModel = PlayerListViewModel(apiService: MockService(model: .player))
    
    viewModel.nameSearch = "LeBron"
    
    XCTAssertEqual(viewModel.playerURL.string, "https://www.balldontlie.io/api/v1/players?per_page=100&search=LeBron", "Incorrect URL when searching LeBron")
  }
  
  // Test if players are being fetched and loaded
  func testPlayerListViewModelFetchPlayers() {
    let mockService = MockService(model: .player)
    let viewModel = PlayerListViewModel(apiService: mockService)
    
    // Players before fetching and loading
    XCTAssertEqual(viewModel.players.count, 0, "Players list should be empty before fetch")
    
    // Mock service should use test JSON with single player (LeBron)
    viewModel.fetchPlayers()
    
    // Players before fetching and loading
    XCTAssertEqual(viewModel.players.count, 1, "Could not load players into view model")
    
    let player = viewModel.players.first!
    XCTAssertEqual(player.firstName, "LeBron", "Player (LeBron) not loaded correctly")
  }
  
  // Test clear list function
  func testPlayerListViewModelClearList() {
    let mockService = MockService(model: .player)
    let viewModel = PlayerListViewModel(apiService: mockService)
    
    // Load players (LeBron) and search text (LeBron)
    viewModel.fetchPlayers()
    viewModel.nameSearch = "LeBron"
    
    // Check players array and search text before clear button
    XCTAssertTrue(!viewModel.players.isEmpty, "Could not load players into view model")
    XCTAssertEqual(viewModel.nameSearch, "LeBron", "Error setting nameSearch")
    
    viewModel.clearListButtonTapped()
    
    // Check players array and search text after clear button
    XCTAssertTrue(viewModel.players.isEmpty, "Players list not empty after pressing clear list button")
    XCTAssertEqual(viewModel.nameSearch, "", "Name search field not cleared after pressing clear list button")
  }
  
  // Test getPlayer error handling
  func testGetPlayerResultsInFailure() {
    let mockService = MockService(model: .player, completeWithFailure: true)
    let viewModel = PlayerListViewModel(apiService: mockService)
    
    // showFetchErrorMessage before fetch
    XCTAssertFalse(viewModel.showFetchErrorMessage)
    
    viewModel.fetchPlayers()
    
    // showFetchErrorMessage after fetch failure
    XCTAssertTrue(viewModel.showFetchErrorMessage)
  }
}
