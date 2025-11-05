import json
import socket
import sys

import snap7

ip = "127.0.0.1"
port = 102

if len(sys.argv) < 2:
    print(f"Uso: python {sys.argv[0]} <ip> <porta>")
    sys.exit(1)

if len(sys.argv) >= 2:
    ip = sys.argv[1]
if len(sys.argv) >= 3:
    port = int(sys.argv[2])


def resolve_hostname(hostname: str) -> str:
    try:
        ip_address = socket.gethostbyname(hostname)
        return ip_address
    except socket.gaierror:
        print(f"Impossibile risolvere l'hostname: {hostname}")
        return hostname


ip = resolve_hostname(ip)


def decode_c_strings(raw: bytes):
    parts = raw.split(b"\x00")
    out = []
    for p in parts:
        if not p:
            continue
        try:
            out.append(p.decode("utf-8", errors="replace"))
        except Exception:
            out.append(p.decode("latin1", errors="replace"))
    return out


def parse_component_identification(data_bytes: bytes):
    strings = decode_c_strings(data_bytes)
    keys_in_order = [
        ("system_name", "W#16#0001"),
        ("module_name", "W#16#0002"),
        ("plant_ident", "W#16#0003"),
        ("copyright", "W#16#0004"),
        ("serial", "W#16#0005"),
        ("module_type_name", "W#16#0007"),
        ("oem_id", "W#16#000A"),
        ("location", "W#16#000B"),
    ]
    result = {}
    for idx, (k, wid) in enumerate(keys_in_order):
        val = strings[idx] if idx < len(strings) else ""
        result[k] = {"id": wid, "value": val}
    return result


def main():
    client = snap7.client.Client()

    try:
        client.connect(ip, 0, 1, tcp_port=port)

        if not client.get_connected():
            print("Connessione non riuscita.")
            sys.exit(2)

        out = {
            "s7comm": {
                "enabled": True,
                "host": ip,
                "port": port,
                "system_status_lists": {},
            }
        }

        # ---- SZL 0x001C: Component Identification
        try:
            szl_1c = client.read_szl(0x001C, 0x0000)  # ritorna un oggetto S7SZL
            data_1c = bytes(szl_1c.Data)[: szl_1c.Header.LengthDR * szl_1c.Header.NDR]
            out["s7comm"]["system_status_lists"]["Component Identification"] = {
                "ssl_id": "W#16#001C",
                "fields": parse_component_identification(data_1c),
            }
        except Exception as e:
            out["s7comm"]["system_status_lists"]["Component Identification"] = {
                "ssl_id": "W#16#001C",
                "error": str(e),
            }

        # ---- SZL 0x0011: Module Identification (grezzo)
        try:
            szl_11 = client.read_szl(0x0011, 0x0000)
            data_11 = bytes(szl_11.Data)[: szl_11.Header.LengthDR * szl_11.Header.NDR]
            out["s7comm"]["system_status_lists"]["Module Identification"] = {
                "ssl_id": "W#16#0011",
                "raw_hex": data_11.hex(),
                "decoded_strings": decode_c_strings(data_11),
            }
        except Exception as e:
            out["s7comm"]["system_status_lists"]["Module Identification"] = {
                "ssl_id": "W#16#0011",
                "error": str(e),
            }

        print(json.dumps(out, ensure_ascii=False, indent=2))

    except Exception as e:
        print(f"Errore di connessione/lettura: {e}")
    finally:
        try:
            client.disconnect()
        except Exception:
            pass
        client.destroy()


if __name__ == "__main__":
    main()
