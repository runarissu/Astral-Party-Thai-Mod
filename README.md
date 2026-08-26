<p align="center">
  <img src="assets/hero.jpg" alt="Astral Party" width="640">
</p>

<h1 align="center">Astral Party Thai Mod</h1>

<p align="center">
  <strong>ม็อดแปลภาษาไทยสำหรับ Astral Party (星穹派对)</strong>
</p>

<p align="center">
  รองรับเวอร์ชั่น <strong>V3.2.0.1</strong> (INT) · Mod v1.1.0
</p>

<p align="center">
  <a href="https://github.com/runarissu/Astral-Party-Thai-Mod/graphs/traffic"><img alt="Repository views" src="https://raw.githubusercontent.com/runarissu/Astral-Party-Thai-Mod/traffic-data/views.svg"></a>
  <img alt="Downloads" src="https://img.shields.io/github/downloads/runarissu/Astral-Party-Thai-Mod/total?color=blue&label=downloads">
  <img alt="Latest Release Downloads" src="https://img.shields.io/github/downloads/runarissu/Astral-Party-Thai-Mod/latest/total?color=success&label=latest%20release">
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

## มีอะไรใหม่ใน v1.1.0

- **DynamicFont rendering path** — non-TMP fonts ใช้ Prompt (OS font) ผ่าน DynamicFont แทน TMP fallback เดิม แก้ปัญหา outline หนาดำที่เคยเกิด
- **Char-based pair adjustments** — ทั้ง TMPFont และ DynamicFont ใช้ char-based lookup แทน glyphIndex หลีกเลี่ยง IL2CPP stripping
- **Dual pair adjustment data** — `pair_adjustments.bin` สำหรับ TMPFont + `pair_adjustments_prompt.bin` สำหรับ DynamicFont (yOffsets scaled)
- **8 TMP font bundles** — รวมใน release แล้ว ติดตั้งอัตโนมัติ

## วิธีการทำงาน

ม็อดนี้แก้ไข 4 ระบบหลัก:

**Font Redirection** — font names ที่ลงท้ายด้วย `_TMP` คงไว้โหลด Thai TMP bundle ผ่าน Addressables ส่วน font names อื่น redirect ไป `"Prompt"` (OS font) เพื่อสร้าง DynamicFont ผ่าน `Font.CreateDynamicFontFromOSFont`

**TMP Font Bundles** — clone Unity-built Static TMP_FontAsset (family Prompt) ออกเป็น 8 bundles สำหรับ 8 fonts ของเกม แต่ละ bundle มี pre-baked SDF atlas + glyph-pair adjustments

**Pair Adjustments** — embed 34 pair adjustment records เป็น static arrays ในทั้ง TMPFont และ DynamicFont ใช้ char-based linear search ปรับตำแหน่งวรรณยุกต์/สระลอยให้ถูกต้อง

**Translation Cache** — แพตช์เมธอด `GetLocal()` ทั้ง 61 ตัว ให้อ่านคำแปลจาก `clean_thai.tsv` ผ่าน cache แบบ pre-parsed

## วิธีถอนการติดตั้ง

1. **ลบ font**: Control Panel → Fonts → `Prompt Regular` → Delete
2. **กู้คืนไฟล์เกม**: Steam → คลิกขวาเกม → Properties → Local Files → Verify integrity of game files

## โครงสร้างไฟล์ใน Release

```
├── install.bat              # One-click installer
├── install.ps1              # Installer script (v1.1.0)
├── fonts/
│   └── Prompt-Regular.ttf   # Thai font (OS font for DynamicFont)
├── data/
│   └── clean_thai.tsv       # Translation table
└── bundles/
    ├── hotupdate_dll/       # Patched DLL (font redirect + cache + pair adjustments)
    ├── localization/        # Thai localization bundle
    └── tmp_fonts/           # 8 Thai TMP font bundles
```

## Disclaimer

ม็อดนี้ไม่ได้เกี่ยวข้องกับผู้พัฒนาเกม ไม่ได้แจกจ่ายไฟล์เกมที่มีลิขสิทธิ์ ใช้ความเสี่ยงของผู้ใช้เอง หากเกมอัปเดต ม็อดอาจต้องได้รับการอัปเดตตาม

## License

[MIT](LICENSE)
