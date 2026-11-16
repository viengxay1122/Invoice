import SwiftUI
import PDFKit

struct InvoiceDetailView: View {
    @EnvironmentObject var store: InvoiceStore
    @Environment(\.dismiss) private var dismiss
    let invoiceID: UUID

    @State private var editing: Invoice?
    @State private var pdfURL: URL?
    @State private var pdfData: Data?
    @State private var confirmDelete = false

    private var invoice: Invoice? { store.invoices.first { $0.id == invoiceID } }

    var body: some View {
        Group {
            if let invoice {
                VStack(spacing: 0) {
                    if let pdfData {
                        PDFKitView(data: pdfData)
                    } else {
                        ProgressView().frame(maxHeight: .infinity)
                    }
                }
                .navigationTitle(invoice.number)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if let pdfURL {
                            ShareLink(item: pdfURL) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        Menu {
                            Button { editing = invoice } label: {
                                Label("แก้ไข", systemImage: "pencil")
                            }
                            Button { store.toggleStatus(invoice.id) } label: {
                                Label(invoice.status == .paid ? "ทำเป็นยังไม่ชำระ" : "ทำเป็นชำระแล้ว",
                                      systemImage: "checkmark.circle")
                            }
                            Button {
                                var copy = store.newInvoice()
                                copy.customerName = invoice.customerName
                                copy.customerPhone = invoice.customerPhone
                                copy.customerAddress = invoice.customerAddress
                                copy.items = invoice.items.map { LineItem(name: $0.name, quantity: $0.quantity, unitPrice: $0.unitPrice) }
                                copy.discount = invoice.discount
                                copy.taxRate = invoice.taxRate
                                copy.note = invoice.note
                                editing = copy
                            } label: {
                                Label("ทำสำเนาเป็นใบใหม่", systemImage: "doc.on.doc")
                            }
                            Button(role: .destructive) { confirmDelete = true } label: {
                                Label("ลบ", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .onAppear { regenerate(invoice) }
                .onChange(of: invoice) { regenerate($0) }
                .onChange(of: store.business) { _ in regenerate(invoice) }
            } else {
                Text("ไม่พบใบแจ้งหนี้").foregroundColor(.secondary)
            }
        }
        .sheet(item: $editing) { inv in
            InvoiceEditorView(invoice: inv)
        }
        .confirmationDialog("ลบใบแจ้งหนี้นี้?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("ลบ", role: .destructive) {
                store.delete(ids: [invoiceID])
                dismiss()
            }
        }
    }

    private func regenerate(_ invoice: Invoice) {
        if let url = PDFExporter.makePDF(invoice: invoice, business: store.business) {
            pdfURL = url
            pdfData = try? Data(contentsOf: url)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.backgroundColor = .systemGroupedBackground
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) {
        view.document = PDFDocument(data: data)
        view.autoScales = true
    }
}
