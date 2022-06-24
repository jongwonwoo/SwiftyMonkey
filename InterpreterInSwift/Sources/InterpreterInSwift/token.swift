//
//  File.swift
//  
//
//  Created by Jongwon Woo on 2022/02/10.
//

typealias TokenType = String

struct Token {
    let type: TokenType
    let literal: String
}

extension TokenType {
    static var ILLEGAL = "ILLEGAL"
    static var EOF = "EOF"

    // Identifiers + literals
    static var IDENT = "IDENT" // add, foobar, x, y, ...
    static var INT = "INT"   // 1343456
    static var STRING = "STRING"

    // Operators
    static var ASSIGN = "="
    static var PLUS = "+"
    static var MINUS = "-"
    static var BANG = "!"
    static var ASTERISK = "*"
    static var SLASH = "/"

    static var LT = "<"
    static var GT = ">"

    static var EQ = "=="
    static var NOT_EQ = "!="

    // Delimiters
    static var COMMA = ","
    static var SEMICOLON = ";"
    static var COLON = ":"

    static var LPAREN = "("
    static var RPAREN = ")"
    static var LBRACE = "{"
    static var RBRACE = "}"
    static var LBRACKET = "["
    static var RBRACKET = "]"

    // Keywords
    static var FUNCTION = "FUNCTION"
    static var LET = "LET"
    static var TRUE = "TRUE"
    static var FALSE = "FALSE"
    static var IF = "IF"
    static var ELSE = "ELSE"
    static var RETURN = "RETURN"
}

extension TokenType {
    static let keywords = [
        "fn": FUNCTION,
        "let": LET,
        "true": TRUE,
        "false": FALSE,
        "if": IF,
        "else": ELSE,
        "return": RETURN
    ]
    
    static func lookupIdent(_ ident: String) -> TokenType {
        if let tok = TokenType.keywords[ident] {
            return tok
        }
        return IDENT
    }
}
