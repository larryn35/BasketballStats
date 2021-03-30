
![](https://github.com/larryn35/BasketballStats/blob/main/ReadMeResources/Screenshots.png?raw=true)

## About the app

A simple, iOS app that allows you to find player stats for the current NBA season. Built with SwiftUI using MVVM and the  [balldontlie API](https://www.balldontlie.io/). My goals for this app were to get familiar with Combine and unit testing, as well as practice making network requests and retrieving data from a web API.

### Networking

Player and stats data are obtained from the [balldontlie API](https://www.balldontlie.io/), a really awesome, free API that doesn't require an email or API key to access. Besides player and current season stats, the API also contains data for games and seasons all the way back to 1979. 

The documentation provides examples of the JSON returned following a request, which I used to construct my models with the help of [Ducky - Model Editor](https://apps.apple.com/us/app/ducky-model-editor/id1525505933).

```swift
// Structure of JSON returned from "https://www.balldontlie.io/api/v1/players"

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
  }
```



```swift
// Model

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
```

<br>

[James Haville's tutorial](https://www.youtube.com/watch?v=olZra64Wz9E) on using Combine to make a network request introduced me to `URLComponents`. I found this method to be a cleaner and more structured way to construct URLs, especially when it comes to more complex ones with multiple query parameters, compared to simply using string concatenation.

```swift
final class PlayerDetailViewModel: ObservableObject {
  @Published var nameSearch = ""
  
  // [...]
  
  var playerURL: URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "www.balldontlie.io"
    components.path = "/api/v1/players
    components.queryItems = [
      URLQueryItem(name: "per_page", value: "100"),
      URLQueryItem(name: "search", value: nameSearch)
    ]
    
    return components 
  }

  // Example - With nameSearch = "James":
  print(playerURL.url) 
  // Prints: https://www.balldontlie.io/api/v1/players?per_page=100&search=James
}
```

A topic to explore and perhaps implement in future projects are [endpoints](https://www.swiftbysundell.com/articles/constructing-urls-in-swift/). But with my models and URLs set, I now just needed to make the network request.

<br>

### Combine

Another resource that helped me understand how to use Combine to make API calls, was a [video series by Stewart Lynch](https://www.youtube.com/watch?v=oC8GQIAgYZ4). His project utilizes an `APIServiceCombine` class, which has the benefit of being reusable in this and other apps, as well as make testing easier later on. 

Within this class, we have a method `getJSON` that calls `dataTaskPublisher`.

```swift
final class APIServiceCombine: ServiceProtocol {
  var cancellables = Set<AnyCancellable>()

  func getJSON<T: Decodable>(url: URL, completion: @escaping (Result<T,APIError>) -> Void) {
    let request = URLRequest(url: url)

    URLSession.shared.dataTaskPublisher(for: request)
      .map { $0.data }
      .decode(type: T.self, decoder: JSONDecoder())
      .receive(on: DispatchQueue.main)
      .sink { taskCompletion in
        switch taskCompletion {
        case .finished:
          return
        case .failure(let decodingError):
          completion(.failure(.error("Error decoding data: \(decodingError.localizedDescription)")))
        }
      } receiveValue: { decodedData in
        completion(.success(decodedData))
      }
      .store(in: &cancellables)
  }
}
```

This Combine publisher performs the task of fetching data from the URL request and publishes either:

- a tuple containing the raw data and `URLResponse` if the task was successful 
- an error in the case of a failed task 

We use operators to separate the data from the tuple, decode it, and pass the data (or error if the task failed to complete) to the sink to make the completion call. 

Back in `PlayerListViewModel`, I can use the `getJSON` method to retrieve and update the list of players - which will in turn update the `PlayerList` view through the @Published property wrapper.

```swift
final class PlayerListViewModel: ObservableObject {
  @Published var players = [PlayerInfo]()

  // [...]
  
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
}
```

<br>

Another use for Combine that I often came across is field validation. There isn't really a point to include this in the app, but I decided to throw it in there for practice anyway. I set the minimum character limit for the player search to two, the shortest length for a player's name that I could think of (ex. Mo Bamba, CJ McCollum). The search button is disabled until the limit is met, and a minimum character limit message is displayed when a user starts typing and disappears when they reach that threshold (basically when there's one character in the search). I followed [BeyondOnesAndZeros' video](https://www.youtube.com/watch?v=YJRApch2cc4) for setting up this feature.

```swift
final class PlayerListViewModel: ObservableObject {
  @Published var nameSearch = ""
  @Published var isSearchValid = false
  @Published var characterLimitMessage = ""
  
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
      .assign(to: \.isSearchValid, on: self)
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
      .assign(to: \.characterLimitMessage, on: self)
      .store(in: &cancellables)
  }
  
  // [...]
}
```
<br>

![](https://github.com/larryn35/BasketballStats/blob/main/ReadMeResources/LimitMessage.jpeg?raw=true)

<br>

### Unit testing

Both `PlayerListViewModel` and `PlayerDetailViewModel` utilize the `APIServiceCombine` in their respective fetch methods. Instinctively, my thought process was to create an instance of the `APIServiceCombine` class in each view model and then call `getJSON` within the fetch methods. 

```swift
final class PlayerListViewModel: ObservableObject {
  private let apiService = APIServiceCombine()
  @Published var players = [PlayerInfo]()
  @Published var showFetchErrorMessage = false
  
  func fetchPlayers() {
  /* 
    apiService.getJSON() {
   		if success, players = fetched data
    	otherwise, showFetchErrorMessage = true
  	}		
  */
  }
}
```

Let's say I run the app on a simulator or my device and the method works as expected. Every time I perform the search, my view refreshes with a list of the results. But what if I want to make sure the failure case is handled properly? In this instance, I might be able to get away with temporarily changing the `getJson` method within `APIServiceCombine` to always call the failure case or perform the search with wifi disabled. In more complex apps, however, these workarounds may cause errors elsewhere. The problem here, which happens often in my previous projects, is that the view model is dependent on an object, such as a database or network, that I have little to no control over. Testing various outcomes becomes challenging when I can't get there.

This [article by Liem Vo](https://medium.com/@liemvo/swiftui-mvvm-and-mock-service-unit-testing-13ed2fa167ec) was a tremendous guide for refactoring my code and setting up my tests. Decoupling my `PlayerListViewModel` and `APIServiceCombine` starts with creating a `ServiceProtocol`.

```swift
protocol ServiceProtocol {
  func getJSON<T: Decodable>(url: URL, completion: @escaping (Result<T,APIError>) -> Void)
}
```

The `ServiceProtocol` contains the same `getJSON` signature as `APIServiceCombine`. As shown earlier, we'll make `APIServiceCombine` conform to the protocol. Now we can head back to `PlayerListViewModel`, where we'll swap out `APIServicCombine` for `ServiceProtocol` and inject `apiService` into the view model with `APIServiceCombine` as a default parameter using an initializer method.

```swift
final class PlayerListViewModel: ObservableObject {
  private let apiService: ServiceProtocol

  init(apiService: ServiceProtocol = APIServiceCombine()) {
    self.apiService = apiService
  }
  
  func fetchPlayers() {
  // let players = apiService.getJSON()...
  }
}
```

Next, we'll create a mock API service that conforms to the `ServiceProtocol`and behaves similarly to `APIServiceCombine`.

```swift
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
      let mockPlayerJSON = MockData()
      	.playerJSON // Same JSON from the Networking section above
      	.data(using: .utf8)! 
      let playerContainer = try? JSONDecoder().decode(PlayerContainer.self, from: mockPlayerJSON)
      completion(.success(playerContainer as! T))
    } else {
      let mockStatsJSON = MockData()
      	.statsJSON  // Sample JSON for season stats from the API documentation
      	.data(using: .utf8)!
      let statsContainer = try? JSONDecoder().decode(StatsContainer.self, from: mockStatsJSON)
      completion(.success(statsContainer as! T))
    }
  }
}
```

Finally, we can inject our own mock API service in our tests and verify the properties in the view model when the `getJSON` method completes with a success or failure case.

```swift
class PlayerListViewModelTests: XCTestCase { 
  // [...]
  
	// Test if players are being fetched and loaded
  func testPlayerListViewModelFetchPlayers() throws {
    let mockService = MockService(model: .player)
    let viewModel = PlayerListViewModel(apiService: mockService)
    
    // Players before fetching and loading
    XCTAssertEqual(viewModel.players.count, 0, "Players list should be empty before fetch")
    
    // Mock service should use test JSON with single player (Lebron)
    viewModel.fetchPlayers()
    
    // Players before fetching and loading
    XCTAssertEqual(viewModel.players.count, 1, "Could not load players into view model")
    
    let player = viewModel.players.first!
    XCTAssertEqual(player.firstName, "LeBron", "Player (Lebron) not loaded correctly")
  }
  
    // [...]
}
```



```swift
  // Test getPlayer error handling
  func testGetPlayerResultsInFailure() {
    let mockService = MockService(model: .player, completeWithFailure: true)
    let viewModel = PlayerListViewModel(apiService: mockService)
    
    // showFetchErrorMessage before fetch
    XCTAssertFalse(viewModel.showFetchErrorMessage)
    
    // MockService should complete with failure
    viewModel.fetchPlayers()
    
    // showFetchErrorMessage after fetch failure
    XCTAssertTrue(viewModel.showFetchErrorMessage)
  }
```

<br>

![](https://github.com/larryn35/BasketballStats/blob/main/ReadMeResources/UnitTestResults.png?raw=true)

<br>


## What's next

With Combine, I found my code to be more readable and the error and optional handling for networking to be quite useful. This app just scratches the surface of what the framework is capable of, and I plan to learn more about Combine and the different ways I can incorporate it into future apps.

Unit testing was managable in this app because of its simplicity, but it was helpful in setting my mindset on how to write more structured, testable code going forward. Continuing to better understand MVVM and concepts, such as generics, dependency-injection, and SOLID principles, will hopefully allow me to incorporate tests in more complex apps later on.

<br>

## Other resources

### Network Requests

- [Antoine van der Lee - URLs in Swift: Common scenarios explained in-depth](https://www.avanderlee.com/swift/url-components/)
- [Bart Jacobs - Working With URLComponents In Swift](https://cocoacasts.com/working-with-nsurlcomponents-in-swift)
- [Matteo Manferdini - Network Requests and REST APIs in iOS with Swift (Protocol-Oriented Approach)](https://matteomanferdini.com/network-requests-rest-apis-ios-swift/)

### Combine

- [Apple Developer Documentation - Processing URL Session Data Task Results with Combine](https://developer.apple.com/documentation/foundation/urlsession/processing_url_session_data_task_results_with_combine)
- [Melvin John - Network Request With Swift Combine](https://09mejohn.medium.com/network-request-with-swift-combine-4ae9e5cc751f)

### Unit Testing

- [James Haville - Swift Unit Testing A ViewModel Basics: Mock & Protoco (Youtube)](https://www.youtube.com/watch?v=kHtEtAP4DNA)
- [Jeremiah Jessel - Mocking With Protocols in Swift](https://www.bignerdranch.com/blog/mocking-with-protocols-in-swift/)


