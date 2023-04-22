//
//  ContentView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/18/23.
//

import SwiftUI
import AptosKit

struct ContentView: View {
    @State var viewModel: HomeViewModel
    
    init() {
        do {
            self.viewModel = try HomeViewModel()
        } catch {
            fatalError()
        }
    }
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Accounts", systemImage: "person.fill.badge.plus")
                }
            
            AccountView(viewModel: viewModel)
                .tabItem {
                    Label("Account Settings", systemImage: "person")
                }
            
            MintNFTView(viewModel: viewModel)
                .tabItem {
                    Label("NFT", systemImage: "photo.artframe")
                }
            
            CreateCollectionView(viewModel: viewModel)
                .tabItem {
                    Label("Collection", systemImage: "shippingbox.fill")
                }
            
            TransferView(viewModel: viewModel)
                .tabItem {
                    Label("Transaction", systemImage: "bitcoinsign.circle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
