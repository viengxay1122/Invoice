import SwiftUI

/// เก็บข้อมูลทั้งหมดเป็นไฟล์ JSON ในเครื่อง (ไม่ต้องใช้อินเทอร์เน็ต)
@MainActor
final class InvoiceStore: ObservableObject {
    @Published var invoices: [Invoice] = [] { didSet { save() } }
    @Published var business = BusinessInfo() { didSet { save() } }
    @Published var nextNumber: Int = 1 { didSet { save() } }

    private struct SaveData: Codable {
        var invoices: [Invoice]
        var business: BusinessInfo
        var nextNumber: Int
    }

    private let fileURL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("invoices.json")

    init() {
        if let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode(SaveData.self, from: data) {
            invoices = saved.invoices
            business = saved.business
            nextNumber = saved.nextNumber
        }
    }

    private func save() {
        let data = SaveData(invoices: invoices, business: business, nextNumber: nextNumber)
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: fileURL, options: .atomic)
        }
    }

    func newInvoice() -> Invoice {
        Invoice(number: String(format: "%@-%04d", business.invoicePrefix, nextNumber))
    }

    func upsert(_ invoice: Invoice) {
        if let i = invoices.firstIndex(where: { $0.id == invoice.id }) {
            invoices[i] = invoice
        } else {
            invoices.insert(invoice, at: 0)
            nextNumber += 1
        }
    }

    func delete(ids: [UUID]) {
        invoices.removeAll { ids.contains($0.id) }
    }

    func toggleStatus(_ id: UUID) {
        guard let i = invoices.firstIndex(where: { $0.id == id }) else { return }
        invoices[i].status = invoices[i].status == .paid ? .unpaid : .paid
    }
}
