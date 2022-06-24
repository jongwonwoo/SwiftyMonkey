//
//  parser.swift
//  InterpreterInSwift
//
//  Created by Jongwon Woo on 2022/03/03.
//

import Foundation

typealias prefixParseFn = () -> Expression?
typealias infixParseFn = (Expression) -> Expression?

enum Precedence: UInt {
    case lowest
    case equals
    case lessGreater
    case sum
    case product
    case prefix
    case call
    case index
}

extension Precedence {
    static func precedence(for tokenType: TokenType) -> Precedence {
        switch tokenType {
        case .EQ, .NOT_EQ:
            return .equals
        case .LT, .GT:
            return .lessGreater
        case .PLUS, .MINUS:
            return .sum
        case .SLASH, .ASTERISK:
            return .product
        case .LPAREN:
            return .call
        case .LBRACKET:
            return .index
        default:
            return .lowest
        }
    }
}

extension Precedence: Comparable {
    static func < (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

class Parser {
    private var l: Lexer
    public private(set) var errors: [String] = []

    private var curToken: Token?
    private var peekToken: Token?

    private var prefixParseFns = [TokenType: prefixParseFn]()
    private var infixParseFns = [TokenType: infixParseFn]()
    
    init(lexer: Lexer) {
        self.l = lexer
        
        nextToken()
        nextToken()
        
        registerPrefix(tokenType: .IDENT, fn: parseIdentifier)
        registerPrefix(tokenType: .INT, fn: parseIntegerLiteral)
        registerPrefix(tokenType: .STRING, fn: parseStringLiteral)
        registerPrefix(tokenType: .BANG, fn: parsePrefixExpression)
        registerPrefix(tokenType: .MINUS, fn: parsePrefixExpression)
        registerPrefix(tokenType: .TRUE, fn: parseBoolean)
        registerPrefix(tokenType: .FALSE, fn: parseBoolean)
        registerPrefix(tokenType: .LPAREN, fn: parseGroupedExpression)
        registerPrefix(tokenType: .IF, fn: parseIfExpression)
        registerPrefix(tokenType: .FUNCTION, fn: parseFunctionLiteral)
        registerPrefix(tokenType: .LBRACKET, fn: parseArrayLiteral)
        registerPrefix(tokenType: .LBRACE, fn: parseHashLiteral)
        
        registerInfix(tokenType: .PLUS, fn: parseInfixExpression)
        registerInfix(tokenType: .MINUS, fn: parseInfixExpression)
        registerInfix(tokenType: .SLASH, fn: parseInfixExpression)
        registerInfix(tokenType: .ASTERISK, fn: parseInfixExpression)
        registerInfix(tokenType: .EQ, fn: parseInfixExpression)
        registerInfix(tokenType: .NOT_EQ, fn: parseInfixExpression)
        registerInfix(tokenType: .LT, fn: parseInfixExpression)
        registerInfix(tokenType: .GT, fn: parseInfixExpression)
        registerInfix(tokenType: .LPAREN, fn: parseCallExpression)
        registerInfix(tokenType: .LBRACKET, fn: parseIndexExpression)
    }
    
    private func nextToken() {
        curToken = peekToken
        peekToken = l.nextToken()
    }
    
    func parseProgram() -> Program {
        var statements = [Statement]()
        while curToken?.type != .EOF {
            if let stmt = parseStatement() {
                statements.append(stmt)
            }
            nextToken()
        }
        return Program(statements: statements)
    }
    
    private func parseStatement() -> Statement? {
        guard let curToken = curToken else {
            return nil
        }

        switch curToken.type {
        case .LET:
            return parseLetStatement()
        case .RETURN:
            return parseReturnStatement()
        default:
            return parseExpressionStatement()
        }
    }
    
    private func parseLetStatement() -> LetStatement? {
        guard let letToken = curToken else {
            return nil
        }
        
        guard expectPeek(.IDENT), let identToken = curToken else {
            return nil
        }
        
        let name = Identifier(token: identToken)
        
        if !expectPeek(.ASSIGN) {
            return nil
        }
        
        nextToken()
        
        let value = parseExpression(.lowest)

        if peekTokenIs(.SEMICOLON) {
            nextToken()
        }
        
        return LetStatement(token: letToken, name: name, value: value)
    }
    
    private func parseReturnStatement() -> ReturnStatement? {
        guard let returnToken = curToken else {
            return nil
        }
        
        nextToken()
        
        let returnValue = parseExpression(.lowest)

        if peekTokenIs(.SEMICOLON) {
            nextToken()
        }
        
        return ReturnStatement(token: returnToken, value: returnValue)
    }
    
    private func parseExpressionStatement() -> ExpressionStatement? {
        let begin = trace("\(#function)")
        defer { untrace(begin) }
        
        guard let expToken = curToken else {
            return nil
        }
        
        let expression = parseExpression(.lowest)
        
        if peekTokenIs(.SEMICOLON) {
            nextToken()
        }
        
        return ExpressionStatement(token: expToken, value: expression)
    }
    
    private func parseExpression(_ precedence: Precedence) -> Expression? {
        let begin = trace("\(#function)")
        defer { untrace(begin) }
        
        guard let curToken = curToken else {
            return nil
        }
 
        guard let prefix = prefixParseFns[curToken.type] else {
            noPrefixParseFnError(curToken.type)
            return nil
        }
        
        var leftExp = prefix()
        
        while !peekTokenIs(.SEMICOLON) && precedence < peekPrecedendce() {
            guard let peekToken = peekToken, let infix = infixParseFns[peekToken.type] else {
                return leftExp
            }
            
            nextToken()
            
            guard let leftExpOld = leftExp else {
                return leftExp
            }
            leftExp = infix(leftExpOld)
        }
        
        return leftExp
    }
    
    private func parseIdentifier() -> Expression? {
        guard let curToken = curToken else {
            return nil
        }

        return Identifier(token: curToken)
    }
    
    private func parseIntegerLiteral() -> Expression? {
        let begin = trace("\(#function)")
        defer { untrace(begin) }
        
        guard let curToken = curToken else {
            return nil
        }

        return IntegerLiteral(token: curToken)
    }
    
    private func parseStringLiteral() -> Expression? {
        guard let curToken = curToken else {
            return nil
        }
        
        return StringLiteral(token: curToken)
    }
    
    private func parseBoolean() -> Expression? {
        guard let curToken = curToken else {
            return nil
        }

        return BooleanLiteral(token: curToken)
    }
    
    private func parsePrefixExpression() -> Expression? {
        let begin = trace("\(#function)")
        defer { untrace(begin) }
        
        guard let curToken = curToken else {
            return nil
        }
        
        nextToken()
        
        guard let right = parseExpression(.prefix) else {
            return nil
        }

        return PrefixExpression(token: curToken, operator: curToken.literal, right: right)
    }
    
    private func parseInfixExpression(_ left: Expression) -> Expression? {
        let begin = trace("\(#function)")
        defer { untrace(begin) }
        
        guard let curToken = curToken else {
            return nil
        }
        
        let precedence = curPrecedence()
        nextToken()
        guard let right = parseExpression(precedence) else {
            return nil
        }
        
        return InfixExpression(token: curToken, left: left, operator: curToken.literal, right: right)
    }
    
    private func parseGroupedExpression() -> Expression? {
        nextToken()
        
        guard let exp = parseExpression(.lowest) else { return nil }
        if !expectPeek(.RPAREN) {
            return nil
        }
        
        return exp
    }
    
    private func parseIfExpression() -> Expression? {
        guard let curToken = curToken else {
            return nil
        }

        guard expectPeek(.LPAREN) else {
            return nil
        }
        
        nextToken()
        
        guard let condition = parseExpression(.lowest) else {
            return nil
        }

        guard expectPeek(.RPAREN) else {
            return nil
        }
        
        guard expectPeek(.LBRACE) else {
            return nil
        }
        
        guard let consequence = parseBlockStatement() else {
            return nil
        }
        
        var alternative: BlockStatement?
        if peekTokenIs(.ELSE) {
            nextToken()
            
            guard expectPeek(.LBRACE) else {
                return nil
            }
            
            alternative = parseBlockStatement()
        }
        
        return IfExpression(token: curToken, condition: condition, consequence: consequence, alternative: alternative)
    }
    
    private func parseFunctionLiteral() -> Expression? {
        guard let curToken = curToken else {
            return nil
        }

        guard expectPeek(.LPAREN) else {
            return nil
        }
        
        guard let parameters = parseFunctionParameters() else {
            return nil
        }
        
        guard expectPeek(.LBRACE) else {
            return nil
        }
        
        guard let body = parseBlockStatement() else {
            return nil
        }
        
        return FunctionLiteral(token: curToken, parameters: parameters, body: body)
    }
    
    private func parseFunctionParameters() -> [Identifier]? {
        var identifiers = [Identifier]()
        
        if peekTokenIs(.RPAREN) {
            nextToken()
            return identifiers
        }
        
        nextToken()
        
        guard let curToken = curToken else {
            return identifiers
        }
        
        let ident = Identifier(token: curToken)
        identifiers.append(ident)
        
        while peekTokenIs(.COMMA) {
            nextToken()
            nextToken()
            guard let curToken = self.curToken else {
                break
            }
            let ident = Identifier(token: curToken)
            identifiers.append(ident)
        }
        
        guard expectPeek(.RPAREN) else {
            return nil
        }
        
        return identifiers
    }
    
    private func parseCallExpression(_ function: Expression) -> Expression? {
        guard let curToken = curToken else {
            return nil
        }
        
        guard let arguments = parseExpressionList(.RPAREN) else {
            return nil
        }
        
        return CallExpression(token: curToken, function: function, arguments: arguments)
    }
    
    private func parseBlockStatement() -> BlockStatement? {
        guard let curToken = curToken else {
            return nil
        }
        
        nextToken()
        
        var statements = [Statement]()
        while !curTokenIs(.RBRACE) && !curTokenIs(.EOF) {
            if let stmt = parseStatement() {
                statements.append(stmt)
            }
            nextToken()
        }
        
        return BlockStatement(token: curToken, statements: statements)
    }
    
    private func parseArrayLiteral() -> Expression? {
        guard let curToken = curToken else {
            return nil
        }

        guard let elements = parseExpressionList(.RBRACKET) else {
            return nil
        }
        
        return ArrayLiteral(token: curToken, elements: elements)
    }

    private func parseHashLiteral() -> Expression? {
        guard let curToken = curToken else {
            return nil
        }

        var pairs = [HashPair]()
        
        while !peekTokenIs(.RBRACE) {
            nextToken()
            guard let key = parseExpression(.lowest) else {
                break
            }
            if !expectPeek(.COLON) {
                return nil
            }
            
            nextToken()
            guard let value = parseExpression(.lowest) else {
                break
            }
            
            pairs.append(HashPair(key: key, value: value))
            
            if !peekTokenIs(.RBRACE) && !expectPeek(.COMMA) {
                return nil
            }
        }
        
        guard expectPeek(.RBRACE) else {
            return nil
        }
        
        return HashLiteral(token: curToken, pairs: pairs)
    }
    
    private func parseIndexExpression(_ left: Expression) -> Expression? {
        guard let curToken = curToken else {
            return nil
        }

        nextToken()
        
        guard let index = parseExpression(.lowest) else {
            return nil
        }
        
        guard expectPeek(.RBRACKET) else {
            return nil
        }
        
        return IndexExpression(token: curToken, left: left, index: index)
    }
    
    private func parseExpressionList(_ end: TokenType) -> [Expression]? {
        var list = [Expression]()
        
        if peekTokenIs(end) {
            nextToken()
            return list
        }
        
        nextToken()
        
        guard let el = parseExpression(.lowest) else {
            return nil
        }
        list.append(el)
        
        while peekTokenIs(.COMMA) {
            nextToken()
            nextToken()
            guard let el = parseExpression(.lowest) else {
                break
            }
            list.append(el)
        }
        
        guard expectPeek(end) else {
            return nil
        }
        
        return list
    }
    
    private func expectPeek(_ t: TokenType) -> Bool {
        if peekTokenIs(t) {
            nextToken()
            return true
        } else {
            peekError(t)
            return false
        }
    }
    
    private func peekTokenIs(_ t: TokenType) -> Bool {
        return peekToken?.type == t
    }
    
    private func curTokenIs(_ t: TokenType) -> Bool {
        return curToken?.type == t
    }
    
    private func peekError(_ t: TokenType) {
        let msg = "expected next token to be \(t), got \(peekToken?.type ?? "nil") instead"
        errors.append(msg)
    }
    
    private func registerPrefix(tokenType: TokenType, fn: @escaping prefixParseFn) {
        prefixParseFns[tokenType] = fn
    }
    
    private func registerInfix(tokenType: TokenType, fn: @escaping infixParseFn) {
        infixParseFns[tokenType] = fn
    }
    
    private func noPrefixParseFnError(_ t: TokenType) {
        let msg = "no prefix parse function fo \(t) found"
        errors.append(msg)
    }
    
    private func peekPrecedendce() -> Precedence {
        guard let peekToken = peekToken else {
            return .lowest
        }
        return Precedence.precedence(for: peekToken.type)
    }
    
    private func curPrecedence() -> Precedence {
        guard let curToken = curToken else {
            return .lowest
        }
        return Precedence.precedence(for: curToken.type)
    }
}

func trace(_ msg: String) -> String {
    ParserTracing.shared.trace(msg)
}

func untrace(_ msg: String) {
    ParserTracing.shared.untrace(msg)
}

struct ParserTracing {
    static var shared = ParserTracing()
    private init() {}
    
    private var traceLevel = Int(0)
    private let traceIdentPlaceholder = "\t"
    
    private func identLevel() -> String {
        return String(repeating: traceIdentPlaceholder, count: traceLevel - 1)
    }
    
    private func tracePrint(_ fs: String) {
        let tracing = { false }
        tracing() ? print("\(identLevel())\(fs)") : ()
    }
    
    private mutating func incIdent() {
        traceLevel += 1
    }
    
    private mutating func decIdent() {
        traceLevel -= 1
    }
    
    mutating func trace(_ msg: String) -> String {
        incIdent()
        tracePrint("BEGIN \(msg)")
        return msg
    }
    
    mutating func untrace(_ msg: String) {
        tracePrint("END \(msg)")
        decIdent()
    }
}
