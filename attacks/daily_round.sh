#!/bin/bash

# =================================================================
# FILE: daily_round.sh (THE BOSS SCRIPT)
# Deskripsi: Otomatisasi Pengujian IDS Berbasis Ronde
# Metodologi: Interleaved Design (7 Serangan x 10 Ronde)
# =================================================================

# --- KONFIGURASI ---
TOTAL_ROUNDS=10           # Jumlah ronde per hari (Target riset Anda)
DELAY_BETWEEN_ATTACKS=30  # Jeda istirahat antar serangan (detik)
DELAY_BETWEEN_ROUNDS=120  # Jeda istirahat antar ronde (detik)

# Warna untuk Output Terminal (Agar terlihat profesional)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fungsi hitung mundur visual
function countdown() {
    secs=$1
    echo -ne "${YELLOW}    [Wait] Cooling down for analysis separation... "
    while [ $secs -gt 0 ]; do
        echo -ne "$secs\033[0K\r${YELLOW}    [Wait] Cooling down for analysis separation... "
        sleep 1
        : $((secs--))
    done
    echo -e "${NC}Ready!"
}

# Fungsi menjalankan modul
function run_module() {
    SCRIPT_NAME=$1
    MODULE_TITLE=$2
    
    echo -e "${BLUE}[+] Menjalankan Modul: ${MODULE_TITLE}${NC}"
    
    if [ -f "attacks/$SCRIPT_NAME" ]; then
        # Jalankan script modul
        ./attacks/$SCRIPT_NAME
        
        # Cek status exit
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}    -> Modul Selesai.${NC}"
        else
            echo -e "${RED}    -> Modul Error/Gagal! Cek log modul tersebut.${NC}"
        fi
        
        # Jeda waktu agar log tidak menumpuk
        countdown $DELAY_BETWEEN_ATTACKS
    else
        echo -e "${RED}[!] ERROR: File attacks/$SCRIPT_NAME tidak ditemukan!${NC}"
    fi
    echo ""
}

# =================================================================
# MAIN PROGRAM
# =================================================================
clear
echo "==========================================================="
echo -e "   ${RED}SURICATA IDS RESEARCH AUTOMATION${NC}"
echo "   Methodology: Interleaved Attack Rounds"
echo "==========================================================="
echo "Total Ronde   : $TOTAL_ROUNDS"
echo "Jeda Serangan : $DELAY_BETWEEN_ATTACKS detik"
echo "Jeda Ronde    : $DELAY_BETWEEN_ROUNDS detik"
echo "Start Time    : $(date)"
echo "==========================================================="
echo ""

# Loop Ronde (1 sampai 10)
for (( round=1; round<=TOTAL_ROUNDS; round++ ))
do
    echo -e "${YELLOW}###########################################################"
    echo -e " MEMULAI RONDE KE-$round DARI $TOTAL_ROUNDS"
    echo -e " Waktu: $(date)"
    echo -e "###########################################################${NC}"
    echo ""

    # --- URUTAN EKSEKUSI (WORKERS) ---
    
    # 1. Network Recon
    run_module "01_nmap.sh" "01 - Port Scanning (Nmap)"
    
    # 2. Brute Force
    run_module "02_hydra.sh" "02 - SSH Brute Force (Hydra)"
    
    # 3. Denial of Service
    run_module "03_dos.sh" "03 - DoS Attack (Hping3)"
    
    # 4. Web Attack: SQLi
    run_module "04_sqlmap.sh" "04 - SQL Injection (Sqlmap)"
    
    # 5. Web Attack: XSS
    run_module "05_xss.sh" "05 - XSS Injection (Curl)"
    
    # 6. Web Attack: LFI
    run_module "06_trav.sh" "06 - Path Traversal (Curl)"
    
    # 7. Exploitation
    run_module "07_rce.sh" "07 - RCE (Metasploit)"

    # --- AKHIR RONDE ---
    echo -e "${GREEN}>>> RONDE $round SELESAI.${NC}"
    
    if [ $round -lt $TOTAL_ROUNDS ]; then
        echo -e "${BLUE}Istirahat panjang sebelum ronde berikutnya...${NC}"
        countdown $DELAY_BETWEEN_ROUNDS
    else
        echo -e "${GREEN}SEMUA RONDE SELESAI!${NC}"
    fi
    echo ""
done

echo "==========================================================="
echo "Penelitian Hari Ini Selesai pada $(date)"
echo "Silakan ambil file logs/ dan eve.json untuk analisis."
echo "==========================================================="
