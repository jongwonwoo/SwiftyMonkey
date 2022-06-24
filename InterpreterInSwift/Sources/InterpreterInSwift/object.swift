//
//  object.swift
//  InterpreterInSwift
//
//  Created by Jongwon Woo on 2022/05/06.
//

typealias ObjectType = String
typealias BuiltinFunction = ([Object]) -> Object

extension ObjectType {
    static var NULL_OBJ = "NULL"
    static var ERROR_OBJ = "ERROR"

    static var INTEGER_OBJ = "INTEGER"
    static var BOOLEAN_OBJ = "BOOLEAN"
    static var STRING_OBJ = "STRING"

    static var RETURN_VALUE_OBJ = "RETURN_VALUE"

    static var FUNCTION_OBJ = "FUNCTION"
    static var BUILTIN_OBJ = "BUILTIN"
    
    static var ARRAY_OBJ = "ARRAY"
    static var HASH_OBJ = "HASH"
}

protocol Object {
    var type: ObjectType { get }
    var inspect: String { get }
}

struct IntegerObject: Object, HashableObject {
    let value: Int64
    
    var type: ObjectType {
        ObjectType.INTEGER_OBJ
    }
    
    var inspect: String {
        "\(value)"
    }
    
    var hashKey: HashKey {
        HashKey(type: type, value: value)
    }
}

struct BooleanObject: Object, HashableObject {
    let value: Bool

    var type: ObjectType {
        ObjectType.BOOLEAN_OBJ
    }
    
    var inspect: String {
        "\(value)"
    }
    
    var hashKey: HashKey {
        HashKey(type: type, value: value ? 1 : 0)
    }
}

struct StringObject: Object, HashableObject {
    let value: String
    
    var type: ObjectType {
        ObjectType.STRING_OBJ
    }
    
    var inspect: String {
        value
    }
    
    var hashKey: HashKey {
        HashKey(type: type, value: Int64(value.hashValue))
    }
}

struct NullObject: Object {
    var type: ObjectType {
        ObjectType.NULL_OBJ
    }
    
    var inspect: String {
        "null"
    }
}

struct ReturnValueObject: Object {
    let value: Object
    
    var type: ObjectType {
        ObjectType.RETURN_VALUE_OBJ
    }
    
    var inspect: String {
        value.inspect
    }
}

struct FunctionObject: Object {
    let parameters: [Identifier]
    let body: BlockStatement
    let env: Environment
    
    var type: ObjectType {
        ObjectType.FUNCTION_OBJ
    }
    
    var inspect: String {
        "fn(\(parameters.map { "\($0.description)" }.joined(separator: ", "))) {\n\(body.description)\n}"
    }
}

struct ErrorObject: Object {
    let message: String
    
    var type: ObjectType {
        ObjectType.ERROR_OBJ
    }
    
    var inspect: String {
        "ERROR: \(message)"
    }
}

struct BuiltinObject: Object {
    let fn: BuiltinFunction
    
    var type: ObjectType {
        ObjectType.BUILTIN_OBJ
    }
    
    var inspect: String {
        "builtin function"
    }
}

struct ArrayObject: Object {
    let elements: [Object]
    
    var type: ObjectType {
        ObjectType.ARRAY_OBJ
    }
    
    var inspect: String {
        "[\(elements.map { "\($0.inspect)" }.joined(separator: ", "))]"
    }
}

struct HashObject: Object {
    let pairs: [HashKey: HashObjectPair]
    
    var type: ObjectType {
        ObjectType.HASH_OBJ
    }
    
    var inspect: String {
        "{\(pairs.map { "\($1.key.inspect): \($1.value.inspect)" }.joined(separator: ", "))}"
    }
}

struct HashKey {
    let type: ObjectType
    let value: Int64
}

extension HashKey: Equatable {}
extension HashKey: Hashable {}

struct HashObjectPair {
    let key: Object
    let value: Object
}

protocol HashableObject {
    var hashKey: HashKey { get }
}
