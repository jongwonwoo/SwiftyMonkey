//
//  ast_test.swift
//  InterpreterInSwiftTests
//
//  Created by Jongwon Woo on 2022/03/17.
//

import XCTest

class ast_test: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testString() {
        let program = Program(statements: [
            LetStatement(token: Token(type: .LET, literal: "let"),
                         name: Identifier(token: Token(type: .IDENT, literal: "myVar")),
                         value: Identifier(token: Token(type: .IDENT, literal: "anotherVar")))
        ])
        
        let expectedDescriptions = [
            "let myVar = anotherVar;"
        ]
        
        program.statements.enumerated().forEach { i, stmt in
            XCTAssertTrue(stmt.description == expectedDescriptions[i], "program.description wrong. got=\(stmt.description)")
        }
    }

}
