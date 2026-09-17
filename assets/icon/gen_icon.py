"""Generates the launcher icon + splash images. Run: python assets/icon/gen_icon.py"""
from PIL import Image, ImageDraw, ImageFilter

S = 1024
PURPLE = (98, 0, 238)       # 0xFF6200EE – app seed colour
PURPLE_DARK = (63, 0, 160)
WHITE = (255, 255, 255)
GOLD = (255, 200, 60)

def gradient_bg(size, c1, c2):
    img = Image.new("RGB", (size, size), c1)
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        col = tuple(int(c1[i] * (1 - t) + c2[i] * t) for i in range(3))
        for x in range(size):
            px[x, y] = col
    return img

def draw_chord(draw, cx, cy, w, h, line, color):
    """Draws a chord diagram: nut, 5 frets, 6 strings, 3 finger dots."""
    left, top = cx - w // 2, cy - h // 2
    right, bottom = cx + w // 2, cy + h // 2
    # nut (thick top bar)
    draw.rounded_rectangle([left, top - line, right, top + line * 2], radius=line, fill=color)
    # frets
    for i in range(1, 5):
        y = top + (h * i) // 4
        draw.line([(left, y), (right, y)], fill=color, width=line)
    # strings
    for i in range(6):
        x = left + (w * i) // 5
        draw.line([(x, top), (x, bottom)], fill=color, width=line)
    # finger dots (looks like a D / G-ish shape)
    r = int(w * 0.075)
    for (si, fi) in [(1, 2), (2, 3), (3, 2)]:
        x = left + (w * si) // 5
        y = top + (h * (fi - 0.5)) // 4
        draw.ellipse([x - r, y - r, x + r, y + r], fill=GOLD)

def make_icon(size, bg=True, pad=0.18):
    if bg:
        img = gradient_bg(size, PURPLE, PURPLE_DARK).convert("RGBA")
    else:
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    inner = int(size * (1 - pad * 2))
    w, h = int(inner * 0.70), int(inner * 0.86)
    draw_chord(draw, size // 2, size // 2 + int(size * 0.02), w, h, max(2, size // 40), WHITE)
    return img

# Full-bleed icon (iOS / legacy Android / web)
make_icon(S).save("assets/icon/icon.png")
# Adaptive foreground (transparent, extra safe-zone padding) + background
make_icon(S, bg=False, pad=0.28).save("assets/icon/icon_foreground.png")
gradient_bg(S, PURPLE, PURPLE_DARK).save("assets/icon/icon_background.png")
# Native splash logo (transparent, centered)
make_icon(S, bg=False, pad=0.22).save("assets/splash/splash_logo.png")
print("done")
