"""Convert the package name of the logo into vector paths (outlines).

The SVG logo then no longer depends on the fonts installed on the computer.
The text is drawn with Arimo Bold (open font, Apache License 2.0, metrically
compatible with Arial/Helvetica), centered at x=259 with the baseline at
y=468 and a font size of 60, as in make_logo_camel.R. "Type" is in red.

Output: name_outline.svgfrag, a <g> element read by make_logo_camel.R.
"""
import os
import re
import sys
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen

# Arimo Bold font file: first command line argument, or the ARIMO_FONT
# environment variable. Arimo is available from Google Fonts
# (https://fonts.google.com/specimen/Arimo) and is installed with TeX Live.
FONT_FILE = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("ARIMO_FONT")
if not FONT_FILE or not os.path.isfile(FONT_FILE):
    sys.exit("Usage: python3 make_name_outline.py /path/to/Arimo-Bold.ttf\n"
             "Arimo Bold is available from "
             "https://fonts.google.com/specimen/Arimo")
SIZE, CENTER_X, BASELINE_Y = 60, 259, 468
PARTS = [("split", "#1B3A57"), ("Type", "#B03A36"), ("R", "#1B3A57")]

font = TTFont(FONT_FILE)
scale = SIZE / font["head"].unitsPerEm
cmap = font.getBestCmap()
glyphs = font.getGlyphSet()
hmtx = font["hmtx"]

# Kerning pairs from the 'kern' table (format 0)
kern = {}
if "kern" in font:
    for table in font["kern"].kernTables:
        kern.update(getattr(table, "kernTable", {}))

text = "".join(p for p, _ in PARTS)
names = [cmap[ord(ch)] for ch in text]

# Horizontal position of each glyph, with kerning
xs, x = [], 0.0
for i, name in enumerate(names):
    xs.append(x)
    x += hmtx[name][0]
    if i + 1 < len(names):
        x += kern.get((name, names[i + 1]), 0)
start = CENTER_X - x * scale / 2

out, k = ['<g id="name">'], 0
for part, color in PARTS:
    for _ in part:
        pen = SVGPathPen(glyphs)
        # Font units (y up) to SVG pixels (y down)
        tpen = TransformPen(pen, (scale, 0, 0, -scale,
                                  start + xs[k] * scale, BASELINE_Y))
        glyphs[names[k]].draw(tpen)
        # Round the coordinates to 2 decimals to keep the file small
        d = re.sub(r"-?\d+\.\d+", lambda m: "%.2f" % float(m.group()),
                   pen.getCommands())
        out.append('<path fill="%s" d="%s"/>' % (color, d))
        k += 1
out.append("</g>")

with open("name_outline.svgfrag", "w") as f:
    f.write("\n".join(out) + "\n")
print("glyphs:", len(names), " width: %.1f px" % (x * scale))
