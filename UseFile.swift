//
//  UseFile.swift
//
//
//  Created by Monish Painter on 13/3/18.
//  Copyright © 2017 Qwesys. All rights reserved.
//

import AlgoliaSearch
import Foundation

import UIKit

public enum SortByCellEnumStr : String {
    case PopularSort = "popular"
    case RecentSort = "recent"
    case LowestPriceSort = "lowprice"
    case HighestPriceSort = "highprice"
    case NearestSort = "near"
}


class UseFile: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Get Search Product
    func getSearchProduct(_ page : Int = 0) {
        if page == 0 {
            self.arrProducts.removeAll()
            runOnMainThread {
                //                self.cwProducts.mj_footer.isHidden = true
                self.cwProducts.reloadDataWithLoader(true)
            }
        }
        var dic = ["text" : searchText.lowercased(), "page" : page] as [String : Any]
        var arrFilter : [String] = ["is_delete:false AND is_reserve:false AND is_available:true"]
        dic["Ranking"] = SortByCellEnumStr.RecentSort.rawValue
        
        var arrNumericFilters : [String] = [String]()
        if isCategoryOn{
            for (key,value) in categoriDic {
                if (value as! String).lowercased() != "all"{
                    if key == "category" {
                        arrFilter.append("category:\(value as! String)")
                    }
                    if key == "subCategory" {
                        arrFilter.append("subCategory:\(value as! String)")
                    }
                    
                }
            }
        }
        if let newSection = SortByCellEnumStr.init(rawValue: userFilterSort) {
            switch newSection {
            case .PopularSort :
                dic["Ranking"] = SortByCellEnumStr.PopularSort.rawValue
                break
            case .RecentSort:
                dic["Ranking"] = SortByCellEnumStr.RecentSort.rawValue
                break
            case .LowestPriceSort:
                dic["Ranking"] = SortByCellEnumStr.LowestPriceSort.rawValue
                break
            case .HighestPriceSort:
                dic["Ranking"] = SortByCellEnumStr.HighestPriceSort.rawValue
                break
            case .NearestSort:
                break
            }
        }
        
        if (self.userFilterConditionNew != self.userFilterConditionUsed) {
            if (self.userFilterConditionNew) {
                arrFilter.append("condition:new")
            }
            if (self.userFilterConditionUsed) {
                arrFilter.append("condition:used")
            }
        }
        
        // 3 - AREA
        if(self.userFilterArea == "university") {
            arrFilter.append("university:\(userFilterAreaValue)")
        }
        if(self.userFilterArea == "city") {
            arrFilter.append("city:\(userFilterAreaValue)")
        }
        if(self.userFilterArea == "country") {
            arrFilter.append("country:\(userFilterAreaValue)")
        }
        
        
        
        dic["Filter"] = arrFilter
        
        
        if (self.userFilterRangeFrom > 0) {
            arrNumericFilters.append("price >= \(self.userFilterRangeFrom )")
        }
        if (self.userFilterRangeTo > 0) {
            arrNumericFilters.append("price <= \(self.userFilterRangeTo)")
        }
        if arrNumericFilters.count != 0 {
            dic["NumericFilters"] = arrNumericFilters
        }
        
        AlgoliaManager.sharedInstance.getSearchProduct(dic) { (res, error) in
            if error == nil {
                guard let dataArray : NSArray = res?["hits"] as? NSArray else {
//                    self.cwProducts.reloadData("No Product found.", APP_BLACK_COLOR)
                    return
                }
                if dataArray.count != 0 {
                    
                    for dicProd in dataArray{
                        guard let dataDic : [String:Any] = dicProd as? [String:Any] else {
                            return
                        }
//                        let objProductKey = dataDic["objectID"] as! String
//                        let json = JSON(dataDic)
//                        let objProdMain = ObjProduct.init(json: json, dic: dataDic as [String : Any])
//                        objProdMain.productId = objProductKey as String
                    }
                    
                    if let page : Int = res?["page"] as? Int {
                        
                        if let nbPages : Int = res?["nbPages"] as? Int {
                            if page+1 == nbPages {
                               // self.footerw.endRefreshingWithNoMoreData()
                            }
                            else{
//                                self.pageCountAlgolia = page + 1
//                                self.footerw.endRefreshing()
                            }
                        }else{
//                            self.footerw.endRefreshing()
                        }
                    }else{
//                        self.footerw.endRefreshing()
                    }
                    
                }
                else{
                   // self.cwProducts.reloadData("No Product found.", APP_BLACK_COLOR)
                }
            }
            else{
//                showAlertWithTitleWithMessage(message: "\(error?.localizedDescription ?? "")")
//                self.cwProducts.reloadData("\(error?.localizedDescription ?? "")", APP_BLACK_COLOR)
            }
        }
        
        /*(Query(query: "\(self.searchText)"), completionHandler: { (content, error) -> Void in
         if error == nil {
         print("Result: \(content)")
         
         }
         })*/
    }
}
