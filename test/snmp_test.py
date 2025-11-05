import asyncio
import random
import sys

from pysnmp.hlapi.v3arch.asyncio import SnmpEngine, UdpTransportTarget
from pysnmp.hlapi.v3arch.asyncio.auth import CommunityData
from pysnmp.hlapi.v3arch.asyncio.cmdgen import bulk_cmd, get_cmd, next_cmd, set_cmd
from pysnmp.hlapi.v3arch.asyncio.context import ContextData
from pysnmp.hlapi.varbinds import ObjectIdentity, ObjectType
from pysnmp.proto.rfc1902 import OctetString

HOST = "127.0.0.1"
PORT = 161

if len(sys.argv) < 2:
    print(f"Usage: python {sys.argv[0]} <host> [port] [community_get] [community_set]")
    sys.exit(1)

if len(sys.argv) >= 2:
    HOST = sys.argv[1]
if len(sys.argv) >= 3:
    PORT = int(sys.argv[2])

COMM_GET = sys.argv[3] if len(sys.argv) >= 4 else "public"
COMM_SET = sys.argv[4] if len(sys.argv) >= 5 else "private"

# ----- Config tarpit (ritardi prima delle richieste) -----
TARPIT = {
    "get": (0.1, 0.2),
    "set": (0.1, 0.2),
    "next": (0.0, 0.1),
    "bulk": (0.2, 0.4),
}


def resolve(token: str) -> str:
    SYMBOLS = {
        "sysDescr": "1.3.6.1.2.1.1.1.0",
        "sysUpTime": "1.3.6.1.2.1.1.3.0",
        "sysContact": "1.3.6.1.2.1.1.4.0",
        "sysName": "1.3.6.1.2.1.1.5.0",
        "sysLocation": "1.3.6.1.2.1.1.6.0",
        "sysServices": "1.3.6.1.2.1.1.7.0",
    }
    return SYMBOLS.get(token, token)


async def tarpit_delay(cmd: str):
    a, b = TARPIT.get(cmd, (0.0, 0.0))
    d = random.uniform(a, b)
    if d > 0:
        await asyncio.sleep(d)


def print_varbinds(varBinds):
    if not varBinds:
        print("(nessun varbind)")
        return
    for name, val in varBinds:
        print(f"{name.prettyPrint()} = {val.prettyPrint()}")


# -------- Operazioni SNMP (async) --------


async def aget(engine, community, transport, oid):
    await tarpit_delay("get")
    errInd, errStat, errIdx, vbs = await get_cmd(
        engine,
        CommunityData(community),
        transport,
        ContextData(),
        ObjectType(ObjectIdentity(oid)),
    )
    if errInd:
        raise RuntimeError(errInd)
    if errStat:
        raise RuntimeError(f"{errStat.prettyPrint()} at {errIdx}")
    return vbs


async def anext(engine, community, transport, oid):
    await tarpit_delay("next")
    errInd, errStat, errIdx, vbs = await next_cmd(
        engine,
        CommunityData(community),
        transport,
        ContextData(),
        ObjectType(ObjectIdentity(oid)),
        lexicographicMode=False,
    )
    if errInd:
        raise RuntimeError(errInd)
    if errStat:
        raise RuntimeError(f"{errStat.prettyPrint()} at {errIdx}")
    return vbs


async def abulk(engine, community, transport, oid, max_rep=5):
    await tarpit_delay("bulk")
    errInd, errStat, errIdx, vbs = await bulk_cmd(
        engine,
        CommunityData(community),
        transport,
        ContextData(),
        0,
        max_rep,  # non-repeaters, max-repetitions
        ObjectType(ObjectIdentity(oid)),
    )
    if errInd:
        raise RuntimeError(errInd)
    if errStat:
        raise RuntimeError(f"{errStat.prettyPrint()} at {errIdx}")
    # ritorna una “pagina” (come facevi prima)
    return [vbs]


async def aset(engine, community, transport, oid, value: str):
    await tarpit_delay("set")
    errInd, errStat, errIdx, vbs = await set_cmd(
        engine,
        CommunityData(community),
        transport,
        ContextData(),
        ObjectType(ObjectIdentity(oid), OctetString(value)),
    )
    if errInd:
        raise RuntimeError(errInd)
    if errStat:
        raise RuntimeError(f"{errStat.prettyPrint()} at {errIdx}")
    return vbs


# -------- Sequenza principale --------


