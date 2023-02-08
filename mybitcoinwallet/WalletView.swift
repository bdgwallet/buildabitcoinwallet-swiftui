//
//  ContentView.swift
//  mybitcoinwallet
//
//  Created by Daniel Nordh on 19/01/2023.
//

import SwiftUI
import BitcoinDevKit
import WalletUI

struct WalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    @State private var receiveAddress: String?
    
    var body: some View {
        VStack (spacing: 32) {
            Image(systemName: "bitcoinsign")
                .imageScale(.large)
                .foregroundColor(.bitcoinOrange)
            switch bdkManager.syncState {
            case .syncing:
                Text("Syncing")
                    .textStyle(BitcoinTitle1())
            case .synced:
                HStack(alignment: .firstTextBaseline) {
                    Text((bdkManager.balance?.total.description)!)
                        .textStyle(BitcoinTitle1())
                    Text("Sats")
                        .textStyle(BitcoinTitle5())
                }
            case .notsynced:
                Text("Not synced")
                    .textStyle(BitcoinTitle1())
            case .failed:
                Text("Sync failed")
                    .textStyle(BitcoinTitle1())
            }
            HStack {
                Button("Copy address") {
                    UIPasteboard.general.setValue(receiveAddress ?? "", forPasteboardType: "public.plain-text")
                }.buttonStyle(BitcoinFilled(width: 150))
                Button("Send 1k sats") {
                    do {
                        let address = "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB"
                        let addressScript = try Address(address: address).scriptPubkey()
                        let success = bdkManager.sendBitcoin(script: addressScript, amount: 10000, feeRate: 1000)
                        debugPrint("Send success:" + success.description)
                    } catch let error {
                        debugPrint(error.localizedDescription)
                    }
                }.buttonStyle(BitcoinFilled(width: 150))
            }
            List {
                ForEach(bdkManager.transactions, id: \.self) {transaction in
                    Text(transaction.confirmationTime?.timestamp.description != nil ? transaction.received.description : "Pending")
                        .foregroundColor(transaction.sent == 0 ? .bitcoinRed : .bitcoinGreen)
                }
            }.listStyle(.plain)
            Spacer()
            Button("Sync") {
                bdkManager.sync()
            }.buttonStyle(BitcoinOutlined())
        }
        .padding(16)
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
