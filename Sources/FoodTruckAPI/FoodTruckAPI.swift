public protocol FoodTruckAPI {
    
    // MARK: - Trucks
    // Get all Food Trucks
    func getAllTrucks(completion: @escaping ([FoodTruckItem]?, Error?) -> Void)
}
