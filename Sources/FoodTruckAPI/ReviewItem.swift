//
//  ReviewItem.swift
//  FoodTruckAPI
//
//  Created by Emanuel  Guerrero on 4/30/17.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI
import CouchDB

public struct ReviewItem {
    
    /// ID
    public let docId: String
    
    /// FoodTruckId
    /// - ID of the Food Truck this review belongs to
    public let truckId: String
    
    /// Title of Review
    public let reviewTitle: String
    
    /// Review Text
    public let reviewText: String
    
    /// Star Rating
    /// 1 - 5
    public let starRating: Int
    
    public init(docId: String, truckId: String, title: String, reviewText: String, starRating: Int) {
        self.docId = docId
        self.truckId = truckId
        self.reviewTitle = title
        self.reviewText = reviewText
        self.starRating = starRating
    }
}

extension ReviewItem: Equatable {
    public static func == (lhs: ReviewItem, rhs: ReviewItem) -> Bool {
        return lhs.docId == rhs.docId &&
               lhs.truckId == rhs.truckId &&
               lhs.reviewTitle == rhs.reviewTitle &&
               lhs.reviewText == rhs.reviewText &&
               lhs.starRating == rhs.starRating
    }
}

extension ReviewItem: DictionaryConvertible {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = docId
        result["truckid"] = truckId
        result["reviewtitle"] = reviewTitle
        result["reviewtext"] = reviewText
        result["starrating"] = starRating
        return result
    }
}
