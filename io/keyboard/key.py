import serial
from pynput import keyboard

ser = serial.Serial('COM9', 115200, timeout=0.1)

# PS/2 Set 1 mapping
key_map = {
    'a': 0x1C, 'b': 0x32, 'c': 0x21, 'd': 0x23, 'e': 0x24,
    'f': 0x2B, 'g': 0x34, 'h': 0x33, 'i': 0x43, 'j': 0x3B,
    'k': 0x42, 'l': 0x4B, 'm': 0x3A, 'n': 0x31, 'o': 0x44,
    'p': 0x4D, 'q': 0x15, 'r': 0x2D, 's': 0x1B, 't': 0x2C,
    'u': 0x3C, 'v': 0x2A, 'w': 0x1D, 'x': 0x22, 'y': 0x35,
    'z': 0x1A, '1': 0x16, '2': 0x1E, '3': 0x26, '4': 0x25,
    '5': 0x2E, '6': 0x36, '7': 0x3D, '8': 0x3E, '9': 0x46,
    '0': 0x45, ' ': 0x29, '\n': 0x5A, ',': 0x41, '.': 0x49
}

# Special keys mapping
special_keys = {
    keyboard.Key.shift_l: 0x12,
    keyboard.Key.shift_r: 0x59,
    keyboard.Key.ctrl_l: 0x14,
    keyboard.Key.ctrl_r: 0x14,
    keyboard.Key.enter: 0x5A,
    keyboard.Key.space: 0x29
}

pressed_keys = set()  # track pressed keys

def send_make_break(code):
    """Stuur make-code via UART"""
    ser.write(bytes([code]))

def send_break(code):
    """Stuur break-code via UART"""
    ser.write(bytes([0xF0, code]))

def on_press(key):
    if key in special_keys and key not in pressed_keys:
        pressed_keys.add(key)
        send_make_break(special_keys[key])
        print(f"Pressed: {key} → {special_keys[key]:02X}")
        return
    try:
        k = key.char.lower()
        if k in key_map and k not in pressed_keys:
            pressed_keys.add(k)
            send_make_break(key_map[k])
            print(f"Pressed: {k} → {key_map[k]:02X}")
    except AttributeError:
        pass

def on_release(key):
    if key in special_keys and key in pressed_keys:
        pressed_keys.remove(key)
        send_break(special_keys[key])
        print(f"Released: {key} → {special_keys[key]:02X}")
        return
    try:
        k = key.char.lower()
        if k in key_map and k in pressed_keys:
            pressed_keys.remove(k)
            send_break(key_map[k])
            print(f"Released: {k} → {key_map[k]:02X}")
    except AttributeError:
        pass

    if key == keyboard.Key.esc:
        print("Exiting...")
        return False

with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
    listener.join()
