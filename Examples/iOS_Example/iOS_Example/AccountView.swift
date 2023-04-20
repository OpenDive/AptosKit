//
//  AccountView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/20/23.
//

import SwiftUI
import AptosKit
import UniformTypeIdentifiers

struct AccountView: View {
    @State private var isAirdropping: Bool = false
    @State private var isShowingAlert: Bool = false
    
    @Binding var currentWallet: Wallet
    
    var body: some View {
        VStack {
            Image("aptosLogo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 200)
                .padding(.horizontal)
                .padding(.top, 25)
            
            Text("Account Settings")
                .font(.title)
                .padding(.top)
            
            Button {
                UIPasteboard.general.setValue(
                    self.currentWallet.passphrase.joined(separator: " "),
                    forPasteboardType: UTType.plainText.identifier
                )
            } label: {
                Text("Copy Mnemonic Words")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
            .padding(.top)
            
            Button {
                UIPasteboard.general.setValue(
                    self.currentWallet.account.privateKey.key.hexEncodedString(),
                    forPasteboardType: UTType.plainText.identifier
                )
            } label: {
                Text("Copy Private Key")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
            .padding(.top)
            
            Button {
                Task {
                    do {
                        self.isAirdropping = true
                        let restClient = try await RestClient(baseUrl: "https://fullnode.devnet.aptoslabs.com/v1")
                        let faucetClient = FaucetClient(baseUrl: "https://faucet.devnet.aptoslabs.com", restClient: restClient)
                        
                        try await faucetClient.fundAccount(currentWallet.account.address().description, 1)
                        self.isShowingAlert = true
                    } catch {
                        print("ERROR - \(error)")
                    }
                }
            } label: {
                if isAirdropping {
                    ProgressView()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                } else {
                    Text("Airdrop 1 APT")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                }
            }
            .padding(.top)
        }
        .alert("Successfully Airdropped 1 APT", isPresented: $isShowingAlert) {
            Button("OK", role: .cancel) {
                self.isAirdropping = false
                self.isShowingAlert = false
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    struct WrapperView: View {
        @State private var currentWallet: Wallet
        
        init() {
            do {
                let newWallet = try Wallet()
                self.currentWallet = newWallet
            } catch {
                print("ERROR - \(error)")
                fatalError()
            }
        }
        
        var body: some View {
            AccountView(currentWallet: $currentWallet)
        }
    }
    
    static var previews: some View {
        WrapperView()
    }
}
