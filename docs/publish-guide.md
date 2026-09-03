# Publish Guide — วิธี Publish Mod Version ใหม่ขึ้น GitHub

คู่มือ step-by-step สำหรับ publish mod version ใหม่ไปยัง public repo และ GitHub Releases
ใช้สำหรับทุกครั้งที่อัปเดต mod หลังจาก game update หรือ translation update

---

## 0. ข้อกำหนดเบื้องต้น

| รายการ | หมายเหตุ |
|--------|----------|
| Dev repo | `X:\Astral-Party-Thai-Mod-Dev` (working dir) |
| Public repo | `D:\AstralPartyThaiMod-GitHub` (release staging) |
| GitHub CLI | `gh` (ติดตั้งผ่าน `winget install --id GitHub.cli`) |
| Git credential | ต้อง login แล้ว (`git credential fill` หา token ได้) |
| Release folder | `D:\AstralPartyThaiMod-GitHub\release\` ต้องมีไฟล์ล่าสุด |

---

## 1. เตรียมไฟล์ใน release/ folder

ตรวจว่า `D:\AstralPartyThaiMod-GitHub\release\` มีไฟล์ครบ:

```
release/
├── install.bat
├── install.ps1
├── fonts/
│   └── Prompt-Regular.ttf
├── data/
│   └── clean_thai.tsv
└── bundles/
    ├── hotupdate_dll/
    ├── localization/
    ├── font_cache/
    └── tmp_fonts/
```

```powershell
# ตรวจไฟล์
Get-ChildItem "D:\AstralPartyThaiMod-GitHub\release" -Recurse -File | Measure-Object
```

---

## 2. สร้าง ZIP ไฟล์

```powershell
$version = "1.2.0"  # เปลี่ยนตาม version ใหม่
$zipPath = "D:\AstralPartyThaiMod-GitHub\Astral-Party-Thai-Mod-v$version.zip"

# ลบ zip เก่าถ้ามี
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

# สร้าง zip จาก release/ folder
Compress-Archive -Path "D:\AstralPartyThaiMod-GitHub\release\*" -DestinationPath $zipPath -CompressionLevel Optimal

# ตรวจขนาด
$info = Get-Item $zipPath
Write-Host "ZIP built: $($info.Name) size=$($info.Length) bytes ($([math]::Round($info.Length/1MB,2)) MB)"
```

---

## 3. อัปเดต README.md

อัปเดตส่วนต่อไปนี้ใน `D:\AstralPartyThaiMod-GitHub\README.md`:

| ส่วน | ที่ต้องเปลี่ยน |
|------|---------------|
| Version badge | `Mod v1.2.0` → version ใหม่ |
| Game version | `V3.2.0` → version ใหม่ |
| มีอะไรใหม่ | เพิ่ม changelog ของ version ใหม่ |
| โครงสร้างไฟล์ | อัปเดตถ้ามีไฟล์เพิ่ม/ลด |
| GetLocal count | อัปเดตถ้า DLL เปลี่ยน |

---

## 4. Commit + Push ไป public repo

```powershell
$repo = "D:\AstralPartyThaiMod-GitHub"

# Stage ทุกอย่าง (รวม zip ใหม่)
git -C $repo add -A

# Commit
$msg = "chore: rebuild v$version zip and update README"
git -C $repo commit -m $msg

# Push
git -C $repo push origin main
```

> **หมายเหตุ**: ลบ zip version เก่าออกจาก repo ด้วย (เช่น `git rm Astral-Party-Thai-Mod-v1.1.0.zip`)

---

## 5. อัปเดต GitHub Release

### 5.1 ดึง GitHub token จาก credential manager

```powershell
$credInput = "protocol=https`nhost=github.com`n`n"
$token = ($credInput | git -C "D:\AstralPartyThaiMod-GitHub" credential fill 2>&1 |
    Select-String "password" | ForEach-Object { $_.Line.Substring(9) } | Select-Object -First 1)
$headers = @{ "Authorization" = "Bearer $token"; "Accept" = "application/vnd.github+json" }
```

### 5.2 สร้าง release ใหม่ (ถ้ายังไม่มี)

```powershell
$tag = "v$version"  # เช่น v1.2.0
$releaseName = "Astral Party Thai Mod $tag"

$body = @{
    tag_name = $tag
    name = $releaseName
    body = "Release notes here"  # ดู template ในขั้นตอน 5.4
    draft = $false
    prerelease = $false
} | ConvertTo-Json -Depth 3

$resp = Invoke-RestMethod -Uri "https://api.github.com/repos/runarissu/Astral-Party-Thai-Mod/releases" -Headers $headers -Method Post -Body $body -ContentType "application/json"
$releaseId = $resp.id
Write-Host "Release created: id=$releaseId"
```

### 5.3 ลบ asset เก่า + อัปโหลด zip ใหม่ (ถ้า release มีอยู่แล้ว)

```powershell
# หา release id จาก tag
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/runarissu/Astral-Party-Thai-Mod/releases/tags/$tag" -Headers $headers
$releaseId = $release.id

# ลบ asset เก่าทั้งหมด
foreach ($asset in $release.assets) {
    Invoke-RestMethod -Uri "https://api.github.com/repos/runarissu/Astral-Party-Thai-Mod/releases/assets/$($asset.id)" -Headers $headers -Method Delete
    Write-Host "Deleted old asset: $($asset.name)"
}

