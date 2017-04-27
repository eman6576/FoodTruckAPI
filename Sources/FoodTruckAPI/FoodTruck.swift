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
    }
}
