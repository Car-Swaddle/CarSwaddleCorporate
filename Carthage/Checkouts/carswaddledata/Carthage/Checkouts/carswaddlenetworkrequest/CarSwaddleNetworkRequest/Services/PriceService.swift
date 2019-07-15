//
//  PriceService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 12/18/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import MapKit

extension NetworkRequest.Request.Endpoint {
    fileprivate static let price = Request.Endpoint(rawValue: "/api/price")
}


final public class PriceService: Service {
    
    @discardableResult
    public func getPrice(mechanicID: String, oilType: String, location: CLLocationCoordinate2D, couponCode: String?, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        let locationJSON: JSONObject = ["latitude": location.latitude, "longitude": location.longitude]
        var json: JSONObject = ["mechanicID": mechanicID, "oilType": oilType, "location": locationJSON]
        if let couponCode = couponCode {
            json["coupon"] = couponCode
        }
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])),
            let urlRequest = serviceRequest.post(with: .price, body: body, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getPrice(mechanicID: String, oilType: String, locationID: String, couponCode: String?, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var json: JSONObject = ["mechanicID": mechanicID, "oilType": oilType, "locationID": locationID]
        if let couponCode = couponCode {
            json["coupon"] = couponCode
        }
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])),
            let urlRequest = serviceRequest.post(with: .price, body: body, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
}
