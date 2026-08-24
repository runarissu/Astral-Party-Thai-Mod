<p align="center">
  <img src="assets/hero.jpg" alt="Astral Party" width="640">
</p>

<h1 align="center">Astral Party Thai Mod</h1>

<p align="center">
  <strong>ม็อดแปลภาษาไทยสำหรับ Astral Party (星穹派对)</strong>
</p>

[![Views](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Frunarissu%2FAstral-Party-Thai-Mod&count_bg=%237952B3&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false)](https://hits.seeyoufarm.com)
[![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/runarissu/Astral-Party-Thai-Mod/latest/total?color=blue&label=downloads)](https://github.com/runarissu/Astral-Party-Thai-Mod/releases)

<p align="center">
  รองรับเวอร์ชั่น <strong>V3.2.0.1</strong> (INT)
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

**Font Redirection** — เปลี่ยนเส้นทางการขอ font ทั้งหมดไปยัง "Prompt Thai Stacked" ซึ่งเป็น DynamicFont ที่แก้ตำแหน่งวรรณยุกต์แล้ว เพื่อหลีกเลี่ยงปัญหา Unity ที่ไม่รองรับ GPOS สำหรับภาษาไทย

**Translation Cache** — แพตช์เมธอด `GetLocal()` ทั้ง 61 ตัว ให้อ่านคำแปลจากไฟล์ TSV ผ่าน cache แบบ pre-parsed ครั้งแรกที่เรียกจะ parse และ cache ไว้ใน array การเรียกครั้งต่อไปจะค้นหาจาก array เล็กๆ (~20-50 entries) โดยไม่มีการ allocate string เพิ่ม

## วิธีถอนการติดตั้ง

1. **ลบ font**: Control Panel → Fonts → `Prompt Thai Stacked` → Delete
2. **กู้คืนไฟล์เกม**: Steam → คลิกขวาเกม → Properties → Local Files → Verify integrity of game files

## โครงสร้างไฟล์ใน Release

```
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
