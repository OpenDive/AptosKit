//
//  CreateCollectionView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/21/23.
//

import SwiftUI

struct CreateCollectionView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var collectionName: String = "AptosTestingCollection"
    @State private var collectionDescription: String = "AptosTestingCollection"
    @State private var collectionUri: String = "AptosTestingCollection"
    
    @State private var message: String = ""
    @State private var isShowingPopup: Bool = false
    @State private var isCreatingCollection: Bool = false
    
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
                
                TextField("Collection Description", text: $collectionDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                
                TextField("Collection URI", text: $collectionUri)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top, 10)
                    .padding(.horizontal)
            }
            
            Button {
                Task {
                    do {
                        self.isCreatingCollection = true
                        let response = try await self.viewModel.createCollection(collectionName, collectionDescription, collectionUri)
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
                if isCreatingCollection {
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
                self.isCreatingCollection = false
            }
        }
    }
}

struct CreateCollectionView_Previews: PreviewProvider {
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
            CreateCollectionView(viewModel: viewModel)
        }
    }
    
    static var previews: some View {
        WrapperView()
    }
}
