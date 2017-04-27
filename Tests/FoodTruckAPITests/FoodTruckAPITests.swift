import XCTest
@testable import FoodTruckAPI

class FoodTruckAPITests: XCTestCase {
    static var allTests = [
        ("testAddTruck", testAddAndGetTruck),
    ]
    
    var trucks: FoodTruck?
    
    override func setUp() {
        trucks = FoodTruck()
        super.setUp()
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
}
