//
//  environment.swift
//  InterpreterInSwift
//
//  Created by Jongwon Woo on 2022/05/20.
//

import Foundation

class Environment {
    var store: [String: Object]
    var outer: Environment?
    
    init(store: [String: Object]) {
        self.store = store
    }
    
    func get(name: String) -> Object? {
        if let obj = store[name] {
            return obj
        }
        if let outer = outer {
            return outer.get(name: name)
        }
        return nil
    }
    
    @discardableResult
    func set(name: String, val: Object) -> Object {
        store[name] = val
        return val
    }
}

extension Environment {
    static func newEnclosedEnvironment(_ outer: Environment) -> Environment {
        let env = newEnvironment
        env.outer = outer
        return env
    }
    
    static var newEnvironment: Environment {
        return Environment(store: [:])
    }
}
