#!/bin/bash
set -e

# 1. Cek isi block modul yang konflik di Android.bp (berdasarkan nomor baris dari error)
sed -n '2530,2560p' vendor/samsung/a02/Android.bp
sed -n '2715,2740p' vendor/samsung/a02/Android.bp
sed -n '3390,3415p' vendor/samsung/a02/Android.bp
sed -n '3425,3450p' vendor/samsung/a02/Android.bp

# 2. Rename 4 modul yang bentrok nama dengan modul AOSP core
sed -i 's/name: "group_vendor"/name: "a02_group_vendor"/' vendor/samsung/a02/Android.bp
sed -i 's/name: "boringssl_self_test_vendor"/name: "a02_boringssl_self_test_vendor"/' vendor/samsung/a02/Android.bp
sed -i 's/name: "mkshrc_vendor"/name: "a02_mkshrc_vendor"/' vendor/samsung/a02/Android.bp
sed -i 's/name: "passwd_vendor"/name: "a02_passwd_vendor"/' vendor/samsung/a02/Android.bp

# 3. Verifikasi tidak ada referensi lain ke nama modul lama (hasil kosong = aman)
grep -rn '"group_vendor"\|"boringssl_self_test_vendor"\|"mkshrc_vendor"\|"passwd_vendor"' vendor/samsung/a02/ device/samsung/a02/ --include="*.mk" --include="*.bp"

# 4. Hapus modul libstagefright_bufferqueue_helper_DISABLED_vendor (dokumentasi disabled, source-nya memang sengaja tidak ada, versi real-nya sudah tersedia di modul lain tanpa suffix DISABLED)
sed -i '10222,10231d' vendor/samsung/a02/Android.bp

# Verifikasi sudah hilang (harusnya kosong)
grep -n '_DISABLED_' vendor/samsung/a02/Android.bp

echo "Selesai."

# 5. Build
cd /tmp/android_build
source build/envsetup.sh
lunch lineage_a02-userdebug
mka vendorimage
