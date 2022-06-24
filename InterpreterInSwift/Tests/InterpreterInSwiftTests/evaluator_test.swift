//
//  evaluator_test.swift
//  InterpreterInSwiftTests
//
//  Created by Jongwon Woo on 2022/05/12.
//

import XCTest

class evaluator_test: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEvalIntegerExpression() {
        let tests: [(input: String, expected: Int64)] = [
            ("5", 5),
            ("10", 10),
            ("-5", -5),
            ("-10", -10),
            ("5 + 5 + 5 + 5 - 10", 10),
            ("2 * 2 * 2 * 2 * 2", 32),
            ("-50 + 100 + -50", 0),
            ("5 * 2 + 10", 20),
            ("5 + 2 * 10", 25),
            ("20 + 2 * -10", 0),
            ("50 / 2 * 2 + 10", 60),
            ("2 * (5 + 10)", 30),
            ("3 * 3 * 3 + 10", 37),
            ("3 * (3 * 3) + 10", 37),
            ("(5 + 10 * 2 + 15 / 3) * 2 + -10", 50),
        ]
        
        tests.forEach {
            let evaluated = testEval($0.input)
            testIntegerObject(evaluated, expected: $0.expected)
        }
    }
    
    func testStringLiteral() {
        let input = "\"Hello World!\""
        
        let evaluated = testEval(input)
        guard let str = evaluated as? StringObject else {
            XCTFail("object is not String. got=\(type(of: evaluated)) (\(String(describing: evaluated)))")
            return
        }
        
        XCTAssertTrue(str.value == "Hello World!", "String has wrong value. got=\(str.value)")
    }
    
    func testEvalBooleanExpression() {
        let tests: [(input: String, expected: Bool)] = [
            ("true", true),
            ("false", false),
            ("1 < 2", true),
            ("1 < 2", true),
            ("1 > 2", false),
            ("1 < 1", false),
            ("1 > 1", false),
            ("1 == 1", true),
            ("1 != 1", false),
            ("1 == 2", false),
            ("1 != 2", true),
            ("true == true", true),
            ("false == false", true),
            ("true == false", false),
            ("true != false", true),
            ("false != true", true),
            ("(1 < 2) == true", true),
            ("(1 < 2) == false", false),
            ("(1 > 2) == true", false),
            ("(1 > 2) == false", true),
        ]
        
        tests.forEach {
            let evaluated = testEval($0.input)
            testBooleanObject(evaluated, expected: $0.expected)
        }
    }
    
    func testBangOperator() {
        let tests: [(input: String, expected: Bool)] = [
            ("!true", false),
            ("!false", true),
            ("!5", false),
            ("!!true", true),
            ("!!false", false),
            ("!!5", true),
        ]
        
        tests.forEach {
            let evaluated = testEval($0.input)
            testBooleanObject(evaluated, expected: $0.expected)
        }
    }
    
    func testIfElseExpressions() {
        let tests: [(input: String, expected: Any?)] = [
            ("if (true) { 10 }", 10),
            ("if (false) { 10 }", nil),
            ("if (1) { 10 }", 10),
            ("if (1 < 2) { 10 }", 10),
            ("if (1 > 2) { 10 }", nil),
            ("if (1 > 2) { 10 } else { 20 }", 20),
            ("if (1 < 2) { 10 } else { 20 }", 10),
        ]
        
        tests.forEach {
            let evaluated = testEval($0.input)
            if let integer = $0.expected as? Int {
                testIntegerObject(evaluated, expected: Int64(integer))
            } else {
                testNullObject(evaluated)
            }
        }
    }
    
    func testReturnStatements() {
        let tests: [(input: String, expected: Int64)] = [
            ("return 10;", 10),
            ("return 10; 9;", 10),
            ("return 2 * 5; 9;", 10),
            ("9; return 2 * 5; 9;", 10),
            ("""
                if (10 > 1) {
                  if (10 > 1) {
                    return 10;
                  }
                
                  return 1;
                }
            """,
             10),
        ]
        
        tests.forEach {
            let evaluated = testEval($0.input)
            testIntegerObject(evaluated, expected: $0.expected)
        }
    }
    
    func testErrorHandling() {
        let tests: [(input: String, expectedMessage: String)] = [
            (
                "5 + true;",
                "type mismatch: INTEGER + BOOLEAN"
            ),
            (
                "5 + true; 5;",
                "type mismatch: INTEGER + BOOLEAN"
            ),
            (
                "-true",
                "unknown operator: -BOOLEAN"
            ),
            (
                "true + false;",
                "unknown operator: BOOLEAN + BOOLEAN"
            ),
            (
                "5; true + false; 5",
                "unknown operator: BOOLEAN + BOOLEAN"
            ),
            (
                """
                    "Hello" - "World"
                """,
                "unknown operator: STRING - STRING"
            ),
            (
                "if (10 > 1) { true + false; }",
                "unknown operator: BOOLEAN + BOOLEAN"
            ),
            (
                """
                    if (10 > 1) {
                      if (10 > 1) {
                        return true + false;
                      }
                    
                      return 1;
                    }
                """,
                "unknown operator: BOOLEAN + BOOLEAN"
            ),
            (
                "foobar",
                "identifier not found: foobar"
            ),
            (
                """
                    {"name": "Monkey"}[fn(x) { x }];
                """,
                "unusable as hash key: FUNCTION"
            ),
        ]
        
        tests.forEach {
            let evaluated = testEval($0.input)
            if let errObj = evaluated as? ErrorObject {
                XCTAssertTrue(errObj.message == $0.expectedMessage, "wrong error message. expected=\($0.expectedMessage), got=\(errObj.message)")
            } else {
                XCTFail("no error object returned. got=\(type(of: evaluated)) (\(String(describing: evaluated)))")
            }
        }
    }
    
    func testLetStatements() {
        let tests: [(input: String, expected: Int64)] = [
            ("let a = 5; a;", 5),
            ("let a = 5 * 5; a;", 25),
            ("let a = 5; let b = a; b;", 5),
            ("let a = 5; let b = a; let c = a + b + 5; c;", 15),
        ]
        
        tests.forEach {
            testIntegerObject(testEval($0.input), expected: $0.expected)
        }
    }
    
    func testFunctionObject() {
        let input = "fn(x) { x + 2; };"
        
        let evaluated = testEval(input)
        guard let fn = evaluated as? FunctionObject else {
            XCTFail("object is not Function. got=\(type(of: evaluated)) (\(String(describing: evaluated)))")
            return
        }
        
        XCTAssertTrue(fn.parameters.count == 1, "function has wrong parameters. Parameters=\(fn.parameters.count)")
        XCTAssertTrue(fn.parameters.first?.description == "x", "parameter is not 'x'. got=\(String(describing: fn.parameters.first))")

        let expectedBody = "(x + 2)"
        XCTAssertTrue(fn.body.description == expectedBody, "body is not \(expectedBody). got=\(fn.body.description)")
    }
    
    func testFunctionApplication() {
        let tests: [(input: String, expected: Int64)] = [
            ("let identity = fn(x) { x; }; identity(5);", 5),
            ("let identity = fn(x) { return x; }; identity(5);", 5),
            ("let double = fn(x) { x * 2; }; double(5);", 10),
            ("let add = fn(x, y) { x + y; }; add(5, 5);", 10),
            ("let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));", 20),
            ("fn(x) { x; }(5)", 5),
        ]
        
        tests.forEach {
            testIntegerObject(testEval($0.input), expected: $0.expected)
        }
    }
    
    func testClosure() {
        let input = """
        let newAdder = fn(x) {
            fn(y) { x + y };
        };
        
        let addTwo = newAdder(2);
        addTwo(2);
        """
        
        testIntegerObject(testEval(input), expected: 4)
    }
    
    func testStringConcatenation() {
        let input = """
        "Hello" + " " + "World!"
        """
        
        let evaluated = testEval(input)
        guard let str = evaluated as? StringObject else {
            XCTFail("object is not String. got=\(type(of: evaluated)) (\(String(describing: evaluated)))")
            return
        }
        
        XCTAssertTrue(str.value == "Hello World!", "String has wrong value. got=\(str.value)")
    }
    
    func testBuiltinFunctions() {
        let tests: [(input: String, expected: Any?)] = [
            (
                """
                    len("")
                """,
                0
            ),
            (
                """
                    len("four")
                """,
                4
            ),
            (
                """
                    len("hello world")
                """,
                11
            ),
            (
                """
                    len(1)
                """,
                "argument to `len` not supported, got IntegerObject"
            ),
            (
                """
                    len("one", "two")
                """,
                "wrong number of arguments. got=2, want=1"
            ),
            (
                """
                    len([1, 2, 3])
                """,
                3
            ),
            (
                """
                    len([])
                """,
                0
            ),
            (
                """
                    first([1, 2, 3])
                """,
                1
            ),
            (
                """
                    first([])
                """,
                nil
            ),
            (
                """
                    first(1)
                """,
                "argument to `first` must be ARRAY, got IntegerObject"
            ),
            (
                """
                    last([1, 2, 3])
                """,
                3
            ),
            (
                """
                    last([])
                """,
                nil
            ),
            (
                """
                    last(1)
                """,
                "argument to `last` must be ARRAY, got IntegerObject"
            ),
            (
                """
                    rest([1, 2, 3])
                """,
                [2, 3]
            ),
            (
                """
                    rest([])
                """,
                nil
            ),
            (
                """
                    push([], 1)
                """,
                [1]
            ),
            (
                """
                    push([1], 2)
                """,
                [1, 2]
            ),
            (
                """
                    push(1, 1)
                """,
                "argument to `push` must be ARRAY, got IntegerObject"
            ),
            (
                // `rest([])` returns `NULL`. `len(rest([]))` returns 0.
                """
                    len(rest([]))
                """,
                0
            ),
        ]
        
        tests.forEach {
            let evaluated = testEval($0.input)
            switch $0.expected {
            case let int as Int:
                testIntegerObject(evaluated, expected: Int64(int))
            case let string as String:
                guard let errObj = evaluated as? ErrorObject else {
                    XCTFail("object is not Error. got=\(type(of: evaluated)) (\(String(describing: evaluated)))")
                    return
                }
                XCTAssertTrue(errObj.message == string, "wrong error message. expected=\(string), got=\(errObj.message)")
            case let array as [Int]:
                guard let arrayObj = evaluated as? ArrayObject else {
                    XCTFail("object is not Array. got=\(type(of: evaluated)) (\(String(describing: evaluated)))")
                    return
                }
                guard arrayObj.elements.count == array.count else {
                    XCTFail("wrong num of elements. want=\(array.count) got=\(arrayObj.elements.count)")
                    return
                }
                array.enumerated().forEach {
                    testIntegerObject(arrayObj.elements[$0], expected: Int64($1))
                }
            default:
                testNullObject(evaluated)
            }
        }
    }
    
    func testArrayObject() {
        let input = "[1, 2 * 2, 3 + 3];"
        
        let evaluated = testEval(input)
        guard let result = evaluated as? ArrayObject else {
            XCTFail("object is not Array. got=\(type(of: evaluated)) (\(String(describing: evaluated)))")
            return
        }
        
        XCTAssertTrue(result.elements.count == 3, "array has wrong number of elements. got=\(result.elements.count)")
        testIntegerObject(result.elements[0], expected: 1)
        testIntegerObject(result.elements[1], expected: 4)
        testIntegerObject(result.elements[2], expected: 6)
    }
    
    func testArrayIndexExpressions() {
        let tests: [(input: String, expected: Any?)] = [
            (
                """
                    [1, 2, 3][0]
                """,
                1
            ),
            (
                """
                    [1, 2, 3][1]
                """,
                2
            ),
            (
                """
                    [1, 2, 3][2]
                """,
                3
            ),
            (
                """
                    let i = 0; [1][i];
                """,
                1
            ),
            (
                """
                    [1, 2, 3][1 + 1];
                """,
                3
            ),
            (
                """
                    let myArray = [1, 2, 3]; myArray[2];
                """,
                3
            ),
            (
                """
                    let myArray = [1, 2, 3]; myArray[0] + myArray[1] + myArray[2];
                """,
                6
            ),
            (
                """
                    let myArray = [1, 2, 3]; let i = myArray[0]; myArray[i]
                """,
                2
            ),
            (
                """
                    [1, 2, 3][3]
                """,
                nil
            ),
            (
                """
                    [1, 2, 3][-1]
                """,
                nil
            )
        ]
        
        tests.forEach {
            let evaluated = testEval($0.input)
            switch $0.expected {
            case let int as Int:
                testIntegerObject(evaluated, expected: Int64(int))
            default:
                testNullObject(evaluated)
            }
        }
    }
    
    func testHashLiterals() {
        let input = """
            let two = "two";
            {
                "one": 10 - 9,
                two: 1 + 1,
                "thr" + "ee": 6 / 2,
                4: 4,
                true: 5,
                false: 6
            }
        """
        
        let evaluated = testEval(input)
        guard let result = evaluated as? HashObject else {
            XCTFail("Eval didn't return Hash. got=\(type(of: evaluated)) (\(String(describing: evaluated)))")
            return
        }
        
        let expected: [HashKey: Int64] = [
            StringObject(value: "one").hashKey: 1,
            StringObject(value: "two").hashKey: 2,
            StringObject(value: "three").hashKey: 3,
            IntegerObject(value: 4).hashKey: 4,
            TRUE.hashKey: 5,
            FALSE.hashKey: 6
        ]
        
        XCTAssertTrue(result.pairs.count == expected.count, "hash has wrong number of pairs. got=\(result.pairs.count)")
        expected.forEach { (expectedKey: HashKey, expectedValue: Int64) in
            guard let pair = result.pairs[expectedKey] else {
                XCTFail("no pair for given key in Pairs")
                return
            }
            testIntegerObject(pair.value, expected: expectedValue)
        }
    }
    
    func testHashIndexExpressions() {
        let tests: [(input: String, expected: Any?)] = [
            (
                """
                    {"foo": 5}["foo"]
                """,
                5
            ),
            (
                """
                    {"foo": 5}["bar"]
                """,
                nil
            ),
            (
                """
                    let key = "foo"; {"foo": 5}[key]
                """,
                5
            ),
            (
                """
                    {}["foo"]
                """,
                nil
            ),
            (
                """
                    {5: 5}[5]
                """,
                5
            ),
            (
                """
                    {true: 5}[true]
                """,
                5
            ),
            (
                """
                    {false: 5}[false]
                """,
                5
            ),
        ]
        
        tests.forEach {
            let evaluated = testEval($0.input)
            switch $0.expected {
            case let int as Int:
                testIntegerObject(evaluated, expected: Int64(int))
            default:
                testNullObject(evaluated)
            }
        }
    }
    
    private func testEval(_ input: String) -> Object? {
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        let program = p.parseProgram()
        let env = Environment.newEnvironment
        return eval(program, env: env)
    }
    
    private func testIntegerObject(_ obj: Object?, expected: Int64) {
        guard let result = obj as? IntegerObject else {
            XCTFail("object is not Integer. got=\(type(of: obj)) (\(String(describing: obj)))")
            return
        }
        
        XCTAssertTrue(result.value == expected, "object has wrong value. got=\(result.value), want=\(expected)")
    }
    
    private func testBooleanObject(_ obj: Object?, expected: Bool) {
        guard let result = obj as? BooleanObject else {
            XCTFail("object is not Boolean. got=\(type(of: obj)) (\(String(describing: obj)))")
            return
        }
        
        XCTAssertTrue(result.value == expected, "object has wrong value. got=\(result.value), want=\(expected)")
    }
    
    private func testNullObject(_ obj: Object?) {
        guard let _ = obj as? NullObject else {
            XCTFail("object is not NULL. got=\(type(of: obj)) (\(String(describing: obj)))")
            return
        }
    }
}
