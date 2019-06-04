import BlockChainKit
import XCTest

class Tests: XCTestCase {
    func testPadding() {
        print("015950000000000000000000".paddingLeft(size: 64))
    }

    func testRLP() {
        XCTAssertEqual(try! RLP.encode("dog").toHexString(), "83646f67")
    }
}
