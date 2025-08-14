//
//  SimpleThreadCalculator.swift
//  SimpleThreadCalculator
//
//  Created by Humza Ahmed on 8/14/25.
//

import Foundation
import ArgumentParser

public struct SimpleThreadCalculator: ParsableCommand {
    
    @Argument(help: "The input JSON file containing an array of projects and associated metadata")
    var file: String
    
    @Flag(name: .shortAndLong, help: "Verbose output with calculation breakdown")
    var verbose = false

    public init() { }
    public func run() throws {
        do {
            let calculator = try ReimbursementCalculator(file: file)
        } catch {
            throw error
        }
    }
}
