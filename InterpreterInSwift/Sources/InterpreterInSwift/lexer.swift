//
//  File.swift
//  
//
//  Created by Jongwon Woo on 2022/02/16.
//

class Lexer {
    private let input: String
    private var position: Int = 0
    private var readPosition: Int = 0
    private var ch: Character?
    
    init(input: String) {
        self.input = input
        readChar()
    }
    
    func nextToken() -> Token {
        let tok: Token
        
        skipWhitespace()
        
        switch ch {
        case "=":
            if peekChar() == "=" {
                let ch = ch!
                readChar()
                let literal = String("\(ch)\(self.ch!)")
                tok = Token(type: .EQ, literal: literal)
            } else {
                tok = Token(type: .ASSIGN, literal: String(ch!))
            }
        case "+":
            tok = Token(type: .PLUS, literal: String(ch!))
        case "-":
            tok = Token(type: .MINUS, literal: String(ch!))
        case "!":
            if peekChar() == "=" {
                let ch = ch!
                readChar()
                let literal = String("\(ch)\(self.ch!)")
                tok = Token(type: .NOT_EQ, literal: literal)
            } else {
                tok = Token(type: .BANG, literal: String(ch!))
            }
        case "/":
            tok = Token(type: .SLASH, literal: String(ch!))
        case "*":
            tok = Token(type: .ASTERISK, literal: String(ch!))
        case "<":
            tok = Token(type: .LT, literal: String(ch!))
        case ">":
            tok = Token(type: .GT, literal: String(ch!))
        case ";":
            tok = Token(type: .SEMICOLON, literal: String(ch!))
        case ":":
            tok = Token(type: .COLON, literal: String(ch!))
        case "(":
            tok = Token(type: .LPAREN, literal: String(ch!))
        case ")":
            tok = Token(type: .RPAREN, literal: String(ch!))
        case ",":
            tok = Token(type: .COMMA, literal: String(ch!))
        case "{":
            tok = Token(type: .LBRACE, literal: String(ch!))
        case "}":
            tok = Token(type: .RBRACE, literal: String(ch!))
        case "[":
            tok = Token(type: .LBRACKET, literal: String(ch!))
        case "]":
            tok = Token(type: .RBRACKET, literal: String(ch!))
        case "\"":
            tok = Token(type: .STRING, literal: readString())
        case nil:
            tok = Token(type: .EOF, literal: "")
        default:
            if let ch = ch, isLetter(ch) {
                let literal = readIdentifier()
                let type = TokenType.lookupIdent(literal)
                return Token(type: type, literal: literal)
            } else if let ch = ch, isDigit(ch) {
                return Token(type: .INT, literal: readNumber())
            } else {
                tok = Token(type: .ILLEGAL, literal: String(ch!))
            }
        }
        
        readChar()
        return tok
    }
    
    private func readChar() {
        if readPosition >= input.count {
            ch = nil
        } else {
            ch = input[readPosition]
        }
        position = readPosition
        readPosition += 1
    }
    
    private func readIdentifier() -> String {
        let position = position
        while let ch = ch, isLetter(ch) {
            readChar()
        }
        return String(input[position..<self.position])
    }
    
    private func readNumber() -> String {
        let position = position
        while let ch = ch, isDigit(ch) {
            readChar()
        }
        return String(input[position..<self.position])
    }
    
    private func readString() -> String {
    let position = position + 1
        repeat {
            readChar()
        } while ch != "\"" && ch != nil
        
        return String(input[position..<self.position])
    }
    
    func peekChar() -> Character? {
        guard readPosition < input.count else {
            return nil
        }
        return input[readPosition]
    }
    
    private func isLetter(_ ch: Character) -> Bool {
        return ("a"..."z").contains(ch) ||
            ("A"..."Z").contains(ch) ||
            ch == "_"
    }
    
    private func isDigit(_ ch: Character) -> Bool {
        return ("0"..."9").contains(ch)
    }
    
    private func skipWhitespace() {
        while ch == " " ||
                ch == "\t" ||
                ch == "\n" ||
                ch == "\r" {
            readChar()
        }
    }
}
