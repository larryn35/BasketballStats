//
//  ContentView.swift
//  BasketballStats
//
//  Created by Larry N on 3/25/21.
//

import SwiftUI

struct PlayerList: View {
  @StateObject private var viewModel = PlayerListViewModel()
  
  var body: some View {
    NavigationView {
      VStack {
        HStack {
          TextField("Search for player", text: $viewModel.nameSearch)
          Button {
            viewModel.clearSearchButtonTapped()
          } label: {
            Image(systemName: "xmark.circle.fill")
          }
        }
        .padding()
        .background(Color.secondary.opacity(0.2))
        .clipShape(Capsule())
        .padding(.horizontal)
        
        Text(viewModel.characterLimitMessage).font(.caption)
        
        Button {
          viewModel.searchButtonTapped()
          hideKeyboard()
        } label: {
          Text("search")
            .padding()
            .frame(minWidth: .zero, maxWidth: .infinity)
            .foregroundColor(viewModel.searchTextColor)
            .background(viewModel.searchButtonColor)
            .clipShape(Capsule())
            .padding()
        }
        .disabled(!viewModel.isSearchValid)

        List(viewModel.players.filtered(viewModel.nameSearch), id: \.self) { player in
          NavigationLink(destination: PlayerDetail(player: player)) {
            Text(player.infoText)
          }
        }
      }
      .navigationTitle("NBA Season Stats")
      .navigationBarItems(
        trailing:
          Button("Clear List") {
            viewModel.clearListButtonTapped()
          }
      )
    }
  }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    PlayerList()
  }
}
