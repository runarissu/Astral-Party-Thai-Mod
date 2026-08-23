<p align="center">
  <img src="assets/cover.jpg" alt="Astral Party" width="480">
</p>

<h1 align="center">Astral Party Thai Mod</h1>

<p align="center">
  <strong>ม็อดแปลภาษาไทยสำหรับ Astral Party (星穹派对)</strong>
</p>

---

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

**Font Redirection** — redirects all font requests to "Prompt Thai Stacked", a DynamicFont with corrected tone mark positions, bypassing Unity's lack of GPOS support for Thai

**Translation Cache** — patches all 61 `GetLocal()` methods to read Thai translations from a TSV file via pre-parsed static cache. First call parses and caches into arrays; subsequent calls do a linear search through a small array (~20-50 entries) with zero string allocation

## วิธีถอนการติดตั้ง

1. **ลบ font**: Control Panel → Fonts → `Prompt Thai Stacked` → Delete
2. **กู้คืนไฟล์เกม**: Steam → คลิกขวาเกม → Properties → Local Files → Verify integrity of game files

## โครงสร้างไฟล์

```
release/
├── install.bat              # One-click installer
├── install.ps1              # Installer script
├── fonts/
│   └── Prompt-Thai-Stacked.ttf
├── data/
│   └── thai_tab.tsv         # Translation table
└── bundles/
    ├── hotupdate_dll/       # Patched DLL (font + cache)
    └── localization/        # Thai localization bundle
```

## Disclaimer

ม็อดนี้ไม่ได้เกี่ยวข้องกับผู้พัฒนาเกม ไม่ได้แจกจ่ายไฟล์เกมที่มีลิขสิทธิ์ ใช้ความเสี่ยงของผู้ใช้เอง หากเกมอัปเดต ม็อดอาจต้องได้รับการอัปเดตตาม

## License

[MIT](LICENSE)
