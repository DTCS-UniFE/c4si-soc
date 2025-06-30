import random
import string
import sys
import time

import paramiko


def random_string(length=8):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


def attempt_ssh(ip, username, password, attempt_number):
    print(
        f"[Attempt {attempt_number}] SSH connection to {ip} with username='{username}' and password='{password}'"
    )
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        client.connect(ip, port=22, username=username, password=password, timeout=5)
        print(
            f"[+] Connection successful on attempt {attempt_number} with {username}:{password}"
        )
        client.close()
        return True
    except paramiko.AuthenticationException:
        print(f"[-] Authentication failed ({username}:{password})")
    except paramiko.SSHException as e:
        print(f"[!] SSH error: {e}")
    except Exception as e:
        print(f"[!] General error: {e}")
    finally:
        client.close()
    return False


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <ip_address>")
        sys.exit(1)

    ip = sys.argv[1]

    # Attempts with random credentials
    for i in range(1, 3):
        user = random_string()
        pwd = random_string()
        attempt_ssh(ip, user, pwd, i)
        time.sleep(1)

    # Attempt with correct credentials
    attempt_ssh(ip, "root", "123456", 3)


if __name__ == "__main__":
    main()
