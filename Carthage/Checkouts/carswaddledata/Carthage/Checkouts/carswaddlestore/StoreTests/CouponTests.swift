//
//  CouponTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 7/14/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//


import XCTest
@testable import Store

class CouponTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? store.destroyAllData()
        store.mainContext.persist()
    }
    
    func testCreateAuthority() {
        let coupon = Coupon.fetchOrCreate(json: couponJSON, context: store.mainContext)
        
        XCTAssert(coupon != nil, "Should have coupon")
        
        let result = store.mainContext.persist()
        
        XCTAssert(result, "Should be true")
    }
    
}

private let couponJSON: [String: Any] = [
    "amountOff": 30,
    "createdAt": "2019-07-14T20:23:57.664Z",
    "createdByUserId": "e5f87000-a5f7-11e9-a48b-9d48cebf745e",
    "discountBookingFee": false,
    "id": "testnoob",
    "isCorporate": false,
    "maxRedemptions": 1,
    "name": "Marks test 1",
    "percentOff": NSNull(),
    "redeemBy": "2019-07-31T02:38:08.948Z",
    "redemptions": 0,
    "updatedAt": "2019-07-14T20:23:57.664Z",
]

