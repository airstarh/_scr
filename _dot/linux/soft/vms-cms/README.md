/opt/VMS/VMS.sh

# INSTALL

Первым делом обновляем систему:
sudo apt update
sudo apt upgrade
Добавляем 32-битную архитектуру, так как скорее всего ваша ОС 64-битная
и устанавливаем библиотеки QT:
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libqt5opengl5:i386
sudo apt install libxrender1:i386
Устанавливаем VMS:
cd ~
chmod +x vms.run
sudo su
./vms.run
chmod 777 -R /opt/VMS
mv /opt/VMS/libxcb.so.1 /opt/VMS/libxcb.so.1.old
exit
vms.run
TCG VMS
