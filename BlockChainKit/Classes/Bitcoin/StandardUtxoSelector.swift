//
//  StandardUtxoSelector.swift
//
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public struct StandardUtxoSelector {
    public let feePerByte: UInt64
    public let dustThreshhold: UInt64

    public init(feePerByte: UInt64 = 1, dustThreshhold: UInt64 = 3 * 182) {
        self.feePerByte = feePerByte
        self.dustThreshhold = dustThreshhold
    }

    public func select(from utxos: [BTCUnspentTransaction],
                       targetValue: UInt64) throws -> (utxos: [BTCUnspentTransaction], fee: UInt64) {
        guard targetValue > 0 else { return ([], 0) }
        let doubleTargetValue = targetValue * 2
        var numOutputs = 2
        var numInputs = 2
        var fee: UInt64 { return calculateFee(nIn: numInputs, nOut: numOutputs) }
        var targetWithFee: UInt64 { return targetValue + fee }
        var targetWithFeeAndDust: UInt64 { return targetWithFee + dustThreshhold }
        let sortedUtxos: [BTCUnspentTransaction] = utxos.sorted { $0.output.value < $1.output.value }
        let sum = sortedUtxos.sum()
        guard sum >= targetValue && !sortedUtxos.isEmpty else {
            throw UtxoSelectError.insufficientFunds(targetValue - sum)
        }
        func distFrom2x(_ val: UInt64) -> UInt64 {
            if val > doubleTargetValue { return val - doubleTargetValue } else { return doubleTargetValue - val }
        }

        txN: do {
            for numTx in (1...sortedUtxos.count) {
                numInputs = numTx
                let nOutputsSlices = sortedUtxos.eachSlices(numInputs)
                var nOutputsInRange = nOutputsSlices.filter { $0.sum() >= targetWithFeeAndDust }
                nOutputsInRange.sort { distFrom2x($0.sum()) < distFrom2x($1.sum()) }
                if let nOutputs = nOutputsInRange.first {
                    return (nOutputs, fee)
                }
            }
        }

        txDiscardDust: do {
            for numTx in (1...sortedUtxos.count) {
                numInputs = numTx
                let nOutputsSlices = sortedUtxos.eachSlices(numInputs)
                let nOutputsInRange = nOutputsSlices.filter {
                    return $0.sum() >= targetWithFee
                }
                if let nOutputs = nOutputsInRange.first {
                    return (nOutputs, fee)
                }
            }
        }
        throw UtxoSelectError.insufficientFunds(targetWithFeeAndDust - sum)
    }

    private func calculateFee(nIn: Int, nOut: Int = 2) -> UInt64 {
        var txsize: Int { return ((148 * nIn) + (34 * nOut) + 10) }
        return UInt64(txsize) * feePerByte
    }
}

extension Sequence where Element == BTCUnspentTransaction {
    func sum() -> UInt64 { return reduce(UInt64()) { $0 + UInt64($1.output.value) } }
}

public enum UtxoSelectError: Error {
    case insufficientFunds(UInt64)
    case error(String)
}

private extension Array {
    // Slice Array
    // [0,1,2,3,4,5,6,7,8,9].eachSlices(3)
    // >
    // [[0, 1, 2], [1, 2, 3], [2, 3, 4], [3, 4, 5], [4, 5, 6], [5, 6, 7], [6, 7, 8], [7, 8, 9]]
    func eachSlices(_ num: Int) -> [[Element]] {
        let slices = (0...count - num).map { self[$0..<$0 + num].map { $0 } }
        return slices
    }
}

