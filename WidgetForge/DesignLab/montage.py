#!/usr/bin/env python3
"""Stitch rendered widget-concept PNGs into labeled contact-sheet montages.

Reads <shots>/index.json + the per-concept PNGs, and writes montage sheets
(one grid for medium, one for large) with each tile labeled by title. Lets a
human review 40+ designs in a couple of images instead of one file at a time.
"""
import json, sys, os
from PIL import Image, ImageDraw, ImageFont

SHOTS = sys.argv[1] if len(sys.argv) > 1 else "/tmp/concept-review"
OUT = sys.argv[2] if len(sys.argv) > 2 else "/tmp/concept-review"

def load_font(size):
    for p in ["/System/Library/Fonts/SFNS.ttf",
              "/System/Library/Fonts/Helvetica.ttc",
              "/Library/Fonts/Arial.ttf"]:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, size)
            except Exception: pass
    return ImageFont.load_default()

def build(entries, family, cols, out_path):
    tiles = []
    for e in entries:
        fn = next((f for f in e["files"] if f.endswith(f"__{family}.png")), None)
        if not fn: continue
        fp = os.path.join(SHOTS, fn)
        if not os.path.exists(fp): continue
        tiles.append((e["title"], e["id"], e["scheme"], fp))
    if not tiles:
        print(f"no {family} tiles"); return

    # Target tile width; scale each image, add a label bar under it.
    TW = 420
    LABEL_H = 46
    PAD = 18
    BG = (18, 18, 20)
    thumbs = []
    for title, cid, scheme, fp in tiles:
        im = Image.open(fp).convert("RGB")
        scale = TW / im.width
        th = int(im.height * scale)
        im = im.resize((TW, th), Image.LANCZOS)
        thumbs.append((title, cid, scheme, im))

    max_h = max(t[3].height for t in thumbs)
    cell_w = TW + PAD
    cell_h = max_h + LABEL_H + PAD
    rows = (len(thumbs) + cols - 1) // cols
    W = cols * cell_w + PAD
    H = rows * cell_h + PAD + 60

    sheet = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(sheet)
    title_font = load_font(30)
    label_font = load_font(22)
    sub_font = load_font(16)
    d.text((PAD, 18), f"WidgetForge concepts — {family.upper()}  ({len(thumbs)})",
           fill=(240, 240, 245), font=title_font)

    for i, (title, cid, scheme, im) in enumerate(thumbs):
        r, c = divmod(i, cols)
        x = PAD + c * cell_w
        y = 60 + PAD + r * cell_h
        # checker so transparent/dark designs are distinguishable from bg
        sheet.paste(im, (x, y))
        d.rectangle([x, y, x + TW, y + im.height], outline=(60, 60, 66), width=1)
        ly = y + im.height + 6
        d.text((x + 2, ly), title, fill=(235, 235, 240), font=label_font)
        d.text((x + 2, ly + 24), f"{cid} · {scheme}", fill=(150, 150, 158), font=sub_font)

    sheet.save(out_path)
    print(f"wrote {out_path}  ({len(thumbs)} tiles, {cols}x{rows})")

def main():
    idx = os.path.join(SHOTS, "index.json")
    entries = json.load(open(idx))["entries"]
    entries.sort(key=lambda e: e["title"].lower())
    # chunk into sheets of at most 12 tiles so each montage stays legible
    CHUNK = 12
    for family in ("medium", "large"):
        chunks = [entries[i:i+CHUNK] for i in range(0, len(entries), CHUNK)]
        for n, ch in enumerate(chunks, 1):
            suffix = f"-{n}" if len(chunks) > 1 else ""
            build(ch, family, cols=3, out_path=os.path.join(OUT, f"montage-{family}{suffix}.png"))

if __name__ == "__main__":
    main()
