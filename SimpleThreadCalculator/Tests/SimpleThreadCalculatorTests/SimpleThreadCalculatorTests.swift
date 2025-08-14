//
//  SimpleThreadCalculatorTests.swift
//  SimpleThreadCalculator
//
//  Created by Humza Ahmed on 8/14/25.
//

import XCTest
import Foundation
@testable import SimpleThreadCalculatorCore

final class SimpleThreadCalculatorTests: XCTestCase {
    
    // MARK: - Test Setup
    
    func createTestProjectsJSON() -> String {
        let testData = """
        [
            {
                "id": 1,
                "projects": [
                    {
                        "name": "Test Project 1",
                        "city_type": "low",
                        "start_date": "10/1/24",
                        "end_date": "10/3/24"
                    },
                    {
                        "name": "Test Project 2", 
                        "city_type": "high",
                        "start_date": "10/4/24",
                        "end_date": "10/5/24"
                    }
                ]
            }
        ]
        """
        
        let tempDir = NSTemporaryDirectory()
        let testFilePath = tempDir + "test_projects.json"
        
        try! testData.write(to: URL(fileURLWithPath: testFilePath), atomically: true, encoding: .utf8)
        return testFilePath
    }
    
    // MARK: - File Finding Tests
    
    func testFileExists() throws {
        let testFilePath = createTestProjectsJSON()
        
        let fileExists = FileManager.default.fileExists(atPath: testFilePath)
        XCTAssertTrue(fileExists, "Test file should exist at path: \(testFilePath)")
        
        // Clean up
        try FileManager.default.removeItem(atPath: testFilePath)
    }
    
    func testFileNotFound() throws {
        let nonExistentPath = "/nonexistent/path/to/file.json"
        
        XCTAssertThrowsError(try ReimbursementCalculator(file: nonExistentPath)) { error in
            if case ReimbursementCalculator.CalculatorError.fileNotFound(let path) = error {
                XCTAssertEqual(path, nonExistentPath)
            } else {
                XCTFail("Expected fileNotFound error, got \(error)")
            }
        }
    }
    
    func testFileContentsAccessible() throws {
        let testFilePath = createTestProjectsJSON()
        
        let data = FileManager.default.contents(atPath: testFilePath)
        XCTAssertNotNil(data, "Should be able to read file contents")
        XCTAssertTrue(data!.count > 0, "File should contain data")
        
        // Clean up
        try FileManager.default.removeItem(atPath: testFilePath)
    }
    
    // MARK: - JSON Import Tests
    
    func testValidJSONImport() throws {
        let testFilePath = createTestProjectsJSON()
        
        let calculator = try ReimbursementCalculator(file: testFilePath)
        XCTAssertNotNil(calculator.projectSets)
        XCTAssertEqual(calculator.projectSets.count, 1)
        
        let firstSet = calculator.projectSets[0]
        XCTAssertEqual(firstSet.id, 1)
        XCTAssertEqual(firstSet.projects.count, 2)
        
        // Clean up
        try FileManager.default.removeItem(atPath: testFilePath)
    }
    
    func testProjectDecodingFromJSON() throws {
        let testFilePath = createTestProjectsJSON()
        
        let calculator = try ReimbursementCalculator(file: testFilePath)
        let firstProject = calculator.projectSets[0].projects[0]
        
        XCTAssertEqual(firstProject.name, "Test Project 1")
        XCTAssertEqual(firstProject.cityType, .low)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/d/yy"
        let expectedStartDate = dateFormatter.date(from: "10/1/24")!
        let expectedEndDate = dateFormatter.date(from: "10/3/24")!
        
        XCTAssertEqual(firstProject.startDate, expectedStartDate)
        XCTAssertEqual(firstProject.endDate, expectedEndDate)
        
        // Clean up
        try FileManager.default.removeItem(atPath: testFilePath)
    }
    
