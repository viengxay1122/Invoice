import SwiftUI

struct InvoiceEditorView: View {
    @EnvironmentObject var store: InvoiceStore
    @Environment(\.dismiss) private var dismiss
    @State private var invoice: Invoice

    init(invoice: Invoice) {
        _invoice = State(initialValue: invoice)
    }

    private var symbol: String { store.business.currencySymbol }
    private var isNew: Bool { !store.invoices.contains { $0.id == invoice.id } }

    var body: some View {
        NavigationStack {
            Form {
                Section("ข้อมูลใบแจ้งหนี้") {
                    TextField("เลขที่", text: $invoice.number)
                    DatePicker("วันที่", selection: $invoice.date, displayedComponents: .date)
                    DatePicker("ครบกำหนดชำระ", selection: $invoice.dueDate, displayedComponents: .date)
                    Picker("สถานะ", selection: $invoice.status) {
                        ForEach(InvoiceStatus.allCases) { Text($0.label).tag($0) }
                    }
                }

                Section("ลูกค้า") {
                    TextField("ชื่อลูกค้า", text: $invoice.customerName)
                    TextField("เบอร์โทร", text: $invoice.customerPhone)
                        .keyboardType(.phonePad)
                    TextField("ที่อยู่", text: $invoice.customerAddress, axis: .vertical)
                }

                Section("รายการสินค้า / บริการ") {
                    ForEach($invoice.items) { $item in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("ชื่อรายการ", text: $item.name)
                                .font(.body.weight(.medium))
                            HStack {
                                NumberField(title: "จำนวน", value: $item.quantity)
                                    .frame(width: 60)
                                Text("×").foregroundColor(.secondary)
                                NumberField(title: "ราคา/หน่วย", value: $item.unitPrice)
                                Spacer()
                                Text(item.total.money(symbol))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { invoice.items.remove(atOffsets: $0) }

                    Button {
                        invoice.items.append(LineItem())
                    } label: {
                        Label("เพิ่มรายการ", systemImage: "plus.circle.fill")
                    }
                }

                Section("สรุปยอด") {
                    HStack {
                        Text("ส่วนลด (\(symbol))")
                        Spacer()
                        NumberField(title: "0", value: $invoice.discount)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    HStack {
                        Text("ภาษี (%)")
                        Spacer()
                        NumberField(title: "0", value: $invoice.taxRate)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    row("รวมย่อย", invoice.subtotal.money(symbol))
                    if invoice.taxRate > 0 {
                        row("ภาษี \(invoice.taxRate.plain)%", invoice.taxAmount.money(symbol))
                    }
                    HStack {
                        Text("ยอดสุทธิ").bold()
                        Spacer()
                        Text(invoice.grandTotal.money(symbol)).bold().foregroundColor(.accentColor)
                    }
                }

                Section("หมายเหตุ") {
                    TextField("เช่น เงื่อนไขการชำระเงิน", text: $invoice.note, axis: .vertical)
                }
            }
            .navigationTitle(isNew ? "สร้างใบแจ้งหนี้" : "แก้ไขใบแจ้งหนี้")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("บันทึก") {
                        var toSave = invoice
                        toSave.items.removeAll { $0.name.trimmingCharacters(in: .whitespaces).isEmpty && $0.unitPrice == 0 }
                        store.upsert(toSave)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }
}

/// ช่องกรอกตัวเลขที่อัปเดตค่าทันทีทุกครั้งที่พิมพ์
struct NumberField: View {
    let title: String
    @Binding var value: Double
    @State private var text = ""

    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.decimalPad)
            .onAppear {
                text = value == 0 ? "" : Self.format(value)
            }
            .onChange(of: text) { newValue in
                let cleaned = newValue.replacingOccurrences(of: ",", with: ".")
                value = Double(cleaned) ?? 0
            }
    }

    static func format(_ v: Double) -> String {
        v == v.rounded() && abs(v) < 1e15 ? String(Int64(v)) : String(v)
    }
}
