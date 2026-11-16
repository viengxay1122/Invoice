import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: InvoiceStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("ข้อมูลร้าน / บริษัท (แสดงบนใบแจ้งหนี้)") {
                    TextField("ชื่อร้าน", text: $store.business.name)
                    TextField("เบอร์โทร", text: $store.business.phone)
                        .keyboardType(.phonePad)
                    TextField("ที่อยู่", text: $store.business.address, axis: .vertical)
                    TextField("เลขประจำตัวผู้เสียภาษี (ถ้ามี)", text: $store.business.taxID)
                }

                Section("ช่องทางชำระเงิน") {
                    TextField("เช่น ธนาคาร / เลขบัญชี / ชื่อบัญชี", text: $store.business.bankInfo, axis: .vertical)
                }

                Section("รูปแบบ") {
                    Picker("สกุลเงิน", selection: $store.business.currencySymbol) {
                        Text("₭ กีบ").tag("₭")
                        Text("฿ บาท").tag("฿")
                        Text("$ ดอลลาร์").tag("$")
                        Text("¥ หยวน").tag("¥")
                    }
                    HStack {
                        Text("คำนำหน้าเลขที่")
                        Spacer()
                        TextField("INV", text: $store.business.invoicePrefix)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    Stepper("เลขที่ถัดไป: \(store.nextNumber)", value: $store.nextNumber, in: 1...999_999)
                }
            }
            .navigationTitle("ตั้งค่า")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("เสร็จ") { dismiss() }.bold()
                }
            }
        }
    }
}
