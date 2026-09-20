#!/bin/bash
# FIXLOG.SH - catetan fix ad-hoc satu-satu yang ketemu belakangan,
# di LUAR ulti.sh (dijalanin SETELAH ulti.sh, urutan: ulti.sh -> fixlog.sh -> ./z)
# Idempotent: aman dijalanin ulang.
set -e
cd /tmp/android_build
VBP="vendor/samsung/a02/Android.bp"
VMK="vendor/samsung/a02/a02-vendor.mk"
DMK="device/samsung/a02/device.mk"

# --- TARGET_USES_64_BIT_BINDER wajib true kalau PRODUCT_SHIPPING_API_LEVEL >= 28 ---
grep -q "TARGET_USES_64_BIT_BINDER" device/samsung/a02/BoardConfig.mk || \
  echo "TARGET_USES_64_BIT_BINDER := true" >> device/samsung/a02/BoardConfig.mk

# --- Rename modul yang double-collide (hasil rename "_vendor" dedup ternyata
#     JUGA udah dipake modul lain) -> pake suffix "_samsung" ---
for name in boringssl_self_test mkshrc passwd group vendor_seapp_contexts; do
  if grep -q "name: \"${name}_vendor\"," "$VBP" 2>/dev/null; then
    sed -i "s/name: \"${name}_vendor\",/name: \"${name}_samsung\",/" "$VBP"
    sed -i "s/    ${name}_vendor \\\\/    ${name}_samsung \\\\/" "$VMK" "$DMK" 2>/dev/null || true
  fi
done

# --- Modul cc_prebuilt "*_DISABLED" (placeholder rusak dari proses dump
#     blob, source file-nya emang gak pernah ada) - hapus semua ---
python3 -c "
import re
p='$VBP'
s=open(p).read()
s=re.sub(r'cc_prebuilt_\w+ \{\s*name: \"[^\"]*_DISABLED[^\"]*\",.*?\n\}\n', '', s, flags=re.S)
open(p,'w').write(s)
"

# --- Modul-modul install-path-conflict satu-satu yang ketemu di sesi
#     a02-trial (di luar daftar known-fixes.sh yang lama) ---
for spec in \
  "cc_prebuilt_library_shared:libwpa_client" \
  "cc_prebuilt_library_shared:android.hardware.camera.provider@2.4-legacy" \
  "cc_prebuilt_library_shared:android.hardware.camera.provider@2.5-legacy" \
  "cc_prebuilt_library_shared:android.hardware.graphics.composer@2.1-resources" \
; do
  mtype="${spec%%:*}"
  core="${spec#*:}"
  for name in "$core" "${core}_vendor" "a02_${core}"; do
    if grep -q "name: \"$name\"," "$VBP" 2>/dev/null; then
      python3 -c "
import re
p='$VBP'
s=open(p).read()
s=re.sub(r'$mtype \{\s*name: \"$name\",.*?\n\}\n', '', s, flags=re.S)
open(p,'w').write(s)
"
      sed -i "/    $name \\\\/d" "$VMK"
    fi
  done
done

# --- hapus modul prebuilt vendor cas@1.2-service (bentrok install path sama AOSP source) ---
python3 - "$VBP" "$VMK" "$DMK" << 'PY'
import re,sys
vbp,*mks=sys.argv[1:]
s=open(vbp).read()
names=[]
def drop(m):
    b=m.group(0)
    if 'cas@1.2-service' in b:
        n=re.search(r'name:\s*"([^"]+)"',b)
        if n: names.append(n.group(1))
        return ''
    return b
s=re.sub(r'(?ms)^\w+ \{\n.*?^\}\n',drop,s)
open(vbp,'w').write(s)
print("cas dihapus:",names)
for f in mks:
    try: t=open(f).read()
    except: continue
    for n in names:
        t=re.sub(r'(?m)^\s*'+re.escape(n)+r'\s*\\?\n','',t)
    open(f,'w').write(t)
PY

# --- hapus awk_vendor_vendor (bentrok install path vendor/bin/awk sama AOSP source) ---
python3 - "$VBP" "$VMK" << 'PY'
import re,sys
vbp,vmk=sys.argv[1:3]
s=open(vbp).read()
s,n=re.subn(r'(?ms)^\w+ \{\n\s*name: "awk_vendor_vendor",.*?^\}\n','',s)
open(vbp,'w').write(s)
t=open(vmk).read()
t=re.sub(r'(?m)^\s*awk_vendor_vendor\s*\\?\n','',t)
open(vmk,'w').write(t)
print("awk_vendor_vendor dihapus:",n)
PY

