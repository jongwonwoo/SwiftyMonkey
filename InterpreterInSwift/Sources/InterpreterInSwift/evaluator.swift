//
//  evaluator.swift
//  InterpreterInSwift
//
//  Created by Jongwon Woo on 2022/05/12.
//

import Foundation

let NULL = NullObject()
let TRUE = BooleanObject(value: true)
let FALSE = BooleanObject(value: false)

func eval(_ node: Node, env: Environment) -> Object? {
    switch node {
    case let program as Program:
        return evalProgram(program, env: env)
    case let expression as ExpressionStatement:
        guard let exp = expression.expression else {
            return nil
        }
        return eval(exp, env: env)
    case let integerLiteral as IntegerLiteral:
        return IntegerObject(value: integerLiteral.value)
    case let stringLiteral as StringLiteral:
        return StringObject(value: stringLiteral.value)
    case let boolean as BooleanLiteral:
        return nativeBoolToBooleanObject(boolean.value)
    case let prefixExpression as PrefixExpression:
        guard let right = eval(prefixExpression.right, env: env) else {
            return nil
        }
        guard !isError(right) else {
            return right
        }
        return evalPrefixExpression(prefixExpression.operator, right: right)
    case let infixExpression as InfixExpression:
        guard let left = eval(infixExpression.left, env: env) else {
            return nil
        }
        guard !isError(left) else {
            return left
        }
        guard let right = eval(infixExpression.right, env: env) else {
            return nil
        }
        guard !isError(right) else {
            return right
        }
        return evalInfixExpression(infixExpression.operator, left: left, right: right)
    case let blockStatement as BlockStatement:
        return evalBlockStatements(blockStatement, env: env)
    case let ifExpression as IfExpression:
        return evalIfExpression(ifExpression, env: env)
    case let returnStatement as ReturnStatement:
        guard let returnValue = returnStatement.returnValue,
                let val = eval(returnValue, env: env) else {
            return nil
        }
        guard !isError(val) else {
            return val
        }
        return ReturnValueObject(value: val)
    case let letStatement as LetStatement:
        guard let letValue = letStatement.value, let val = eval(letValue, env: env) else {
            return nil
        }
        guard !isError(val) else {
            return val
        }
        return env.set(name: letStatement.name.value, val: val)
    case let identifier as Identifier:
        return evalIdentifier(identifier, env: env)
    case let functionLiteral as FunctionLiteral:
        return FunctionObject(parameters: functionLiteral.parameters, body: functionLiteral.body, env: env)
    case let callExpression as CallExpression:
        guard let function = eval(callExpression.function, env: env) else {
            return nil
        }
        guard !isError(function) else {
            return function
        }
        let args = evalExpression(callExpression.arguments, env: env)
        if args.count == 1, let first = args.first, isError(first) {
            return first
        }
        return applyFunction(function, args: args)
    case let arrayLiteral as ArrayLiteral:
        let elements = evalExpression(arrayLiteral.elements, env: env)
        if elements.count == 1, let first = elements.first, isError(first) {
            return first
        }
        return ArrayObject(elements: elements)
    case let hashLiteral as HashLiteral:
        return evalHashLiteral(hashLiteral, env: env)
    case let indexExpression as IndexExpression:
        guard let left = eval(indexExpression.left, env: env) else {
            return nil
        }
        guard !isError(left) else {
            return left
        }
        guard let index = eval(indexExpression.index, env: env) else {
            return nil
        }
        guard !isError(index) else {
            return index
        }
        return evalIndexExpression(left, index)
    default:
        return nil
    }
}

func evalProgram(_ program: Program, env: Environment) -> Object? {
    var result: Object?
    
    for statement in program.statements {
        result = eval(statement, env: env)
        
        if let returnValue = result as? ReturnValueObject {
            return returnValue.value
        } else if let error = result as? ErrorObject {
            return error
        }
    }
    
    return result
}

