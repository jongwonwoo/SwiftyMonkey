//
//  parser_test.swift
//  InterpreterInSwiftTests
//
//  Created by Jongwon Woo on 2022/03/15.
//

import XCTest

class parser_test: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLetStatements() {
        let tests: [(input: String, expectedIdentifier: String, expectedValue: Any)] = [
            ("let x = 5;", "x", 5),
            ("let y = true;", "y", true),
            ("let foobar = y;", "foobar", "y"),
        ]
        
        tests.forEach {
            let l = Lexer(input: $0.input)
            let p = Parser(lexer: l)
            
            let program = p.parseProgram()
            checkParserErrors(p)
            
            guard program.statements.count == 1 else {
                XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
                return
            }
            
            let stmt = program.statements[0]
            if !testLetStatement(stmt, $0.expectedIdentifier) {
                return
            }
            
            if let letStmt = stmt as? LetStatement, let value = letStmt.value {
                testLiteralExpression(value, expected: $0.expectedValue)
            }
        }
    }
    
    func testReturnStatements() {
        let tests: [(input: String, expectedValue: Any)] = [
            ("return 5;", 5),
            ("return true;", true),
            ("return foobar;", "foobar"),
        ]
        
        tests.forEach {
            let l = Lexer(input: $0.input)
            let p = Parser(lexer: l)
            
            let program = p.parseProgram()
            checkParserErrors(p)
            
            guard program.statements.count == 1 else {
                XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
                return
            }
            
            guard let returnStmt = program.statements[0] as? ReturnStatement else {
                XCTFail("stmt not \(ReturnStatement.self). got=\(type(of: program.statements[0]))")
                return
            }
            
            if returnStmt.tokenLiteral != "return" {
                XCTFail("retunStmt.toktnLiteral not 'retur', got \(returnStmt.tokenLiteral)")
            }
            
            if let value = returnStmt.returnValue {
                testLiteralExpression(value, expected: $0.expectedValue)
            }
        }
    }
    
    func testIdentifierExpression() {
        let input = "foobar;"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program has not enough statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        testIdentifier(stmt.expression, value: "foobar")
    }
    
    func testIntegerLiteralExpression() {
        let input = "5;"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program has not enough statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        testIntegerLiteral(stmt.expression, value: 5)
    }
    
    func testBooleanExpression() {
        let tests: [(input: String, expectedBoolean: Bool)] = [
            ("true;", true),
            ("false;", false)
        ]
        
        tests.forEach {
            let l = Lexer(input: $0.input)
            let p = Parser(lexer: l)
            
            let program = p.parseProgram()
            checkParserErrors(p)
            
            guard program.statements.count == 1 else {
                XCTFail("program has not enough statements. got=\(program.statements.count)")
                return
            }
            
            guard let stmt = program.statements[0] as? ExpressionStatement else {
                XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
                return
            }
            
            guard let boolean = stmt.expression as? BooleanLiteral else {
                XCTFail("exp not \(BooleanLiteral.self). got=\(String(describing: stmt.expression))")
                return
            }
            
            XCTAssertTrue(boolean.value == $0.expectedBoolean, "boolean.value not \($0.expectedBoolean). got=\(boolean.value)")
        }
    }
    
    func testStringLiteralExpression() {
        let input = "\"hello world\";"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program has not enough statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let literal = stmt.expression as? StringLiteral else {
            XCTFail("exp not \(StringLiteral.self). got=\(String(describing: stmt))")
            return
        }
        
        let expectedValue = "hello world"
        XCTAssertTrue(literal.value == expectedValue, "literal.value not \(expectedValue). got=\(literal.value)")
    }
    
    func testIfExpression() {
        let input = "if (x < y) { x }"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let exp = stmt.expression as? IfExpression else {
            XCTFail("exp not \(IfExpression.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        testInfixExpression(exp.condition, left: "x", operator: "<", right: "y")
        
        guard exp.consequence.statements.count == 1 else {
            XCTFail("consequence is not 1 statements. got=\(exp.consequence.statements.count)")
            return
        }
        
        guard let consequence = exp.consequence.statements[0] as? ExpressionStatement else {
            XCTFail("statements[0] is not \(ExpressionStatement.self). got=\(type(of: exp.consequence.statements[0]))")
            return
        }
        
        testIdentifier(consequence.expression, value: "x")
        
        XCTAssertTrue(exp.alternative == nil, "exp.alternative.statements was not nil. got=\(type(of: exp.alternative))")
    }
    
    func testIfElseExpression() {
        let input = "if (x < y) { x } else { y }"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let exp = stmt.expression as? IfExpression else {
            XCTFail("exp not \(IfExpression.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        testInfixExpression(exp.condition, left: "x", operator: "<", right: "y")
        
        guard exp.consequence.statements.count == 1 else {
            XCTFail("consequence is not 1 statements. got=\(exp.consequence.statements.count)")
            return
        }
        
        guard let consequence = exp.consequence.statements[0] as? ExpressionStatement else {
            XCTFail("statements[0] is not \(ExpressionStatement.self). got=\(type(of: exp.consequence.statements[0]))")
            return
        }
        
        testIdentifier(consequence.expression, value: "x")
        
        guard exp.alternative?.statements.count == 1 else {
            XCTFail("alternative is not 1 statements. got=\(exp.alternative?.statements.count ?? 0)")
            return
        }
        
        guard let alternative = exp.alternative?.statements[0] as? ExpressionStatement else {
            XCTFail("statements[0] is not \(ExpressionStatement.self). got=\(type(of: exp.alternative?.statements[0]))")
            return
        }
        
        testIdentifier(alternative.expression, value: "y")
    }

    func testFunctionLiteralParsing() {
        let input = "fn(x, y) { x + y; }"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let exp = stmt.expression as? FunctionLiteral else {
            XCTFail("exp not \(FunctionLiteral.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        guard exp.parameters.count == 2 else {
            XCTFail("function literal parameters wrong. want 2, got=\(exp.parameters.count)")
            return
        }
        
        testLiteralExpression(exp.parameters[0], expected: "x")
        testLiteralExpression(exp.parameters[1], expected: "y")
        
        guard exp.body.statements.count == 1 else {
            XCTFail("function.body.statements has not 1 statements. got=\(exp.body.statements.count)")
            return
        }
        
        guard let bodyStmt = exp.body.statements[0] as? ExpressionStatement else {
            XCTFail("function body stmt is not \(ExpressionStatement.self). got=\(type(of: exp.body.statements[0]))")
            return
        }
        
        testInfixExpression(bodyStmt.expression, left: "x", operator: "+", right: "y")
    }
    
    func testFunctionParameterParsing() {
        let tests: [(input: String, expectedParams: [String])] = [
            ("fn() {};", []),
            ("fn(x) {};", ["x"]),
            ("fn(x, y, z) {};", ["x", "y", "z"]),
        ]
        
        tests.forEach {
            let l = Lexer(input: $0.input)
            let p = Parser(lexer: l)

            let program = p.parseProgram()
            checkParserErrors(p)

            guard let stmt = program.statements[0] as? ExpressionStatement else {
                XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
                return
            }

            guard let exp = stmt.expression as? FunctionLiteral else {
                XCTFail("exp not \(FunctionLiteral.self). got=\(String(describing: stmt.expression))")
                return
            }

            XCTAssertTrue(exp.parameters.count == $0.expectedParams.count, "length parameters wrong. want \($0.expectedParams.count), got=\(exp.parameters.count)")
            $0.expectedParams.enumerated().forEach {
                testLiteralExpression(exp.parameters[$0], expected: $1)
            }
        }
    }
    
    func testCallExpressionParsing() {
        let input = "add(1, 2 * 3, 4 + 5);"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let exp = stmt.expression as? CallExpression else {
            XCTFail("exp not \(CallExpression.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        testIdentifier(exp.function, value: "add")
        XCTAssertTrue(exp.arguments.count == 3, "wrong length of arguments. got=\(exp.arguments.count)")
        testLiteralExpression(exp.arguments[0], expected: 1)
        testInfixExpression(exp.arguments[1], left: 2, operator: "*", right: 3)
        testInfixExpression(exp.arguments[2], left: 4, operator: "+", right: 5)
    }
    
    func testParsingPrefixExpressions() {
        let prefixTests: [(input: String, operator: String, value: Any)] = [
            ("!5;", "!", 5),
            ("-15;", "-", 15),
            ("!true;", "!", true),
            ("!false;", "!", false),
        ]
        
        prefixTests.forEach {
            let l = Lexer(input: $0.input)
            let p = Parser(lexer: l)

            let program = p.parseProgram()
            checkParserErrors(p)

            guard program.statements.count == 1 else {
                XCTFail("program has not enough statements. got=\(program.statements.count)")
                return
            }

            guard let stmt = program.statements[0] as? ExpressionStatement else {
                XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
                return
            }

            guard let exp = stmt.expression as? PrefixExpression else {
                XCTFail("exp not \(PrefixExpression.self). got=\(String(describing: stmt.expression))")
                return
            }

            XCTAssertTrue(exp.operator == $0.operator, "exp.operator is not \($0.operator). got=\(exp.operator)")
            testLiteralExpression(exp.right, expected: $0.value)
        }
    }
    
    func testParsingInfixExpression() {
        let infixTests: [(input: String, leftValue: Any, operator: String, rightValue: Any)] = [
            ("5 + 5", 5, "+", 5),
            ("5 - 5", 5, "-", 5),
            ("5 * 5", 5, "*", 5),
            ("5 / 5", 5, "/", 5),
            ("5 > 5", 5, ">", 5),
            ("5 < 5", 5, "<", 5),
            ("5 == 5", 5, "==", 5),
            ("5 != 5", 5, "!=", 5),
            ("true == true", true, "==", true),
            ("true != false", true, "!=", false),
            ("false == false", false, "==", false),
        ]
        
        infixTests.forEach {
            let l = Lexer(input: $0.input)
            let p = Parser(lexer: l)

            let program = p.parseProgram()
            checkParserErrors(p)
            
            guard program.statements.count == 1 else {
                XCTFail("program has not enough statements. got=\(program.statements.count)")
                return
            }

            guard let stmt = program.statements[0] as? ExpressionStatement else {
                XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
                return
            }
            
            testInfixExpression(stmt.expression, left: $0.leftValue, operator: $0.operator, right: $0.rightValue)
        }
    }
    
    func testOperatorPrecedenceParsing() {
        let tests: [(input: String, expected: String)] = [
            ("-a * b", "((-a) * b)"),
            ("!-a", "(!(-a))"),
            ("a + b + c", "((a + b) + c)"),
            ("a + b - c", "((a + b) - c)"),
            ("a * b * c", "((a * b) * c)"),
            ("a * b / c", "((a * b) / c)"),
            ("a + b / c", "(a + (b / c))"),
            ("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"),
            ("3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"),
            ("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"),
            ("5 < 4 != 3 < 4", "((5 < 4) != (3 < 4))"),
            ("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
            ("true", "true"),
            ("false", "false"),
            ("3 > 5 == false", "((3 > 5) == false)"),
            ("3 < 5 == true", "((3 < 5) == true)"),
            ("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"),
            ("(5 + 5) * 2", "((5 + 5) * 2)"),
            ("2 / (5 + 5)", "(2 / (5 + 5))"),
            ("-(5 + 5)", "(-(5 + 5))"),
            ("!(true == true)", "(!(true == true))"),
            ("a + add(b * c) + d", "((a + add((b * c))) + d)"),
            ("add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"),
            ("add(a + b + c * d / f + g)", "add((((a + b) + ((c * d) / f)) + g))"),
            ("a * [1, 2, 3, 4][b * c] * d", "((a * ([1, 2, 3, 4][(b * c)])) * d)"),
            ("add(a * b[2], b[1], 2 * [1, 2][1])", "add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))")
        ]
        
        tests.forEach {
            let l = Lexer(input: $0.input)
            let p = Parser(lexer: l)

            let program = p.parseProgram()
            checkParserErrors(p)
            
            XCTAssertTrue(program.description == $0.expected, "exptected=\($0.expected), got=\(program.description)")
        }
    }
    
    func testParsingArrayLiterals() {
        let input = "[1, 2 * 2, 3 + 3];"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let exp = stmt.expression as? ArrayLiteral else {
            XCTFail("exp not \(ArrayLiteral.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        XCTAssertTrue(exp.elements.count == 3, "wrong length of elements. got=\(exp.elements.count)")
        testLiteralExpression(exp.elements[0], expected: 1)
        testInfixExpression(exp.elements[1], left: 2, operator: "*", right: 2)
        testInfixExpression(exp.elements[2], left: 3, operator: "+", right: 3)
    }
    
    func testParsingIndexExpressions() {
        let input = "myArray[1 + 1];"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let exp = stmt.expression as? IndexExpression else {
            XCTFail("exp not \(IndexExpression.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        testIdentifier(exp.left, value: "myArray")
        testInfixExpression(exp.index, left: 1, operator: "+", right: 1)
    }
    
    func testParsingHashLiteralsStringKeys() {
        let input = """
            {"one": 1, "two": 2, "three": 3}
        """
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let hash = stmt.expression as? HashLiteral else {
            XCTFail("exp not \(HashLiteral.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        XCTAssertTrue(hash.pairs.count == 3, "wrong length of pairs. got=\(hash.pairs.count)")
        
        let expected = ["one": 1, "two": 2, "three": 3]
        hash.pairs.forEach { pair in
            guard let literal = pair.key as? StringLiteral else {
                XCTFail("key is not \(StringLiteral.self). got=\(String(describing: pair.key))")
                return
            }
            guard let expectedValue = expected[literal.description] else {
                XCTFail("expected does not have \(literal.description).")
                return
            }
            testIntegerLiteral(pair.value, value: Int64(expectedValue))
        }
    }
    
    func testParsingHashLiteralsBooleanKeys() {
        let input = """
            {true: 1, false: 2}
        """
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let hash = stmt.expression as? HashLiteral else {
            XCTFail("exp not \(HashLiteral.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        XCTAssertTrue(hash.pairs.count == 2, "wrong length of pairs. got=\(hash.pairs.count)")
        
        let expected = ["true": 1, "false": 2]
        hash.pairs.forEach { pair in
            guard let literal = pair.key as? BooleanLiteral else {
                XCTFail("key is not \(BooleanLiteral.self). got=\(String(describing: pair.key))")
                return
            }
            guard let expectedValue = expected[literal.description] else {
                XCTFail("expected does not have \(literal.description).")
                return
            }
            testIntegerLiteral(pair.value, value: Int64(expectedValue))
        }
    }
    
    func testParsingHashLiteralsIntegerKeys() {
        let input = """
            {1: 1, 2: 2, 3: 3}
        """
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let hash = stmt.expression as? HashLiteral else {
            XCTFail("exp not \(HashLiteral.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        XCTAssertTrue(hash.pairs.count == 3, "wrong length of pairs. got=\(hash.pairs.count)")
        
        let expected = ["1": 1, "2": 2, "3": 3]
        hash.pairs.forEach { pair in
            guard let literal = pair.key as? IntegerLiteral else {
                XCTFail("key is not \(IntegerLiteral.self). got=\(String(describing: pair.key))")
                return
            }
            guard let expectedValue = expected[literal.description] else {
                XCTFail("expected does not have \(literal.description).")
                return
            }
            testIntegerLiteral(pair.value, value: Int64(expectedValue))
        }
    }
    
    func testParsingHashLiteralsWithExpressions() {
        let input = """
            {"one": 0 + 1, "two": 10 - 8, "three": 15 / 5}
        """
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let hash = stmt.expression as? HashLiteral else {
            XCTFail("exp not \(HashLiteral.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        XCTAssertTrue(hash.pairs.count == 3, "wrong length of pairs. got=\(hash.pairs.count)")
        
        typealias funcValue = (Expression) -> Void
        let expected: [String: funcValue] = [
            "one": { self.testInfixExpression($0, left: 0, operator: "+", right: 1) },
            "two": { self.testInfixExpression($0, left: 10, operator: "-", right: 8) },
            "three": { self.testInfixExpression($0, left: 15, operator: "/", right: 5) }]
        hash.pairs.forEach { pair in
            guard let literal = pair.key as? StringLiteral else {
                XCTFail("key is not \(StringLiteral.self). got=\(String(describing: pair.key))")
                return
            }
            guard let testFunc = expected[literal.description] else {
                XCTFail("expected does not have \(literal.description).")
                return
            }
            testFunc(pair.value)
        }
    }
    
    func testParsingEmptyHashLiteral() {
        let input = "{}"
        
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        checkParserErrors(p)
        
        guard program.statements.count == 1 else {
            XCTFail("program.statements does not contain 1 statements. got=\(program.statements.count)")
            return
        }
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail("program.statements[0] is not \(ExpressionStatement.self). got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let hash = stmt.expression as? HashLiteral else {
            XCTFail("exp not \(HashLiteral.self). got=\(String(describing: stmt.expression))")
            return
        }
        
        XCTAssertTrue(hash.pairs.count == 0, "hash.Pairs has wrong length. got=\(hash.pairs.count)")
    }
    
    private func testLetStatement(_ s: Statement, _ name: String) -> Bool {
        if s.tokenLiteral != "let" {
            XCTFail("s.tokenLiteral not 'let'. got=\(s.tokenLiteral)")
            return false
        }
        
        guard let letStmt = s as? LetStatement else {
            XCTFail("s not \(LetStatement.self). got=\(type(of: s))")
            return false
        }
        
        if letStmt.name.value != name {
            XCTFail("letStmt.name.value not '\(name)'. got=\(letStmt.name.value)")
            return false
        }
        
        if letStmt.name.tokenLiteral != name {
            XCTFail("letStmt.name.tokenLiteral not '\(name)'. got=\(letStmt.name.tokenLiteral)")
            return false
        }
        
        return true
    }
    
    private func testInfixExpression(_ exp: Expression?, left: Any, operator: String, right: Any) {
        guard let opExp = exp as? InfixExpression else {
            XCTFail("exp not \(InfixExpression.self). got=\(String(describing: exp))")
            return
        }

        testLiteralExpression(opExp.left, expected: left)
        XCTAssertTrue(opExp.operator == `operator`, "exp.operator is not \(`operator`). got=\(opExp.operator)")
        testLiteralExpression(opExp.right, expected: right)
    }
    
    private func testLiteralExpression(_ exp: Expression, expected: Any) {
        switch expected {
        case let value as Int:
            testIntegerLiteral(exp, value: Int64(value))
        case let value as Int64:
            testIntegerLiteral(exp, value: value)
        case let value as Bool:
            testBooleanLiteral(exp, value: value)
        case let value as String:
            testIdentifier(exp, value: value)
        default:
            XCTFail("type of exp not handled. got=\(exp)")
        }
    }
    
    private func testIntegerLiteral(_ il: Expression?, value: Int64) {
        guard let integ = il as? IntegerLiteral else {
            XCTFail("integ not \(IntegerLiteral.self). got=\(String(describing: il))")
            return
        }
        
        XCTAssertTrue(integ.value == value, "integ.value not \(value). got=\(integ.value)")
        XCTAssertTrue(integ.tokenLiteral == "\(value)", "integ.tokenLiteral not \(value). got=\(integ.tokenLiteral)")
    }
    
    private func testIdentifier(_ exp: Expression?, value: String) {
        guard let ident = exp as? Identifier else {
            XCTFail("ident not \(Identifier.self). got=\(String(describing: exp))")
            return
        }
        
        XCTAssertTrue(ident.value == value, "ident.value not foobar. got=\(ident.value)")
        XCTAssertTrue(ident.tokenLiteral == value, "ident.tokenLiteral not foobar. got=\(ident.tokenLiteral)")
    }
    
    private func testBooleanLiteral(_ exp: Expression?, value: Bool) {
        guard let bo = exp as? BooleanLiteral else {
            XCTFail("integ not \(BooleanLiteral.self). got=\(String(describing: exp))")
            return
        }
        
        XCTAssertTrue(bo.value == value, "bo.value not \(value). got=\(bo.value)")
        XCTAssertTrue(bo.tokenLiteral == "\(value)", "integ.tokenLiteral not \(value). got=\(bo.tokenLiteral)")
    }
    
    private func checkParserErrors(_ p: Parser) {
        let errors = p.errors
        guard errors.count > 0 else {
            return
        }
        print("parser has \(errors.count)")
        errors.forEach {
            print("parser error: \($0)")
        }
        XCTFail("ParseProgram() fail")
    }
}
