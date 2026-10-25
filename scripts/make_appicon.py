#!/usr/bin/env python3
"""Render the WidgetForge app icon: a bento/widget grid on Widget Horizon blue.

The mark reads as a widget-builder: a 2x2 bento of rounded tiles where the
top-left tile spans two rows (the "large widget"), one tile is accented, and
the layout echoes the widget families the app forges. Deterministic vector-ish
render at 1024px so it stays crisp with no AI artifacts.
"""
from PIL import Image, ImageDraw
import math

S = 1024
# Widget Horizon blue #0070F2, with a subtle vertical deepening for depth.
TOP = (0x11, 0x84, 0xFF)      # slightly lifted top
BOT = (0x00, 0x5A, 0xCC)      # deeper bottom
WHITE = (255, 255, 255)
ACCENT = (0xFF, 0xC4, 0x53)   # Widget "gold" accent tile


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def rounded(draw, box, r, fill):
    draw.rounded_rectangle(box, radius=r, fill=fill)


img = Image.new("RGB", (S, S), TOP)
px = img.load()
for y in range(S):
    t = y / (S - 1)
    # ease so most of the icon stays vivid blue, deepening near the bottom
    tt = t * t
    row = lerp(TOP, BOT, tt)
    for x in range(S):
        px[x, y] = row

draw = ImageDraw.Draw(img, "RGBA")

# Bento grid geometry. Content inset leaves an iOS-safe margin; the grid is a
# 2x2 field with a gutter. Top-left tile spans both rows (the hero widget).
inset = 224
gutter = 40
field = S - inset * 2
cell = (field - gutter) / 2
r = 48

x0 = inset
y0 = inset

# Hero tile: left column, full height (spans two rows).
hero = [x0, y0, x0 + cell, y0 + field]
# Top-right tile.
tr = [x0 + cell + gutter, y0, x0 + field, y0 + cell]
# Bottom-right tile (accented).
br = [x0 + cell + gutter, y0 + cell + gutter, x0 + field, y0 + field]

# Soft drop shadow under the whole cluster for a little material depth.
shadow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
sdraw = ImageDraw.Draw(shadow)
for box in (hero, tr, br):
    sb = [box[0], box[1] + 14, box[2], box[3] + 14]
    sdraw.rounded_rectangle(sb, radius=r, fill=(0, 0, 30, 60))
shadow = shadow.filter(__import__("PIL.ImageFilter", fromlist=["ImageFilter"]).GaussianBlur(18))
img = Image.alpha_composite(img.convert("RGBA"), shadow).convert("RGB")
draw = ImageDraw.Draw(img, "RGBA")

# Tiles. Hero + top-right are white; bottom-right is the accent.
rounded(draw, hero, r, (255, 255, 255, 255))
rounded(draw, tr, r, (255, 255, 255, 235))
rounded(draw, br, r, (*ACCENT, 255))

# Inside the hero tile, hint at "content rows" so it reads as a live widget:
# a header bar plus two list lines, drawn in translucent blue.
hx0, hy0, hx1, hy1 = hero
pad = 46
bar_h = 60
line_h = 34
blue = (0x00, 0x70, 0xF2)
# header block
rounded(draw, [hx0 + pad, hy0 + pad, hx1 - pad, hy0 + pad + bar_h], 18,
        (*blue, 235))
# two list lines of decreasing width
ly = hy0 + pad + bar_h + 44
rounded(draw, [hx0 + pad, ly, hx1 - pad, ly + line_h], 12, (*blue, 90))
ly += line_h + 26
rounded(draw, [hx0 + pad, ly, hx1 - pad - 70, ly + line_h], 12, (*blue, 90))
ly += line_h + 26
rounded(draw, [hx0 + pad, ly, hx1 - pad - 150, ly + line_h], 12, (*blue, 90))

# Top-right tile: a small KPI dot + metric bar hint.
tx0, ty0, tx1, ty1 = tr
tpad = 40
cd = 46
draw.ellipse([tx0 + tpad, ty0 + tpad, tx0 + tpad + cd, ty0 + tpad + cd],
             fill=(*blue, 235))
rounded(draw, [tx0 + tpad, ty1 - tpad - 34, tx1 - tpad, ty1 - tpad], 12,
        (*blue, 90))

# Bottom-right accent tile: a white "add / spark" plus mark, the forge action.
bx0, by0, bx1, by1 = br
cx = (bx0 + bx1) / 2
cy = (by0 + by1) / 2
arm = (bx1 - bx0) * 0.26
thick = 30
draw.rounded_rectangle([cx - arm, cy - thick / 2, cx + arm, cy + thick / 2],
                       radius=thick / 2, fill=WHITE)
draw.rounded_rectangle([cx - thick / 2, cy - arm, cx + thick / 2, cy + arm],
                       radius=thick / 2, fill=WHITE)

img.save("AppIcon-1024.png")
print("wrote AppIcon-1024.png")
