"""Round 2 logo concepts: stronger Khmer identity + lunar calendar. Run: python3 build_round2.py"""
import math, html, os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'round2')
NAVY, NAVY2, RED, RED2, GOLD1, GOLD2, CREAM = '#0E2A6B', '#071640', '#C8102E', '#8E0B20', '#F7DA86', '#D59A2E', '#FBF6EA'
KH = "'Kantumruy Pro','Noto Sans Khmer','Khmer Sangam MN',sans-serif"
TOWER = 'M224 392V366L221 357L231 364V344L228 335L237 342V326L234 318L243 324V311L247 311C243 298 247 282 256 250C265 282 269 298 265 311L269 311V324L278 318L275 326V342L284 335L281 344V364L291 357L288 366V392Z'
# Kbach "flame leaf" (base at 0,0 pointing up), the basic unit of Khmer ornament
KBACH = 'M-13 0C-17-14-10-27 0-44C-1-33 7-28 9-19C13-23 15-12 13 0Z'

def defs(p, extra=''):
    return (f'<defs><linearGradient id="{p}g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{GOLD1}"/><stop offset="1" stop-color="{GOLD2}"/></linearGradient>'
            f'<linearGradient id="{p}bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#123383"/><stop offset="1" stop-color="{NAVY2}"/></linearGradient>'
            f'<linearGradient id="{p}red" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#D21836"/><stop offset="1" stop-color="{RED2}"/></linearGradient>{extra}</defs>')
def svg(p, body, extra=''):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">{defs(p, extra)}{body}</svg>'
def tile(fill):
    return f'<rect width="512" height="512" rx="112" fill="{fill}"/>'
def split_moon(p, cx, cy, r, tower_fill=NAVY, tower_scale=None, ring=GOLD2):
    s = tower_scale or r / 86
    return (f'<circle cx="{cx}" cy="{cy}" r="{r - 4*s:.1f}" fill="none" stroke="{ring}" stroke-width="{8*s:.1f}"/>'
            f'<path d="M{cx} {cy - r}a{r} {r} 0 0 0 0 {2*r}z" fill="url(#{p}g)"/>'
            f'<g transform="translate({cx} {cy}) scale({s:.3f}) translate(-256 -306)"><path d="{TOWER}" fill="{tower_fill}"/>'
            f'<rect x="180" y="388" width="152" height="10" rx="5" fill="{tower_fill}"/></g>')
def kbach_ring(cx, cy, r, n, fill, scale=1.0, rot0=0):
    return ''.join(f'<path d="{KBACH}" fill="{fill}" transform="rotate({rot0 + i*360/n:.2f} {cx} {cy}) translate({cx} {cy - r}) scale({scale})"/>' for i in range(n))

C = []

# 11 Royal Seal — Khmer name around a split moon with prasat, kbach crown ring
p = 'r11'
body = (tile(f'url(#{p}bg)') + kbach_ring(256, 256, 196, 24, f'url(#{p}g)', 0.62)
        + f'<circle cx="256" cy="256" r="180" fill="{RED}"/><circle cx="256" cy="256" r="176" fill="none" stroke="{GOLD1}" stroke-width="3"/>'
        + f'<circle cx="256" cy="256" r="122" fill="{CREAM}"/>'
        + f'<path id="{p}top" d="M118 256a138 138 0 0 1 276 0" fill="none"/>'
        + f'<path id="{p}bot" d="M98 256a158 158 0 0 0 316 0" fill="none"/>'
        + f'<text font-family="{KH}" font-weight="700" font-size="30" fill="{GOLD1}" letter-spacing="7"><textPath href="#{p}top" startOffset="50%" text-anchor="middle">KHMER CALENDAR</textPath></text>'
        + f'<text font-family="{KH}" font-weight="700" font-size="34" fill="{GOLD1}"><textPath href="#{p}bot" startOffset="50%" text-anchor="middle">ប្រតិទិនខ្មែរ</textPath></text>'
        + ''.join(f'<path d="M0-9l3 6 6 3-6 3-3 6-3-6-6-3 6-3z" fill="{GOLD1}" transform="translate({256 + 151*math.cos(math.radians(a)):.1f} {256 + 151*math.sin(math.radians(a)):.1f})"/>' for a in (180, 0))
        + split_moon(p, 256, 252, 92))
