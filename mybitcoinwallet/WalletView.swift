//
//  ContentView.swift
//  mybitcoinwallet
//
//  Created by Daniel Nordh on 19/01/2023.
//

import SwiftUI
import BitcoinDevKit

struct WalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @State private var receiveAddress: String?
    
    var body: some View {
        VStack {
            Image(systemName: "bitcoinsign")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, wallet!")
            Text("Syncstate: " + bdkManager.syncState.rawValue)
            Text("Balance: " + (bdkManager.balance?.total.description ?? "unknown"))
            Text(receiveAddress ?? "no receive address")
            Button("Sync") {
                bdkManager.sync()
            }
            Button("Send 10000 sats") {
                do {
                    let address = "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB"
                    let addressScript = try Address(address: address).scriptPubkey()
                    let success = bdkManager.sendBitcoin(script: addressScript, amount: 10000, feeRate: 1000)
                    debugPrint("Send success:" + success.description)
                } catch let error {
                    debugPrint(error.localizedDescription)
                }
            }
            List {
                ForEach(bdkManager.transactions, id: \.self) {transaction in
                    Text(transaction.confirmationTime?.timestamp.description != nil ? transaction.txid : "Pending")
                }
            }.listStyle(.plain)
        }
        .padding()
        .task {
            bdkManager.sync()
            receiveAddress = bdkManager.getAddress(addressIndex: AddressIndex.new)
            debugPrint(receiveAddress ?? "no address")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