async def main():
    print(
        f"Target: {HOST}:{PORT} (get community='{COMM_GET}', set community='{COMM_SET}')"
    )
    print("=" * 60)

    # Costruisci SnmpEngine e trasporto *asincrono*
    engine = SnmpEngine()
    # ⚠️ Qui è dove prima avevi l’errore: bisogna **await** la create()
    transport = await UdpTransportTarget.create((HOST, PORT), timeout=2, retries=0)

    # 1) GET principali
    print(
        "1) GET principali (sysDescr, sysUpTime, sysName, sysContact, sysLocation, sysServices)"
    )
    for sym in (
        "sysDescr",
        "sysUpTime",
        "sysName",
        "sysContact",
        "sysLocation",
        "sysServices",
    ):
        oid = resolve(sym)
        print(f"-- {sym} ({oid})")
        try:
            vbs = await aget(engine, COMM_GET, transport, oid)
            print_varbinds(vbs)
        except Exception as e:
            print(f"[GET ERROR] {sym} -> {e}")
    print("=" * 60)

    # 2) GETNEXT
    base_oid = "1.3.6.1.2.1.1"
    print(f"2) GETNEXT a partire da {base_oid}")
    try:
        vbs = await anext(engine, COMM_GET, transport, base_oid)
        print_varbinds(vbs)
    except Exception as e:
        print(f"[GETNEXT ERROR] {e}")
    print("=" * 60)

    # 3) GETBULK
    print(f"3) GETBULK a partire da {base_oid} (max-rep=5)")
    try:
        bulk_sets = await abulk(engine, COMM_GET, transport, base_oid, max_rep=5)
        if not bulk_sets:
            print("(nessun risultato bulk)")
        for vbset in bulk_sets:
            print_varbinds(vbset)
    except Exception as e:
        print(f"[GETBULK ERROR] {e}")
    print("=" * 60)

    # 4) SET sysContact (salva -> set -> verifica -> restore)
    contact_oid = resolve("sysContact")
    new_contact = "honeypot-contact@example.local"
    print(f"4) SET sysContact -> '{new_contact}' (oid {contact_oid})")
    try:
        orig_vb = await aget(engine, COMM_GET, transport, contact_oid)
        orig_val = orig_vb[0][1].prettyPrint() if orig_vb else ""
        print("  original:", orig_val)

        try:
            set_vb = await aset(engine, COMM_SET, transport, contact_oid, new_contact)
            print("  set result:")
            print_varbinds(set_vb)
        except Exception as e:
            print(f"  [SET ERROR] cannot set sysContact: {e}")

        try:
            vb_after = await aget(engine, COMM_GET, transport, contact_oid)
            print("  after set read:")
            print_varbinds(vb_after)
        except Exception as e:
            print(f"  [VERIFY ERROR] {e}")

        if orig_val is not None:
            try:
                await aset(engine, COMM_SET, transport, contact_oid, orig_val)
                print("  restored original sysContact.")
            except Exception as e:
                print(f"  [RESTORE ERROR] cannot restore original sysContact: {e}")

    except Exception as e:
        print(f"[SYS_CONTACT SEQUENCE ERROR] {e}")
    print("=" * 60)

    # 5) SET sysName (salva -> set -> verifica -> restore)
    name_oid = resolve("sysName")
    new_name = "honeypot-test"
    print(f"5) SET sysName -> '{new_name}' (oid {name_oid})")
    try:
        orig_vb = await aget(engine, COMM_GET, transport, name_oid)
        orig_val = orig_vb[0][1].prettyPrint() if orig_vb else ""
        print("  original:", orig_val)

        try:
            set_vb = await aset(engine, COMM_SET, transport, name_oid, new_name)
            print("  set result:")
            print_varbinds(set_vb)
        except Exception as e:
            print(f"  [SET ERROR] cannot set sysName: {e}")

        try:
            vb_after = await aget(engine, COMM_GET, transport, name_oid)
            print("  after set read:")
            print_varbinds(vb_after)
        except Exception as e:
            print(f"  [VERIFY ERROR] {e}")

        if orig_val is not None:
            try:
                await aset(engine, COMM_SET, transport, name_oid, orig_val)
                print("  restored original sysName.")
            except Exception as e:
                print(f"  [RESTORE ERROR] cannot restore original sysName: {e}")

    except Exception as e:
        print(f"[SYS_NAME SEQUENCE ERROR] {e}")
    print("=" * 60)

    print("Batch operations complete.")


if __name__ == "__main__":
    asyncio.run(main())
