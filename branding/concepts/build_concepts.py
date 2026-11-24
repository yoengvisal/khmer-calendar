import math, re, sys, html
OUT = sys.argv[1]
ICON1 = open(sys.argv[2]).read()
NAVY, NAVY2, RED, GOLD1, GOLD2, CREAM = '#0E2A6B', '#071640', '#C8102E', '#F7DA86', '#D59A2E', '#FBF6EA'
TOWER = 'M224 392V366L221 357L231 364V344L228 335L237 342V326L234 318L243 324V311L247 311C243 298 247 282 256 250C265 282 269 298 265 311L269 311V324L278 318L275 326V342L284 335L281 344V364L291 357L288 366V392Z'
KH = "'Kantumruy Pro','Noto Sans Khmer','Khmer Sangam MN',sans-serif"

def svg(p, body, defs=''):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><defs>{gold(p)}<linearGradient id="{p}bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#123383"/><stop offset="1" stop-color="{NAVY2}"/></linearGradient>{defs}</defs>{body}</svg>'
def gold(p):
    return f'<linearGradient id="{p}g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{GOLD1}"/><stop offset="1" stop-color="{GOLD2}"/></linearGradient>'
def tile(p, fill=None):
    return f'<rect width="512" height="512" rx="112" fill="{fill or f"url(#{p}bg)"}"/>'

def phase(cx, cy, r, k, waxing=True, lit=None, dark=NAVY):
    """Moon disc with illuminated fraction k (0..1); waxing = lit on the right."""
    lit = lit or GOLD1
    out = f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{dark}"/>'
    if k <= 0.001:
        return out + f'<circle cx="{cx}" cy="{cy}" r="{r-2}" fill="none" stroke="{lit}" stroke-width="3"/>'
    if k >= 0.999:
        return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{lit}"/>'
    rx = abs(1 - 2 * k) * r
    sweep = 0 if k < 0.5 else 1
    d = f'M{cx} {cy-r}A{r} {r} 0 0 1 {cx} {cy+r}A{rx:.2f} {r} 0 0 {sweep} {cx} {cy-r}Z'
    tf = '' if waxing else f' transform="translate({2*cx} 0) scale(-1 1)"'
    return out + f'<path d="{d}" fill="{lit}"{tf}/>'

concepts = []

# 1 Prasat Moon (existing refined icon)
icon1 = re.sub(r'<\?xml[^>]*>', '', ICON1)
concepts.append(('Prasat Moon', 'ព្រះចន្ទប្រាសាទ', 'A calendar page holding the lunar month: the waxing half (កើត) solid gold, the waning half (រោច) outlined, and a prasat standing on the line between them.', icon1))

