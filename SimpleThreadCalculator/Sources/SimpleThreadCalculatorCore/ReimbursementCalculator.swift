//
//  ReimbursementCalculator.swift
//  SimpleThreadCalculator
//
//  Created by Humza Ahmed on 8/14/25.
//

import Foundation

//The ProjectSequence struct encapsulates a set of projects that overlap or are contiguous.
struct ProjectSequence {
    
    // Use enum to centralize rates and for code completion
    enum WorkdayRate: Int {
        case travelLow = 45
        case travelHigh = 55
        case fullDayLow = 75
        case fullDayHigh = 85
    }
    
    //Array of projects associated with the current sequence of projects.
    let projects: [Project]
    
    init(projects: [Project]) {
        //Always sort projects in a sequence by dates
        let sortedProjects = projects.sorted { $0.startDate < $1.startDate }
        self.projects = sortedProjects
    }
    
    var sequenceStartDate: Date? {
        if projects.isEmpty {
            return nil
        }
        return projects[0].startDate
    }
    
    var sequenceEndDate: Date? {
        if projects.isEmpty {
            return nil
        }
        return projects[projects.count - 1].endDate
    }
    
    var sequenceDates: Array<Date> {
        //Compute array of every date included in the sequence
        guard let sequenceStartDate else { return [] }
        guard let sequenceEndDate else { return [] }
        
        var allDates: Array<Date> = []
        var currentDate = sequenceStartDate
        while currentDate <= sequenceEndDate {
            allDates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return allDates
    }
    
    var mapDateToCity: [Date: Project.CityType] {
        //Compute a dictionary mapping each date to a city type
        let allDates = sequenceDates
        if allDates.isEmpty {
            return [:]
        }
        var map: [Date: Project.CityType] = [:]
        for date in allDates {
            for project in projects {
                if date >= project.startDate && date <= project.endDate {
                    if let value = map[date] {
                        //If a date is already mapped to a low cost of living city, but the current project is in a high cost of living city, High COL is prioritized.
                        if value == .low && project.cityType == .high {
                            map[date] = .high
                        }
                    } else {
                        map[date] = project.cityType
                    }
                }
            }
        }
        return map
    }
    
    var mapeDateToRate: [Date: WorkdayRate] {
        //Compute dictionary mapping each Date to a reimbursement rate
        let allDates = sequenceDates
        if allDates.isEmpty {
            return [:]
        }
        let cityTypeMap = mapDateToCity
        var map: [Date: WorkdayRate] = [:]
        for date in allDates {
            let city = cityTypeMap[date]
            if date == allDates[0] || date == allDates[allDates.count - 1] {
                switch city {
                case .low:
                    map[date] = .travelLow
                case .high:
                    map[date] = .travelHigh
                default:
                    break
                }
            } else {
                switch city {
                case .low:
                    map[date] = .fullDayLow
                case .high:
                    map[date] = .fullDayHigh
                default:
                    break
                }
            }
        }
        return map
    }
    
    var total: Int {
        //Compute total by summing workday rates for each date in sequence
        var sum = 0
        for workdayRate in mapeDateToRate.values {
            sum = sum + workdayRate.rawValue
        }
        return sum
    }
}

class ReimbursementCalculator {
    
    //Custom error definition for import of JSON
    enum CalculatorError: Error, LocalizedError {
        case invalidDateFormat
        case invalidCityType(String)
        case fileNotFound(String)
        case invalidJSON
        
        var errorDescription: String? {
            switch self {
            case .invalidDateFormat:
                return "Invalid date format. Use M/d/yy format (e.g., 10/1/24)"
            case .invalidCityType(let type):
                return "Invalid city type '\(type)'. Must be 'low' or 'high'"
            case .fileNotFound(let filename):
                return "File '\(filename)' not found"
            case .invalidJSON:
                return "Invalid JSON format in file"
            }
        }
    }
    
    //Calculator can hold more than one set of projects defined in a JSON file
    var projectSets: [ProjectSet]! = nil
    
    init(file: String) throws {
        guard let data = FileManager.default.contents(atPath: file) else {
            throw CalculatorError.fileNotFound(file)
        }
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/d/yy"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        do {
            projectSets = try decoder.decode([ProjectSet].self, from: data)
            guard let projectSets else { return }
        } catch DecodingError.dataCorrupted(let context) {
            // Check if it's a date format error
            if context.codingPath.contains(where: { key in
                if let key = key as? Project.CodingKeys {
                    return key == .startDate || key == .endDate
                }
                return false
            }) {
                throw CalculatorError.invalidDateFormat
            } else {
                print("Data corruption error: \(context.debugDescription)")
            }
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Missing key '\(key.stringValue)': \(context.debugDescription)")
            throw CalculatorError.invalidJSON
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type mismatch for \(type): \(context.debugDescription)")
            throw CalculatorError.invalidJSON
        } catch DecodingError.valueNotFound(let type, let context) {
            print("Value not found for \(type): \(context.debugDescription)")
            throw CalculatorError.invalidJSON
        } catch {
            throw error
        }
    }
    
    func findSequences() -> [ProjectSequence] {
        guard let projectSets else { return [] }
        var projectSequences = [ProjectSequence]()
        for set in projectSets {
            let sortedProjects = set.projects.sorted { $0.startDate < $1.startDate }
            var projectsInCurrentSequence = [sortedProjects[0]]
            
            for project in sortedProjects {
                let lastProject = projectsInCurrentSequence.last!
                let gap = Calendar.current.dateComponents([.day], from: lastProject.endDate, to: project.startDate).day ?? 0
                // If The end date of the current sequence overlaps or is contiguous with the start date of the next project, add the project to the sequence.
                if gap <= 1 {
                    projectsInCurrentSequence.append(project)
                } else {
                    //Gap exists -- current project should be in a separate sequence.
                    let projectSequence = ProjectSequence(projects: projectsInCurrentSequence)
                    projectSequences.append(projectSequence)

                    projectsInCurrentSequence = [project]
                }
            }
            
            projectSequences.append(ProjectSequence(projects: projectsInCurrentSequence))
        }
        return projectSequences
    }

}
