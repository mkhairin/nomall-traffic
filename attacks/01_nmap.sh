#!/bin/bash

# =================================================================
# SKENARIO 01: PORT SCANNING (NMAP)
# Strategi: 3 Level Depth (Basic, Evasion, Advanced)
# =================================================================


# KONFIGURASI
TARGET_IP="192.168.x.x" # Ganti IP Target
LOG_FILE="logs/nmap_session_$(date +%F).log"

echo "[+] [01_NMAP] Memulai Skenario Port Scanning..."
echo "[+] Target: $TARGET_IP"
echo "[+] Waktu Mulai: $(date)"

# -----------------------------------------------------------------
# LEVEL 1: NOISY / BASIC SCAN
# Tujuan: Baseline. Harus terdeteksi 100%.
# Teknik: Scan agresif (T4), Version Detection (-sV), All Ports.
# -----------------------------------------------------------------
echo "[Level 1] Running Aggresive Service Scan (-sV -T4)..."
nmap -sV -T4 -F $TARGET_IP -oN logs/nmap_lvl1.txt > /dev/null 2>&1
echo " -> Selesai. (Target: Alert ET SCAN / GPL SCAN berisik)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 2: EVASION / FRAGMENTATION
# Tujuan: Menguji reassembly packet engine Suricata.
# Teknik: Packet Fragmentation (-f). Memecah paket jadi kecil (8 bytes)
#         agar tidak terbaca oleh firewall/IDS sederhana.
# -----------------------------------------------------------------
echo "[Level 2] Running Fragmented Scan (-f)..."
# Menggunakan -f (fragment) dan -sS (Syn Stealth) tapi dipecah
nmap -f -sS -p 21,22,80,3306 $TARGET_IP -oN logs/nmap_lvl2.txt > /dev/null 2>&1
echo "    -> Selesai. (Harapan: Alert ET SCAN / Potential Evasion)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 3: ADVANCED / STEALTH & DECOY
# Tujuan: Membingungkan Analyst & IDS.
# Teknik: Decoy (-D) untuk memalsukan source IP, dicampur IP asli.
#         Ditambah scan FIN (-sF) yang tidak standar (bukan SYN).
# -----------------------------------------------------------------
echo "[Level 3] Running Decoy & FIN Scan (-D RND -sF)..."
# -D RND:5 = Membuat 5 IP palsu seolah-olah mereka yang scan
# -sF = FIN Scan (teknik lolos firewall lama)
nmap -D RND:5 -sF -p 80 $TARGET_IP -oN logs/nmap_lvl3.txt > /dev/null 2>&1
echo "    -> Selesai. (Harapan: Deteksi IP Asli di antara Decoy)"

echo "[+] [01_NMAP] Skenario Selesai pada $(date)"
echo "-----------------------------------------------------------"
