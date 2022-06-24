//
//  builtins.swift
//  InterpreterInSwift
//
//  Created by Jongwon Woo on 2022/06/02.
//

import Foundation

/*
 Test `map`.
 
 let map = fn(arr, f) { let iter = fn(arr, accumulated) { if (len(arr) == 0) { accumulated } else { iter(rest(arr), push(accumulated, f(first(arr))));}}; iter(arr,[]);};
 let a = [1, 2]
 let double = fn(x) { x * 2 }
 map(a, double)
 */

/*
 Test `reduce`.
 
 let reduce = fn(arr, initial, f) { let iter = fn(arr, result) { if (len(arr) == 0) { result } else { iter(rest(arr), f(result, first(arr))); } }; iter(arr, initial); };
 let sum = fn(arr) { reduce(arr, 0, fn(initial, el) { initial + el }); };
 sum([1, 2, 3, 4, 5])
 */

var builtins = [
    "len": BuiltinObject(fn: { args in
        guard args.count == 1 else {
            return newError(format: "wrong number of arguments. got=%d, want=1", args: args.count)
        }
        switch args[0] {
        case let array as ArrayObject:
            return IntegerObject(value: Int64(array.elements.count))
        case let string as StringObject:
            return IntegerObject(value: Int64(string.value.count))
        case _ as NullObject:
            return IntegerObject(value: 0)
        default:
            return newError(format: "argument to `len` not supported, got %@", args: String(describing: type(of: args[0])))
        }
    }),
    "puts": BuiltinObject(fn: { args in
        args.forEach { arg in
            print("\(arg.inspect)")
        }
        return NULL
    }),
    "first": BuiltinObject(fn: { args in
        guard args.count == 1 else {
            return newError(format: "wrong number of arguments. got=%d, want=1", args: args.count)
        }
        switch args[0] {
        case let array as ArrayObject:
            return array.elements.first ?? NULL
        default:
            return newError(format: "argument to `first` must be ARRAY, got %@", args: String(describing: type(of: args[0])))
        }
    }),
    "last": BuiltinObject(fn: { args in
        guard args.count == 1 else {
            return newError(format: "wrong number of arguments. got=%d, want=1", args: args.count)
        }
        switch args[0] {
        case let array as ArrayObject:
            return array.elements.last ?? NULL
        default:
            return newError(format: "argument to `last` must be ARRAY, got %@", args: String(describing: type(of: args[0])))
        }
    }),
    "rest": BuiltinObject(fn: { args in
        guard args.count == 1 else {
            return newError(format: "wrong number of arguments. got=%d, want=1", args: args.count)
        }
        switch args[0] {
        case let array as ArrayObject:
            let rest = array.elements.dropFirst()
            guard rest.count > 0 else {
                return NULL
            }
            return ArrayObject(elements: Array(rest))
        default:
            return newError(format: "argument to `rest` must be ARRAY, got %@", args: String(describing: type(of: args[0])))
        }
    }),
    "push": BuiltinObject(fn: { args in
        guard args.count == 2 else {
            return newError(format: "wrong number of arguments. got=%d, want=2", args: args.count)
        }
        switch args[0] {
        case let array as ArrayObject:
            var newElements = array.elements
            newElements.append(args[1])
            return ArrayObject(elements: newElements)
        default:
            return newError(format: "argument to `push` must be ARRAY, got %@", args: String(describing: type(of: args[0])))
        }
    })
]
