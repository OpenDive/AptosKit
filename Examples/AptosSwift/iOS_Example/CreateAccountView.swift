//
//  CreateAccountView.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/18/23.
//

import SwiftUI
import AptosKit

struct CreateAccountView: View {
    @State private var bob: Account?
    
    var body: some View {
        VStack {
            if let bob {
                Text("Bob: \(bob.address().description)")
                    .padding(.horizontal)
            }
            Button {
                do {
                    bob = try Account.generate()
                } catch {
                    print("ERROR - \(error)")
                }
            } label: {
                Text("Generate Account")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 270, height: 50)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
        }
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
