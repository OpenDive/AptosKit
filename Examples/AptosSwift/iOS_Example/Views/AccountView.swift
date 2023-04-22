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
    @ObservedObject var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    @State private var isAirdropping: Bool = false
    @State private var isShowingAlert: Bool = false
    
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
                    self.viewModel.currentWallet.mnemonic.phrase.joined(separator: " "),
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
                    self.viewModel.getCurrentWalletAddress(),
                    forPasteboardType: UTType.plainText.identifier
                )
            } label: {
                Text("Copy Address")
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
                    self.viewModel.currentWallet.account.privateKey.key.hexEncodedString(),
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
                        try await self.viewModel.airdropToCurrentWallet()
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
            
            Spacer()
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
        @State var viewModel: HomeViewModel
        
        init() {
            do {
                self.viewModel = try HomeViewModel()
            } catch {
                fatalError()
            }
        }
        
        var body: some View {
            AccountView(viewModel: viewModel)
        }
    }
    
    static var previews: some View {
        WrapperView()
    }
}
