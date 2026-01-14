#!/bin/bash

# =================================================================
# FILE: daily_round.sh (THE BOSS SCRIPT) - REVISI INTERLEAVED
# Deskripsi: Otomatisasi Pengujian IDS Berbasis Ronde Campuran
# Metodologi: Interleaved Design (Serangan + Trafik Normal)
# =================================================================

# --- KONFIGURASI ---
TOTAL_ROUNDS=10           # Jumlah ronde per hari
DELAY_BETWEEN_ATTACKS=30  # Jeda istirahat antar serangan (detik)
DELAY_BETWEEN_NOISE=20    # Jeda istirahat setelah trafik normal (detik)
DELAY_BETWEEN_ROUNDS=120  # Jeda istirahat antar ronde (detik)

# Warna untuk Output Terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fungsi hitung mundur visual
function countdown() {
    secs=$1
    echo -ne "${YELLOW}    [Wait] Cooling down ($secs s)... "
    while [ $secs -gt 0 ]; do
        echo -ne "$secs\033[0K\r${YELLOW}    [Wait] Cooling down ($secs s)... "
        sleep 1
        : $((secs--))
    done
    echo -e "${NC}Ready!"
}

# Fungsi menjalankan modul serangan
function run_module() {
    SCRIPT_NAME=$1
    MODULE_TITLE=$2
    
    echo -e "${BLUE}[+] [ATTACK] Menjalankan Modul: ${MODULE_TITLE}${NC}"
    
    if [ -f "attacks/$SCRIPT_NAME" ]; then
        ./attacks/$SCRIPT_NAME
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}    -> Modul Serangan Selesai.${NC}"
        else
            echo -e "${RED}    -> Modul Error! Cek log.${NC}"
        fi
        countdown $DELAY_BETWEEN_ATTACKS
    else
        echo -e "${RED}[!] ERROR: attacks/$SCRIPT_NAME tidak ditemukan!${NC}"
    fi
    echo ""
}

# Fungsi menjalankan trafik normal (Noise)
function run_noise() {
    echo -e "${CYAN}[+] [NOISE] Menjalankan Normal Traffic (Aktivitas Legal)...${NC}"
    echo -e "${CYAN}    Tujuan: Simulasi aktivitas user di tengah serangan.${NC}"
    
    if [ -f "./normal_traffic.sh" ]; then
        # Menjalankan script normal traffic
        ./normal_traffic.sh
        
        echo -e "${GREEN}    -> Normal Traffic Selesai.${NC}"
        countdown $DELAY_BETWEEN_NOISE
    else
        echo -e "${RED}[!] ERROR: File normal_traffic.sh tidak ditemukan di folder utama!${NC}"
    fi
    echo ""
}

# =================================================================
# MAIN PROGRAM
# =================================================================
clear
echo "==========================================================="
echo -e "   ${RED}SURICATA IDS RESEARCH AUTOMATION${NC}"
echo "   Methodology: Interleaved (Attack + Normal Noise)"
echo "==========================================================="
echo "Total Ronde   : $TOTAL_ROUNDS"
echo "Jeda Serangan : $DELAY_BETWEEN_ATTACKS detik"
echo "Start Time    : $(date)"
echo "==========================================================="

# Cek Izin Eksekusi normal_traffic.sh
if [ ! -x "./normal_traffic.sh" ]; then
    echo -e "${RED}[!] PERINGATAN: normal_traffic.sh belum executable.${NC}"
    echo "    Mencoba memperbaiki izin..."
    chmod +x normal_traffic.sh
fi

echo ""

# Loop Ronde (1 sampai 10)
for (( round=1; round<=TOTAL_ROUNDS; round++ ))
do
    echo -e "${YELLOW}###########################################################"
    echo -e " MEMULAI RONDE KE-$round DARI $TOTAL_ROUNDS"
    echo -e " Waktu: $(date)"
    echo -e "###########################################################${NC}"
    echo ""

    # --- KELOMPOK 1: RECON & BRUTE FORCE ---
    run_module "01_nmap.sh" "01 - Port Scanning (Nmap)"
    run_module "02_hydra.sh" "02 - SSH Brute Force (Hydra)"

    # >>> SISIPAN 1: NORMAL TRAFFIC <<<
    # Logika: Setelah ada yang scan port & brute force, 
    # Admin/User mungkin melakukan aktivitas jaringan (Ping/Update).
    run_noise

    # --- KELOMPOK 2: NETWORK STRESS ---
    run_module "03_dos.sh" "03 - DoS Attack (Hping3)"
    
    # --- KELOMPOK 3: WEB ATTACKS ---
    run_module "04_sqlmap.sh" "04 - SQL Injection (Sqlmap)"

    # >>> SISIPAN 2: NORMAL TRAFFIC <<<
    # Logika: Di tengah serangan web, user valid tetap mengakses web.
    run_noise
    
    run_module "05_xss.sh" "05 - XSS Injection (Curl)"
    run_module "06_trav.sh" "06 - Path Traversal (Curl)"
    
    # --- KELOMPOK 4: EXPLOITATION ---
    run_module "07_rce.sh" "07 - RCE (Metasploit)"

    # --- AKHIR RONDE ---
    echo -e "${GREEN}>>> RONDE $round SELESAI.${NC}"
    
    if [ $round -lt $TOTAL_ROUNDS ]; then
        echo -e "${BLUE}Istirahat panjang sebelum ronde berikutnya...${NC}"
        countdown $DELAY_BETWEEN_ROUNDS
    else
        echo -e "${GREEN}SEMUA RONDE SELESAI PADA $(date)!${NC}"
    fi
    echo ""
done

echo "==========================================================="
echo "Penelitian Selesai. Silakan analisis 'logs/' dan 'eve.json'"
echo "==========================================================="
