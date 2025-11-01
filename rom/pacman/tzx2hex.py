# tzx2hex.py
import sys

def tzx_to_hex(tzx_file, hex_file):
    with open(tzx_file, "rb") as f:
        data = f.read()

    if not data.startswith(b"ZXTape!\x1A"):
        print("Dit is geen geldig TZX-bestand")
        return

    ptr = 10  # header + version
    hex_bytes = []

    while ptr < len(data):
        block_id = data[ptr]
        ptr += 1

        if block_id == 0x10:  # Standard Speed Data Block
            length = int.from_bytes(data[ptr:ptr+2], 'little')
            ptr += 2
            hex_bytes.extend(data[ptr:ptr+length])
            ptr += length

        elif block_id == 0x11:  # Turbo Speed Data Block
            length = int.from_bytes(data[ptr+5:ptr+9], 'little')  # data length at offset 5
            ptr += 9  # skip pause (2), sync1, sync2, zero bit length (total 9 bytes header)
            hex_bytes.extend(data[ptr:ptr+length])
            ptr += length

        elif block_id == 0x30:  # Text description block
            text_len = data[ptr]
            ptr += 1 + text_len

        else:
            # voor nu skip andere block types
            # veel blocks hebben 2-4 byte lengte headers
            # we negeren geluid/pilot blocks
            if ptr+2 <= len(data):
                length = int.from_bytes(data[ptr:ptr+2], 'little')
                ptr += 2 + length
            else:
                break

    # schrijf naar hex file
    with open(hex_file, "w") as f:
        for i, b in enumerate(hex_bytes):
            f.write(f"{b:02X}\n")

    print(f"Succes! {len(hex_bytes)} bytes geschreven naar {hex_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Gebruik: python tzx2hex.py pacman.tzx pacman.hex")
    else:
        tzx_to_hex(sys.argv[1], sys.argv[2])
