//
//  CreateWalletView.swift
//  mybitcoinwallet
//
//  Created by Daniel Nordh on 19/01/2023.
//

import SwiftUI
import BitcoinDevKit

struct CreateWalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    
    var body: some View {
        Text("Hello, wallet!")
        Button("Create wallet") {
            createWallet(bdkManager: self.bdkManager)
        }
    }
}

struct CreateWalletView_Previews: PreviewProvider {
    static var previews: some View {
        CreateWalletView()
    }
}

// Create and load a new wallet
func createWallet(bdkManager: BDKManager) {
    let mnemonic = Mnemonic(wordCount: WordCount.words12)
    let descriptorSecretKey = DescriptorSecretKey(
        network: bdkManager.network,
        mnemonic: mnemonic,
        password: nil)
    let descriptor = Descriptor.newBip84(
        secretKey: descriptorSecretKey,
        keychain: KeychainKind.external,
        network: bdkManager.network)
    do {
        let keyData = KeyData(
            mnemonic: mnemonic.asString(),
            descriptor: descriptor.asStringPrivate())
        try saveKeyData(keyData: keyData)
        bdkManager.loadWallet(descriptor: descriptor, changeDescriptor: nil)
    } catch let error {
        debugPrint(error)
    }
}
