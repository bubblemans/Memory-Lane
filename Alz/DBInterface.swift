//
//  DBInterface.swift
//  Alz
//
//  Created by Alvin Lin on 2/15/20.
//  Copyright © 2020 Alvin Lin. All rights reserved.
//

import Foundation

struct Link: Codable {
    var rel: String
    var href: String
}

struct Item: Codable {
    var username: String
    var dob: String
    var relation: String
    var memories: String
    var links: [Link]
}

struct Contact: Codable{
    var items: [Item]
    var hasMore: Bool
    var limit: Int
    var offset: Int
    var count: Int
    var links: [Link]
}

var jsonData: Contact?

class DBInterface {
//    open func retrieveUserInfo() {
//        guard let url = URL(string: "https://rugurocpkcsywus-frnsandfam.adb.us-phoenix-1.oraclecloudapps.com/ords/") else { return }
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
//            if error != nil { return }
//
//
//        }.resume()
//    }
    
    open func retrieveContactInfo() {
        guard let url = URL(string: "https://rugurocpkcsywus-frnsandfam.adb.us-phoenix-1.oraclecloudapps.com/ords/alvin/user_relations/") else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil { return }
            
            if let data = data {
                do {
                    jsonData = try JSONDecoder().decode(Contact.self, from: data)
//                    print(jsonData)
//                    print(jsonData?.items[0].username)
//                    print(jsonData?.items[0].relation)
                } catch {
                    print("Caught error")
                }
            }
            
            
        }.resume()
    }
}
