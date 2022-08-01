import StoreKit

public protocol InAppPurchaseDelegate: AnyObject {
    func purchaseFail(error: TransactionAuthError) -> Void
    func purchaseStatus(status: InAppPurchaseStatus) -> Void
    func purchaseSuccess(receipt: String?, transaction: SKPaymentTransaction) -> Void
}

fileprivate typealias CompletionHandler = (([SKProduct]) -> Void)

public class InAppPurchase: NSObject {
    private var products = [SKProduct]()
    private var productsId: Set<String>?
    private weak var delegate: InAppPurchaseDelegate?
    private var completionHandler: CompletionHandler?
    
    public convenience init(productsId: Set<String>, delegate: InAppPurchaseDelegate) {
        self.init()
        self.delegate = delegate
        self.productsId = productsId
        fetchProducts { products in
            debugPrint("Total Products: \(products.count)")
        }
        SKPaymentQueue.default().add(self)
    }
    
    fileprivate override init() {
        super.init()
    }
    
    public func purchaseProduct(id: String) {
      let filterProducts = products.filter {$0.productIdentifier == id}
      if filterProducts.count == 1 {
        guard let firstProduct = filterProducts.first else { return }
        let payment = SKPayment(product: firstProduct)
        SKPaymentQueue.default().add(payment)
      } else {
          self.delegate?.purchaseFail(error: .invalidProductIdentifier)
      }
    }
    
    private func getReceipt() -> String? {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
      do {
        let receiptData = try NSData(contentsOf: receiptUrl,
                                     options: NSData.ReadingOptions.alwaysMapped)
        let receipt = receiptData.base64EncodedString(options: [])
        return receipt
      } catch(let e) {
        debugPrint(e.localizedDescription)
        return nil
      }
    }

}

//MARK: extend product request delegate
extension InAppPurchase: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let allProducts = response.products
        if allProducts.isEmpty {
            self.delegate?.purchaseFail(error: .noValidProductsAvailable)
        } else {
            self.products = allProducts
            self.completionHandler?(products)
        }
        self.completionHandler = nil
    }
    
    private func fetchProducts(completion: @escaping CompletionHandler) {
        guard let productsId = self.productsId else {
            self.delegate?.purchaseFail(error: .productIdNotFound)
            return
        }
        self.completionHandler = completion
        let request = SKProductsRequest(productIdentifiers: productsId)
        request.delegate = self
        request.start()
    }
}

//MARK: extend payment transaction observer delegate
extension InAppPurchase: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                self.delegate?.purchaseStatus(status: .purchasing)
            case .purchased, .restored:
                self.delegate?.purchaseStatus(status: .purchased)
                self.delegate?.purchaseSuccess(receipt: getReceipt(), transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed, .deferred:
                self.delegate?.purchaseStatus(status: .failed)
                guard let error = transaction.error else {
                    self.delegate?.purchaseFail(error: .transactionFailed)
                    return
                }
                self.delegate?.purchaseFail(error: TransactionAuthError(rawValue: error.localizedDescription) ?? .transactionFailed)
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                self.delegate?.purchaseFail(error: .unknown)
                break
            }
        }
    }
}