# --- hapus boringssl_self_test32 (bentrok install path vendor/bin/boringssl_self_test32 sama AOSP source) ---
python3 - "$VBP" "$VMK" << 'PY'
import re,sys
vbp,vmk=sys.argv[1:3]
s=open(vbp).read()
s,n=re.subn(r'(?ms)^\w+ \{\n\s*name: "boringssl_self_test32",.*?^\}\n','',s)
open(vbp,'w').write(s)
t=open(vmk).read()
t=re.sub(r'(?m)^\s*boringssl_self_test32\s*\\?\n','',t)
open(vmk,'w').write(t)
print("boringssl_self_test32 dihapus:",n)
PY

# --- hapus camera.device@1.0-impl_vendor (bentrok install path vendor/lib/camera.device@1.0-impl.so sama AOSP source) ---
python3 - "$VBP" "$VMK" << 'PY'
import re,sys
vbp,vmk=sys.argv[1:3]
s=open(vbp).read()
s,n=re.subn(r'(?ms)^\w+ \{\n\s*name: "camera.device@1.0-impl_vendor",.*?^\}\n','',s)
open(vbp,'w').write(s)
t=open(vmk).read()
t=re.sub(r'(?m)^\s*camera\.device@1\.0-impl_vendor\s*\\?\n','',t)
open(vmk,'w').write(t)
print("camera.device@1.0-impl_vendor dihapus:",n)
PY

# --- hapus camera.device@3.2-impl_vendor (bentrok install path vendor/lib/camera.device@3.2-impl.so sama AOSP source) ---
python3 - "$VBP" "$VMK" << 'PY'
import re,sys
vbp,vmk=sys.argv[1:3]
s=open(vbp).read()
s,n=re.subn(r'(?ms)^\w+ \{\n\s*name: "camera.device@3.2-impl_vendor",.*?^\}\n','',s)
open(vbp,'w').write(s)
t=open(vmk).read()
t=re.sub(r'(?m)^\s*camera\.device@3\.2-impl_vendor\s*\\?\n','',t)
open(vmk,'w').write(t)
print("camera.device@3.2-impl_vendor dihapus:",n)
PY

# --- hapus camera.device@3.3/3.4/3.5-impl_vendor (bentrok install path vendor/lib/camera.device@3.x-impl.so sama AOSP source) ---
python3 - "$VBP" "$VMK" << 'PY'
import re,sys
vbp,vmk=sys.argv[1:3]
s=open(vbp).read()
t=open(vmk).read()
for v in ['3.3','3.4','3.5']:
    nm='camera.device@%s-impl_vendor'%v
    s,n=re.subn(r'(?ms)^\w+ \{\n\s*name: "'+re.escape(nm)+r'",.*?^\}\n','',s)
    t=re.sub(r'(?m)^\s*'+re.escape(nm)+r'\s*\\?\n','',t)
    print(nm,"dihapus:",n)
open(vbp,'w').write(s)
open(vmk,'w').write(t)
PY

# --- hapus dumpsys_vendor_vendor (bentrok install path vendor/bin/dumpsys sama AOSP dumpsys_vendor) ---
python3 - "$VBP" "$VMK" << 'PY'
import re,sys
vbp,vmk=sys.argv[1:3]
s=open(vbp).read()
s,n=re.subn(r'(?ms)^\w+ \{\n\s*name: "dumpsys_vendor_vendor",.*?^\}\n','',s)
open(vbp,'w').write(s)
t=open(vmk).read()
t=re.sub(r'(?m)^\s*dumpsys_vendor_vendor\s*\\?\n','',t)
open(vmk,'w').write(t)
print("dumpsys_vendor_vendor dihapus:",n)
PY

# --- hapus libalsautils_vendor (bentrok install path vendor/lib/libalsautils.so sama AOSP system/media/alsa_utils) ---
python3 - "$VBP" "$VMK" << 'PY'
import re,sys
vbp,vmk=sys.argv[1:3]
s=open(vbp).read()
s,n=re.subn(r'(?ms)^\w+ \{\n\s*name: "libalsautils_vendor",.*?^\}\n','',s)
open(vbp,'w').write(s)
t=open(vmk).read()
t=re.sub(r'(?m)^\s*libalsautils_vendor\s*\\?\n','',t)
open(vmk,'w').write(t)
print("libalsautils_vendor dihapus:",n)
PY

rm -rf out/target/product/a02/vendor/etc/vintf/manifest out/target/product/a02/vendor/etc/etc
echo "fixlog.sh selesai. Lanjut: ./z"
