//
//  MintNFTView.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import SwiftUI

struct MintNFTView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var collectionName: String = "AptosTestingCollection"
    @State private var tokenName: String = "AptosTestingCollectionNFT"
    @State private var tokenDescription: String = "AptosTestingCollection"
    @State private var supply: String = "100"
    @State private var tokenURI: String = "https://aptos.dev/img/aptos_word_dark.svg"
    @State private var royalty: String = "0"
    
    @State private var message: String = ""
    @State private var isShowingPopup: Bool = false
    @State private var isMintingNft: Bool = false
    
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
            
            Text("Create an NFT")
                .font(.title)
                .padding(.top)
            
            VStack {
                TextField("Collection Name", text: $collectionName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                
                TextField("Token Name", text: $tokenName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                
                TextField("Token Description", text: $tokenDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                
                TextField("Supply (Int)", text: $supply)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                
                TextField("Token URI", text: $tokenURI)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                
                TextField("Royalty Points Per Million (Int)", text: $royalty)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top, 10)
                    .padding(.horizontal)
            }
            
            Button {
                Task {
                    do {
                        self.isMintingNft = true
                        guard let supplyInt = Int(supply), let royaltyInt = Int(royalty) else {
                            self.message = "Please use a valid Integer for royalty points and / or supply number."
                            self.isShowingPopup = true
                            return
                        }
                        let response = try await self.viewModel.createNft(collectionName, tokenName, tokenDescription, supplyInt, tokenURI, royaltyInt)
                        if !response.contains("0x") {
                            self.message = "Something went wrong: \(response)"
                        } else {
                            self.message = "Transaction successfully submitted with name: \(collectionName)"
                        }
                        self.isShowingPopup = true
                    } catch {
                        self.message = "Something went wrong: \(error.localizedDescription)"
                        self.isShowingPopup = true
                    }
                }
            } label: {
                if isMintingNft {
                    ProgressView()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                } else {
                    Text("Create NFT")
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
                self.isMintingNft = false
            }
        }
    }
}

struct MintNFTView_Previews: PreviewProvider {
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
            MintNFTView(viewModel: viewModel)
        }
    }
    
    static var previews: some View {
        WrapperView()
    }
}