# อัปโหลด zip ใหม่
$zipPath = "D:\AstralPartyThaiMod-GitHub\Astral-Party-Thai-Mod-v$version.zip"
$fileName = "Astral-Party-Thai-Mod-v$version.zip"
$bytes = [System.IO.File]::ReadAllBytes($zipPath)

$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"
$bodyLines = @(
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
    "Content-Type: application/zip",
    "",
    ""
) -join $LF
$closeBoundary = "$LF--$boundary--$LF"

$encoding = [System.Text.Encoding]::UTF8
$headerBytes = $encoding.GetBytes($bodyLines)
$closeBytes = $encoding.GetBytes($closeBoundary)
$fullBody = New-Object byte[] ($headerBytes.Length + $bytes.Length + $closeBytes.Length)
[System.Array]::Copy($headerBytes, 0, $fullBody, 0, $headerBytes.Length)
[System.Array]::Copy($bytes, 0, $fullBody, $headerBytes.Length, $bytes.Length)
[System.Array]::Copy($closeBytes, 0, $fullBody, $headerBytes.Length + $bytes.Length, $closeBytes.Length)

$uploadHeaders = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "Content-Type" = "multipart/form-data; boundary=$boundary"
}

$resp = Invoke-RestMethod -Uri "https://uploads.github.com/repos/runarissu/Astral-Party-Thai-Mod/releases/$releaseId/assets?name=$fileName" -Headers $uploadHeaders -Method Post -Body $fullBody
Write-Host "Upload complete: $($resp.name) | $($resp.browser_download_url)"
```

### 5.4 อัปเดต release notes

```powershell
$releaseBody = @"
## Astral Party Thai Mod $tag

อัปเดตล่าสุดสำหรับเกม Astral Party เวอร์ชัน X.X.X

### วิธีติดตั้ง

1. ดาวน์โหลดไฟล์ ``Astral-Party-Thai-Mod-$tag.zip``
2. แตกไฟล์ ZIP ไปยังโฟลเดอร์ใดก็ได้
3. คลิกขวา ``install.bat`` → เลือก **"Run as administrator"**
4. กด **Yes** เมื่อ Windows ถาม UAC
5. รอจนกว่าจะเห็นข้อความ **"Installation Complete!"**
6. ปิด installer แล้วเปิดเกมได้เลย

> หากติดตั้งม็อดเวอร์ชั่นเก่าแล้ว สามารถติดตั้งทับได้เลย installer จะสำรองไฟล์เดิมอัตโนมัติ

### มีอะไรใหม่

- [เพิ่ม changelog ของ version ใหม่ที่นี่]

### ข้อกำหนด

- Astral Party เวอร์ชัน X.X.X ขึ้นไป (INT)
- Windows 10/11
- เคยเปิดเกมอย่างน้อย 1 ครั้ง

### วิธีถอนการติดตั้ง

1. ลบ font: Control Panel → Fonts → ``Prompt Regular`` → Delete
2. กู้คืนไฟล์เกม: Steam → Properties → Local Files → Verify integrity of game files
3. ลบ cache ม็อด: ลบโฟลเดอร์ ``AppData\LocalLow\feimo\AstralParty_INT\com.unity.addressables\AssetBundles`` แล้วเปิดเกมใหม่
"@

$bodyJson = @{ body = $releaseBody } | ConvertTo-Json -Depth 3
$resp = Invoke-RestMethod -Uri "https://api.github.com/repos/runarissu/Astral-Party-Thai-Mod/releases/$releaseId" -Headers $headers -Method Patch -Body $bodyJson -ContentType "application/json"
Write-Host "Release notes updated!"
```

---

## 6. ตรวจสอบผล

```powershell
# เช็ค release บน GitHub
$latest = Invoke-RestMethod -Uri "https://api.github.com/repos/runarissu/Astral-Party-Thai-Mod/releases/latest" -Headers $headers
Write-Host "Latest release: $($latest.tag_name) | $($latest.name)"
Write-Host "URL: $($latest.html_url)"
$latest.assets | ForEach-Object { Write-Host "  Asset: $($_.name) | $($_.state) | $($_.size) bytes" }
```

---

## 7. Sync กลับไป dev repo

```powershell
# อัปเดต docs ใน dev repo
# - versions.json: เพิ่ม version ใหม่
# - docs/session-log.md: บันทึกการ publish
# - docs/active-task.md: อัปเดตสถานะ

git -C "X:\Astral-Party-Thai-Mod-Dev" add -A
git -C "X:\Astral-Party-Thai-Mod-Dev" commit -m "docs: publish $tag to GitHub"
git -C "X:\Astral-Party-Thai-Mod-Dev" push origin main
```

---

## สรุปลำดับทั้งหมด

| Step | งาน | เครื่องมือ |
|------|-----|-----------|
| 1 | เตรียมไฟล์ใน `release/` | manual / build script |
| 2 | สร้าง ZIP | `Compress-Archive` |
| 3 | อัปเดต README.md | manual edit |
| 4 | Commit + Push | `git` |
| 5 | อัปเดต GitHub Release | GitHub REST API |
| 6 | ตรวจสอบผล | GitHub REST API |
| 7 | Sync dev repo docs | `git` |

> **URL สำคัญ**
> - Repo: https://github.com/runarissu/Astral-Party-Thai-Mod
> - Releases: https://github.com/runarissu/Astral-Party-Thai-Mod/releases
> - API docs: https://docs.github.com/en/rest/releases
