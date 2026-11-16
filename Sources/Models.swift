import Foundation

struct LineItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String = ""
    var quantity: Double = 1
    var unitPrice: Double = 0

    var total: Double { quantity * unitPrice }
}

enum InvoiceStatus: String, Codable, CaseIterable, Identifiable {
    case unpaid, paid
    var id: String { rawValue }
    var label: String { self == .paid ? "ชำระแล้ว" : "ยังไม่ชำระ" }
}

struct Invoice: Identifiable, Codable, Hashable {
    var id = UUID()
    var number: String
    var date: Date = Date()
    var dueDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var customerName: String = ""
    var customerPhone: String = ""
    var customerAddress: String = ""
    var items: [LineItem] = [LineItem()]
    var discount: Double = 0
    var taxRate: Double = 0 // เปอร์เซ็นต์
    var note: String = ""
    var status: InvoiceStatus = .unpaid

    var subtotal: Double { items.reduce(0) { $0 + $1.total } }
    var afterDiscount: Double { max(subtotal - discount, 0) }
    var taxAmount: Double { afterDiscount * taxRate / 100 }
    var grandTotal: Double { afterDiscount + taxAmount }
}

struct BusinessInfo: Codable, Equatable {
    var name: String = "ชื่อร้านของคุณ"
    var phone: String = ""
    var address: String = ""
    var taxID: String = ""
    var bankInfo: String = ""
    var currencySymbol: String = "₭"
    var invoicePrefix: String = "INV"
}

extension Double {
    func money(_ symbol: String) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return "\(f.string(from: NSNumber(value: self)) ?? "0") \(symbol)"
    }

    var plain: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: self)) ?? "0"
    }
}

extension Date {
    var short: String { formatted(date: .abbreviated, time: .omitted) }
}
