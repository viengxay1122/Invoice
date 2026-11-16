import SwiftUI

struct InvoiceListView: View {
    @EnvironmentObject var store: InvoiceStore
    @State private var editing: Invoice?
    @State private var showSettings = false
    @State private var search = ""

    private var filtered: [Invoice] {
        guard !search.isEmpty else { return store.invoices }
        return store.invoices.filter {
            $0.customerName.localizedCaseInsensitiveContains(search) ||
            $0.number.localizedCaseInsensitiveContains(search)
        }
    }

    private var symbol: String { store.business.currencySymbol }

    var body: some View {
        NavigationStack {
            List {
                if !store.invoices.isEmpty {
                    Section {
                        HStack {
                            summaryBox(title: "ค้างชำระ",
                                       amount: store.invoices.filter { $0.status == .unpaid }.reduce(0) { $0 + $1.grandTotal },
                                       color: .orange)
                            summaryBox(title: "ชำระแล้ว",
                                       amount: store.invoices.filter { $0.status == .paid }.reduce(0) { $0 + $1.grandTotal },
                                       color: .green)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }

                Section {
                    ForEach(filtered) { inv in
                        NavigationLink(value: inv.id) {
                            InvoiceRow(invoice: inv, symbol: symbol)
                        }
                    }
                    .onDelete { offsets in
                        store.delete(ids: offsets.map { filtered[$0].id })
                    }
                }
            }
            .overlay {
                if store.invoices.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("ยังไม่มีใบแจ้งหนี้").font(.headline)
                        Text("กดปุ่ม + เพื่อสร้างใบแรก").foregroundColor(.secondary)
                    }
                }
            }
            .searchable(text: $search, prompt: "ค้นหาลูกค้า หรือเลขที่")
            .navigationTitle("ใบแจ้งหนี้")
            .navigationDestination(for: UUID.self) { id in
                InvoiceDetailView(invoiceID: id)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { editing = store.newInvoice() } label: { Image(systemName: "plus") }
                }
            }
            .sheet(item: $editing) { inv in
                InvoiceEditorView(invoice: inv)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private func summaryBox(title: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(amount.money(symbol))
                .font(.headline)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct InvoiceRow: View {
    let invoice: Invoice
    let symbol: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(invoice.customerName.isEmpty ? "(ไม่มีชื่อลูกค้า)" : invoice.customerName)
                    .font(.headline)
                Text("\(invoice.number) · \(invoice.date.short)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(invoice.grandTotal.money(symbol)).font(.subheadline.bold())
                Text(invoice.status.label)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background((invoice.status == .paid ? Color.green : Color.orange).opacity(0.15))
                    .foregroundColor(invoice.status == .paid ? .green : .orange)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 2)
    }
}
