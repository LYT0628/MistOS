mkdir /mnt/floppy
mount -o loop pm.img /mnt/floppy
cp kernel.com /mnt/floppy/
umount /mnt/floppy