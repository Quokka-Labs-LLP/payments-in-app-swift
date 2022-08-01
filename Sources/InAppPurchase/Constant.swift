//MARK: some constant errors
public enum TransactionAuthError: String {
    case noValidProductsAvailable
    case productIdNotFound
    case invalidProductIdentifier
    case transactionFailed
    case unknown
}

//MARK: Transaction States
public enum InAppPurchaseStatus {
    case purchasing, purchased, restored, failed
}
