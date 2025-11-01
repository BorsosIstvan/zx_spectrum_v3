# tap2hex_data_only.py
import sys

if len(sys.argv) < 3:
    print("Gebruik: python3 tap2hex_data_only.py input.tap output.hex")
    sys.exit(1)

tap_file = sys.argv[1]
hex_file = sys.argv[2]

with open(tap_file, "rb") as f:
    content = f.read()

# Spectrum TAP: eerste blok is header, tweede blok is data
ptr = 0
# Lees eerste blok (header)
if ptr + 2 > len(content):
    raise ValueError("TAP te kort")
header_len = content[ptr] + (content[ptr+1] << 8)
ptr += 2 + header_len

# Lees tweede blok (data)
if ptr + 2 > len(content):
    raise ValueError("Geen tweede blok gevonden")
data_len = content[ptr] + (content[ptr+1] << 8)
ptr += 2
data_block = content[ptr:ptr+data_len]

# Strip trailing 0xFF
while data_block and data_block[-1] == 0xFF:
    data_block = data_block[:-1]

# Schrijf naar hex
with open(hex_file, "w") as f:
    for b in data_block:
        f.write(f"{b:02X}\n")

print(f"Data bytes geschreven (zonder trailing FF): {len(data_block)}")
print(f"Output: {hex_file}")
