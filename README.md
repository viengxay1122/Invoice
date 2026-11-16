# InvoiceApp – แอปสร้างใบแจ้งหนี้ (iOS)

แอป iPhone เขียนด้วย SwiftUI (iOS 16 ขึ้นไป) ทำงานออฟไลน์ทั้งหมด

**ความสามารถ**
- สร้าง / แก้ไข / ลบ / ทำสำเนาใบแจ้งหนี้ เลขที่รันอัตโนมัติ (INV-0001, INV-0002 …)
- ข้อมูลลูกค้า, รายการสินค้า/บริการไม่จำกัด, ส่วนลด, ภาษี %
- สถานะ ชำระแล้ว / ยังไม่ชำระ พร้อมยอดสรุปหน้าแรก และค้นหา
- ดูตัวอย่างเป็น PDF ขนาด A4 และ **แชร์ PDF** ไป LINE / WhatsApp / Messenger / พิมพ์ / บันทึกลง Files
- ตั้งค่าข้อมูลร้าน, เบอร์โทร, เลขบัญชี, สกุลเงิน (₭ ฿ $ ¥)

---

## ขั้นที่ 1: สร้างไฟล์ .ipa (ไม่ต้องมี Mac — ใช้ GitHub ฟรี)

การ build แอป iOS ต้องใช้ Xcode ซึ่งมีแค่บน macOS เลยใช้เครื่อง Mac ฟรีของ GitHub Actions แทน

1. สมัคร/เข้า https://github.com แล้วสร้าง repository ใหม่ (Private ก็ได้)
2. อัปโหลดทุกไฟล์ในโฟลเดอร์ `InvoiceApp` ขึ้นไป (รวมโฟลเดอร์ `.github`)
   - วิธีง่ายสุด: ติดตั้ง [GitHub Desktop](https://desktop.github.com) → Add local repository → Publish
3. เข้าแท็บ **Actions** ใน repo → workflow **Build IPA** จะรันเอง (ประมาณ 3–5 นาที)
   ถ้าไม่รัน กด **Run workflow**
4. เมื่อขึ้นเครื่องหมายถูกสีเขียว กดเข้าไป → ส่วน **Artifacts** → ดาวน์โหลด `InvoiceApp-unsigned-ipa`
   แตก zip จะได้ไฟล์ `InvoiceApp-unsigned.ipa`

> ไฟล์นี้ยัง **ไม่ได้เซ็น (unsigned)** ต้องเซ็นก่อนติดตั้ง ซึ่งขั้นที่ 2 ทำให้อัตโนมัติ

## ขั้นที่ 2: ติดตั้งลง iPhone จาก Windows ด้วย Sideloadly

1. ติดตั้ง **iTunes** (เวอร์ชันจากเว็บ apple.com ไม่ใช่ Microsoft Store) และ **Sideloadly** จาก https://sideloadly.io
2. เสียบสาย iPhone เข้าคอม กด "เชื่อถือคอมพิวเตอร์นี้" บนมือถือ
3. เปิด Sideloadly → ลากไฟล์ `.ipa` ใส่ → ใส่ Apple ID → กด **Start**
4. บน iPhone: **ตั้งค่า → ทั่วไป → VPN และการจัดการอุปกรณ์** → กดเชื่อถือ Apple ID ของคุณ
5. iOS 16 ขึ้นไป: เปิด **ตั้งค่า → ความเป็นส่วนตัวและความปลอดภัย → โหมดนักพัฒนา (Developer Mode)** แล้วรีสตาร์ท

### ข้อจำกัดตามประเภท Apple ID

| แบบ | ค่าใช้จ่าย | อายุแอป | หมายเหตุ |
|---|---|---|---|
| Apple ID ฟรี | ฟรี | **7 วัน** แล้วต้องติดตั้งซ้ำ (ข้อมูลไม่หาย ถ้าติดตั้งทับ) | ได้สูงสุด 3 แอปต่อเครื่อง |
| Apple Developer Program | 99 USD/ปี | 1 ปี | แจกผ่าน TestFlight หรือลง App Store ได้ |

---

## แก้ไขต่อ

| ไฟล์ | หน้าที่ |
|---|---|
| `Sources/Models.swift` | โครงสร้างข้อมูล (ใบแจ้งหนี้, รายการ, ข้อมูลร้าน) |
| `Sources/InvoiceStore.swift` | บันทึก/โหลดข้อมูล (ไฟล์ JSON ในเครื่อง) |
| `Sources/InvoiceListView.swift` | หน้าแรก รายการใบแจ้งหนี้ |
| `Sources/InvoiceEditorView.swift` | ฟอร์มสร้าง/แก้ไข |
| `Sources/InvoiceDetailView.swift` | ดู PDF + แชร์ |
| `Sources/InvoicePDF.swift` | **หน้าตาใบแจ้งหนี้** (แก้สี ฟอนต์ ข้อความ ตรงนี้) |
| `Sources/SettingsView.swift` | หน้าตั้งค่าร้าน |

ทุกครั้งที่ push โค้ดใหม่ GitHub จะ build `.ipa` ใหม่ให้อัตโนมัติ

ถ้ามี Mac: `brew install xcodegen && xcodegen generate` แล้วเปิด `InvoiceApp.xcodeproj` ใน Xcode กด Run ลงเครื่องได้เลย
