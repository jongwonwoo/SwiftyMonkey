//
//  object_test.swift
//  InterpreterInSwiftTests
//
//  Created by Jongwon Woo on 2022/06/24.
//

import XCTest

class object_test: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringHashKey() {
        let hello1 = StringObject(value: "Hello World")
        let hello2 = StringObject(value: "Hello World")
        let diff1 = StringObject(value: "My name is johnny")
        let diff2 = StringObject(value: "My name is johnny")
        
        XCTAssertTrue(hello1.hashKey == hello2.hashKey, "strings with same content have different hash keys")
        XCTAssertTrue(diff1.hashKey == diff2.hashKey, "strings with same content have different hash keys")
        XCTAssertTrue(hello1.hashKey != diff1.hashKey, "strings with different content have same hash keys")
    }
    
    func testBooleanHashKey() {
        let true1 = BooleanObject(value: true)
        let true2 = BooleanObject(value: true)
        let false1 = BooleanObject(value: false)
        let false2 = BooleanObject(value: false)
        
        XCTAssertTrue(true1.hashKey == true2.hashKey, "trues do not have same hash key")
        XCTAssertTrue(false1.hashKey == false2.hashKey, "falses do not have same hash key")
        XCTAssertTrue(true1.hashKey != false1.hashKey, "true has same hash key as false")
    }

    func testIntegerHashKey() {
        let one1 = IntegerObject(value: 1)
        let one2 = IntegerObject(value: 1)
        let two1 = IntegerObject(value: 2)
        let two2 = IntegerObject(value: 2)
        
        XCTAssertTrue(one1.hashKey == one2.hashKey, "integers with same content have different hash keys")
        XCTAssertTrue(two1.hashKey == two2.hashKey, "integers with same content have different hash keys")
        XCTAssertTrue(one1.hashKey != two1.hashKey, "integers with different content have same hash keys")
    }
}
