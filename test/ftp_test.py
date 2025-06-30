import sys
from ftplib import FTP, all_errors, error_perm


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <ip_address>")
        sys.exit(1)

    ip_address = sys.argv[1]

    try:
        print(f"[+] Connecting to {ip_address} on FTP port (21)...")
        ftp = FTP(ip_address, timeout=10)
        ftp.login("ftp", "anonymous")  # Anonymous login

        print("\n[+] Sending FEAT command...")
        try:
            features = ftp.sendcmd("FEAT")
            print("[FEAT Output]\n" + features)
        except error_perm as e:
            print(f"[!] FEAT Error: {e}")

        print("\n[+] Sending LIST command...")
        try:
            ftp.retrlines("LIST")
        except error_perm as e:
            print(f"[!] LIST Error: {e}")

        ftp.quit()
        print("\n[+] Disconnection completed.")

    except all_errors as e:
        print(f"[!] FTP Error: {e}")


if __name__ == "__main__":
    main()
