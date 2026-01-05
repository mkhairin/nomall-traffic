#!/bin/bash
TARGET="192.168.x.x"

echo "========================================"
echo "   MULAI SKENARIO 1: NMAP SCANNING"
echo "========================================"

# --- BAGIAN 1: LEVEL 1 (BASIC) ---
echo "[+] Menjalankan Level 1: Fast SYN Scan..."
# Perintah serangan langsung dijalankan 
nmap -sS -T4 -p 1-1000 $TARGET
echo ">> Level 1 Selesai."

# Jeda internal
sleep 5

# --- BAGIAN 2: LEVEL 2 (EVASION) ---
echo "[+] Menjalankan Level 2: Fragmentation..."
# Perintah berubah pakai flag -f
nmap -f -p 1-1000 $TARGET
echo ">> Level 2 Selesai."

sleep 5

# --- BAGIAN 3: LEVEL 3 (ADVANCED) ---
echo "[+] Menjalankan Level 3: Decoy + Slow..."
# Perintah berubah pakai flag -D dan -T2
nmap -D RND:5 -T2 -p 80,443 $TARGET
echo ">> Level 3 Selesai."

echo "========================================"
echo "   SKENARIO 1 SELESAI."
echo "========================================"
