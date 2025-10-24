//
//  TestDatas.swift
//  SeelWidget_Example
//
//  Created by Developer on 10/11/2025.
//  Copyright (c) 2025 Developer. All rights reserved.
//

import Foundation
import SeelWidget

public extension Dictionary where Key == String, Value == Any {
    func toObject<T: Decodable>(_ type: T.Type) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            let decoder = JSONDecoder()
            // Remove convertFromSnakeCase strategy as struct already defines custom CodingKeys
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(type, from: data)
        } catch {
            print("Decoding error: \(error)")
            return nil
        }
    }
}

class TestDatas {
    
    /// Default Opted Valid Time: 30 mins
    static let defaultOptedValidTime: Double = 30
    
    static let optedValidTimeKey = "OptedValidTimeKey"
    
    static let apiKey: String = "yojct9zbwxok8961hr7e1s6i3fgmm1o1"
    
    class func getQuote(_ accepted: Bool = true, defaultOn: Bool = true, itemCount: Int = 3, error: Bool = false) -> QuotesRequest? {
        let params: Dictionary<String, Any> = [
            "type": error ? "" : "poshmark-wfp",
            "cart_id": "3b87ea2a6cecdb94bae186263feb9e7f",
            "session_id": "3b87ea2a6cecdb94bae186263feb9e7f",
            "merchant_id": "20251022203385298661",
            "device_id": "1737534673",
            "device_category": "web",
            "device_platform": "ios",
            "is_default_on": defaultOn,
            "line_items": [
                [
                    "line_item_id": "11111",
                    "product_id": "10013-0000-319802",
                    "variant_id": "10013-0000-319802",
                    "product_title": "Williams Brand Allegro 2 Model Digital Piano w/ Accessories",
                    "variant_title": "Williams Brand Allegro 2 Model Digital Piano w/ Accessories",
                    "price": 50,
                    "quantity": itemCount,
                    "currency": "USD",
                    "sales_tax": 0,
                    "requires_shipping": true,
                    "final_price": "50",
                    "is_final_sale": true,
                    "allocated_discounts": 0,
                    "category_1": "Household Goods",
                    "category_2": "Decor",
                    "image_urls": [
                        "https://example.com/image1",
                        "https://example.com/image2"
                    ],
                    "shipping_origin": [
                        "country": "US"
                    ]
                ],
                [
                    "line_item_id": "22222",
                    "product_id": "10013-0000-319803",
                    "variant_id": "10013-0000-319803",
                    "product_title": "Williams Brand Allegro 2",
                    "variant_title": "Williams Brand Allegro 2",
                    "price": 10,
                    "quantity": 3,
                    "currency": "USD",
                    "sales_tax": 6,
                    "requires_shipping": true,
                    "final_price": "15.00",
                    "is_final_sale": true,
                    "allocated_discounts": 1,
                    "category_1": "Household Goods",
                    "category_2": "Decor",
                    "image_urls": [
                        "https://example.com/image1",
                        "https://example.com/image2"
                    ],
                    "shipping_origin": [
                        "country": "US"
                    ]
                ]
            ],
            "shipping_address": [
                "address_1": "7 Buswell Street",
                "city": "Boston",
                "state": "MA",
                "zipcode": "02215",
                "country": accepted ? "US" : "CN"
            ],
            "customer": [
                "customer_id": "1111",
                "first_name": "name",
                "last_name": "name",
                "email": "xie@seel.com",
                "phone": NSNull()
            ],
            "extra_info": [
                "shipping_fee": 10
            ]
        ]
        if let quotes = params.toObject(QuotesRequest.self) {
            return quotes
        }
        return nil
    }
    
    class func getEvent() -> EventsRequest {
        var event = EventsRequest(sessionID: "3b87ea2a6cecdb94bae186263feb9e7f", customerID: "1111", eventSource: "ios", eventType: "product_page_enter")
        event.eventInfo = [
            "user_email": AnyCodable("xie@seel.com"),
            "user_phone_number": AnyCodable("+1234567890"),
            "shipping_address": AnyCodable([
                "shipping_address_country": "US",
                "shipping_address_state": "CA",
                "shipping_address_city": "San Francisco",
                "shipping_address_zipcode": "94102"
            ])
        ]
        return event
    }
    
    // MARK: - JSON Conversion Methods
    
    class func printJSON<T: Encodable>(_ object: T, label: String = "JSON") {
        do {
            let jsonData = try JSONEncoder().encode(object)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("\(label): \(jsonString)")
            }
        } catch {
            print("Failed to encode \(label): \(error)")
        }
    }
    
    class func printResult<T: Encodable>(_ result: Result<T, NetworkError>, successLabel: String = "Success JSON") {
        switch result {
        case .success(let response):
            printJSON(response, label: successLabel)
        case .failure(let error):
            print("Error: \(error)")
        }
    }
    
}
