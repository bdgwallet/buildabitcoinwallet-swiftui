//
//  KeyManager.swift
//  mybitcoinwallet
//
//  Created by Daniel Nordh on 19/01/2023.
//

import Foundation
import BitcoinDevKit

public struct KeyData: Codable {
    public var mnemonic: String?
    public var descriptor: String

    public init(mnemonic: String, descriptor: String ) {
        self.mnemonic = mnemonic
        self.descriptor = descriptor
    }
}

// Save KeyData as file
public func saveKeyData(keyData: KeyData) throws {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    if let url = urls.first {
        let fileURL = url.appendingPathComponent("KeyData.json")
        if let jsonData = try? JSONEncoder().encode(keyData) {
            do {
                try jsonData.write(to: fileURL, options: [.atomicWrite])
            } catch {
                throw KeyDataError.writeError
            }
        } else  {
            throw KeyDataError.encodingError
        }
    } else {
        throw KeyDataError.urlError
    }
}

// Get KeyData from file
public func getKeyData() throws -> KeyData {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    if let url = urls.first {
        let fileURL = url.appendingPathComponent("KeyData.json")
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(KeyData.self, from: data)
        } catch {
            throw KeyDataError.decodingError
        }
    } else {
        throw KeyDataError.urlError
    }
}

// Delete KeyData WARNING!
public func deleteKeyData() {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    if let url = urls.first {
        let fileURL = url.appendingPathComponent("KeyData.json")
        do {
            try fileManager.removeItem(at: fileURL)
        } catch let error {
            debugPrint(error)
        }
    } else {
        debugPrint(KeyDataError.urlError)
    }
}

enum KeyDataError: Error {
    case encodingError
    case writeError
    case urlError
    case decodingError
    case readError
}
