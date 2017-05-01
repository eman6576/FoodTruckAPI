import XCTest
@testable import FoodTruckAPI

class FoodTruckAPITests: XCTestCase {
    static var allTests = [
        ("testAddTruck", testAddAndGetTruck),
        ("testUpdateTruck", testUpdateTruck),
        ("testClearAll", testClearAll),
        ("testDeleteTruck", testDeleteTruck),
        ("testCountTrucks", testCountTrucks)
    ]
    
    var trucks: FoodTruck?
    
    override func setUp() {
        trucks = FoodTruck()
        super.setUp()
    }
    
    override func tearDown() {
        guard let trucks = trucks else {
            return
        }
        trucks.clearAll { (error) in
            guard error == nil else {
                return
            }
        }
    }
    
    // Add and get specific truck
    func testAddAndGetTruck() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        let addExpectation = expectation(description: "Add truck item")
        // First add new truck
        trucks.addTruck(name: "testAdd", foodType: "testType", avgCost: 0, latitude: 0, longtitude: 0) { (addedTruck, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            if let addedTruck = addedTruck {
                trucks.getTruck(docId: addedTruck.docId, completion: { (returnedTruck, error) in
                    // Assert that the added truck equals the returned truck
                    XCTAssertEqual(addedTruck, returnedTruck)
                    addExpectation.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "addTruck Timeout")
        }
    }
    
    func testUpdateTruck() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        let updateExpectation = expectation(description: "Update truck item")
        trucks.addTruck(name: "testUpdate", foodType: "testUpdate", avgCost: 0, latitude: 0, longtitude: 0) { (addedTruck, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            if let addedTruck = addedTruck {
                // Update the added truck
                trucks.updateTruck(docId: addedTruck.docId, name: "UpdatedTruck", foodType: nil, avgCost: nil, latitude: nil, longitude: nil, completion: { (updatedTruck, error) in
                    guard error == nil else {
                        XCTFail()
                        return
                    }
                    if let updatedTruck = updatedTruck {
                        // Fetch the truck from the DB
                        trucks.getTruck(docId: addedTruck.docId, completion: { (fetchedTruck, error) in
                            // Assert that the updated truck equals the fetched truck
                            XCTAssertEqual(fetchedTruck, updatedTruck)
                            updateExpectation.fulfill()
                        })
                    }
                })
            }
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "Uodate truck timeout")
        }
    }
    
    // Clear all documents
    func testClearAll() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        let clearExpectation = expectation(description: "Clear all DB documents")
        trucks.addTruck(name: "testClearAll", foodType: "testClearAll", avgCost: 0, latitude: 0, longtitude: 0) { (addedTruck, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            trucks.clearAll { (error) in
                
            }
            trucks.countTrucks { (count, error) in
                XCTAssertEqual(count, 0)
                // TODO: - countReviews
                clearExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "clearAll timeout")
        }
    }
    
    // Delete truck
    func testDeleteTruck() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        let deleteExpectation = expectation(description: "Delete a specific truck")
        // First add a new truck
        trucks.addTruck(name: "testDelete", foodType: "testDelete", avgCost: 0, latitude: 0, longtitude: 0) { (addedTruck, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            if let addedTruck = addedTruck {
                // TODO: - Second add a review
                // Delete the truck
                trucks.deleteTruck(docId: addedTruck.docId, completion: { (error) in
                    guard error == nil else {
                        XCTFail()
                        return
                    }
                })
                // Count trucks and reviews to assert that count == 0
                trucks.countTrucks(completion: { (count, error) in
                    XCTAssertEqual(count, 0)
                    deleteExpectation.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "Delete truck timeout")
        }
    }
    
    // Count of all trucks
    func testCountTrucks() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        let countExpectation = expectation(description: "Test Truck Count")
        for _ in 0..<5 {
            trucks.addTruck(name: "testCount", foodType: "testCount", avgCost: 0, latitude: 0, longtitude: 0, completion: { (addedTruck, error) in
                guard error == nil else {
                    XCTFail()
                    return
                }
            })
        }
        // Count should equal 5
        trucks.countTrucks { (count, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            XCTAssertEqual(count, 5)
            countExpectation.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
    }
}
