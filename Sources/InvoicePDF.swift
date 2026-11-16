import SwiftUI

/// หน้าตาใบแจ้งหนี้ขนาด A4 (595 x 842 pt) ใช้ทั้งแสดงผลและสร้าง PDF
struct InvoiceDocumentView: View {
    let invoice: Invoice
    let business: BusinessInfo

    private let accent = Color(red: 0.15, green: 0.35, blue: 0.75)
    private var sym: String { business.currencySymbol }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            // หัวกระดาษ
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(business.name).font(.system(size: 20, weight: .bold))
                    if !business.address.isEmpty { Text(business.address).font(.system(size: 11)) }
                    if !business.phone.isEmpty { Text("โทร: \(business.phone)").font(.system(size: 11)) }
                    if !business.taxID.isEmpty { Text("เลขประจำตัวผู้เสียภาษี: \(business.taxID)").font(.system(size: 11)) }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("ใบแจ้งหนี้").font(.system(size: 24, weight: .bold)).foregroundColor(accent)
                    Text("INVOICE").font(.system(size: 10, weight: .semibold)).foregroundColor(.gray)
                    Text("เลขที่: \(invoice.number)").font(.system(size: 11))
                    Text("วันที่: \(invoice.date.short)").font(.system(size: 11))
                    Text("ครบกำหนด: \(invoice.dueDate.short)").font(.system(size: 11))
                }
            }

            Rectangle().fill(accent).frame(height: 2)

            // ลูกค้า
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("เรียกเก็บจาก").font(.system(size: 10, weight: .semibold)).foregroundColor(.gray)
                    Text(invoice.customerName.isEmpty ? "-" : invoice.customerName).font(.system(size: 13, weight: .bold))
                    if !invoice.customerPhone.isEmpty { Text("โทร: \(invoice.customerPhone)").font(.system(size: 11)) }
                    if !invoice.customerAddress.isEmpty { Text(invoice.customerAddress).font(.system(size: 11)) }
                }
                Spacer()
                Text(invoice.status.label)
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .foregroundColor(invoice.status == .paid ? .green : .orange)
                    .overlay(RoundedRectangle(cornerRadius: 4)
                        .stroke(invoice.status == .paid ? Color.green : Color.orange, lineWidth: 1.5))
            }

            // ตารางรายการ
            VStack(spacing: 0) {
                tableRow("#", "รายการ", "จำนวน", "ราคา/หน่วย", "รวม", header: true)
                ForEach(Array(invoice.items.enumerated()), id: \.element.id) { idx, item in
                    tableRow("\(idx + 1)", item.name, item.quantity.plain,
                             item.unitPrice.plain, item.total.plain, header: false)
                        .background(idx % 2 == 1 ? Color.gray.opacity(0.07) : Color.clear)
                }
            }

            // สรุปยอด
            HStack {
                Spacer()
                VStack(spacing: 6) {
                    totalRow("รวมย่อย", invoice.subtotal.money(sym))
                    if invoice.discount > 0 { totalRow("ส่วนลด", "-" + invoice.discount.money(sym)) }
                    if invoice.taxRate > 0 { totalRow("ภาษี \(invoice.taxRate.plain)%", invoice.taxAmount.money(sym)) }
                    Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                    HStack {
                        Text("ยอดสุทธิ").font(.system(size: 14, weight: .bold))
                        Spacer()
                        Text(invoice.grandTotal.money(sym)).font(.system(size: 14, weight: .bold)).foregroundColor(accent)
                    }
                }
                .frame(width: 240)
            }

            if !business.bankInfo.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    Text("ช่องทางชำระเงิน").font(.system(size: 10, weight: .semibold)).foregroundColor(.gray)
                    Text(business.bankInfo).font(.system(size: 11))
                }
            }
            if !invoice.note.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    Text("หมายเหตุ").font(.system(size: 10, weight: .semibold)).foregroundColor(.gray)
                    Text(invoice.note).font(.system(size: 11))
                }
            }

            Spacer(minLength: 0)

            Text("ขอบคุณที่ใช้บริการ")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
        }
        .padding(36)
        .frame(width: 595)
        .frame(minHeight: 842, alignment: .top)
        .background(Color.white)
        .foregroundColor(.black)
        .environment(\.colorScheme, .light)
    }

    private func tableRow(_ no: String, _ name: String, _ qty: String, _ price: String, _ total: String, header: Bool) -> some View {
        HStack(spacing: 6) {
            Text(no).frame(width: 22, alignment: .leading)
            Text(name).frame(maxWidth: .infinity, alignment: .leading)
            Text(qty).frame(width: 50, alignment: .trailing)
            Text(price).frame(width: 90, alignment: .trailing)
            Text(total).frame(width: 100, alignment: .trailing)
        }
        .font(.system(size: 11, weight: header ? .bold : .regular))
        .foregroundColor(header ? .white : .black)
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(header ? accent : Color.clear)
    }

    private func totalRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 11))
            Spacer()
            Text(value).font(.system(size: 11))
        }
    }
}

@MainActor
enum PDFExporter {
    /// สร้างไฟล์ PDF ไว้ในโฟลเดอร์ชั่วคราว แล้วคืน URL ให้นำไปแชร์
    static func makePDF(invoice: Invoice, business: BusinessInfo) -> URL? {
        let renderer = ImageRenderer(content: InvoiceDocumentView(invoice: invoice, business: business))
        renderer.proposedSize = ProposedViewSize(width: 595, height: nil)

        let safeName = invoice.number
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).pdf")

        var success = false
        renderer.render { size, draw in
            var box = CGRect(x: 0, y: 0, width: 595, height: max(842, size.height))
            guard let ctx = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            ctx.beginPDFPage(nil)
            ctx.translateBy(x: 0, y: box.height - size.height)
            draw(ctx)
            ctx.endPDFPage()
            ctx.closePDF()
            success = true
        }
        return success ? url : nil
    }
}
