//
//  FoodTruckItem.swift
//  FoodTruckAPI
//
//  Created by Emanuel  Guerrero on 4/27/17.
//
//

import Foundation

typealias JSONDictionary = [String: Any]

protocol DictionaryConvertible {
    func toDict() -> JSONDictionary
}

public struct FoodTruckItem {
    
    /// ID
    public let docId: String
    
    /// Name of the FoodATruck Business
    public let name: String
    
    /// Food Type
    public let foodType: String
    
    /// Average cost of the food served
    public let avgCost: Float
    
    /// Coordinate Latitude
    public let latitude: Float
    
    /// Coordinate Longitude
    public let longitude: Float
    
    public init(docId: String, name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float) {
        self.docId = docId
        self.name = name
        self.foodType = foodType
        self.avgCost = avgCost
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension FoodTruckItem: Equatable {
    public static func == (lhs: FoodTruckItem, rhs: FoodTruckItem) -> Bool {
        return lhs.docId == rhs.docId &&
               lhs.name == rhs.name &&
               lhs.foodType == rhs.foodType &&
               lhs.avgCost == rhs.avgCost &&
               lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude
    }
}

extension FoodTruckItem: DictionaryConvertible {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = docId
        result["name"] = name
        result["foodtype"] = foodType
        result["avgcost"] = avgCost
        result["latitude"] = latitude
        result["longitude"] = longitude
        return result
    }
}

extension Array where Element: DictionaryConvertible {
    func toDict() -> [JSONDictionary] {
        return self.map { $0.toDict() }
    }
}
