//
//  ContentView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/18/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: CreateAccountView()) {
                    Text("Create Account")
                }
                
                NavigationLink(destination: TransactionView()) {
                    Text("Create Transaction")
                }
                
                NavigationLink(destination: SimulateTransactionView()) {
                    Text("Simulate Transaction")
                }
            }
            .navigationTitle("AptosKit Examples")
            .listStyle(.plain)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
