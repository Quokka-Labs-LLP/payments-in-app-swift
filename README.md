# InAppPurchase
Simple and lightweight In-App Purchase library which provides support for UIKit & SwiftUI

[![UIKit](https://img.shields.io/badge/UIKit-orange.svg?style=flat)](https://developer.apple.com/documentation/uikit)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-blue.svg?style=flat)](https://developer.apple.com/xcode/swiftui/)

## Example

To run the example project, clone the repo, and add the package `https://github.com/Quokka-Labs-LLP/payments-in-app-swift` from the Example directory first.

## How to use
* **Step-1 Add Package:** Add package form following link 

```ruby
https://github.com/Quokka-Labs-LLP/payments-in-app-swift
```
* **Step-2 Import Library:** Import InAppPurchase and StoreKit in the class and struct where we use it. Create a class in the project, now create an instance of the InAppPurchase() class and call the fetchProduct Function to fetch the product form the App Store. code as follows.
```ruby

import InAppPurchase
import StoreKit

class InAppPurchaseManager: ObservableObject {

    var productID: Set<String>  = ["com.abas.common"]
    var iapObserver: InAppPurchase?

    func fetchProduct() {
        iapObserver = InAppPurchase(productsId: productID, delegate: self)
    }
}
```
* **Step-3 Configure delegate and protocol:** Create extension of InAppPurchaseManager class for implementation of delegate and protocol of InAppPurchaseDelegate as shown in code.
```ruby
extension InAppPurchaseManager: InAppPurchaseDelegate {
    func purchaseFail(error: TransactionAuthError ) {
        switch error {
        case .noValidProductsAvailable:
            print("No valid products available")
        case .productIdNotFound:
            print("ProductId not found")
        case .invalidProductIdentifier:
            print("Invalid product identifier")
        case .transactionFailed:
            print("Transaction Failed")
        case .unknown:
            print("Unknown Fail")
        }

    }

    func purchaseStatus(status: InAppPurchaseStatus) {
        switch status {
        case .purchasing:
            print("purchasing")
        case .purchased:
            print("purchased")
        case .restored:
            print("restored")
        case .failed:
            print("failed")
        }

    }

    func purchaseSuccess(receipt: String?, transaction: SKPaymentTransaction) {
        switch transaction.transactionState {
        case .purchasing:
            // you can show the loader
            print("purchasing")
        case .purchased:
            // you can write your code that you want to do after purchased.
            print("purchased")
        case .restored:
            // you can write your code that you want to do after restored.
            print("restored")
        case .deferred:
            // you can write your code that you want to do after deferred.
            print("deferred")
        case .failed:
            // you can hide the loader
            print("failed")
        @unknown default:
            print("unknown")
        }
    }
}
```
* **Step-4 Implementation in View:** In View where we want to use it, So create an instance of InAppPurchaseManager() in view, and then use the instance to fetch the product and show the In-app purchase sheet with these lines of code. and purchaseProduct function is used for purchasing products with the product Id that is created in the App Store.
```ruby
import InAppPurchase

struct ContentView: View {
    @ObservedObject var inAppPurchaseViewModel = InAppPurchaseViewModel()
    var body: some View {
        VStack {
            Button {
                inAppPurchaseViewModel.iapObserver?.purchaseProduct(id: "com.abas.common")
            } label: {
                Text("Do Payment")
            }
        }
        .padding()
        .onAppear {
            inAppPurchaseViewModel.fetchProduct()

        }
    }
}
```
Note: always first fetchProduct function after that call the purchaseProduct function because without fetching the product id we can't purchase products.
  
## Requirements

* iOS 9+
* Xcode 11+

## Add Package

InAppPurchase is available through [GitHub](https://github.com/Quokka-Labs-LLP/payments-in-app-swift). To add
it, simply add the following link to your Project:

```ruby
https://github.com/Quokka-Labs-LLP/payments-in-app-swift
```

## Author

Mohammad Jeeshan
```ruby
mohammad.jeeshan.91@gmail.com
```

## License

InAppPurchase is available under the MIT license. See the LICENSE file for more info.

