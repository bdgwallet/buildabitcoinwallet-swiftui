//
//  mybitcoinwalletApp.swift
//  mybitcoinwallet
//
//  Created by Daniel Nordh on 19/01/2023.
//

import SwiftUI
import BitcoinDevKit

@main
struct mybitcoinwalletApp: App {
    @ObservedObject var bdkManager: BDKManager
    
    init() {
        bdkManager = BDKManager()
        do {
            let keyData = try getKeyData()
            let descriptor = try Descriptor(descriptor: keyData.descriptor, network: bdkManager.network)
            bdkManager.loadWallet(descriptor: descriptor, changeDescriptor: nil)
        } catch let error {
            debugPrint(error)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if bdkManager.wallet != nil {
                WalletView()
                    .environmentObject(bdkManager)
            } else {
                CreateWalletView()
                    .environmentObject(bdkManager)
            }
        }
    }
}
