//
//  AlgoliaManager.swift
//  UniSell
//
//  Created by Monish Painter on 13/3/18.
//  Copyright © 2017 Unisell. All rights reserved.
//

import AlgoliaSearch
import Foundation


private let DEFAULTS_KEY_MIRRORED       = "algolia.mirrored"
private let DEFAULTS_KEY_STRATEGY       = "algolia.requestStrategy"
private let DEFAULTS_KEY_TIMEOUT        = "algolia.offlineFallbackTimeout"


class AlgoliaManager: NSObject {
    /// The singleton instance.
    static let sharedInstance = AlgoliaManager()
    
    let client: Client
    var productIndex: Index
    var productPopularIndex: Index
    var productPriceDescIndex: Index
    var productPriceAscIndex: Index
    
    
    private override init() {
        client = Client(appID: "xxxxxxxxxxxx", apiKey: "xxxxxxxxxxxx")
     
        productIndex = client.index(withName: "products")
        productIndex.searchCacheEnabled = true
        
        productPopularIndex = client.index(withName: "products_popular")
        productPopularIndex.searchCacheEnabled = true
        
        productPriceDescIndex = client.index(withName: "products_price_dec")
        productPriceDescIndex.searchCacheEnabled = true
        
        productPriceAscIndex = client.index(withName: "products_price_asc")
        productPriceAscIndex.searchCacheEnabled = true
    }
    
    func getSearchProduct( _ dataDict:[String:Any],_ completionHandler:@escaping (_ content: [String: Any]?, _ error: Error?) -> Void){
        let text = dataDict["text"] as! String
        
        var productsIndex : Index?
        
        productsIndex  = AlgoliaManager.sharedInstance.productIndex

        if let newSection = SortByCellEnumStr(rawValue: "\(dataDict["Ranking"] as! String)") {
            switch newSection {
            case .PopularSort :
                productsIndex  = AlgoliaManager.sharedInstance.productPopularIndex
                break
            case .RecentSort:
                productsIndex  = AlgoliaManager.sharedInstance.productIndex
                break
            case .LowestPriceSort:
                productsIndex  = AlgoliaManager.sharedInstance.productPriceAscIndex
                break
            case .HighestPriceSort:
                productsIndex  = AlgoliaManager.sharedInstance.productPriceDescIndex
                break
            case .NearestSort:
                productsIndex  = AlgoliaManager.sharedInstance.productIndex
                break
            }
        }
        

        // Filter Ranking NumericFilters
        let strFilter = (dataDict["Filter"] as! [String]).joined(separator: " AND ")
        
        let query = Query(query: text)
        query.filters = strFilter //"categories.-L24hfvCiDh7TTNggPGL:true"
        if (dataDict["NumericFilters"] != nil) {
            query.numericFilters = dataDict["NumericFilters"] as! [String]
        }
        
        query.page = UInt(dataDict["page"] as? Int ?? 0)
        productsIndex?.search(query, completionHandler: { (res, error) in
            completionHandler(res, error)
        })
    }
}
