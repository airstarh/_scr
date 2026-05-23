#! /bin/bash
sudo dd if=/home/qqq/_sandbox/fd.iso of=/dev/sdc bs=4M status=progress && sync

# /home/qqq/_sandbox/
#

mkdir ./flash
sudo mount -o loop fd.iso /mnt
cp -r /mnt/* ./flash/
sudo umount /mnt

cp hp.exe ./flash/

isoinfo -d -i fd.iso | grep -i boot


xorriso -as mkisofs \
  -o new_freedos.iso \
  -b isolinux/isolinux.bin \
  -c boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -J -r -V "FREEDOS" \
  ./flash/


sudo dd if=new_freedos.iso of=/dev/sdc bs=4M status=progress && sync
