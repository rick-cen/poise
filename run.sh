#!/bin/bash

ip=$(ip -4 addr show enp0s3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

clear

echo "-------------------------------------------------------------"
echo "     ██████╗  ██████╗ ██╗███████╗███████╗"
echo "     ██╔══██╗██╔═══██╗██║╚══███╔╝██╔════╝"
echo "     ██████╔╝██║   ██║██║  ███╔╝ █████╗  "
echo "     ██╔═══╝ ██║   ██║██║ ███╔╝  ██╔══╝  "
echo "     ██║     ╚██████╔╝██║███████╗███████╗"
echo "     ╚═╝      ╚═════╝ ╚═╝╚══════╝╚══════╝"
echo "-------------------------------------------------------------"
echo "Practical Offensive Industrial Cybersecurity Essentials - LAB"
echo "-------------------------------------------------------------"

# stop mqtt broker to avoid interference with other exercises
#sudo /etc/init.d/mosquitto stop > /dev/null 2>&1
sudo /etc/init.d/mosquitto stop > /dev/null 2>&1

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
echo "[4] Simatic IOT2000 Smart Factory MQTT Broker"
sleep 0.1
echo "[5] 1756-L61/B LOGIX5561"
sleep 0.1
echo "[6] Conpot TLS-350"
sleep 0.1
echo "[7] Simatic KTP 700 HMI Sm@rt Server"
sleep 0.1
echo "[8] Simatic KTP 700 HMI Sm@rt Server (Password Protected)"
sleep 0.1
echo "[9] Modicon Modbus PLC"
sleep 0.1
echo "[a] Conpot IEC-104 Substation"
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
  cd ~/poise/s7300/
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
  cd ~/poise/s71500/
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
  cd ~/poise/iec104/
  nohup sudo python3 -m http.server 80 > /dev/null 2>&1 &
  cd ~
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

hmi() {  
  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[+] Emulating Simatic KTP 700 HMI Sm@rt Server on "$ip
  Xvfb :1 -screen 0 1024x754x24 &
  sudo nc -l -k -p 102 &
  echo ""
  sleep 2
  DISPLAY=:1 feh --fullscreen --no-hint ~/poise/HMI/screen.png &
  x11vnc -display :1 -desktop "SVEHMI" -rfbport 5900 -forever -shared
}

hmipw() {  
  echo "[!] Reboot your VM when you're done with this emulation"
  sleep 1
  echo "[+] Emulating Simatic KTP 700 HMI Sm@rt Server with passwort protection on "$ip
  Xvfb :1 -screen 0 1024x754x24 &
  sudo nc -l -k -p 102 &
  echo ""
  sleep 2
  DISPLAY=:1 feh --fullscreen --no-hint ~/poise/HMI/screen.png &
  x11vnc -display :1 -rfbauth ~/.vnc/passwd -desktop "SVEHMI" -rfbport 5900 -forever -shared
}

otnet() {
  echo "[!]Reboot your VM when you're done with this emulation"
  sleep 1
  sudo pkill farpd
  sudo pkill honeyd
  echo "[*] Creating hosts and spawning OT network"
  echo ""
  sudo honeyd -f ot.conf 10.2.0.50-10.2.0.71
  #sudo nohup honeyd -f ot.conf 10.2.0.50-10.2.0.71 > /dev/null 2>&1 &
  sleep 5
  echo ""
  echo "[*] Starting Forwarding and Routing Protocol Daemon for OT network"
  echo ""
  sudo farpd 10.2.0.50-10.2.0.71
  #sudo nohup farpd 10.2.0.50-10.2.0.71 > /dev/null 2>&1 &
  sleep 2
  echo ""
  echo "[+] OT network emulation ready"
  echo -n "[!] Press Enter to end this emulation and reboot the VM."
  read key
  case $key in
    *) reboot ;;
  esac
}

reboot() {
  echo "[*] Rebooting the VM..."
  sudo pkill farpd
  sudo pkill honeyd
  sleep 1
  sudo reboot
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
  7) hmi ;;
  8) hmipw ;;
  9) modicon ;;
  a) coniec ;;
  o) otnet ;;

  *) echo "[!] Invalid option. Quitting..." ;;
esac