//
//  HomeView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/20/23.
//

import SwiftUI
import AptosKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var currentWalletBalance: Double = 0.0
    @State private var phrase: String = ""
    @State private var isShowingPopup: Bool = false
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Image("aptosLogo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 200)
                .padding(.horizontal)
                .padding(.top, 25)
            
            Text("Add Account")
                .font(.title)
                .padding(.top)
            
            Button {
                do {
                    try self.viewModel.createWallet()
                } catch {
                    print("ERROR - \(error)")
                }
            } label: {
                Text("Create Wallet")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
            .padding(.top)
            
            Button {
                do {
                    try self.viewModel.restoreWallet(phrase)
                    self.phrase = ""
                } catch {
                    self.phrase = ""
                }
            } label: {
                Text("Import Wallet")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
            .padding(.top)
            
            if !self.viewModel.wallets.isEmpty {
                Picker("Select A Wallet", selection: self.$viewModel.currentWallet) {
                    ForEach(self.viewModel.wallets, id: \.self) { wallet in
                        Text("\(wallet.account.address().description)")
                    }
                }
                .pickerStyle(.menu)
                .padding(.top, 40)
                .padding(.horizontal)
                
                Text("Current Wallet Balance: \(self.currentWalletBalance) APT")
                    .padding(.top)
            } else {
                Text("Generate or Import a wallet")
                    .padding(.top, 40)
            }
            
            TextField("Enter your seed phrase (separate words with spaces)", text: $phrase, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.top, 40)
            
            Spacer()
        }
        .task {
            Task {
                do {
                    self.currentWalletBalance = try await self.viewModel.getCurrentWalletBalance()
                } catch {
                    print("ERROR - \(error)")
                }
            }
        }
        .onChange(of: self.viewModel.currentWallet) { newValue in
            Task {
                do {
                    self.currentWalletBalance = try await self.viewModel.getCurrentWalletBalance()
                } catch {
                    print("ERROR - \(error)")
                }
            }
        }
        .alert("Seed Phrase is Invalid, please try again.", isPresented: $isShowingPopup) {
            Button("OK", role: .cancel) {
                self.isShowingPopup = false
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    struct WrapperView: View {
        @State var viewModel: HomeViewModel
        
        init() {
            do {
                self.viewModel = try HomeViewModel()
            } catch {
                fatalError()
            }
        }
        
        var body: some View {
            HomeView(viewModel: viewModel)
        }
    }
    
    static var previews: some View {
        WrapperView()
    }
}

