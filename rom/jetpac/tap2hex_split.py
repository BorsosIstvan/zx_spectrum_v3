import sys
import struct

def tap_to_split_hex(tapfile, hexfile0, hexfile1):
    with open(tapfile, "rb") as f:
        data = f.read()

    ptr = 0
    blocks = []
    while ptr < len(data):
        if ptr + 2 > len(data):
            break
        block_len = struct.unpack("<H", data[ptr:ptr+2])[0]
        ptr += 2
        block_data = data[ptr:ptr+block_len]
        ptr += block_len
        blocks.append(block_data)

    print(f"📦 Found {len(blocks)} blocks")

    # Header blok = blok[0], Data blok = blok[1]
    if len(blocks) < 2:
        print("⚠️  File does not contain header+data blocks!")
        sys.exit(1)

    data_block = blocks[1]
    # Verwijder flag, header checksum etc.
    payload = data_block[1:-1]

    # Jetpac laadt zich meestal bij 0x5B00 of 0x8000, maar we plaatsen hem in 0x4000
    start_addr = 0x4000
    end_addr = start_addr + len(payload)

    print(f"🧠 Data size: {len(payload)} bytes ({hex(start_addr)}–{hex(end_addr-1)})")

    # Maak 16 KB RAM, gevuld met 0xFF
    full_ram = [0xFF] * 16384
    full_ram[:len(payload)] = payload

    # Split in twee 8K delen
    ram0 = full_ram[:8192]
    ram1 = full_ram[8192:]

    with open(hexfile0, "w") as f0:
        for b in ram0:
            f0.write(f"{b:02X}\n")

    with open(hexfile1, "w") as f1:
        for b in ram1:
            f1.write(f"{b:02X}\n")

    print(f"✅ Created {hexfile0} and {hexfile1}")
    print(f"jetpac_0.hex → 0x4000–0x5FFF")
    print(f"jetpac_1.hex → 0x6000–0x7FFF")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python tap2hex_split.py Jetpac.tap")
        sys.exit(1)

    tapfile = sys.argv[1]
    tap_to_split_hex(tapfile, "jetpac_0.hex", "jetpac_1.hex")
