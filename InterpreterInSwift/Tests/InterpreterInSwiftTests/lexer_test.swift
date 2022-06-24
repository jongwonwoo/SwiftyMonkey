//
//  lexer_test.swift
//  
//
//  Created by Jongwon Woo on 2022/02/16.
//

import XCTest
import InterpreterInSwift

class lexer_test: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNextToken() throws {
        let input = """
        let five = 5;
        let ten = 10;
        
        let add = fn(x, y) {
            x + y;
        };
        
        let result = add(five, ten);
        
        !-/*5;
        5 < 10 > 5;
        
        if (5 < 10) {
            return true;
        } else {
            return false;
        }
        
        10 == 10;
        10 != 9;
        "foobar"
        "foo bar"
        [1, 2];
        {"foo": "bar"}
        """
        
        let tests = [
            Token(type: .LET, literal: "let"),
            Token(type: .IDENT, literal: "five"),
            Token(type: .ASSIGN, literal: "="),
            Token(type: .INT, literal: "5"),
            Token(type: .SEMICOLON, literal: ";"),
            Token(type: .LET, literal: "let"),
            Token(type: .IDENT, literal: "ten"),
            Token(type: .ASSIGN, literal: "="),
            Token(type: .INT, literal: "10"),
            Token(type: .SEMICOLON, literal: ";"),
            
            Token(type: .LET, literal: "let"),
            Token(type: .IDENT, literal: "add"),
            Token(type: .ASSIGN, literal: "="),
            Token(type: .FUNCTION, literal: "fn"),
            Token(type: .LPAREN, literal: "("),
            Token(type: .IDENT, literal: "x"),
            Token(type: .COMMA, literal: ","),
            Token(type: .IDENT, literal: "y"),
            Token(type: .RPAREN, literal: ")"),
            Token(type: .LBRACE, literal: "{"),
            Token(type: .IDENT, literal: "x"),
            Token(type: .PLUS, literal: "+"),
            Token(type: .IDENT, literal: "y"),
            Token(type: .SEMICOLON, literal: ";"),
            Token(type: .RBRACE, literal: "}"),
            Token(type: .SEMICOLON, literal: ";"),
            
            Token(type: .LET, literal: "let"),
            Token(type: .IDENT, literal: "result"),
            Token(type: .ASSIGN, literal: "="),
            Token(type: .IDENT, literal: "add"),
            Token(type: .LPAREN, literal: "("),
            Token(type: .IDENT, literal: "five"),
            Token(type: .COMMA, literal: ","),
            Token(type: .IDENT, literal: "ten"),
            Token(type: .RPAREN, literal: ")"),
            Token(type: .SEMICOLON, literal: ";"),
            
            Token(type: .BANG, literal: "!"),
            Token(type: .MINUS, literal: "-"),
            Token(type: .SLASH, literal: "/"),
            Token(type: .ASTERISK, literal: "*"),
            Token(type: .INT, literal: "5"),
            Token(type: .SEMICOLON, literal: ";"),
            Token(type: .INT, literal: "5"),
            Token(type: .LT, literal: "<"),
            Token(type: .INT, literal: "10"),
            Token(type: .GT, literal: ">"),
            Token(type: .INT, literal: "5"),
            Token(type: .SEMICOLON, literal: ";"),
            
            Token(type: .IF, literal: "if"),
            Token(type: .LPAREN, literal: "("),
            Token(type: .INT, literal: "5"),
            Token(type: .LT, literal: "<"),
            Token(type: .INT, literal: "10"),
            Token(type: .RPAREN, literal: ")"),
            Token(type: .LBRACE, literal: "{"),
            Token(type: .RETURN, literal: "return"),
            Token(type: .TRUE, literal: "true"),
            Token(type: .SEMICOLON, literal: ";"),
            Token(type: .RBRACE, literal: "}"),
            Token(type: .ELSE, literal: "else"),
            Token(type: .LBRACE, literal: "{"),
            Token(type: .RETURN, literal: "return"),
            Token(type: .FALSE, literal: "false"),
            Token(type: .SEMICOLON, literal: ";"),
            Token(type: .RBRACE, literal: "}"),
            
            Token(type: .INT, literal: "10"),
            Token(type: .EQ, literal: "=="),
            Token(type: .INT, literal: "10"),
            Token(type: .SEMICOLON, literal: ";"),
            Token(type: .INT, literal: "10"),
            Token(type: .NOT_EQ, literal: "!="),
            Token(type: .INT, literal: "9"),
            Token(type: .SEMICOLON, literal: ";"),
            
            Token(type: .STRING, literal: "foobar"),
            Token(type: .STRING, literal: "foo bar"),
            
            Token(type: .LBRACKET, literal: "["),
            Token(type: .INT, literal: "1"),
            Token(type: .COMMA, literal: ","),
            Token(type: .INT, literal: "2"),
            Token(type: .RBRACKET, literal: "]"),
            Token(type: .SEMICOLON, literal: ";"),
            
            Token(type: .LBRACE, literal: "{"),
            Token(type: .STRING, literal: "foo"),
            Token(type: .COLON, literal: ":"),
            Token(type: .STRING, literal: "bar"),
            Token(type: .RBRACE, literal: "}"),
            
            Token(type: .EOF, literal: ""),
        ]
        
        let l = Lexer(input: input)
        tests.enumerated().forEach { i, tt in
            let tok = l.nextToken()
            if tok.type != tt.type {
                XCTFail("tests\(i) - tokentype wrong. expected=\(tt.type), got=\(tok.type)")
            }
            if tok.literal != tt.literal {
                XCTFail("tests\(i) - literal wrong. expected=\(tt.literal), got=\(tok.literal)")
            }
        }
    }

}
