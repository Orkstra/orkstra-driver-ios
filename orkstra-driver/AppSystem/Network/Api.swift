//
//  Api.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 01/04/2025.
//

import Foundation
import Alamofire
import Japx
import SwiftyJSON
import PKHUD

//API
let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
var headers: HTTPHeaders = ["uid": currentUser.uid ?? "", "access-token": currentUser.token ?? "", "client": currentUser.client ?? "", "X-Platform": "ios_customer", "X-Client-Version": version]
let authURL = "https://api.oneorder.net"
let apiURL = authURL + "/v1"

var API = APIClass()

class APIClass: NSObject {
    
    func fetchData<T: Decodable>(
        url: String,
        method: HTTPMethod = .get,
        completion: @escaping (T?, Error?, String?) -> Void
    ) {
        let localizedURL = localizeURL(url: url)
        
        AF.request(localizedURL, method: method, headers: headers)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decodedResponse = try JapxDecoder().decode(T.self, from: data) // Generic decoding
                        let nextLink = API.getNextLink(data: data) // Extract next link if applicable
                        completion(decodedResponse, nil, nextLink)
                    } catch {
                        completion(nil, error, nil) // Return decoding error
                    }
                case .failure(let error):
                    completion(nil, error, nil) // Return network error
                }
            }
    }
    
    func localizeURL(url: String) -> String{
        var str = ""
        if url.contains("?"){
            str = url + "&locale=" + NSLocale.current.languageCode!
        }else{
            str = url + "?locale=" + NSLocale.current.languageCode!
        }
        return str
    }
    
    func getNextLink(data: Data) -> String?{
        do {
            let json = try JSON(data: data)
            if let next = json["links"]["next"].string{
                return next
            }
        }catch{
            return nil
        }
        return nil
    }
    
}
