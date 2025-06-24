import sys
from ftplib import FTP, all_errors, error_perm


def main():
    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <indirizzo_ip>")
        sys.exit(1)

    ip_address = sys.argv[1]

    try:
        print(f"[+] Connessione a {ip_address} sulla porta FTP (21)...")
        ftp = FTP(ip_address, timeout=10)
        ftp.login("ftp", "anonymous")  # Connessione anonima

        print("\n[+] Invio comando FEAT...")
        try:
            features = ftp.sendcmd("FEAT")
            print("[FEAT Output]\n" + features)
        except error_perm as e:
            print(f"[!] Errore FEAT: {e}")

        print("\n[+] Invio comando LIST...")
        try:
            ftp.retrlines("LIST")
        except error_perm as e:
            print(f"[!] Errore LIST: {e}")

        ftp.quit()
        print("\n[+] Disconnessione completata.")

    except all_errors as e:
        print(f"[!] Errore FTP: {e}")


if __name__ == "__main__":
    main()
