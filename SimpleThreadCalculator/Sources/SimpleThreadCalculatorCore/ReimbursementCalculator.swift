//
//  ReimbursementCalculator.swift
//  SimpleThreadCalculator
//
//  Created by Humza Ahmed on 8/14/25.
//

import Foundation

struct ProjectSequence {
    
    enum WorkdayRate: Int {
        case travelLow = 45
        case travelHigh = 55
        case fullDayLow = 75
        case fullDayHigh = 85
    }
    
    let projects: [Project]
    
    init(projects: [Project]) {
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
        let allDates = sequenceDates
        if allDates.isEmpty {
            return [:]
        }
        var map: [Date: Project.CityType] = [:]
        for date in allDates {
            for project in projects {
                if date >= project.startDate && date <= project.endDate {
                    if let value = map[date] {
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
        var sum = 0
        for workdayRate in mapeDateToRate.values {
            sum = sum + workdayRate.rawValue
        }
        return sum
    }
}

class ReimbursementCalculator {
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
            for set in projectSets {
                for project in set.projects {
                    print("Project \(project.name) found in file")
                }
            }
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
                
                if gap <= 1 {
                    projectsInCurrentSequence.append(project)
                } else {
                    //Gap exists
                    let projectSequence = ProjectSequence(projects: projectsInCurrentSequence)
                    projectSequences.append(projectSequence)
                }
            }
            
            projectSequences.append(ProjectSequence(projects: projectsInCurrentSequence))
        }
        return projectSequences
    }

}