C.append(('Royal Seal', 'ត្រាប្រតិទិនខ្មែរ', 'A seal in the style of a Khmer royal stamp: "ប្រតិទិនខ្មែរ" runs around a red band crowned with kbach flames, with the lunar moon and prasat at the centre. Clearly Khmer and official. Too detailed for small icons, so pair it with a simpler icon.', svg(p, body)))

# 12 Pagoda Gable — Khmer roof with chovea hooks framing the moon
p = 'r12'
roof = (f'<path d="M256 96L420 300H372L256 156L140 300H92Z" fill="url(#{p}red)"/>'
        f'<path d="M256 96L420 300H372L256 156L140 300H92Z" fill="none" stroke="url(#{p}g)" stroke-width="8" stroke-linejoin="round"/>'
        f'<path d="M92 300C70 300 58 284 64 262" fill="none" stroke="url(#{p}g)" stroke-width="12" stroke-linecap="round"/>'
        f'<path d="M420 300C442 300 454 284 448 262" fill="none" stroke="url(#{p}g)" stroke-width="12" stroke-linecap="round"/>'
        f'<path d="M256 100C250 84 252 66 262 52C258 66 264 76 270 86" fill="none" stroke="url(#{p}g)" stroke-width="9" stroke-linecap="round"/>'
        + ''.join(f'<path d="{KBACH}" fill="url(#{p}g)" transform="translate({256 + dx} {176 + abs(dx)*1.15}) rotate({dx*0.35}) scale(.42)"/>' for dx in (-84, -56, 56, 84)))
moon = (f'<circle cx="256" cy="246" r="54" fill="none" stroke="{GOLD2}" stroke-width="6"/><path d="M256 189a57 57 0 0 0 0 114z" fill="url(#{p}g)"/>')
base = (f'<rect x="132" y="312" width="248" height="16" rx="8" fill="url(#{p}g)"/>'
        + ''.join(f'<rect x="{150 + i*44}" y="336" width="18" height="72" rx="4" fill="{CREAM}"/>' for i in range(6))
        + f'<rect x="120" y="412" width="272" height="16" rx="8" fill="url(#{p}g)"/>')
C.append(('Pagoda Gable', 'ហោជាងវត្ត', 'The gable of a Khmer wat roof, with upturned chovea hooks and kbach on the eaves, framing the half-lit lunar moon above a colonnade. Temple architecture, so it reads as Cambodian straight away.', svg(p, tile(f'url(#{p}bg)') + roof + moon + base)))

# 13 Krama Calendar — the krama check as the calendar header
p = 'r13'
pat = (f'<pattern id="{p}k" width="32" height="32" patternUnits="userSpaceOnUse"><rect width="32" height="32" fill="{CREAM}"/>'
       f'<rect width="16" height="32" fill="{RED}" opacity=".55"/><rect width="32" height="16" fill="{RED}" opacity=".55"/></pattern>')
body = (tile(f'url(#{p}bg)')
        + f'<rect x="92" y="124" width="328" height="308" rx="44" fill="{CREAM}"/>'
        + f'<clipPath id="{p}hc"><path d="M92 168a44 44 0 0 1 44-44h240a44 44 0 0 1 44 44v40H92z"/></clipPath>'
        + f'<rect x="92" y="124" width="328" height="84" fill="url(#{p}k)" clip-path="url(#{p}hc)"/>'
        + f'<rect x="92" y="204" width="328" height="6" fill="{RED}"/>'
        + f'<rect x="164" y="96" width="24" height="56" rx="12" fill="url(#{p}g)"/><rect x="324" y="96" width="24" height="56" rx="12" fill="url(#{p}g)"/>'
        + f'<g transform="translate(0 20)">{split_moon(p, 256, 300, 82)}</g>')
C.append(('Krama Calendar', 'ក្រមាប្រតិទិន', 'A calendar page whose header is woven in the red-and-white check of the krama scarf, worn across Cambodia. Below it sit the lunar moon and prasat. Everyday Khmer life plus the calendar.', svg(p, body, pat)))

