//
//  Product.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 01/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class Product: DirtyRealmObject, Codable{
    // These two attributes are crucial in any struct
    @Persisted var id: String?
    @Persisted var type: String = "products"
    // Attributes
    @Persisted var name: String?
    @Persisted var sku: String?
    @Persisted var price_cents: Int?
    
    func getPrice() -> Int {
        let price = price_cents ?? 0
        return price
    }
}

class ProductModel: NSObject{
    
    struct ProductList: Codable {
        var data: [Product]
    }

    struct ProductObject: Codable {
        var data: Product
    }
    
    func getProducts(completion: @escaping ([Product]?, Error?, String?) -> Void){
        let url = apiURL + "/products?pagination_links=true"
        
        API.fetchData(url: url) { (productList: ProductList?, error, nextLink) in
            completion(productList?.data, error, nextLink) // Call the completion handler
        }
    }
    
    func getProduct(id: String, completion: @escaping (Product?, Error?, String?) -> Void){
        let url = apiURL + "/products/\(id)"
        
        API.fetchData(url: url) { (product: ProductObject?, error, nextLink) in
            completion(product?.data, error, nextLink) // Call the completion handler
        }
    }
    
}
