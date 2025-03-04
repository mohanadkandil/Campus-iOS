//
//  Enums.swift
//  Campus-iOS
//
//  Created by Milen Vitanov on 13.01.22.
//

import Foundation
import CoreLocation
import KVKCalendar
import SwiftUI

enum SheetDestination {
    case none
    case loginSheet(model: Model)
    case profileSheet(model: Model)
}

enum Gender: Decodable, Hashable {
    case male
    case female
    case nonBinary
    case unkown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        switch try container.decode(String.self) {
        case "M", "m": self = .male
        case "F", "f": self = .female
        default: self = .unkown
        }
    }
}

enum ContactInfo: Identifiable {
    var id: String {
        switch self {
        case .phone(let phone):
            return phone
        case .mobilePhone(let mobile):
            return mobile
        case .fax(let fax):
            return fax
        case .additionalInfo(let info):
            return info
        case .homepage(let homepage):
            return homepage
        }
    }
    
    case phone(String)
    case mobilePhone(String)
    case fax(String)
    case additionalInfo(String)
    case homepage(String)

    init?(key: String, value: String) {
        guard !value.isEmpty else { return nil }
        switch key {
        case "telefon": self = .phone(value)
        case "mobiltelefon": self = .mobilePhone(value)
        case "fax": self = .fax(value)
        case "zusatz_info": self = .additionalInfo(value)
        case "www_homepage": self = .homepage(value)
        default: return nil
        }
    }
}

enum Role: String {
    case student = "student"
    case extern = "extern"
    case employee = "employee"

    var localizedDesription: String {
        switch self {
        case .student: return "Student".localized
        case .extern: return "Extern".localized
        case .employee: return "Employee".localized
        }
    }
}

/* Views for which we gather usage data for the widget recommendations. */
enum CampusAppView: String, CaseIterable {
    case cafeteria = "cafeteria",
         cafeterias = "cafeterias",
         calendar = "calendar",
         calendarEvent = "calendarEvent",
         grades = "grades",
         studyRoom = "studyRoom",
         studyRooms = "studyRooms",
         tuition = "tuition",
         departures = "departures"
    
    // Widgets associated to the widget in some way.
    // We can use this to make assumptions for widget recommendations, based on the views that the user visited.
    func associatedWidget() -> Widget {
        switch self {
        case .cafeteria:
            return .cafeteria
        case .cafeterias:
            return .cafeteria
        case .calendar:
            return .calendar
        case .calendarEvent:
            return .calendar
        case .grades:
            return .grades
        case .studyRoom:
            return .studyRoom
        case .studyRooms:
            return .studyRoom
        case .tuition:
            return .tuition
        case .departures:
            return .departures
        }
    }
}

enum Campus: String, Codable, CaseIterable {
    case stammgelaende = "👔 Stammgelände"
    case olympiapark = "⛹️‍♀️ Campus Olympiapark"
    case klinikumRechts = "👨‍⚕️ Klinikum rechts der Isar"
    case großhadern = "Klinikum Großhadern"
    case garching = "🧪 Garching Forschungszentrum"
    case freising = "🌱 Campus Freising"
    
    var image: Image {
        switch self {
        case .stammgelaende: return Image("campus-stamm")
        case .olympiapark: return Image("campus-olympia")
        case .klinikumRechts: return Image("campus-klinikum")
        case .großhadern: return Image("placeholder")
        case .garching: return Image("campus-garching")
        case .freising: return Image("campus-freising")
        }
    }
    
    var searchStringRooms: String {
        switch self {
        case .stammgelaende: return "Stammgelände"
        case .olympiapark: return "Olympiapark"
        case .klinikumRechts: return "klinikum isar"
        case .großhadern: return "Großhadern"
        case .garching: return "Garching Forschungszentrum"
        case .freising: return "Weihenstephan"
        }
    }
    
    var location: CLLocation {
        switch self {
        case .stammgelaende : return CLLocation(latitude: 48.14887567648079, longitude: 11.568029074814328)
        case .olympiapark : return CLLocation(latitude: 48.17957305879896, longitude: 11.546601863009668)
        case .klinikumRechts : return CLLocation(latitude: 48.13760759635786, longitude: 11.60083902677729)
        case .großhadern: return CLLocation(latitude: 48.1116433849602, longitude: 11.47027262422505)
        case .garching : return CLLocation(latitude: 48.26513710129958, longitude: 11.671590834492283)
        case .freising : return CLLocation(latitude: 48.39549985559942, longitude: 11.727904526510946)
        }
    }
    
    var defaultStation: Station {
        switch self {
        case .stammgelaende : return Station(name: "Technische Universität", apiName: "91000095", latitude: 48.148145129847244, longitude: 11.566048520744298)
        case .olympiapark : return Station(name: "Olympiazentrum", apiName: "91000350", latitude: 48.17946648767361, longitude: 11.555783595899824)
        case .klinikumRechts : return Station(name: "Max-Weber-Platz", apiName: "91000580", latitude: 48.13573243097588, longitude: 11.599014647301777)
        case .großhadern: return Station(name: "Klinikum Großhadern", apiName: "91001540", latitude: 48.10889880944028, longitude: 11.47363212095666)
        case .garching : return Station(name: "Forschungszentrum", apiName: "1000460", latitude: 48.26519145730091, longitude: 11.671545161597082)
        case .freising : return Station(name: "Freising, Weihenstephan", apiName: "1002911", latitude: 48.39799498961109, longitude: 11.723989661968458)
        }
    }
    
    var allStations: [Station] {
        switch self {
        case .stammgelaende : return
            [
                self.defaultStation,
                Station(name: "Theresienstraße", apiName: "91000120", latitude: 48.1512235719802, longitude: 11.564211669898931),
                Station(name: "Pinakotheken", apiName: "91000051", latitude: 48.148780089472, longitude: 11.571870970398924)
            ]
        case .olympiapark : return
            [
                self.defaultStation
            ]
        case .klinikumRechts : return
            [
                self.defaultStation,
                Station(name: "Friedensengel/Villa Stuck", apiName: "91000073", latitude: 48.14074544433942, longitude: 11.600075277341709)
            ]
        case .großhadern: return
            [
                self.defaultStation,
                Station(name: "Klinikum Großhadern Ost", apiName: "91001472", latitude: 48.11092668280441, longitude: 11.473909030506093),
                Station(name: "Klinikum Großhadern Nord", apiName: "91001474", latitude: 48.11250562334001, longitude: 11.467122898318992)
            ]
        case .garching : return
            [
                self.defaultStation,
                Station(name: "Lichtenbergstraße", apiName: "1002070", latitude: 48.26777168760462, longitude: 11.665502685140389)
            ]
        case .freising : return
            [
                self.defaultStation,
                Station(name: "Freising, Forstzentrum", apiName: "1009413", latitude: 48.39924842116169, longitude: 11.716601891310122),
                Station(name: "Freising, Weihenstephaner Berg", apiName: "1002617", latitude: 48.39581877364193, longitude: 11.725859432987532)
            ]
        }
    }
    
    func getAll() -> [Campus : CLLocation] {
        var campusWithLocations = [Campus : CLLocation]()
        AllCases.Element.allCases.forEach { campus in
            campusWithLocations.updateValue(campus.location, forKey: campus)
        }
        return campusWithLocations
    }
}