# 14 Kbach Kor — ក in a split moon, wreathed in kbach flames
p = 'r14'
txt = lambda fill: f'<text x="256" y="322" text-anchor="middle" font-family="{KH}" font-weight="700" font-size="200" fill="{fill}">ក</text>'
body = (tile(f'url(#{p}bg)') + kbach_ring(256, 256, 188, 16, f'url(#{p}g)', 0.95)
        + f'<circle cx="256" cy="256" r="150" fill="{NAVY2}"/>'
        + f'<clipPath id="{p}L"><rect width="256" height="512"/></clipPath><clipPath id="{p}R"><rect x="256" width="256" height="512"/></clipPath>'
        + f'<circle cx="256" cy="256" r="124" fill="none" stroke="{GOLD2}" stroke-width="8"/>'
        + f'<path d="M256 128a128 128 0 0 0 0 256z" fill="url(#{p}g)"/>'
        + f'<g clip-path="url(#{p}L)">{txt(NAVY)}</g><g clip-path="url(#{p}R)">{txt(GOLD1)}</g>')
C.append(('Kbach Kor', 'ក្បាច់ក', 'Monogram 09 (ក in the waxing/waning moon) set in a wreath of kbach flame leaves, the motif carved on Khmer temples. Script plus ornament, so it reads as Khmer twice over.', svg(p, body)))

# 15 Angkor Bands — blue/red/blue bands, gold moon, three white prasats
p = 'r15'
def tower(tx, ty, s, fill):
    return f'<path d="{TOWER}" fill="{fill}" transform="translate({tx} {ty}) scale({s}) translate(-256 -392)"/>'
body = (f'<clipPath id="{p}clip"><rect width="512" height="512" rx="112"/></clipPath><g clip-path="url(#{p}clip)">'
        f'<rect width="512" height="512" fill="#0B2E8A"/><rect y="150" width="512" height="230" fill="{RED}"/></g>'
        + f'<circle cx="256" cy="250" r="88" fill="none" stroke="{GOLD1}" stroke-width="6"/><path d="M256 159a91 91 0 0 0 0 182z" fill="url(#{p}g)"/>'
        + tower(256, 352, 1.35, CREAM) + tower(186, 352, 0.95, CREAM) + tower(326, 352, 0.95, CREAM)
        + f'<rect x="132" y="348" width="248" height="10" rx="5" fill="{CREAM}"/>')
C.append(('Angkor Bands', 'ប្រាសាទ ពណ៌ជាតិ', 'National colours (blue, red, blue) with three white prasats in front of the half-lit moon. A nod to the flag without copying it. The most patriotic option; national symbols can have usage rules, so check before shipping it.', svg(p, body)))

# 16 Naga Moon — the Angkor naga balustrade curling around the moon
p = 'r16'
hood = 'M-6 0C-8-26-26-46-19-68C-13-84 13-84 19-68C26-46 8-26 6 0Z'
heads = ''.join(f'<path d="{hood}" fill="url(#{p}g)" stroke="{NAVY2}" stroke-width="3" transform="translate(124 318) rotate({a}) scale({1 - abs(a)/260:.2f})"/>' for a in (-72, 72, -48, 48, -24, 24, 0))
body_path = 'M124 318C136 396 226 436 312 424C386 414 428 372 438 308'
body = (tile(f'url(#{p}bg)')
        + f'<circle cx="300" cy="222" r="90" fill="none" stroke="{GOLD2}" stroke-width="7"/><path d="M300 128a94 94 0 0 0 0 188z" fill="url(#{p}g)"/>'
        + f'<g transform="translate(300 222) scale(.95) translate(-256 -306)"><path d="{TOWER}" fill="{NAVY}"/><rect x="180" y="388" width="152" height="10" rx="5" fill="{NAVY}"/></g>'
        + f'<path d="{body_path}" fill="none" stroke="url(#{p}g)" stroke-width="40" stroke-linecap="round"/>'
        + f'<path d="{body_path}" fill="none" stroke="{RED}" stroke-width="28" stroke-linecap="round"/>'
        + f'<path d="{body_path}" fill="none" stroke="url(#{p}g)" stroke-width="5" stroke-dasharray="1 13" stroke-linecap="round"/>'
        + heads + ''.join(f'<circle cx="0" cy="-66" r="4" fill="{NAVY2}" transform="translate(124 318) rotate({a}) scale({1 - abs(a)/260:.2f})"/>' for a in (-72, 72, -48, 48, -24, 24, 0)) + f'<circle cx="124" cy="318" r="16" fill="{RED}" stroke="url(#{p}g)" stroke-width="4"/>')
