//
//  String+Test.swift
//  
//
//  Created by Jongwon Woo on 2022/02/16.
//

import XCTest
import Foundation

class String_Test: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let test = "Hello USA 🇺🇸!!! Hello Brazil 🇧🇷!!!"
        XCTAssertEqual(test[safe: 10], "🇺🇸")
        XCTAssertEqual(test[11], "!")
        XCTAssertEqual(test[10...], "🇺🇸!!! Hello Brazil 🇧🇷!!!")
        XCTAssertEqual(test[10..<12], "🇺🇸!")
        XCTAssertEqual(test[10...12], "🇺🇸!!")
        XCTAssertEqual(test[...10], "Hello USA 🇺🇸")
        XCTAssertEqual(test[..<10], "Hello USA ")
        XCTAssertEqual(test.first, "H")
        XCTAssertEqual(test.last, "!")

        // Subscripting the Substring
        XCTAssertEqual(test[...][...3], "Hell")

        // Note that they all return a Substring of the original String.
        // To create a new String from a substring
        XCTAssertEqual(test[10...].string, "🇺🇸!!! Hello Brazil 🇧🇷!!!")
    }

}
