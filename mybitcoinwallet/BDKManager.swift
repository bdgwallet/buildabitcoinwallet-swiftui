//
//  BDKManager.swift
//  mybitcoinwallet
//
//  Created by Daniel Nordh on 19/01/2023.
//

import Foundation
import BitcoinDevKit

public class BDKManager: ObservableObject {
    // Public variables
    public var network: Network
    @Published public var wallet: Wallet?
    @Published public var balance: Balance?
    @Published public var transactions: [TransactionDetails] = []
    @Published public var syncState = SyncState.notsynced
    
    // Private variables
    private let bdkQueue = DispatchQueue (label: "bdkQueue", qos: .userInitiated)
    private let databaseConfig: DatabaseConfig
    private let blockchainConfig: BlockchainConfig
    
    // Initialize a BDKManager instance
    public init() {
        self.network = Network.testnet
        self.databaseConfig = DatabaseConfig.memory
        let esploraConfig = EsploraConfig(
            baseUrl: self.network == Network.bitcoin ? ESPLORA_URL_BITCOIN : ESPLORA_URL_TESTNET,
            proxy: nil,
            concurrency: nil,
            stopGap: ESPLORA_STOPGAP,
            timeout: ESPLORA_TIMEOUT)
        self.blockchainConfig = BlockchainConfig.esplora(config: esploraConfig)
    }
    
    // Load wallet
    public func loadWallet(descriptor: Descriptor, changeDescriptor: Descriptor?) {
        do {
            let wallet = try Wallet.init(
                descriptor: descriptor,
                changeDescriptor: changeDescriptor,
                network: self.network,
                databaseConfig: self.databaseConfig)
            self.wallet = wallet
        } catch let error {
            debugPrint(error)
        }
    }
    
    // Sync the loaded wallet once
    public func sync() {
        if wallet != nil {
            self.syncState = SyncState.syncing
            bdkQueue.async {
                do {
                    let blockchain = try Blockchain(config: self.blockchainConfig)
                    try self.wallet!.sync(blockchain: blockchain, progress: nil)
                    DispatchQueue.main.async {
                        self.getBalance()
                        self.getTransactions()
                        self.syncState = SyncState.synced
                    }
                } catch let error {
                    debugPrint(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.syncState = SyncState.failed
                    }
                }
            }
        }
    }
    
    // Update .balance
    private func getBalance() {
        do {
            self.balance = try self.wallet!.getBalance()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    // Update .transactions
    private func getTransactions() {
        do {
            let transactions = try self.wallet!.listTransactions()
            self.transactions = transactions
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    // Get wallet address
    public func getAddress(addressIndex: AddressIndex) -> String? {
        do {
            let addressInfo = try self.wallet!.getAddress(addressIndex: addressIndex)
            return addressInfo.address
        } catch (let error){
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    // Send an amount of bitcoin (in sats) to a recipient
    public func sendBitcoin(script: Script, amount: UInt64, feeRate: Float?) -> Bool {
        if wallet != nil {
            do {
                let transaction = try TxBuilder().addRecipient(
                    script: script,
                    amount: amount).feeRate(satPerVbyte: feeRate != nil ? feeRate! : 1.0)
                    .finish(wallet: self.wallet!)
                let signed = try self.wallet!.sign(psbt: transaction.psbt)
                let blockchain = try Blockchain(config: self.blockchainConfig)
                try blockchain.broadcast(psbt: transaction.psbt)
                return true
            } catch let error {
                debugPrint(error.localizedDescription)
                return false
            }
        } else {
            debugPrint("Error sending bitcoin, no wallet found")
            return false
        }
    }
}

// Public API URLs and defaults
let ESPLORA_URL_BITCOIN = "https://blockstream.info/api/"
let ESPLORA_URL_TESTNET = "https://blockstream.info/testnet/api"

let ELECTRUM_URL_BITCOIN = "ssl://electrum.blockstream.info:60001"
let ELECTRUM_URL_TESTNET = "ssl://electrum.blockstream.info:60002"

// Defaults
let ESPLORA_TIMEOUT = UInt64(1000)
let ESPLORA_STOPGAP = UInt64(20)

let ELECTRUM_RETRY = UInt8(5)
let ELECTRUM_STOPGAP = UInt64(10)

public enum SyncState: String {
    case notsynced
    case syncing
    case synced
    case failed
}
