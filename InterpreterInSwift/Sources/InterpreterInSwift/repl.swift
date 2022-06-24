//
//  File.swift
//  
//
//  Created by Jongwon Woo on 2022/02/21.
//

import Foundation

struct REPL {

    let env: Environment
    
    public init() {
        env = Environment.newEnvironment
    }

    func start(with input: String) {
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        
        let program = p.parseProgram()
        guard p.errors.count == 0 else {
            printParseErrors(p.errors)
            return
        }
        
        if let evaluated = eval(program, env: env) {
            print("\(evaluated.inspect)")
        }
    }
    
    private func printParseErrors(_ errors: [String]) {
        errors.forEach {
            print("parser error: \($0)")
        }
    }
}
