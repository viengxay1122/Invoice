import SwiftUI

@main
struct InvoiceApp: App {
    @StateObject private var store = InvoiceStore()

    var body: some Scene {
        WindowGroup {
            InvoiceListView()
                .environmentObject(store)
        }
    }
}
