import random
import string
import sys

import mysql.connector
from mysql.connector import Error


def generate_random_credentials():
    username = "".join(random.choices(string.ascii_lowercase, k=6))
    password = "".join(random.choices(string.ascii_letters + string.digits, k=8))
    return username, password


def try_connect(ip, user, password):
    try:
        connection = mysql.connector.connect(
            host=ip, user=user, password=password, connection_timeout=5
        )
        if connection.is_connected():
            print(f"[SUCCESS] Connessione riuscita con utente: {user}")
            connection.close()
            return True
    except Error as e:
        print(f"[FAILURE] Connessione fallita con utente: {user} - Errore: {e}")
    return False


def main():
    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <indirizzo_ip>")
        sys.exit(1)

    ip_address = sys.argv[1]

    # Tentativi con credenziali casuali
    for _ in range(2):
        user, password = generate_random_credentials()
        print(f"Tentativo con utente: {user} e password: {password}")
        if try_connect(ip_address, user, password):
            return

    # Tentativo con credenziali corrette
    print("Tentativo finale con credenziali conosciute (root / 123456)")
    try_connect(ip_address, "root", "123456")


if __name__ == "__main__":
    main()