func evalBlockStatements(_ block: BlockStatement, env: Environment) -> Object? {
    var result: Object?
    
    for statement in block.statements {
        result = eval(statement, env: env)
        
        if let result = result,
           (result.type == ObjectType.RETURN_VALUE_OBJ || result.type == ObjectType.ERROR_OBJ) {
            return result
        }
    }
    
    return result
}

func evalPrefixExpression(_ operator: String, right: Object) -> Object {
    switch `operator` {
    case "!":
        return evalBangOperatorExpression(right)
    case "-":
        return evalMinusPrefixOperatorExpression(right)
    default:
        return newError(format: "unknown operator: %@%@", args: `operator`, right.type)
    }
}

func evalBangOperatorExpression(_ right: Object) -> Object {
    switch right {
    case let booleanObject as BooleanObject where booleanObject.value:
        return FALSE
    case let booleanObject as BooleanObject where !booleanObject.value:
        return TRUE
    case _ as NullObject:
        return TRUE
    default:
        return FALSE
    }
}

func evalMinusPrefixOperatorExpression(_ right: Object) -> Object {
    switch right {
    case let integerObject as IntegerObject:
        return IntegerObject(value: -integerObject.value)
    default:
        return newError(format: "unknown operator: -%@", args: right.type)
    }
}

func evalInfixExpression(_ operator: String, left: Object, right: Object) -> Object {
    switch (left, right) {
    case (let leftIntegerObject as IntegerObject, let rightIntegerObject as IntegerObject):
        return evalIntegerInfixExpression(`operator`, left: leftIntegerObject, right: rightIntegerObject)
    case (let leftStringObject as StringObject, let rightStringObject as StringObject):
        return evalStringInfixExpression(`operator`, left: leftStringObject, right: rightStringObject)
    case (let leftBooleanObject as BooleanObject, let rightBooleanObject as BooleanObject) where `operator` == "==":
        return nativeBoolToBooleanObject(leftBooleanObject.value == rightBooleanObject.value)
    case (let leftBooleanObject as BooleanObject, let rightBooleanObject as BooleanObject) where `operator` == "!=":
        return nativeBoolToBooleanObject(leftBooleanObject.value != rightBooleanObject.value)
    case _ where left.type != right.type:
        return newError(format: "type mismatch: %@ %@ %@", args: left.type, `operator`, right.type)
    default:
        return newError(format: "unknown operator: %@ %@ %@", args: left.type, `operator`, right.type)
    }
}

func evalIntegerInfixExpression(_ operator: String, left: IntegerObject, right: IntegerObject) -> Object {
    let leftVal = left.value
    let rightVal = right.value
    switch `operator` {
    case "+":
        return IntegerObject(value: leftVal + rightVal)
    case "-":
        return IntegerObject(value: leftVal - rightVal)
    case "*":
        return IntegerObject(value: leftVal * rightVal)
    case "/":
        return IntegerObject(value: leftVal / rightVal)
    case "<":
        return nativeBoolToBooleanObject(leftVal < rightVal)
    case ">":
        return nativeBoolToBooleanObject(leftVal > rightVal)
    case "==":
        return nativeBoolToBooleanObject(leftVal == rightVal)
    case "!=":
        return nativeBoolToBooleanObject(leftVal != rightVal)
    default:
        return newError(format: "unknown operator: %@ %@ %@", args: left.type, `operator`, right.type)
    }
}

func evalStringInfixExpression(_ operator: String, left: StringObject, right: StringObject) -> Object {
    guard `operator` == "+" else {
        return newError(format: "unknown operator: %@ %@ %@", args: left.type, `operator`, right.type)
    }
    
    let leftVal = left.value
    let rightVal = right.value
    return StringObject(value: leftVal + rightVal)
}

func evalIfExpression(_ ie: IfExpression, env: Environment) -> Object? {
    guard let condition = eval(ie.condition, env: env) else {
        return nil
    }
    guard !isError(condition) else {
        return condition
    }
    
    if isTruthy(condition) {
        return eval(ie.consequence, env: env)
    } else if let alt = ie.alternative {
        return eval(alt, env: env)
    } else {
        return NULL
    }
}

