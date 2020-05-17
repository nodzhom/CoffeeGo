//
//  CoffeeShopModel.swift
//  CoffeeGo
//
//  Created by Onur Com on 5.05.2020.
//  Copyright © 2020 Onur Com. All rights reserved.
//

import Foundation

struct FSResponse: Codable {
    let response: Response
}

struct Response: Codable {
    let group: Group
}

struct Group: Codable {
    let results: [Result]
}

struct Result: Codable  {
    let venue: Venue
    let photo: Photo?
    let snippets: Snippets
    
}

struct Photo: Codable {
    let suffix: String
}

struct Snippets: Codable {
    let items: [Item]
}

struct Item: Codable {
    let detail: Detail?
}

struct Detail: Codable {
    let object: Object
}

struct Object: Codable {
    let text: String
    let canonicalUrl: String
}

struct Venue: Codable {
    let id: String
    let name: String
    let location: Location

}

struct Location: Codable {
    let address: String?
    let lat: Double
    let lng: Double
    let postalCode: String?
    let distance: Int
}