    func testInvalidJSONStructure() throws {
        // Test with valid JSON but invalid structure for our model
        let invalidStructureJSON = """
        {
            "not_array": "this is not the expected array structure"
        }
        """
        let tempDir = NSTemporaryDirectory()
        let testFilePath = tempDir + "invalid_structure.json"
        
        try invalidStructureJSON.write(to: URL(fileURLWithPath: testFilePath), atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try ReimbursementCalculator(file: testFilePath)) { error in
            // Should throw some kind of error - either DecodingError or CalculatorError
            let isExpectedError = error is DecodingError || error is ReimbursementCalculator.CalculatorError
            XCTAssertTrue(isExpectedError, "Should throw an error for invalid JSON structure, got \(type(of: error)): \(error)")
        }
        
        // Clean up
        try FileManager.default.removeItem(atPath: testFilePath)
    }
    
    func testInvalidDateFormat() throws {
        let invalidDateJSON = """
        [
            {
                "id": 1,
                "projects": [
                    {
                        "name": "Test Project",
                        "city_type": "low",
                        "start_date": "2024-10-01",
                        "end_date": "2024-10-03"
                    }
                ]
            }
        ]
        """
        
        let tempDir = NSTemporaryDirectory()
        let testFilePath = tempDir + "invalid_date.json"
        
        try invalidDateJSON.write(to: URL(fileURLWithPath: testFilePath), atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try ReimbursementCalculator(file: testFilePath)) { error in
            if case ReimbursementCalculator.CalculatorError.invalidDateFormat = error {
                // Expected error
            } else {
                XCTFail("Expected invalidDateFormat error, got \(error)")
            }
        }
        
        // Clean up
        try FileManager.default.removeItem(atPath: testFilePath)
    }
    
    // MARK: - Examples.json Tests
    
    func testExamplesJSONExists() throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let examplesPath = currentPath + "/Sources/SimpleThreadCalculator/Resources/examples.json"
        