# 2 Lunar Ring
p = 'c2'; dots = []
for i in range(30):
    a = -math.pi / 2 + i * 2 * math.pi / 30
    x, y = 256 + 176 * math.cos(a), 256 + 176 * math.sin(a)
    if i < 15:
        k = (i + 1) / 15; dots.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{5 + 8*k:.1f}" fill="url(#{p}g)"/>')
    else:
        k = (30 - i) / 15; dots.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{4 + 7*k:.1f}" fill="none" stroke="{GOLD2}" stroke-width="3"/>')
petal = 'M256 168C298 214 298 272 256 318C214 272 214 214 256 168Z'
side = 'M256 214C286 248 286 290 256 318C226 290 226 248 256 214Z'
lotus = (f'<path d="{side}" fill="{CREAM}" transform="rotate(-38 256 318)"/>'
         f'<path d="{side}" fill="{CREAM}" transform="rotate(38 256 318)"/>'
         f'<path d="{petal}" fill="url(#{p}g)"/><rect x="186" y="326" width="140" height="8" rx="4" fill="{CREAM}"/>')
concepts.append(('Lunar Ring', 'រង្វង់ខែ', 'Thirty days around the circle: fifteen gold waxing days grow toward the full moon, fifteen outlined waning days shrink away, with a lotus at the centre.', svg(p, tile(p) + ''.join(dots) + lotus)))

# 3 Kbach Crescent
p = 'c3'
ax, ay, ar, bx, by, br = 250, 262, 160, 300, 226, 132
dx, dy = bx - ax, by - ay; d = math.hypot(dx, dy)
a = (ar*ar - br*br + d*d) / (2*d); h = math.sqrt(ar*ar - a*a)
mx, my = ax + a*dx/d, ay + a*dy/d
tips = [(mx + h*dy/d, my - h*dx/d), (mx - h*dy/d, my + h*dx/d)]
tx, ty = max(tips, key=lambda t: t[1])
R0, turns = 40, 1.35
cxs, cys = tx + 6, ty - R0
th0 = math.atan2(ty - cys, tx - cxs)
pts = []
for i in range(121):
    t = i / 120
    th = th0 - t * turns * 2 * math.pi
    r = R0 * (1 - 0.78 * t)
    pts.append((cxs + r * math.cos(th), cys + r * math.sin(th)))
sp = 'M' + 'L'.join(f'{x:.1f} {y:.1f}' for x, y in pts)
body = (f'<rect width="512" height="512" rx="112" fill="url(#{p}red)"/>'
        f'<mask id="{p}m"><rect width="512" height="512" fill="#fff"/><circle cx="300" cy="226" r="132" fill="#000"/></mask>'
        f'<circle cx="250" cy="262" r="160" fill="url(#{p}g)" mask="url(#{p}m)"/>'
        f'<path d="{sp}" fill="none" stroke="url(#{p}g)" stroke-width="13" stroke-linecap="round" stroke-linejoin="round"/>'
        f'<path d="M404 118l14 26 26 14-26 14-14 26-14-26-26-14 26-14z" fill="{CREAM}"/>')
concepts.append(('Kbach Crescent', 'ក្បាច់អឌ្ឍចន្ទ', 'A crescent moon whose tip curls into a kbach flourish from Khmer ornament, with a star on deep ceremonial red. Calligraphic and warm.',
                 svg(p, body, f'<linearGradient id="{p}red" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#D21836"/><stop offset="1" stop-color="#7E0A1D"/></linearGradient>')))

# 4 Lotus Moon
p = 'c4'
pet = 'M256 250C300 300 300 360 256 400C212 360 212 300 256 250Z'
body = (tile(p) + f'<circle cx="256" cy="214" r="96" fill="url(#{p}g)"/>'
        + ''.join(f'<path d="{pet}" fill="{c}" transform="rotate({a} 256 400)"/>' for a, c in [(-62, '#9E0D25'), (62, '#9E0D25'), (-31, RED), (31, RED)])
        + f'<path d="{pet}" fill="#E34A62"/>'
        + f'<path d="M150 428q26-14 53 0t53 0 53 0 53 0" fill="none" stroke="{CREAM}" stroke-width="8" stroke-linecap="round"/>')
concepts.append(('Lotus Moon', 'ឈូកព្រះចន្ទ', 'A full moon rising out of an opening lotus, linking the Buddhist holy days and the lunar month in one soft, celebratory form.', svg(p, body)))

# 5 Numeral 15
p = 'c5'
body = (f'<rect width="512" height="512" rx="112" fill="{CREAM}"/>'
        f'<rect x="84" y="120" width="344" height="320" rx="44" fill="#fff" stroke="#E7DCC4" stroke-width="4"/>'
        f'<path d="M84 164a44 44 0 0 1 44-44h256a44 44 0 0 1 44 44v24H84z" fill="{RED}"/>'
        f'<rect x="160" y="92" width="24" height="56" rx="12" fill="{NAVY}"/><rect x="328" y="92" width="24" height="56" rx="12" fill="{NAVY}"/>'
        f'<text x="256" y="388" text-anchor="middle" font-family="{KH}" font-weight="700" font-size="200" fill="{NAVY}">១៥</text>'
        + f'<circle cx="256" cy="156" r="20" fill="url(#{p}g)"/>')
concepts.append(('Full-Moon Day', 'ថ្ងៃ១៥កើត', 'A tear-off calendar showing ១៥, the full-moon day, in Khmer numerals with a small gold moon. The most literal and readable option. Uses the Kantumruy Pro font.', svg(p, body)))

# 6 Moon Boat
p = 'c6'
hull = 'M84 312C104 372 186 392 262 392C344 392 410 370 436 316C410 346 344 364 262 364C190 364 128 350 104 306Z'
rowers = ''.join(f'<rect x="{150 + i*26}" y="336" width="8" height="22" rx="4" fill="{CREAM}"/>' for i in range(9))
body = (tile(p) + f'<circle cx="256" cy="186" r="84" fill="url(#{p}g)"/>'
        f'<path d="{hull}" fill="{RED}"/>' + rowers +
        f'<path d="M104 306c-14-34 6-58 30-52 18 5 16 30-2 30" fill="none" stroke="{RED}" stroke-width="12" stroke-linecap="round"/>'
        + ''.join(f'<rect x="{256 - w/2}" y="{414 + i*16}" width="{w}" height="6" rx="3" fill="{GOLD2}" opacity="{0.9 - i*0.25}"/>' for i, w in enumerate([150, 96, 48])))
concepts.append(('Moon Boat', 'ទូកព្រះចន្ទ', 'A Water Festival racing boat with a naga prow under the full moon of Kadeuk, when Bon Om Touk and Sampeah Preah Khae are held. Festive and storytelling.', svg(p, body)))

# 7 Angkor Horizon
p = 'c7'
def tower(tx, ty, s, fill, extra=''):
    return f'<path d="{TOWER}" fill="{fill}" transform="translate({tx} {ty}) scale({s}) translate(-256 -392)"{extra}/>'
towers = tower(256, 330, 1.55, NAVY2) + tower(170, 330, 1.05, NAVY2) + tower(342, 330, 1.05, NAVY2)
refl = f'<g transform="translate(0 660) scale(1 -1)" opacity=".45">{towers}</g>'
body = (f'<rect width="512" height="512" rx="112" fill="url(#{p}sky)"/>'
        f'<circle cx="372" cy="146" r="40" fill="url(#{p}g)"/>' + towers + f'<rect x="64" y="328" width="384" height="5" rx="2.5" fill="url(#{p}g)"/>' + refl)
concepts.append(('Angkor Horizon', 'ជើងមេឃអង្គរ', 'Three prasat towers on the horizon, reflected in the baray at dusk, with the moon overhead. Evokes heritage and place.',
                 svg(p, body, f'<linearGradient id="{p}sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#123383"/><stop offset=".38" stop-color="#6B2F74"/><stop offset=".64" stop-color="#F08A4B"/><stop offset=".645" stop-color="#1B2457"/><stop offset="1" stop-color="{NAVY2}"/></linearGradient>')))

# 8 Phase Grid
p = 'c8'
cells = []
ks = [(0.0, True), (0.25, True), (0.5, True), (0.75, True), (1.0, True), (0.75, False), (0.5, False), (0.25, False), (0.0, False)]
for idx, (k, wax) in enumerate(ks):
    cx, cy = 126 + (idx % 3) * 130, 126 + (idx // 3) * 130
    cells.append(phase(cx, cy, 50, k, wax, lit=f'url(#{p}g)'))
cells.append(f'<circle cx="256" cy="256" r="60" fill="none" stroke="{RED}" stroke-width="6"/>')
concepts.append(('Phase Grid', 'តារាងដំណាក់ខែ', 'Nine moon phases set as a calendar grid, from new moon to full moon and back, with the full-moon holy day ringed in red. Modern and systematic.',
                 svg(p, f'<rect width="512" height="512" rx="112" fill="{CREAM}"/>' + ''.join(cells))))

# 9 Ka monogram
p = 'c9'
txt = lambda fill: f'<text x="256" y="336" text-anchor="middle" font-family="{KH}" font-weight="700" font-size="250" fill="{fill}">ក</text>'
body = (tile(p) + f'<clipPath id="{p}L"><rect width="256" height="512"/></clipPath><clipPath id="{p}R"><rect x="256" width="256" height="512"/></clipPath>'
        f'<circle cx="256" cy="256" r="150" fill="none" stroke="{GOLD2}" stroke-width="10"/>'
        f'<path d="M256 101a155 155 0 0 0 0 310z" fill="url(#{p}g)"/>'
        f'<g clip-path="url(#{p}L)">{txt(NAVY)}</g><g clip-path="url(#{p}R)">{txt(GOLD1)}</g>')
concepts.append(('Kor Monogram', 'អក្សរ ក', 'The first Khmer consonant ក (the first letter of កើត, "waxing") set inside a half-lit moon, its colour flipping across the light/dark line. Bold and typographic. Uses the Kantumruy Pro font.', svg(p, body)))

# 10 Sila Days
p = 'c10'
items = []
for d in range(1, 31):
    col, row = (d + 2) % 7, (d + 2) // 7
    cx, cy = 100 + col * 52, 168 + row * 56
    if d == 8:
        items.append(phase(cx, cy, 19, 0.5, True, lit=f'url(#{p}g)', dark='#24407F'))
    elif d == 15:
        items.append(f'<circle cx="{cx}" cy="{cy}" r="23" fill="url(#{p}g)"/>')
    elif d == 23:
        items.append(phase(cx, cy, 19, 0.5, False, lit=f'url(#{p}g)', dark='#24407F'))
    elif d == 30:
        items.append(f'<circle cx="{cx}" cy="{cy}" r="17" fill="none" stroke="{GOLD1}" stroke-width="4"/>')
    else:
        items.append(f'<circle cx="{cx}" cy="{cy}" r="7" fill="{CREAM}" opacity=".35"/>')
body = tile(p) + f'<rect x="78" y="100" width="356" height="12" rx="6" fill="{RED}"/>' + ''.join(items)
concepts.append(('Sila Days', 'ថ្ងៃសីល', 'A month grid where the four holy days stand out as moons: 8 Kert, 15 Kert, 8 Roch and the new moon. Shows what the app is for at a glance.', svg(p, body)))

for i, (name, km, desc, s) in enumerate(concepts, 1):
    open(f'{OUT}/{i:02d}-{name.lower().replace(" ", "-")}.svg', 'w').write(s if s.lstrip().startswith('<svg') else s)

cards = []
for i, (name, km, desc, s) in enumerate(concepts, 1):
    s_inline = s
    smalls = ''.join(f'<div class="sz" style="width:{w}px;height:{w}px">{s_inline}</div>' for w in (64, 40, 24))
    cards.append(f'''<article class="card" id="c{i}">
  <div class="stage">{s_inline}</div>
  <div class="meta">
    <div class="row"><span class="num">{i:02d}</span><h2>{html.escape(name)}</h2></div>
    <p class="km">{km}</p>
    <p class="desc">{html.escape(desc)}</p>
    <div class="sizes"><div class="strip light">{smalls}</div><div class="strip dark">{smalls}</div></div>
  </div>
</article>''')

page = f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Khmer Calendar Logos</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Kantumruy+Pro:wght@400;600;700&display=swap" rel="stylesheet">
<style>
:root{{--bg:#F4EFE3;--card:#fff;--ink:#14213D;--muted:#5B6478;--line:#E6DCC6;--accent:#C8102E;--stage:#EFE7D6}}
@media (prefers-color-scheme:dark){{:root:not([data-theme="light"]){{--bg:#0A1230;--card:#111B42;--ink:#F2EEE4;--muted:#A9B1C9;--line:#22305F;--stage:#0D163A}}}}
:root[data-theme="dark"]{{--bg:#0A1230;--card:#111B42;--ink:#F2EEE4;--muted:#A9B1C9;--line:#22305F;--stage:#0D163A}}
*{{box-sizing:border-box}} body{{margin:0;background:var(--bg);color:var(--ink);font-family:'Kantumruy Pro',system-ui,sans-serif}}
header{{max-width:1240px;margin:0 auto;padding:40px 16px 8px;display:flex;flex-wrap:wrap;gap:16px;align-items:end;justify-content:space-between}}
h1{{margin:0;font-size:clamp(26px,4vw,40px);line-height:1.15}} h1 small{{display:block;font-size:.5em;color:var(--muted);font-weight:400;margin-top:6px}}
.toggle{{border:1px solid var(--line);background:var(--card);color:var(--ink);border-radius:999px;padding:8px 16px;font:inherit;cursor:pointer}}
main{{max-width:1240px;margin:0 auto;padding:16px;display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:20px}}
.card{{background:var(--card);border:1px solid var(--line);border-radius:20px;overflow:hidden;display:flex;flex-direction:column;transition:transform .15s}}
.card:hover{{transform:translateY(-2px)}}
.stage{{background:var(--stage);display:grid;place-items:center;padding:28px}} .stage svg{{width:200px;height:200px;filter:drop-shadow(0 10px 18px rgba(7,22,64,.25))}}
.meta{{padding:18px 20px 20px}} .row{{display:flex;align-items:center;gap:10px}}
.num{{background:var(--accent);color:#fff;border-radius:8px;padding:2px 8px;font-weight:700;font-size:14px}}
h2{{margin:0;font-size:20px}} .km{{margin:6px 0 0;color:var(--muted);font-size:15px}} .desc{{margin:10px 0 14px;font-size:14px;line-height:1.55;color:var(--muted)}}
.sizes{{display:flex;gap:8px}} .strip{{flex:1;display:flex;gap:10px;align-items:center;justify-content:center;padding:10px;border-radius:12px}}
.strip.light{{background:#fff;border:1px solid #eee}} .strip.dark{{background:#000}} .sz svg{{width:100%;height:100%}}
footer{{max-width:1240px;margin:0 auto;padding:8px 16px 48px;color:var(--muted);font-size:13px}}
</style></head><body>
<header><h1>ប្រតិទិនខ្មែរ · Khmer Calendar<small>10 logo concepts. Pick a number (01–10), or combine ideas from two.</small></h1>
<button class="toggle" id="t">Toggle light / dark</button></header>
<main>{''.join(cards)}</main>
<footer>Each card shows the app icon at 200, 64, 40 and 24 px on white and black. Concepts 05 and 09 use the Kantumruy Pro font (SIL OFL); the text will be converted to outlines once one is chosen. All artwork is original to this project.</footer>
<script>document.getElementById('t').onclick=()=>{{const r=document.documentElement;const dark=r.dataset.theme?r.dataset.theme==='dark':matchMedia('(prefers-color-scheme: dark)').matches;r.dataset.theme=dark?'light':'dark'}}</script>
</body></html>'''
open(f'{OUT}/index.html', 'w').write(page)
print('wrote', len(concepts), 'concepts')