C.append(('Naga Moon', 'នាគព្រះចន្ទ', 'The seven-headed naga from the Angkor causeway balustrades, its body curving around the half-lit moon and prasat. A powerful Khmer guardian symbol.', svg(p, body)))

for i, (name, km, desc, s) in enumerate(C, 11):
    open(f'{OUT}/{i}-{name.lower().replace(" ", "-")}.svg', 'w').write(s)

cards = ''.join(f'''<article class="card"><div class="stage">{s}</div><div class="meta"><div class="row"><span class="num">{i}</span><h2>{html.escape(name)}</h2></div>
<p class="km">{km}</p><p class="desc">{html.escape(desc)}</p>
<div class="sizes"><div class="strip light">{''.join(f'<div style="width:{w}px;height:{w}px">{s}</div>' for w in (64,40,24))}</div><div class="strip dark">{''.join(f'<div style="width:{w}px;height:{w}px">{s}</div>' for w in (64,40,24))}</div></div></div></article>''' for i, (name, km, desc, s) in enumerate(C, 11))
page = f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Khmer Calendar Logos</title>
<link href="https://fonts.googleapis.com/css2?family=Kantumruy+Pro:wght@400;600;700&display=swap" rel="stylesheet">
<style>:root{{--bg:#F4EFE3;--card:#fff;--ink:#14213D;--muted:#5B6478;--line:#E6DCC6;--stage:#EFE7D6}}
@media (prefers-color-scheme:dark){{:root{{--bg:#0A1230;--card:#111B42;--ink:#F2EEE4;--muted:#A9B1C9;--line:#22305F;--stage:#0D163A}}}}
*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);color:var(--ink);font-family:'Kantumruy Pro',system-ui,sans-serif}}
header,main,footer{{max-width:1240px;margin:0 auto;padding:16px}} header{{padding-top:40px}} h1{{margin:0;font-size:clamp(26px,4vw,40px)}} h1 small{{display:block;font-size:.5em;color:var(--muted);font-weight:400;margin-top:6px}}
header a{{color:#C8102E}} main{{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:20px}}
.card{{background:var(--card);border:1px solid var(--line);border-radius:20px;overflow:hidden}} .stage{{background:var(--stage);display:grid;place-items:center;padding:28px}}
.stage svg{{width:220px;height:220px;filter:drop-shadow(0 10px 18px rgba(7,22,64,.25))}} .meta{{padding:18px 20px 20px}} .row{{display:flex;gap:10px;align-items:center}}
.num{{background:#C8102E;color:#fff;border-radius:8px;padding:2px 8px;font-weight:700}} h2{{margin:0;font-size:20px}} .km{{margin:6px 0 0;color:var(--muted)}}
.desc{{font-size:14px;line-height:1.55;color:var(--muted)}} .sizes{{display:flex;gap:8px}} .strip{{flex:1;display:flex;gap:10px;align-items:center;justify-content:center;padding:10px;border-radius:12px}}
.strip.light{{background:#fff;border:1px solid #eee}} .strip.dark{{background:#000}} .strip svg{{width:100%;height:100%}} footer{{color:var(--muted);font-size:13px;padding-bottom:48px}}</style></head><body>
<header><h1>ប្រតិទិនខ្មែរ · Round 2: More Khmer identity<small>Script, kbach ornament, prasat, wat roof, krama, naga and national colours, each combined with the lunar moon. Round 1 is <a href="../index.html">here</a>.</small></h1></header>
<main>{cards}</main><footer>All artwork is original. Khmer text uses Kantumruy Pro (SIL OFL) and will be converted to outlines for the final files.</footer></body></html>'''
open(f'{OUT}/index.html', 'w').write(page)
print('wrote', len(C))
