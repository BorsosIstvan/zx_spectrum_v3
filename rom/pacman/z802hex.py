# z80_to_hex.py
import sys

def z80_to_hex(z80_file, hex_file):
    with open(z80_file, "rb") as f:
        data = f.read()

    # Controleer magic
    if len(data) < 30:
        print("Bestand te klein")
        return

    # Header v1: 30 bytes
    pc_l = data[0x0C]
    pc_h = data[0x0D]
    pc_start = pc_l + (pc_h << 8)
    print(f"PC startadres: {pc_start}")

    # RAM dump: 48k mode
    # na header begint RAM op offset 30 (voor v1 snapshot)
    ram_data = data[30:]
    if len(ram_data) < 49152:
        print(f"RAM snapshot is klein: {len(ram_data)} bytes")
    else:
        ram_data = ram_data[:49152]  # alleen 48k

    with open(hex_file, "w") as f:
        for b in ram_data:
            f.write(f"{b:02X}\n")

    print(f"{len(ram_data)} bytes geschreven naar {hex_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Gebruik: python z80_to_hex.py pacman.z80 pacman.hex")
    else:
        z80_to_hex(sys.argv[1], sys.argv[2])
