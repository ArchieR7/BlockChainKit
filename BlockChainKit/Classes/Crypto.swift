//
//  Crypto.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/15.
//

import CryptoSwift

public final class Crypto {
    public static func PBKDF2SHA512(password: [UInt8], salt: [UInt8]) -> Data {
        do {
            let value = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 2048, variant: .sha512).calculate()
            return Data(value)
        } catch {
            fatalError("PKCS5.PBKDF2 failed: \(error)")
        }
    }
}
