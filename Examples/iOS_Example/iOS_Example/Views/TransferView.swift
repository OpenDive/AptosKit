//
//  TransferView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/21/23.
//

import SwiftUI

struct TransferView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var receiverAddress: String = ""
    @State private var tokenAmount: String = "0.2"
    
    @State private var message: String = ""
    @State private var isShowingPopup: Bool = false
    @State private var isTransfering: Bool = false
    
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
            
            Text("Send Transaction")
                .font(.title)
                .padding(.top)
            
            VStack {
                ZStack {
                    Text("Sender Address: ") +
                    Text("\(self.viewModel.getCurrentWalletAddress())").bold()
                }
                .padding()
                
                TextField("Receiver Address", text: $receiverAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                
                TextField("Token Amount (APT)", text: $tokenAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
            }
            
            Button {
                Task {
                    do {
                        self.isTransfering = true
                        guard let amountDouble = Double(tokenAmount) else {
                            self.message = "Please use a valid Double for royalty points and / or supply number."
                            self.isShowingPopup = true
                            return
                        }
                        let response = try await self.viewModel.createTransaction(receiverAddress, amountDouble)
                        if !response.contains("0x") {
                            self.message = "Something went wrong: \(response)"
                        } else {
                            self.message = "Transaction successfully submitted with hash: \(response)"
                        }
                        self.isShowingPopup = true
                    } catch {
                        self.message = "Something went wrong: \(error.localizedDescription)"
                        self.isShowingPopup = true
                    }
                }
            } label: {
                if isTransfering {
                    ProgressView()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                } else {
                    Text("Create Collection")
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
        .alert("\(message)", isPresented: $isShowingPopup) {
            Button("OK", role: .cancel) {
                self.isShowingPopup = false
                self.message = ""
                self.isTransfering = false
            }
        }
    }
}

struct TransferView_Previews: PreviewProvider {
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
            TransferView(viewModel: viewModel)
        }
    }
    
    static var previews: some View {
        WrapperView()
    }
}
