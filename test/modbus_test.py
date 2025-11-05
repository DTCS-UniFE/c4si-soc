import os
import sys
from typing import Any, Dict

from pymodbus.client import ModbusTcpClient

MODBUS_IP = "127.0.0.1"
MODBUS_PORT = 502
MODBUS_TIMEOUT = 3.0

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <ip_address> [port: int] [timeout: float]")
    sys.exit(1)

if len(sys.argv) >= 2:
    MODBUS_IP = sys.argv[1]
if len(sys.argv) >= 3:
    MODBUS_PORT = int(sys.argv[2])
if len(sys.argv) >= 4:
    MODBUS_TIMEOUT = float(sys.argv[3])

BLOCKS = {
    1: [  # slave id 1
        {
            "name": "memoryModbusSlave1BlockA",
            "type": "COILS",
            "starting_address": 1,
            "size": 128,
        },
        {
            "name": "memoryModbusSlave1BlockB",
            "type": "DISCRETE_INPUTS",
            "starting_address": 10001,
            "size": 32,
        },
    ],
    2: [  # slave id 2
        {
            "name": "memoryModbusSlave2BlockC",
            "type": "ANALOG_INPUTS",
            "starting_address": 30001,
            "size": 8,
        },
        {
            "name": "memoryModbusSlave2BlockD",
            "type": "HOLDING_REGISTERS",
            "starting_address": 40001,
            "size": 8,
        },
    ],
}


def read_block(client: ModbusTcpClient, device_id: int, block: Dict[str, Any]):
    reg_type = block["type"]
    start = block["starting_address"]
    count = block["size"]
    addr = start
    print(f"{reg_type=} {start=} {count=} {addr=}")

    if reg_type == "COILS":
        res = client.read_coils(address=addr, count=count, device_id=device_id)
        if res.isError():
            raise RuntimeError(res)
        # res.bits può avere elementi extra; ritaglia
        return list(res.bits)[:count]

    elif reg_type == "DISCRETE_INPUTS":
        res = client.read_discrete_inputs(
            address=addr, count=count, device_id=device_id
        )
        if res.isError():
            raise RuntimeError(res)
        return list(res.bits)[:count]

    elif reg_type == "ANALOG_INPUTS":
        # input registers
        res = client.read_input_registers(
            address=addr, count=count, device_id=device_id
        )
        if res.isError():
            raise RuntimeError(res)
        return list(res.registers)

    elif reg_type == "HOLDING_REGISTERS":
        res = client.read_holding_registers(
            address=addr, count=count, device_id=device_id
        )
        if res.isError():
            raise RuntimeError(res)
        return list(res.registers)

    else:
        raise ValueError(f"Tipo di registro non supportato: {reg_type}")


def main():
    client = ModbusTcpClient(MODBUS_IP, port=MODBUS_PORT, timeout=MODBUS_TIMEOUT)
    if not client.connect():
        print(f"❌ Connessione fallita verso {MODBUS_IP}:{MODBUS_PORT}")
        sys.exit(1)

    try:
        for slave_id, blocks in BLOCKS.items():
            print(f"\n=== Slave ID {slave_id} ===")
            for blk in blocks:
                try:
                    values = read_block(client, slave_id, blk)
                    print(
                        f"- {blk['name']} [{blk['type']} @ {blk['starting_address']} size={blk['size']}]"
                    )
                    print(f"  valori: {values}")
                except Exception as e:
                    print(f"- {blk['name']} [{blk['type']}] → errore: {e}")
    finally:
        try:
            client.close()
        except Exception:
            pass


if __name__ == "__main__":
    main()
