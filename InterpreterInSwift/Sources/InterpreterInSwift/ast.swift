//
//  ast.swift
//  InterpreterInSwift
//
//  Created by Jongwon Woo on 2022/03/03.
//

import Foundation

protocol Node {
    var tokenLiteral: String { get }
    var description: String { get }
}

protocol Statement: Node {
    func statementNode()
}

protocol Expression: Node {
    func expressionNode()
}

struct Program: Node {
    let statements: [Statement]
    
    init(statements: [Statement]) {
        self.statements = statements
    }
    
    var tokenLiteral: String {
        if let statement = statements.first {
            return statement.tokenLiteral
        } else {
            return ""
        }
    }
    
    var description: String {
        statements.reduce("") { $0 + $1.description }
    }
}

struct LetStatement: Statement {
    let token: Token
    let name: Identifier
    let value: Expression?
    
    init(token: Token, name: Identifier, value: Expression?) {
        self.token = token
        self.name = name
        self.value = value
    }
    
    func statementNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        "\(tokenLiteral) \(name.value) = \(value?.description ?? "");"
    }
}

struct ReturnStatement: Statement {
    let token: Token
    let returnValue: Expression?
    
    init(token: Token, value: Expression?) {
        self.token = token
        self.returnValue = value
    }
    
    func statementNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        "\(tokenLiteral) \(returnValue?.description ?? "");"
    }
}

struct ExpressionStatement: Statement {
    let token: Token
    let expression: Expression?
    
    init(token: Token, value: Expression?) {
        self.token = token
        self.expression = value
    }
    
    func statementNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        expression?.description ?? ""
    }
}

struct BlockStatement: Statement {
    let token: Token
    let statements: [Statement]
    
    init(token: Token, statements: [Statement]) {
        self.token = token
        self.statements = statements
    }
    
    func statementNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        statements.reduce("") { $0 + $1.description }
    }
}

struct Identifier: Expression {
    let token: Token
    var value: String {
        token.literal
    }
    
    init(token: Token) {
        self.token = token
    }
    
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        return value
    }
}

struct BooleanLiteral: Expression {
    let token: Token
    var value: Bool {
        Bool(token.literal) ?? false
    }
    
    init(token: Token) {
        self.token = token
    }
    
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        return token.literal
    }
}

struct IntegerLiteral: Expression {
    let token: Token
    var value: Int64 {
        Int64(token.literal) ?? 0
    }
    
    init(token: Token) {
        self.token = token
    }
    
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        return token.literal
    }
}

struct StringLiteral: Expression {
    let token: Token
    var value: String {
        token.literal
    }
    
    init(token: Token) {
        self.token = token
    }
    
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        return token.literal
    }
}

struct PrefixExpression: Expression {
    let token: Token
    let `operator`: String
    let right: Expression
    
    init(token: Token, operator: String, right: Expression) {
        self.token = token
        self.operator = `operator`
        self.right = right
    }
    
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        return "(\(`operator`)\(right.description))"
    }
}

struct InfixExpression: Expression {
    let token: Token
    let left: Expression
    let `operator`: String
    let right: Expression
    
    init(token: Token, left: Expression, operator: String, right: Expression) {
        self.token = token
        self.left = left
        self.operator = `operator`
        self.right = right
    }
    
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        return "(\(left.description) \(`operator`) \(right.description))"
    }
}

struct IfExpression: Expression {
    let token: Token
    let condition: Expression
    let consequence: BlockStatement
    let alternative: BlockStatement?
    
    init(token: Token, condition: Expression, consequence: BlockStatement, alternative: BlockStatement?) {
        self.token = token
        self.condition = condition
        self.consequence = consequence
        self.alternative = alternative
    }
 
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        var result = "if \(condition.description) \(consequence.description)"
        if let alternative = alternative {
            result = result + " else \(alternative.description)"
        }
        return result
    }
}

struct FunctionLiteral: Expression {
    let token: Token
    let parameters: [Identifier]
    let body: BlockStatement
    
    init(token: Token, parameters: [Identifier], body: BlockStatement) {
        self.token = token
        self.parameters = parameters
        self.body = body
    }
 
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        "\(token.literal)(\(parameters.map { "\($0.description)" }.joined(separator: ", "))) \(body.description)"
    }
}

struct CallExpression: Expression {
    let token: Token
    let function: Expression
    let arguments: [Expression]
    
    init(token: Token, function: Expression, arguments: [Expression]) {
        self.token = token
        self.function = function
        self.arguments = arguments
    }
 
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        "\(function.description)(\(arguments.map { "\($0.description)" }.joined(separator: ", ")))"
    }
}

struct ArrayLiteral: Expression {
    let token: Token
    let elements: [Expression]
    
    init(token: Token, elements: [Expression]) {
        self.token = token
        self.elements = elements
    }
 
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        "[\(elements.map { "\($0.description)" }.joined(separator: ", "))]"
    }
}

struct IndexExpression: Expression {
    let token: Token
    let left: Expression
    let index: Expression
    
    init(token: Token, left: Expression, index: Expression) {
        self.token = token
        self.left = left
        self.index = index
    }
 
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        "(\(left.description)[\(index.description)])"
    }
}

struct HashLiteral: Expression {
    let token: Token
    let pairs: [HashPair]
    
    init(token: Token, pairs: [HashPair]) {
        self.token = token
        self.pairs = pairs
    }
 
    func expressionNode() {
    }
    
    var tokenLiteral: String {
        return token.literal
    }

    var description: String {
        "{\(pairs.map { "\($0.key.description):\($0.value.description)" }.joined(separator: ", "))}"
    }
}

struct HashPair {
    let key: Expression
    let value: Expression
}
