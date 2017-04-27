import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import CloudFoundryEnv
import Configuration
import FoodTruckAPI

HeliumLogger.use()
let trucks: FoodTruck
do {
    Log.info("Attempting init with CF environment")
    let service = try getConfig()
    Log.info("Init with Service")
    trucks = FoodTruck(service: service)
} catch {
    Log.info("Could not retrieve CF env: init with defaults")
    trucks = FoodTruck()
}
let controller = FoodTruckController(backend: trucks)
let appEnv = ConfigurationManager()
let port = appEnv.port
Log.verbose("Assigned port \(port)")
Kitura.addHTTPServer(onPort: port, with: controller.router)
Kitura.run()
