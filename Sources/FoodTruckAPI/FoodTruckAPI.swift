public protocol FoodTruckAPI {
    
    // MARK: - Trucks
    // Get all Food Trucks
    func getAllTrucks(completion: @escaping ([FoodTruckItem]?, Error?) -> Void)
    
    // Get specific Food Truck
    func getTruck(docId: String, completion: @escaping (FoodTruckItem?, Error?) -> Void)
    
    // Add Food Truck
    func addTruck(name: String, foodType: String, avgCost: Float, latitude: Float, longtitude: Float, completion: @escaping (FoodTruckItem?, Error?) -> Void)
    
    // Clear all Food Trucks
    func clearAll(completion: @escaping (Error?) -> Void)
    
    // Delete specific Food Truck
    func deleteTruck(docId: String, completion: @escaping (Error?) -> Void)
}