        let fileExists = FileManager.default.fileExists(atPath: examplesPath)
        XCTAssertTrue(fileExists, "examples.json file should exist at: \(examplesPath)")
    }
    
    func testExamplesJSONImport() throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let examplesPath = currentPath + "/Sources/SimpleThreadCalculator/Resources/examples.json"
        
        guard FileManager.default.fileExists(atPath: examplesPath) else {
            XCTFail("Could not find examples.json at \(examplesPath)")
            return
        }
        
        let calculator = try ReimbursementCalculator(file: examplesPath)
        XCTAssertNotNil(calculator.projectSets)
        XCTAssertEqual(calculator.projectSets.count, 4, "examples.json should contain 4 project sets")
        
        // Test specific project set structure
        let firstSet = calculator.projectSets[0]
        XCTAssertEqual(firstSet.id, 0)
        XCTAssertEqual(firstSet.projects.count, 1)
        
        let secondSet = calculator.projectSets[1] 
        XCTAssertEqual(secondSet.id, 1)
        XCTAssertEqual(secondSet.projects.count, 3)
    }
    
    func testExampleCalculations() throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let examplesPath = currentPath + "/Sources/SimpleThreadCalculator/Resources/examples.json"
        
        guard FileManager.default.fileExists(atPath: examplesPath) else {
            XCTFail("Could not find examples.json at \(examplesPath)")
            return
        }
        
        let calculator = try ReimbursementCalculator(file: examplesPath)
        let sequences = calculator.findSequences()
        
        XCTAssertFalse(sequences.isEmpty, "Should find at least one sequence in examples")
        
        // Test that all sequences have valid totals
        for sequence in sequences {
            XCTAssertGreaterThan(sequence.total, 0, "Each sequence should have a positive total")
            XCTAssertFalse(sequence.projects.isEmpty, "Each sequence should have projects")
        }
        
        // Calculate grand total
        var grandTotal = 0
        for sequence in sequences {
            grandTotal += sequence.total
        }
        
        XCTAssertGreaterThan(grandTotal, 0, "Grand total should be positive")
        
        // Test specific example calculation (Set 0 - single project, low city, 4 days)
        // Should be: travel (45) + 2 full days (75*2) + travel (45) = 240
        let firstSequence = sequences.first { sequence in
            sequence.projects.count == 1 && sequence.projects[0].name == "Set 0:0"
        }
        
        if let sequence = firstSequence {
            XCTAssertEqual(sequence.total, 240, "Set 0:0 should total 240 (45 + 75 + 75 + 45)")
        }
    }
    
    func testProjectSequenceCalculation() throws {
        let testProjects = [
            createTestProject(name: "Test Project", cityType: .low, startDate: "10/1/24", endDate: "10/3/24")
        ]
        
        let sequence = ProjectSequence(projects: testProjects)
        
        // 3-day sequence in low city: travel + full day + travel = 45 + 75 + 45 = 165
        XCTAssertEqual(sequence.total, 165)
        
        // Test date mapping
        let dateToCity = sequence.mapDateToCity
        XCTAssertEqual(dateToCity.count, 3)
        
        let dateToRate = sequence.mapeDateToRate
        XCTAssertEqual(dateToRate.count, 3)
        
        // First and last days should be travel rates
        let firstDate = createDate("10/1/24")
        let lastDate = createDate("10/3/24")
        XCTAssertEqual(dateToRate[firstDate], .travelLow)
        XCTAssertEqual(dateToRate[lastDate], .travelLow)
        
        // Middle day should be full day rate
        let middleDate = createDate("10/2/24")
        XCTAssertEqual(dateToRate[middleDate], .fullDayLow)
    }
    
    func testHighCityCalculation() throws {
        let testProjects = [
            createTestProject(name: "High City Test", cityType: .high, startDate: "10/1/24", endDate: "10/2/24")
        ]
        
        let sequence = ProjectSequence(projects: testProjects)
        
        // 2-day sequence in high city: travel + travel = 55 + 55 = 110  
        XCTAssertEqual(sequence.total, 110)
        
        let dateToRate = sequence.mapeDateToRate
        let firstDate = createDate("10/1/24")
        let secondDate = createDate("10/2/24")
        
        XCTAssertEqual(dateToRate[firstDate], .travelHigh)
        XCTAssertEqual(dateToRate[secondDate], .travelHigh)
    }
    
    func testOverlappingProjectsHigherCityTypeWins() throws {
        // Test the overlap logic directly using ProjectSequence with sequential dates
        // The algorithm expects the sequence dates to be determined by first and last project only
        let firstProject = createTestProject(name: "First Project", cityType: .low, startDate: "10/1/24", endDate: "10/1/24")
        let secondProject = createTestProject(name: "Second Project", cityType: .high, startDate: "10/1/24", endDate: "10/1/24") // Same date to test overlap
        
        let sequence = ProjectSequence(projects: [firstProject, secondProject])
        let dateToCity = sequence.mapDateToCity
        
        // Since both projects are on the same date, we should have 1 date
        XCTAssertEqual(dateToCity.count, 1, "Should have 1 date when projects are on same day")
        
        // Oct 1 should be high city due to overlap (high wins over low)
        let overlapDate = createDate("10/1/24")
        XCTAssertEqual(dateToCity[overlapDate], .high, "Overlapping date should use higher city type")
        
        // Also test the total calculation
        let total = sequence.total
        XCTAssertGreaterThan(total, 0, "Sequence should have a positive total")
        
        // Since it's just one day and it's both start and end, it should be travel rate
        let dateToRate = sequence.mapeDateToRate
        XCTAssertEqual(dateToRate[overlapDate], .travelHigh, "Single day should use travel rate")
    }
    
    // MARK: - Helper Methods
    
    private func createDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/d/yy"
        return formatter.date(from: dateString)!
    }
    
    private func createTestProject(name: String, cityType: Project.CityType, startDate: String, endDate: String) -> Project {
        let projectJSON = """
        {
            "name": "\(name)",
            "city_type": "\(cityType.rawValue)",
            "start_date": "\(startDate)",
            "end_date": "\(endDate)"
        }
        """
        
        let data = projectJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/d/yy"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return try! decoder.decode(Project.self, from: data)
    }
}
