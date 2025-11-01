# z80_to_hex_full.py
import sys

def main():
    if len(sys.argv) < 2:
        print("Gebruik: python z80_to_hex_full.py pacman.z80")
        sys.exit(1)

    z80_file = sys.argv[1]

    with open(z80_file, "rb") as f:
        data = f.read()

    # Eerste 30 bytes v1 header
    # Byte 30-31: PC laag/hoog
    pc_low = data[30]
    pc_high = data[31]
    start_addr = pc_low + (pc_high << 8)
    print(f"Startadres voor RANDOMIZE USR: {start_addr}")

    # Detect versie
    version = "v1"
    if len(data) > 49179:  # typisch v2/v3 groter dan 49KB
        version = "v2/v3"
    print(f"Snapshot versie vermoedelijk: {version}")

    # Voor 48K Spectrum, RAM van 0x4000 tot 0xFFFF (16k x 3) - we gebruiken eerste 16k voor RAM0, volgende 16k voor RAM1
    # V1 snapshot: 0x100 header, daarna 48k RAM
    ram_data = data[0x100:0x100+48*1024]  # 48k bytes

    ram0 = ram_data[0:8192]     # 0x4000-0x5FFF
    ram1 = ram_data[8192:16384] # 0x6000-0x7FFF

    # Schrijf HEX
    with open("ram0.hex", "w") as f:
        for b in ram0:
            f.write(f"{b:02X}\n")

    with open("ram1.hex", "w") as f:
        for b in ram1:
            f.write(f"{b:02X}\n")

    print("HEX-bestanden aangemaakt: ram0.hex en ram1.hex")

if __name__ == "__main__":
    main()
