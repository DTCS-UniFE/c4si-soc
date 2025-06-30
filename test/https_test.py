import random
import string
import sys

import requests
import urllib3

# Disable warnings for self-signed certs
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def random_string(length=8):
    chars = string.ascii_letters + string.digits
    return "".join(random.choice(chars) for _ in range(length))


def try_https(ip):
    url = f"https://{ip}/"
    print(f"[*] Sending HTTPS GET to {url}")

    try:
        resp = requests.get(url, timeout=5, verify=False)
        print(f"Status Code: {resp.status_code}")
        print(resp.text[:200])  # show first 200 characters of the body
    except Exception as e:
        print(f"[!] Error during HTTPS GET: {e}")

    for attempt in range(1, 4):
        if attempt < 3:
            username = random_string()
            password = random_string()
        else:
            username = "admin"
            password = "admin"

        data = {"username": username, "password": password}

        print(f"[*] HTTPS POST Attempt {attempt}: {username}/{password}")
        try:
            resp = requests.post(url, data=data, timeout=5, verify=False)
            print(f"Status Code: {resp.status_code}")
            print(resp.text[:200])
        except Exception as e:
            print(f"[!] Error during HTTPS POST: {e}")


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <ip_address>")
        sys.exit(1)

    ip_address = sys.argv[1]

    try_https(ip_address)


if __name__ == "__main__":
    main()
