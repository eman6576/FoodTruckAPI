//
//  Config.swift
//  FoodTruckAPI
//
//  Created by Emanuel  Guerrero on 4/25/17.
//
//

import Foundation
import LoggerAPI
import CouchDB
import Configuration
import CloudFoundryEnv

struct ConfigError: LocalizedError {
    var errorDescription: String? {
        return "Could not retrieve config info"
    }
}

func getConfig() throws -> Service {
    let appEnv = ConfigurationManager()
    appEnv.load(.environmentVariables)
    do {
        Log.warning("Attempting to retrieve CF Env")
        let services = appEnv.getServices()
        let servicePair = services.filter { element in element.value.label == "cloudantNoSQLDB" }.first
        guard let service = servicePair?.value else {
            throw ConfigError()
        }
        return service
    } catch {
        Log.warning("An error occured while trying to retrieve configs")
        throw ConfigError()
    }
}
