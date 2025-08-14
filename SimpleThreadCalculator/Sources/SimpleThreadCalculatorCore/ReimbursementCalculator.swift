//
//  ReimbursementCalculator.swift
//  SimpleThreadCalculator
//
//  Created by Humza Ahmed on 8/14/25.
//

import Foundation

struct ProjectSequence {
    let projects: [Project]
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
