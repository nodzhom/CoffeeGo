//
//  NetworkManager.swift
//  CoffeeGo
//
//  Created by Onur Com on 5.05.2020.
//  Copyright © 2020 Onur Com. All rights reserved.
//

import Foundation

protocol NetworkManagerDelegate {
    func didGetCoffeeShops(networkManager: NetworkManager, venues: [Result])
}

class NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    
    let baseURL = "https://api.foursquare.com/v2/search/recommendations?limit=10&section=coffee&v=20180323&limit=10"
    
    let location = "&ll=48.1351,11.5820"
    let clientID = Secrets.clientID
    let clientSecret = Secrets.clientSecret
    
    
    func getCoffeeShopsAt(latitude: String, longitude: String) {
        
        let endpoint = "https://api.foursquare.com/v2/search/recommendations?limit=20"+"&ll=\(latitude)"+","+"\(longitude)"+"&section=coffee&v=20180323"+clientID+clientSecret
        //let endpoint = baseURL+"&ll=\(latitude)"+","+"\(longitude)"+clientID+clientSecret
        if let url = URL(string: endpoint) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error == nil {
                    print("Successfully connected")
                    print(url)
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do{
                            let response = try decoder.decode(FSResponse.self, from: safeData)
                            self.delegate?.didGetCoffeeShops(networkManager: self, venues: response.response.group.results)
                            print(response)
                        } catch {
                            print(error)
                            print(safeData.self)
                        }
                    }
                }
                
                
            }
            task.resume()
        }
        
        
    }
    
    
}
