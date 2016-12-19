//
//  InAppManager.swift
//  Goodnight Moon
//
//  Created by Yogesh Prajapati on 12/16/16.
//  Copyright © 2016 RayoInfotech. All rights reserved.
//

import Foundation
import StoreKit


let DEBUG_MODE = false

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

protocol InAppManagerDelegate : class {
    func completeTranscation(transaction: SKPaymentTransaction)
    func restoreTransaction(transaction: SKPaymentTransaction)
    func failedTransaction(transaction: SKPaymentTransaction)
    func failedRestoringPurchaseWithError(errorString: String)
}

class InAppManager : NSObject  {
    static let shared = InAppManager()
    weak var delegate:InAppManagerDelegate?
    
    public var productsRequest: SKProductsRequest?
    public var productIdentifiers: Set<ProductIdentifier> = Set<ProductIdentifier>()
    public var purchasedProductIdentifiers = Set<ProductIdentifier>()
    public var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
    

        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    public func buyProduct(product: SKProduct) {
        if DEBUG_MODE{
            print("Buying \(product.productIdentifier)...")
        }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
        
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
}

extension InAppManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        if DEBUG_MODE{
            print("Loaded list of products...")
            for p in products {
                print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
        if DEBUG_MODE {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

extension InAppManager : SKPaymentTransactionObserver {
    
    private func completeTransaction(transaction : SKPaymentTransaction) {
        delegate?.completeTranscation(transaction: transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failedTransaction(transaction:SKPaymentTransaction) {
        guard let error = transaction.error as? SKError else {return}
        if error.code.rawValue != SKError.Code.paymentCancelled.rawValue {
            if DEBUG_MODE{
                print("Transaction Error: \(transaction.error?.localizedDescription)")
            }
        }
        delegate?.failedTransaction(transaction: transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTranscation(transaction:SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else {
            delegate?.restoreTransaction(transaction: transaction)
            return
        }
        if DEBUG_MODE {
            print("restoreTransaction... \(productIdentifier)")
        }
        delegate?.restoreTransaction(transaction: transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                completeTransaction(transaction: transaction)
            case .failed:
                failedTransaction(transaction: transaction)
            case .restored:
                restoreTranscation(transaction: transaction)
            default:
                failedTransaction(transaction: transaction)
                break
            }
        }

    }
}
