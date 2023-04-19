//
//  SimulateTransactionView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/18/23.
//

import SwiftUI
import AptosKit

struct SimulateTransactionView: View {
    @State private var bob: Account?
    @State private var alice: Account?
    @State private var status: String?
    
    @State private var loading: Bool = false
    
    var body: some View {
        VStack {
            if let bob, let alice {
                Text("Bob: \(bob.address().description)")
                    .padding(.horizontal)
                
                Text("Alice: \(alice.address().description)")
                    .padding(.horizontal)
            }
            if let status {
                Text("Status:  \(status)")
                    .padding()
            }
            Button {
                Task {
                    do {
                        self.bob = try Account.generate()
                        self.alice = try Account.generate()
                        
                        let baseUrl = "https://fullnode.devnet.aptoslabs.com/v1"
                        let faucetUrl = "https://faucet.devnet.aptoslabs.com"
                        
                        let restClient = try await RestClient(baseUrl: baseUrl)
                        let faucetClient = FaucetClient(baseUrl: faucetUrl, restClient: restClient)
                        
                        if let bob, let alice {
                            try await faucetClient.fundAccount(alice.address().description, 100_000_000)
                            try await faucetClient.fundAccount(bob.address().description, 0)
                            
                            let payload = try EntryFunction.natural(
                                "0x1::coin",
                                "transfer",
                                [TypeTag(value: StructTag.fromStr("0x1::aptos_coin::AptosCoin"))],
                                [
                                    AnyTransactionArgument(TransactionArgument(value: bob.address(), encoder: Serializer._struct)),
                                    AnyTransactionArgument(TransactionArgument(value: UInt64(100_000), encoder: Serializer.u64))
                                ]
                            )
                            let transaction = try await restClient.createBcsTransaction(
                                alice,
                                try TransactionPayload(payload: payload)
                            )
                            let output = try await restClient.simulateTransaction(transaction, alice)
                            
                            self.status = output[0]["vm_status"].stringValue
                            self.loading = false
                        }
                    } catch {
                        print("ERROR - \(error)")
                    }
                }
            } label: {
                if !self.loading {
                    Text("Simulate Transaction")
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

struct SimulateTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        SimulateTransactionView()
    }
}
