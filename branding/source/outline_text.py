"""Shape text with HarfBuzz and emit SVG path data from Kantumruy Pro Bold outlines."""
import sys, json
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
import uharfbuzz as hb, io

src = sys.argv[1]
font = TTFont(src)
bold = instantiateVariableFont(font, {"wght": 700})
buf = io.BytesIO(); bold.save(buf); data = buf.getvalue()
ft = TTFont(io.BytesIO(data)); gs = ft.getGlyphSet(); upem = ft['head'].unitsPerEm
hbfont = hb.Font(hb.Face(hb.Blob(data)))

def text_path(text, size, x, y, anchor='middle', tracking=0):
    b = hb.Buffer(); b.add_str(text); b.guess_segment_properties()
    hb.shape(hbfont, b, {})
    s = size / upem; track = tracking / s
    names = ft.getGlyphOrder()
    total = sum(p.x_advance for p in b.glyph_positions) + track * (len(b.glyph_positions) - 1)
    ox = {'start': 0, 'middle': -total / 2, 'end': -total}[anchor]
    pen = SVGPathPen(gs); cx = 0
    for info, pos in zip(b.glyph_infos, b.glyph_positions):
        gx, gy = ox + cx + pos.x_offset, pos.y_offset
        tp = TransformPen(pen, (s, 0, 0, -s, x + gx * s, y - gy * s))
        gs[names[info.codepoint]].draw(tp)
        cx += pos.x_advance + (track if pos.x_advance else 0)
    return pen.getCommands(), total * s

out = {}
out['kor'], _ = text_path('ក', 200, 256, 322)
out['km_wordmark'], out['km_width'] = text_path('ប្រតិទិនខ្មែរ', 100, 0, 0, 'start')
out['en_wordmark'], out['en_width'] = text_path('KHMER CALENDAR', 36, 0, 0, 'start', tracking=8)
out['dev'], _ = text_path('DEV', 58, 256, 0, 'middle', tracking=6)
out['stg'], _ = text_path('STG', 58, 256, 0, 'middle', tracking=6)
json.dump(out, open(sys.argv[2], 'w'))
print({k: (len(v) if isinstance(v, str) else round(v, 1)) for k, v in out.items()})
