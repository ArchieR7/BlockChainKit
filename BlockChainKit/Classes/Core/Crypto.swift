//
//  Crypto.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/15.
//

import BigInt
import CryptoSwift
import secp256k1

public enum Crypto {
    public static func PBKDF2SHA512(password: Data, salt: Data) -> Data {
        do {
            let value = try PKCS5.PBKDF2(password: password.bytes,
                                         salt: salt.bytes,
                                         iterations: 2048,
                                         variant: .sha512).calculate()
            return Data(value)
        } catch {
            fatalError("PKCS5.PBKDF2 failed: \(error)")
        }
    }

    public static func HMACSHA512(key: Data, data: Data) -> Data {
        do {
            let value = try HMAC(key: key.bytes, variant: .sha512).authenticate(data.bytes)
            return Data(value)
        } catch {
            fatalError("HMAC failed: \(error)")
        }
    }

    public static func sign(key: Data, data: Data) -> Data {
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(context) }
        var signature = secp256k1_ecdsa_recoverable_signature()
        var secretKey = key.bytes
        var hash = data.bytes
        guard secp256k1_ecdsa_sign_recoverable(context, &signature, &hash, &secretKey, nil, nil) == 1 else {
            fatalError("secp256k1 ecdsa sign recoverable")
        }
        var output64 = Data(repeating: 0, count: 64).bytes
        var recid: Int32 = 0
        secp256k1_ecdsa_recoverable_signature_serialize_compact(context, &output64, &recid, &signature)
        return Data(output64)
    }
}

public protocol BaseCodable {
    static var alphabet: String { get }

    static func encode(_ bytes: Data) throws -> String
    static func decode(_ string: String) throws -> Data
}

public enum BaseCodableError: Error {
    case encode, decode
}

extension BaseCodable {
    public static func encode(_ bytes: Data) throws -> String {
        let alphabetData = [UInt8](alphabet.utf8)
        var bigInt = BigUInt(bytes)
        let radix = BigUInt(alphabetData.count)
        var result = [UInt8](reserveCapacity: bytes.count)
        while bigInt > 0 {
            let (quotient, remainder) = bigInt.quotientAndRemainder(dividingBy: radix)
            result.append(alphabetData[Int(remainder)])
            bigInt = quotient
        }
        let prefix = Array(bytes.prefix(while: { $0 == 0 })).map { _ in alphabetData[0] }
        result.append(contentsOf: prefix)
        result.reverse()
        guard let string = String(bytes: result, encoding: .utf8) else { throw BaseCodableError.encode }
        return string
    }

    public static func decode(_ string: String) throws -> Data {
        let alphabetData = [UInt8](alphabet.utf8)
        var result = BigUInt(0)
        var value = BigUInt(1)
        let radix = BigUInt(alphabet.count)
        let byteString = [UInt8](string.utf8)
        for character in byteString.reversed() {
            guard let index = alphabetData.firstIndex(of: character) else { throw BaseCodableError.decode }
            result = result + (value * BigUInt(index))
            value *= radix
        }
        let bytes = result.serialize()
        return byteString.prefix(while:  { $0 == alphabetData[0] }) + bytes
    }
}

public struct Base58: BaseCodable {
    public static let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
}
