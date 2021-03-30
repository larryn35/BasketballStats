//
//  PlayerListViewModel.swift
//  BasketballStats
//
//  Created by Larry N on 3/25/21.
//

import SwiftUI
import Combine

final class PlayerListViewModel: ObservableObject {
  private let apiService: ServiceProtocol
  @Published var players = [PlayerInfo]()
  @Published var nameSearch = ""
  @Published var isSearchValid = false
  @Published var characterLimitMessage = ""
  @Published var showFetchErrorMessage = false // Display alert/error message in PlayerList view if fetch fails (not done in this app)
  
  private var cancellables = Set<AnyCancellable>()
  
  // Checks if search contains at least 2 characters while user is typing
  private var isSearchValidPublisher: AnyPublisher<Bool, Never> {
    $nameSearch
      .debounce(for: 0.3, scheduler: RunLoop.main) // Adds delay for execution
      .removeDuplicates()
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 } // Search must be at least 2 characters long
      .eraseToAnyPublisher()
  }
  
  init(apiService: ServiceProtocol = APIServiceCombine()) {
    self.apiService = apiService
    
    // Enable/disable button based whether search is valid
    isSearchValidPublisher
      .receive(on: RunLoop.main)
      .assign(to: \.isSearchValid, on: self) // sets isSearchValid as subscriber
      .store(in: &cancellables)
    
    // Display search limit message if search has 1 character
    isSearchValidPublisher
      .receive(on: RunLoop.main)
      .map { bool in
        if bool || self.nameSearch.count == 0 {
          return ""
        } else {
          return "Search must contain at least 2 characters"
        }
      }
      .assign(to: \.characterLimitMessage, on: self) // sets characterLimitMessage as subscriber
      .store(in: &cancellables)
  }
  
  var searchButtonColor: Color {
    isSearchValid ? .blue : Color.secondary.opacity(0.2)
  }
  
  var searchTextColor: Color {
    isSearchValid ? .white : Color.secondary
  }
  
  func searchButtonTapped() {
    fetchPlayers()
    nameSearch = ""
  }
  
  func clearListButtonTapped() {
    nameSearch = ""
    players = [PlayerInfo]()
  }
  
  func clearSearchButtonTapped() {
    nameSearch = ""
  }
  
  var playerURL: URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "www.balldontlie.io"
    components.path = "/api/v1/players"
    components.queryItems = [
      URLQueryItem(name: "per_page", value: "100"),
      URLQueryItem(name: "search", value: nameSearch)
    ]
    
    return components
  }
  
  func fetchPlayers() {
    guard let url = playerURL.url else {
      print("error getting url")
      return
    }
        
    apiService.getJSON(url: url) { [weak self] (result: Result<PlayerContainer, APIError>) in
      switch result {
      case .success(let fetchedPlayers):
        // Most retired players do not have a position listed, filter active players
        self?.players = fetchedPlayers.data.filter { !$0.position.isEmpty }
        
        // No matches found
        if fetchedPlayers.data.isEmpty {
          self?.characterLimitMessage = "No results found"
        }
      
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

extension Array where Element == PlayerInfo {
  func filtered(_ name: String) -> [PlayerInfo] {
    if name.isEmpty {
      return self
    } else {
      return self.filter { $0.fullName.lowercased().contains(name.lowercased()) }
    }
  }
}
