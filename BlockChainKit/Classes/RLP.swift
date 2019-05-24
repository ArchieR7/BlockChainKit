//
//  RLP.swift
//  BlockChainKit
//
//  Created by Aleph Retamal on 31/1/18.
//  Copyright © 2018 Lalacode. All rights reserved.
//  https://github.com/bitfwdcommunity/RLPSwift
//

import Foundation

public enum RLP {
    public enum Error: Swift.Error {
        case stringToData
        case dataToString
        case invalidObject(ofType: Any.Type, expected: Any.Type)

        public var localizedDescription: String {
            switch self {
            case .stringToData: return "Failed to convert String to Data"
            case .dataToString: return "Failed to convert Data to String"
            case .invalidObject(let got, let expected):
                return "Invalid object, expected \(expected), but got \(got)"
            }
        }
    }
}

internal extension RLP {
    static func binaryLength(of n: UInt32) -> UInt8 {
        return UInt8(ceil(log10(Double(n))/log10(Double(UInt8.max))))
    }

    static func encodeLength(_ length: UInt32, offset: UInt8) -> Data {
        if length < 56 {
            let lengthByte = offset + UInt8(length)
            return Data([lengthByte])
        } else {
            let firstByte = offset + 55 + binaryLength(of: length)
            var bytes = [firstByte]
            var result = length.UInt8ArrayBE
            while result.first == UInt8(0) {
                result = Array(result.dropFirst())
            }
            bytes.append(contentsOf: result)
            return Data(bytes)
        }
    }
}

// MARK: Data encoding
public extension RLP {
    static func encode(_ data: Data) -> Data {
        if data.count == 1,
            0x00...0x7f ~= data[0] {
            return data
        } else {
            var result = encodeLength(UInt32(data.count), offset: 0x80)
            result.append(contentsOf: data)
            return result
        }
    }

    static func encode(nestedArrayOfData array: [Any]) throws -> Data {
        var output = Data()

        for item in array {
            if let data = item as? Data {
                output.append(encode(data))
            } else if let array = item as? [Any] {
                output.append(try encode(nestedArrayOfData: array))
            } else {
                throw Error.invalidObject(ofType: Mirror(reflecting: item).subjectType, expected: Data.self)
            }
        }
        let encodedLength = encodeLength(UInt32(output.count), offset: 0xc0)
        output.insert(contentsOf: encodedLength, at: 0)
        return output
    }
}

// MARK: String encoding
public extension RLP {
    static func encode(_ string: String, with encoding: String.Encoding = .ascii) throws -> Data {
        guard let data = string.data(using: encoding) else {
            throw Error.stringToData
        }

        let bytes = encode(data)

        return bytes
    }

    static func encode(nestedArrayOfString array: [Any], encodeStringsWith encoding: String.Encoding = .ascii) throws -> Data {
        var output = Data()

        for item in array {
            if let string = item as? String {
                output.append(try encode(string, with: .ascii))
            } else if let array = item as? [Any] {
                output.append(try encode(nestedArrayOfString: array, encodeStringsWith: encoding))
            } else {
                throw Error.invalidObject(ofType: Mirror(reflecting: item).subjectType, expected: String.self)
            }
        }

        return output
    }
}
