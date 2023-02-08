//
//  CreateWalletView.swift
//  mybitcoinwallet
//
//  Created by Daniel Nordh on 19/01/2023.
//

import SwiftUI
import BitcoinDevKit
import WalletUI

struct CreateWalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            BitcoinImage(named: "bitcoin-circle-filled")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150.0)
                .foregroundColor(.bitcoinOrange)
            Text("Bitcoin wallet")
                .textStyle(BitcoinTitle1())
            Text("A simple bitcoin wallet for your enjoyment")
                .textStyle(BitcoinBody2())
                .multilineTextAlignment(.center)
            Spacer()
            Button("Create wallet") {
                createWallet(bdkManager: self.bdkManager)
            }.buttonStyle(BitcoinFilled())
            Button("Restore existing wallet") {
                // code for restoring wallet called here
            }.buttonStyle(BitcoinPlain())
            Text("Your wallet, your coins. \n100% open-source and open-design")
                .textStyle(BitcoinBody4())
                .multilineTextAlignment(.center)
        }.padding(16)
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
