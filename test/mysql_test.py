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
            print(f"[SUCCESS] Connection successful with user: {user}")
            connection.close()
            return True
    except Error as e:
        print(f"[FAILURE] Connection failed with user: {user} - Error: {e}")
    return False


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <ip_address>")
        sys.exit(1)

    ip_address = sys.argv[1]

    # Attempts with random credentials
    for _ in range(2):
        user, password = generate_random_credentials()
        print(f"Attempt with user: {user} and password: {password}")
        if try_connect(ip_address, user, password):
            return

    # Final attempt with known credentials
    print("Final attempt with known credentials (root / 123456)")
    try_connect(ip_address, "root", "123456")


if __name__ == "__main__":
    main()
