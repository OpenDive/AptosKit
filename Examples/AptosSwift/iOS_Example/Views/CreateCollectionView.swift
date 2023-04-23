//
//  CreateCollectionView.swift
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
            
            Text("Create a Collection")
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
