#!/bin/bash
# Jalanin: bash note.sh
# Nyetak briefing singkat buat di-paste ke AI/asisten baru biar dia
# langsung paham konteks proyek ini tanpa perlu dijelasin ulang dari nol.
cat << 'EOF'
Build AOSP LineageOS 18.1 buat Samsung Galaxy A02 (MT6739) di GitHub
Codespaces. Source di /tmp/android_build. Device+vendor tree dari
github.com/cipin23/vendor (branch a02_vendor, project "vendor" di
local_manifest, di-linkfile ke device/samsung/a02 & vendor/samsung/a02,
lalu dikonversi jadi folder asli - bukan symlink - biar Soong bisa scan).
Di Codespaces, git remote: origin = a02-trial/vendor (repo sendiri),
upstream = cipin23/vendor (JANGAN push ke sini).

MASALAH UTAMA: vendor/samsung/a02/Android.bp (hasil dump blob proprietary
Samsung) isi banyak modul cc_prebuilt_binary/cc_prebuilt_library_shared/
prebuilt_etc yang bentrok nama modul dan/atau install-path sama modul
yang dibangun dari source AOSP asli (toolbox, toybox, protobuf, drm HAL,
power HAL, audio HAL, camera HAL, vndservice, awk, cas, dst). Pola fix:
tiap ketemu error "module X already defined" (bentrok nama) atau
"overriding commands for target Y" (bentrok install path), cari modul
di vendor Android.bp yang install ke situ (grep pake nama binary-nya,
modul sering namanya "*_vendor_vendor" dan pake srcs:+stem:, bukan src:),
HAPUS (biarin versi AOSP source yang jalan) - kecuali kalau memang modul
itu spesifik hardware MT6739/A02 (WiFi, audio) yang perlu di-porting
ulang nanti, bukan dihapus permanen.

FILE-FILE PENTING (semua di /workspaces/vendor/, persisten walau
Codespaces di-reset - beda dari /tmp yang ephemeral):
- ulti.sh   = setup env + sync source + convert symlink + fix dasar
              (Bagian 0-8) + di ujungnya otomatis jalanin fixlog.sh + ./z
- fixlog.sh = catetan fix ad-hoc satu-satu yang ketemu belakangan,
              di-APPEND tiap ketemu fix baru (bukan ditulis ulang)
- z         = script pendek: cd /tmp/android_build && source
              build/envsetup.sh && lunch lineage_a02-userdebug &&
              mka vendorimage
- zImage    = kernel prebuilt (kernel a02 gak bisa dibangun mulus lewat
              AOSP, jadi pake hasil build manual/script "z" terpisah -
              beda "z" ini sama script rebuild di atas, jangan ketuker)
- note.sh   = file ini

ALUR KERJA ABIS RESET/CODESPACES BARU:
1. bash ulti.sh   (otomatis lanjut ke fixlog.sh + ./z di ujungnya)
2. Kalau masih ada error baru yang belum ke-cover: fix manual dulu di
   /tmp/android_build, VERIFIKASI jalan, baru APPEND fix-nya ke
   /workspaces/vendor/fixlog.sh (jangan lupa langkah ini, kalau kelewat
   fix bakal ilang lagi pas reset berikutnya). Fix baru disisipin TEPAT
   SEBELUM baris "rm -rf ... vintf/manifest" di paling bawah fixlog.sh.
   Cara: tulis kode fix ke /tmp/newfix.txt (variabel $VBP $VMK $DMK
   tersedia di fixlog.sh), lalu:
   python3 -c "
   p='/workspaces/vendor/fixlog.sh'
   s=open(p).read()
   m='rm -rf out/target/product/a02/vendor/etc/vintf/manifest'
   s=s.replace(m,open('/tmp/newfix.txt').read().strip()+chr(10)+chr(10)+m,1)
   open(p,'w').write(s)
   "
3. Command rebuild selanjutnya cukup: ./z

ATURAN KERJA PER ERROR (satu command per chat, penjelasan 1-2 kalimat):
cek isi file yang error -> command fix -> command verifikasi ->
command build + append fixlog.sh.

STATUS SEKARANG: masih whack-a-mole di tahap ckati writing build rules.
Fix terakhir yang udah masuk fixlog.sh: cas@1.2-service (vintf) dan
awk_vendor_vendor. Error berikutnya belum diketahui.
EOF
