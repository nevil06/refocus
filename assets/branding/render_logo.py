"""Render the Refocus Again brand mark to PNG using Pillow.

Pure-Python (no cairo/native deps). Mirrors assets/branding/logo.svg and the
in-app AppLogo widget: a rounded violet badge, an indigo-violet focus ring, two
converging aqua aperture arcs, and a center core. Rendered at high supersampling
then downscaled for smooth anti-aliased edges.
"""
import math
from PIL import Image, ImageDraw

OUT = r"C:\Projects\refocus\assets\branding\logo.png"
SIZE = 1024
SS = 4
S = SIZE * SS

# Deep Focus palette
BADGE = (0x1B, 0x1B, 0x25)
VIOLET = (0x6D, 0x5D, 0xF6)
VIOLET_LT = (0x8B, 0x7B, 0xFF)
AQUA = (0x3F, 0xE0, 0xC5)
INK = (0x0B, 0x0B, 0x0F)


def sc(v):
    return v / 512.0 * S


img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)
cx = cy = S / 2

# Rounded badge
draw.rounded_rectangle(
    [sc(24), sc(24), sc(488), sc(488)],
    radius=sc(120),
    fill=BADGE + (255,),
    outline=VIOLET + (64,),
    width=int(sc(4)),
)

# Outer focus ring
ring_r = sc(132)
draw.ellipse(
    [cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r],
    outline=VIOLET + (255,),
    width=int(sc(26)),
)

# Two converging aperture arcs (aqua) with clean rounded caps.
# Pillow's arc() has no round cap, so we draw the arc along its stroke
# centerline as a sequence of dots (a "brush") of diameter == stroke width.
# This yields smooth, fully rounded ends with no disjointed blobs.
arc_r = sc(98)
arc_w = sc(22)
brush = arc_w / 2.0


def stroke_arc(start_deg, end_deg):
    steps = 240
    for i in range(steps + 1):
        a = math.radians(start_deg + (end_deg - start_deg) * i / steps)
        x = cx + arc_r * math.cos(a)
        y = cy + arc_r * math.sin(a)
        draw.ellipse([x - brush, y - brush, x + brush, y + brush], fill=AQUA + (255,))


# Top-right arc: from top (-90) to right (0)
stroke_arc(-90, 0)
# Bottom-left arc: from bottom (90) to left (180)
stroke_arc(90, 180)

# Center core
core_r = sc(40)
draw.ellipse([cx - core_r, cy - core_r, cx + core_r, cy + core_r], fill=VIOLET_LT + (255,))
hole_r = sc(18)
draw.ellipse([cx - hole_r, cy - hole_r, cx + hole_r, cy + hole_r], fill=INK + (255,))

img = img.resize((SIZE, SIZE), Image.LANCZOS)
img.save(OUT, "PNG")
print(f"PNG written: {OUT} ({SIZE}x{SIZE})")
