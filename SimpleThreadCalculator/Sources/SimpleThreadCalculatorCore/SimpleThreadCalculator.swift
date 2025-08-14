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
            let sequences = calculator.findSequences()
            for sequence in sequences {
                print("Sequence: start date \(sequence.projects[0].startDate), end date \(sequence.projects[sequence.projects.count - 1].endDate)")
            }
            var grandTotal = 0
            for sequence in sequences {
                grandTotal += sequence.total
            }
            print("Grand Total Reimbursement: \(grandTotal)")
        } catch {
            throw error
        }
    }
}
