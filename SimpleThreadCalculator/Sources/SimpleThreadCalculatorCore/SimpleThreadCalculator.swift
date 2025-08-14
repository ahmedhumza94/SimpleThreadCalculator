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
    
    @Flag(name: .shortAndLong, help: "Verbose output with calculation breakdown by sequence")
    var verbose = false

    public init() { }
    
    public func run() throws {
        do {
            let calculator = try ReimbursementCalculator(file: file)
            let sequences = calculator.findSequences()
            var grandTotal = 0
            for sequence in sequences {
                if verbose {
                    print("Sequence: start date \(sequence.projects[0].startDate.formatted(date: .long, time: .omitted)), end date \(sequence.projects[sequence.projects.count - 1].endDate.formatted(date: .long, time: .omitted))")
                    print("Sequence Total: \(sequence.total)")
                }
                grandTotal += sequence.total
            }
            print("Grand Reimbursement Total: \(grandTotal)")
        } catch {
            throw error
        }
    }
}
