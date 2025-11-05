import sys

from cpppo.server.enip import client
from cpppo.server.enip.get_attribute import attribute_operations

ip = "127.0.0.1"
port = 44818
timeout = 10.0

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <ip_address> [port: int] [timeout: float]")
    sys.exit(1)

if len(sys.argv) >= 2:
    ip = sys.argv[1]
if len(sys.argv) >= 3:
    port = int(sys.argv[2])
if len(sys.argv) >= 4:
    timeout = float(sys.argv[3])


PATHS = ["@22/1/1", "@22/1/2", "@22/1/3"]  # SCADA, TEXT, FLOAT

if __name__ == "__main__":
    ops = list(attribute_operations(paths=PATHS))

    with client.connector(host=ip, port=port, timeout=timeout) as conn:
        for idx, dsc, op, rpy, sts, val in conn.pipeline(operations=ops):
            # dsc è il path, val è il valore (può essere lista di byte o già tipizzato)
            print(f"{dsc}: {val}")
