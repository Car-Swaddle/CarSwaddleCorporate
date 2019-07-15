//
//  Coupon+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 7/14/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

//typealias CouponValues = (identifier: String, amountOff: Int?, creationDate: Date, createdByUserID: String, autoServiceID: String?, discountBookingFee: Bool, isCorporate: Bool, maxRedemptions: Int?, name: String, percentOff: CGFloat?, redeemBy: Date, redemptions: Int, updatedAt: Date)

struct CouponCodable: Codable {
    public var identifier: String
    public var amountOff: Int?
    public var creationDate: Date
    public var createdByUserID: String
    public var autoServiceID: String?
    public var discountBookingFee: Bool
    public var isCorporate: Bool
    public var maxRedemptions: Int?
    public var name: String
    public var percentOff: CGFloat?
    public var redeemBy: Date
    public var redemptions: Int
    public var updatedAt: Date
}

/*
 amountOff = 30;
 createdAt = "2019-07-14T20:23:57.664Z";
 createdByUserId = "e5f87000-a5f7-11e9-a48b-9d48cebf745e";
 discountBookingFee = 0;
 id = testnoob;
 isCorporate = 0;
 maxRedemptions = 1;
 name = "Marks test 1";
 percentOff = "<null>";
 redeemBy = "2019-07-31T02:38:08.948Z";
 redemptions = 0;
 updatedAt = "2019-07-14T20:23:57.664Z";
 
 */

@objc(Coupon)
final public class Coupon: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Coupon.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values)
    }
    
    
    public func configure(with json: JSONObject) throws {
        guard let values = Coupon.values(from: json) else { throw StoreError.invalidJSON }
        configure(with: values)
    }
    
    
    private func configure(with codable: CouponCodable) {
        identifier = codable.identifier
        amountOff = codable.amountOff
        creationDate = codable.creationDate
        createdByUserID = codable.createdByUserID
        autoServiceID = codable.autoServiceID
        discountBookingFee = codable.discountBookingFee
        isCorporate = codable.isCorporate
        maxRedemptions = codable.maxRedemptions
        name = codable.name
        percentOff = codable.percentOff
        redeemBy = codable.redeemBy
        redemptions = codable.redemptions
        updatedAt = codable.updatedAt
        
        guard let context = managedObjectContext else { return }
        
        user = User.fetch(with: createdByUserID, in: context)
        
        if let autoServiceID = autoServiceID {
            autoservice = AutoService.fetch(with: autoServiceID, in: context)
        } else {
            autoservice = nil
        }
    }
    
    private static func values(from json: JSONObject) -> CouponCodable? {
        guard let id = json.identifier,
            let creationDateString = json["createdAt"] as? String,
            let creationDate = serverDateFormatter.date(from: creationDateString),
            let createdByUserID = json["createdByUserId"] as? String,
            let discountBookingFee = json["discountBookingFee"] as? Bool,
            let isCorporate = json["isCorporate"] as? Bool,
            let name = json["name"] as? String,
            let redeemByString = json["redeemBy"] as? String,
            let redeemBy = serverDateFormatter.date(from: redeemByString),
            let redemptions = json["redemptions"] as? Int,
            let updatedAtString = json["updatedAt"] as? String,
            let updatedAt = serverDateFormatter.date(from: updatedAtString) else { return nil }
        
        let amountOff = json["amountOff"] as? Int
        let maxRedemptions = json["maxRedemptions"] as? Int
        let percentOff = json["percentOff"] as? CGFloat
        let autoServiceID = json["autoServiceID"] as? String
        
        return CouponCodable(identifier: id, amountOff: amountOff, creationDate: creationDate, createdByUserID: createdByUserID, autoServiceID: autoServiceID, discountBookingFee: discountBookingFee, isCorporate: isCorporate, maxRedemptions: maxRedemptions, name: name, percentOff: percentOff, redeemBy: redeemBy, redemptions: redemptions, updatedAt: updatedAt)
    }
    
    
    
    
    private let amountOffKey = "amountOff"
    @NSManaged private var primitiveAmountOff: NSNumber?
    
    public var amountOff: Int? {
        set {
            willChangeValue(forKey: amountOffKey)
            if let newValue = newValue {
                primitiveAmountOff = NSNumber(value: newValue)
            } else {
                primitiveAmountOff = nil
            }
            didChangeValue(forKey: amountOffKey)
        }
        get {
            willAccessValue(forKey: amountOffKey)
            let value = primitiveAmountOff?.intValue
            didAccessValue(forKey: amountOffKey)
            
            return value
        }
    }
    
    private let maxRedemptionsKey = "maxRedemptions"
    @NSManaged private var primitiveMaxRedemptions: NSNumber?
    
    public var maxRedemptions: Int? {
        set {
            willChangeValue(forKey: maxRedemptionsKey)
            if let newValue = newValue {
                primitiveMaxRedemptions = NSNumber(value: newValue)
            } else {
                primitiveMaxRedemptions = nil
            }
            didChangeValue(forKey: maxRedemptionsKey)
        }
        get {
            willAccessValue(forKey: maxRedemptionsKey)
            let value = primitiveMaxRedemptions?.intValue
            didAccessValue(forKey: maxRedemptionsKey)
            
            return value
        }
    }
    
    private let percentOffKey = "percentOff"
    @NSManaged private var primitivePercentOff: NSNumber?
    
    public var percentOff: CGFloat? {
        set {
            willChangeValue(forKey: percentOffKey)
            if let newValue = newValue {
                primitivePercentOff = NSNumber(value: Float(newValue))
            } else {
                primitivePercentOff = nil
            }
            didChangeValue(forKey: percentOffKey)
        }
        get {
            willAccessValue(forKey: percentOffKey)
            let value = primitivePercentOff?.floatValue
            didAccessValue(forKey: percentOffKey)
            
            if let value = value {
                return CGFloat(value)
            } else {
                return nil
            }
        }
    }
    
    
}
