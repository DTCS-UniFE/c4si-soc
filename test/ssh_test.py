import random
import string
import sys
import time

import paramiko


def random_string(length=8):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


def attempt_ssh(ip, username, password, attempt_number):
    print(
        f"[Tentativo {attempt_number}] Connessione SSH a {ip} con username='{username}' e password='{password}'"
    )
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        client.connect(ip, port=22, username=username, password=password, timeout=5)
        print(
            f"[+] Connessione riuscita al tentativo {attempt_number} con {username}:{password}"
        )
        client.close()
        return True
    except paramiko.AuthenticationException:
        print(f"[-] Autenticazione fallita ({username}:{password})")
    except paramiko.SSHException as e:
        print(f"[!] Errore SSH: {e}")
    except Exception as e:
        print(f"[!] Errore generico: {e}")
    finally:
        client.close()
    return False


def main():
    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <indirizzo_ip>")
        sys.exit(1)

    ip = sys.argv[1]

    # Tentativi con credenziali casuali
    for i in range(1, 3):
        user = random_string()
        pwd = random_string()
        attempt_ssh(ip, user, pwd, i)
        time.sleep(1)

    # Tentativo con credenziali corrette
    attempt_ssh(ip, "root", "123456", 3)


if __name__ == "__main__":
    main()
