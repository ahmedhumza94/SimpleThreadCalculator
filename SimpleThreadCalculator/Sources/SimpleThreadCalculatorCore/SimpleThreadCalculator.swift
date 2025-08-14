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
    
    public init() { }
    public func run() throws {
        print("File: \(file)")
    }
}