func evalIdentifier(_ id: Identifier, env: Environment) -> Object? {
    guard let val = env.get(name: id.value) else {
        if let builtin = builtins[id.value] {
            return builtin
        }
        return newError(format: "identifier not found: %@", args: id.value)
    }
    
    
    return val
}

func evalExpression(_ exps: [Expression], env: Environment) -> [Object] {
    var result = [Object]()
    
    for e in exps {
        guard let evaluated = eval(e, env: env) else {
            return []
        }
        guard !isError(evaluated) else {
            return [evaluated]
        }
        result.append(evaluated)
    }
    
    return result
}

func applyFunction(_ fn: Object, args: [Object]) -> Object? {
    switch fn {
    case let function as FunctionObject:
        let extendedEnv = extendFunctionEnv(function, args: args)
        let evaluated = eval(function.body, env: extendedEnv)
        return unwrapReturnValue(evaluated)
    case let builtin as BuiltinObject:
        return builtin.fn(args)
    default:
        return newError(format: "not a function: %@", args: fn.type)
    }
}

func extendFunctionEnv(_ fn: FunctionObject, args: [Object]) -> Environment {
    let env = Environment.newEnclosedEnvironment(fn.env)
    fn.parameters.enumerated().forEach { paramIdx, param in
        env.set(name: param.value, val: args[paramIdx])
    }
    return env
}

func unwrapReturnValue(_ obj: Object?) -> Object? {
    if let returnValue = obj as? ReturnValueObject {
        return returnValue.value
    }
    
    return obj
}

func evalIndexExpression(_ left: Object, _ index: Object) -> Object? {
    switch (left, index) {
    case (let leftObj as ArrayObject, let indexObj as IntegerObject):
        return evalArrayIndexExpression(leftObj, indexObj)
    case (let leftObj as HashObject, _):
        return evalHashIndexExpression(leftObj, index)
    default:
        return newError(format: "index operator not supported: %@", args: left.type)
    }
}

func evalArrayIndexExpression(_ array: ArrayObject, _ index: IntegerObject) -> Object? {
    let idx = Int(index.value)
    let max = array.elements.count - 1
    if idx < 0 || idx > max {
        return NULL
    }
    return array.elements[idx]
}

func evalHashIndexExpression(_ hash: HashObject, _ index: Object) -> Object? {
    guard let key = index as? HashableObject else {
        return newError(format: "unusable as hash key: %@", args: index.type)
    }
    
    guard let pair = hash.pairs[key.hashKey] else {
        return NULL
    }
    return pair.value
}

func evalHashLiteral(_ node: HashLiteral, env: Environment) -> Object? {
    var pairs = [HashKey: HashObjectPair]()
    
    for hashPair in node.pairs {
        guard let key = eval(hashPair.key, env: env) else {
            return nil
        }
        if isError(key) {
            return key
        }
        
        guard let hashKey = key as? HashableObject else {
            return newError(format: "unusable as hash key: %@", args: key.type)
        }
        
        guard let value = eval(hashPair.value, env: env) else {
            return nil
        }
        if isError(value) {
            return value
        }
        
        let hashed = hashKey.hashKey
        pairs[hashed] = HashObjectPair(key: key, value: value)
    }
    
    return HashObject(pairs: pairs)
}

func nativeBoolToBooleanObject(_ input: Bool) -> BooleanObject {
    return input ? TRUE : FALSE
}

func isTruthy(_ obj: Object) -> Bool {
    switch obj {
    case _ as NullObject:
        return false
    case let booleanObject as BooleanObject where booleanObject.value:
        return true
    case let booleanObject as BooleanObject where !booleanObject.value:
        return false
    default:
        return true
    }
}

func newError(format: String, args: CVarArg...) -> ErrorObject {
    return ErrorObject(message: String(format: format, arguments: args))
}

func isError(_ obj: Object) -> Bool {
    return obj.type == ObjectType.ERROR_OBJ
}
