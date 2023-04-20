//
//  ContentView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/18/23.
//

import SwiftUI
import AptosKit

struct ContentView: View {
    @State private var wallets: [Wallet] = []
    @State private var currentWallet: Wallet
    
    init() {
        do {
            let newWallet = try Wallet()
            self.currentWallet = newWallet
            self.wallets.append(newWallet)
        } catch {
            print("ERROR - \(error)")
            fatalError()
        }
    }
    
    var body: some View {
        TabView {
            HomeView(currentWallet: $currentWallet, wallets: $wallets)
                .tabItem {
                    Label("Accounts", systemImage: "person")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
