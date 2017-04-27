//
//  FoodTruck.swift
//  FoodTruckAPI
//
//  Created by Emanuel  Guerrero on 4/25/17.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI
import CouchDB
import CloudFoundryEnv

#if os(Linux)
    typealias ValueType = Any
#else
    typealias ValueType = AnyObject
#endif

public enum APICollectionError: Error {
    case ParseError
    case AuthError
}

public class FoodTruck: FoodTruckAPI {
    static let defaultDBHost = "localhost"
    static let defaultDBPort = UInt16(5984)
    static let defaultDBName = "foodtruckapi"
    static let defaultUsername = "emanuel"
    static let defaultPassword = "1234"
    
    let dbName = "foodtruckapi"
    let designName = "foodtruckdesign"
    let connectionProps: ConnectionProperties
    
    public init(database: String = FoodTruck.defaultDBName, host: String = FoodTruck.defaultDBHost, port: UInt16 = FoodTruck.defaultDBPort, username: String? = FoodTruck.defaultUsername, password: String? = FoodTruck.defaultPassword) {
        let secured = host == FoodTruck.defaultDBHost ? false : true
        connectionProps = ConnectionProperties(host: host, port: Int16(port), secured: secured, username: username, password: password)
        setupDB()
    }
    
    public convenience init(service: Service) {
        let host: String
        let username: String?
        let password: String?
        let port: UInt16
        let databaseName: String = "foodtruckapi"
        if let credentials = service.credentials,
           let tempHost = credentials["host"] as? String,
           let tempUsername = credentials["username"] as? String,
           let tempPassword = credentials["password"] as? String,
           let tempPort = credentials["port"] as? Int {
            host = tempHost
            username = tempUsername
            password = tempPassword
            port = UInt16(tempPort)
            Log.info("Using CF Service Credentials")
        } else {
            host = "localhost"
            username = "emanuel"
            password = "1234"
            port = UInt16(5984)
            Log.info("Using Service Development Credentials")
        }
        self.init(database: databaseName, host: host, port: port, username: username, password: password)
    }
    
    private func setupDB() {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        couchClient.dbExists(dbName) { (exists, error) in
            if exists {
                Log.info("DB exists")
            } else {
                Log.error("DB does not exist")
                couchClient.createDB(self.dbName, callback: { (db, error) in
                    if db != nil {
                        Log.info("DB created!")
                        self.setupDbDesign(db: db!)
                    } else {
                        Log.error("Unable to create DB \(self.dbName): Error \(error!)")
                    }
                })
            }
        }
    }
    
    private func setupDbDesign(db: Database) {
        let design: [String: Any] = [
            "_id": "_design/foodtruckdesign",
            "views": [
                "all_documents": [
                    "map": "function(doc) { emit(doc._id, [doc._id, doc._rev]); }"
                ],
                "all_trucks": [
                    "map": "function(doc) { if (doc.type == 'foodtruck') { emit(doc._id, [doc._id, doc.name, doc.foodtype, doc.avgcost, doc.latitude, doc.longitude]); } }"
                ],
                "total_trucks": [
                    "map": "function(doc) { if (doc.type == 'foodtruck') { emit(doc._id, 1); } }",
                    "reduce": "_count"
                ]
            ]
        ]
        db.createDesign(designName, document: JSON(design)) { (json, error) in
            if error != nil {
                Log.error("Failed to create design: \(error!)")
            } else {
                Log.info("Design created: \(json!)")
            }
        }
    }
    
    public func getAllTrucks(completion: @escaping ([FoodTruckItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        database.queryByView("all_trucks", ofDesign: designName, usingParameters: [.descending(true), .includeDocs(true)]) { (doc, error) in
            if let doc = doc, error == nil {
                do {
                    let trucks = try self.parseTrucks(doc)
                    completion(trucks, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error!)
            }
        }
    }
    
    func parseTrucks(_ document: JSON) throws -> [FoodTruckItem] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        let trucks: [FoodTruckItem] = rows.flatMap {
            let doc = $0["value"]
            guard let id = doc[0].string,
                  let name = doc[1].string,
                  let foodType = doc[2].string,
                  let avgCost = doc[3].float,
                  let latitude = doc[4].float,
                  let longitude = doc[5].float else {
                    return nil
            }
            return FoodTruckItem(docId: id, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
        }
        return trucks
    }
    
    // Get specific Food Truck
    public func getTruck(docId: String, completion: @escaping (FoodTruckItem?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        database.retrieve(docId) { (doc, error) in
            guard let doc = doc,
                  let docId = doc["id"].string,
                  let name = doc["name"].string,
                  let foodType = doc["foodType"].string,
                  let avgCost = doc["avgcost"].float,
                  let latitude = doc["latitude"].float,
                  let longitude = doc["longitude"].float else {
                    completion(nil, error!)
                    return
            }
            let truckItem = FoodTruckItem(docId: docId, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
            completion(truckItem, nil)
        }
    }
    
    // Add Food Truck
    public func addTruck(name: String, foodType: String, avgCost: Float, latitude: Float, longtitude: Float, completion: @escaping (FoodTruckItem?, Error?) -> Void) {
        let json: [String: Any] = [
            "type": "foodtruck",
            "name": name,
            "foodtype": foodType,
            "avgcost": avgCost,
            "latitude": latitude,
            "longitude": longtitude
        ]
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        database.create(JSON(json)) { (id, rev, document, error) in
            if let id = id {
                let truckItem = FoodTruckItem(docId: id, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longtitude)
                completion(truckItem, nil)
            } else {
                completion(nil, error!)
            }
        }
    }
    
    // Clear all Food Trucks
    public func clearAll(completion: @escaping (Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        database.queryByView("all_documents", ofDesign: "foodtruckdesign", usingParameters: [.descending(true), .includeDocs(true)]) { (doc, error) in
            guard let doc = doc else {
                completion(error!)
                return
            }
            guard let idAndRev = try? self.getIdAndRev(doc) else {
                completion(error!)
                return
            }
            if idAndRev.count == 0 {
                completion(nil)
            } else {
                for i in 0...idAndRev.count - 1 {
                    let truck = idAndRev[i]
                    database.delete(truck.0, rev: truck.1, callback: { (error) in
                        guard error == nil else {
                            completion(error!)
                            return
                        }
                    })
                }
            }
        }
    }
    
    func getIdAndRev(_ document: JSON) throws -> [(String, String)] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        return rows.flatMap {
            let doc = $0["doc"]
            let id = doc["_id"].stringValue
            let rev = doc["_rev"].stringValue
            return (id, rev)
        }
    }
    
    // Delete specific Food Truck
    public func deleteTruck(docId: String, completion: @escaping (Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        database.retrieve(docId) { (doc, error) in
            guard let doc = doc, error == nil else {
                completion(error!)
                return
            }
            // TODO: - Fetch all reviews for the truck
            let rev = doc["_rev"].stringValue
            database.delete(docId, rev: rev) { (error) in
                if error != nil {
                    completion(error!)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
