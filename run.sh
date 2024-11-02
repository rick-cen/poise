#!/bin/bash

ip=$(ip -4 addr show enp0s3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

clear

echo "-------------------------------------------------------------"
echo "     ██████╗  ██████╗  ██╗███████╗███████╗"
echo "     ██╔══██╗██╔═══██╗██║╚══███╔╝██╔════╝"
echo "     ██████╔╝██║    ██║██║  ███╔╝  █████╗  "
echo "     ██╔═══╝ ██║    ██║██║ ███╔╝   ██╔══╝  "
echo "     ██║      ╚██████╔╝██║███████╗███████╗"
echo "     ╚═╝       ╚═════╝ ╚═╝╚══════╝╚══════╝"
echo "-------------------------------------------------------------"
echo "Practical Offensive Industrial Cybersecurity Essentials - LAB"
echo "-------------------------------------------------------------"

                       
#keep emulation awake
xset -dpms
xset s off
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
gsettings set org.gnome.desktop.screensaver lock-enabled false
# stop mqtt broker to avoid interference with other exercises
sudo /etc/init.d/mosquitto stop > /dev/null 2>&1 &

sleep 0.25
echo ""
echo "Available emulations on: "$ip
sleep 0.25
echo ""
echo "[1] Conpot Default"
sleep 0.1
echo "[2] Simatic S7-300"
sleep 0.1
echo "[3] Simatic S7-1500"
sleep 0.1
echo "[4] Simatic IOT2050 Smart Factory MQTT Broker"
sleep 0.1
echo "[5] 1756-L61/B LOGIX5561"
sleep 0.1
echo "[6] Conpot TLS-350"
sleep 0.1
echo "[7] Modicon Modbus PLC"
sleep 0.1
echo "[8] IEC-104 Substation"
sleep 0.1

s7300() {
  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[*] Applying S7-300 Profile"
  sudo cp ~/snap7/build/bin/x86_64-linux/libsnap7.so-300 /usr/lib/libsnap7.so
  sleep 1
  echo "[+] Emulating S7-300 PLC on "$ip
  echo ""
  cd ~
  cd aptics/s7300/
  nohup sudo python3 -m http.server 80 > /dev/null 2>&1 &
  cd ~
  sudo ./snap7/examples/cpp/x86_64-linux/server $ip
 
}

s71500() {  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[*] Applying S7-1500 Profile"
  sudo cp ~/snap7/build/bin/x86_64-linux/libsnap7.so-1500 /usr/lib/libsnap7.so
  sleep 1
  echo "[+] Emulating S7-1500 PLC on "$ip
  echo ""
  cd ~
  cd aptics/s71500/
  nohup sudo python3 -m http.server 80 > /dev/null 2>&1 &
  cd ~
  sudo ./snap7/examples/cpp/x86_64-linux/server $ip
}

reboot() {
  echo "[*] Rebooting the VM..."
  sleep 1
  sudo reboot
}

ab1756() {  
  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[+] Emulating 1756-L61/B LOGIX5561 on "$ip
  echo ""
  enip_server -w 0.0.0.0:8080 -S -v

}

condef() {  
  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[+] Starting Conpot Default Template on "$ip
  echo ""
  conpot -f --template default

}

congas() {  
  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[+] Emulating TLS-350 on "$ip
  echo ""
  conpot -f --template guardian_ast

}

coniec() {  
  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[+] Emulating IEC-104 Substation on "$ip
  echo ""
  conpot -f --template IEC104

}

modicon() {  
  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[+] Emulating Modbus Modicon Device on "$ip
  echo ""
  cd ~
  ./pymodbus/examples/server_payload.py --port 502 --log info

}

mqtt() {  
  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[+] Emulating Smart Factory MQTT Broker on "$ip
  sudo /etc/init.d/mosquitto restart
  echo ""
  echo "[+] Publishing to "$ip
  cd ~
  ./otpublisher.sh

}




echo ""
echo -n "[i] Choose a system to emulate: "
read option
case $option in
  1) condef ;;
  2) s7300 ;;
  3) s71500 ;;
  4) mqtt ;;
  5) ab1756 ;;
  6) congas ;;
  7) modicon ;;
  8) coniec ;;

  *) echo "[!] Invalid option. Quitting..." ;;
esac