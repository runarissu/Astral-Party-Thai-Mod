<p align="center">
  <img src="assets/cover.jpg" alt="Astral Party" width="480">
</p>

<h1 align="center">Astral Party Thai Mod</h1>

<p align="center">
  <strong>ม็อดแปลภาษาไทยสำหรับ Astral Party (星穹派对)</strong>
</p>

---

## เกี่ยวกับม็อดนี้

เป็นม็อดที่เพิ่มภาษาไทยให้กับเกม Astral Party บน Steam (เวอร์ชั่น INT) ตอนทำติดปัญหาอยู่ 3 อย่างใหญ่ๆ:

- Unity DynamicFont ไม่รองรับ GPOS สำหรับภาษาไทย เลยต้อง bake ตำแหน่งวรรณยุกต์เข้าไปใน font เอง
- วรรณยุกต์ (่ ้ ๊ ๋) มักจะทับสระบน (ี ื) ต้องยกขึ้นไปอีก 277 units
- การค้นหาคำแปลทำให้ UI กระตุก เลยทำ cache แบบ pre-parsed ฝังไว้ใน DLL

## วิธีติดตั้ง

### ข้อกำหนด

- ติดตั้ง **Astral Party** บน Steam (เวอร์ชั่น INT)
- เคยเปิดเกมอย่างน้อย 1 ครั้ง
- Windows 10/11

### ขั้นตอน

1. ดาวน์โหลด ZIP จากหน้า [Releases](../../releases)
2. แตกไฟล์
3. ดับเบิ้ลคลิก `install.bat`
4. กด **Yes** เมื่อ Windows ถาม UAC
5. เปิดเกม

## วิธีการทำงาน

ม็อดนี้แก้ไข 2 ระบบหลัก:

**Font Redirection** — เปลี่ยนเส้นทางการขอ font ทั้งหมดไปยัง "Prompt Thai Stacked" ซึ่งเป็น DynamicFont ที่แก้ตำแหน่งวรรณยุกต์แล้ว เพื่อหลีกเลี่ยงปัญหา Unity ที่ไม่รองรับ GPOS สำหรับภาษาไทย

**Translation Cache** — แพตช์เมธอด `GetLocal()` ทั้ง 61 ตัว ให้อ่านคำแปลจากไฟล์ TSV ผ่าน cache แบบ pre-parsed ครั้งแรกที่เรียกจะ parse และ cache ไว้ใน array การเรียกครั้งต่อไปจะค้นหาจาก array เล็กๆ (~20-50 entries) โดยไม่มีการ allocate string เพิ่ม

## วิธีถอนการติดตั้ง

1. **ลบ font**: Control Panel → Fonts → `Prompt Thai Stacked` → Delete
2. **กู้คืนไฟล์เกม**: Steam → คลิกขวาเกม → Properties → Local Files → Verify integrity of game files

## โครงสร้างไฟล์

```
release/
├── install.bat              # ตัวติดตั้งแบบคลิกเดียว
├── install.ps1              # สคริปต์ติดตั้ง
├── fonts/
│   └── Prompt-Thai-Stacked.ttf
├── data/
│   └── thai_tab.tsv         # ตารางแปลภาษา
└── bundles/
    ├── hotupdate_dll/       # DLL ที่แพตช์แล้ว (font + cache)
    └── localization/        # Bundle ภาษาไทย
```

## Disclaimer

ม็อดนี้ไม่ได้เกี่ยวข้องกับผู้พัฒนาเกม ไม่ได้แจกจ่ายไฟล์เกมที่มีลิขสิทธิ์ ใช้ความเสี่ยงของผู้ใช้เอง หากเกมอัปเดต ม็อดอาจต้องได้รับการอัปเดตตาม

## License

[MIT](LICENSE)
