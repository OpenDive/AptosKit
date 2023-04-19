//
//  TransactionView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/18/23.
//

import SwiftUI
import AptosKit

struct TransactionView: View {
    @State private var bob: Account?
    @State private var alice: Account?
    
    @State private var bobsBalance: Int = 0
    @State private var loading: Bool = false
    
    var body: some View {
        VStack {
            Text("Bob's Balance: \(bobsBalance) APT")
            
            if let bob, let alice {
                Text("Bob: \(bob.address().description)")
                    .padding(.horizontal)
                Text("Alice: \(alice.address().description)")
                    .padding(.horizontal)
            }
            Button {
                Task {
                    do {
                        self.loading = true
                        bob = try Account.generate()
                        alice = try Account.generate()
                        
                        let baseUrl = "https://fullnode.devnet.aptoslabs.com/v1"
                        let faucetUrl = "https://faucet.devnet.aptoslabs.com"
                        
                        let restClient = try await RestClient(baseUrl: baseUrl)
                        let faucetClient = FaucetClient(baseUrl: faucetUrl, restClient: restClient)
                        
                        if let bob, let alice {
                            try await faucetClient.fundAccount(alice.address().description, 100_000_000)
                            try await faucetClient.fundAccount(bob.address().description, 0)
                            
                            let txnHash = try await restClient.transfer(alice, bob.address(), 1_000)
                            try await restClient.waitForTransaction(txnHash)
                            self.bobsBalance = try await restClient.accountBalance(bob.address())
                            self.loading = false
                        }
                    } catch {
                        print("ERROR - \(error)")
                    }
                }
            } label: {
                if !self.loading {
                    Text("Create Transaction")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                } else {
                    ProgressView()
                        .foregroundColor(.white)
                        .frame(width: 270, height: 50)
                        .background(.blue.opacity(0.8))
                        .clipShape(Capsule())
                        .padding(.top, 8)
                }
            }
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
