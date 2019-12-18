//
//  ViewControllers.swift
//  FrolloSDK Example
//
//  Created by Dipesh Dhakal on 18/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class ViewControllers{
    
    static var transactionCategoriesViewController : TransactionCategoriesViewController{
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: "TransactionCategoriesViewController") as! TransactionCategoriesViewController
    }
    
    static var merchantsViewController : MerchantsViewController{
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: "MerchantsViewController") as! MerchantsViewController
    }
    
}


