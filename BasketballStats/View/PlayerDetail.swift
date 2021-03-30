//
//  PlayerDetail.swift
//  BasketballStats
//
//  Created by Larry N on 3/25/21.
//

import SwiftUI

struct PlayerDetail: View {
  @ObservedObject var viewModel: PlayerDetailViewModel
  let player: PlayerInfo
  
  init(player: PlayerInfo) {
    self.player = player
    viewModel = PlayerDetailViewModel(playerID: player.stringID)
  }
  
    var body: some View {
      List {
        Section(header: Text("Info")) {
          Text("\(player.fullName) · \(player.position)")
          Text(player.team.fullName)
        }
        
        Section(header: Text("\(viewModel.season) Season Stats")) {
          Text(viewModel.points)
          Text(viewModel.assists)
          Text(viewModel.rebounds)
          Text(viewModel.fieldGoalPercent)
          Text(viewModel.threePtPercent)
          Text(viewModel.blocks)
          Text(viewModel.steals)
          Text(viewModel.turnovers)
        }
      }
      .onAppear {
        viewModel.fetchStats()
      }
    }
}

struct PlayerDetail_Previews: PreviewProvider {
  static var previews: some View {
    PlayerDetail(player: PlayerInfo(id: 237,
                                    firstName: "Lebron",
                                    lastName: "James",
                                    position: "SF",
                                    team:
                                      Team(id: 5,
                                           abbreviation: "LAL",
                                           city: "LA",
                                           conference: "West",
                                           division: "Pacific",
                                           fullName: "LAL",
                                           name: "Lakers")))
  }
}
