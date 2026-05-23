# Копируем boot_sector.bin в папку с файлами и сразу собираем образ
cp boot_sector.bin ./flash/ && \
xorriso -as mkisofs \
  -o new_freedos.iso \
  -b boot_sector.bin \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -J -r -V "FREEDOS" \
  ./flash/
