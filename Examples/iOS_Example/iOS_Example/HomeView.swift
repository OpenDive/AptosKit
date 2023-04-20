//
//  HomeView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/20/23.
//

import SwiftUI
import AptosKit

struct HomeView: View {
    @State private var openFile: Bool = false
    
    @Binding var currentWallet: Wallet
    @Binding var wallets: [Wallet]
    
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
                    wallets.append(try Wallet())
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
                self.openFile.toggle()
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
            
            if !self.wallets.isEmpty {
                Picker("Select a Wallet", selection: $currentWallet) {
                    ForEach(wallets, id: \.self) { wallet in
                        Text("0x\(wallet.account.privateKey.key.hexEncodedString())")
                    }
                }
                    .pickerStyle(.menu)
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                Text("Current Wallet Passphrase: \(currentWallet.passphrase.joined(separator: ", "))")
                    .padding(.horizontal)
                    .padding(.top)
            } else {
                Text("Generate or Import a wallet")
                    .padding(.top, 40)
            }
            
            Spacer()
        }
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.json]) { result in
            do {
                let fileUrl = try result.get()
                let account = try Account.load(fileUrl.relativePath)
                self.wallets.append(try Wallet(account: account))
            } catch {
                print("ERROR - \(error)")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    struct WrapperView: View {
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
            HomeView(currentWallet: $currentWallet, wallets: $wallets)
        }
    }
    
    static var previews: some View {
        WrapperView()
    }
}

