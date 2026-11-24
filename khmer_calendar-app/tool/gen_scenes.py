"""Generate the gradient and pet header wallpapers (400x250 SVG, flutter_svg-safe:
no <use>, no filters, no CSS). Usage (from khmer_calendar-app): python3 tool/gen_scenes.py assets/scenes"""
import random
import sys
from pathlib import Path

OUT = Path(sys.argv[1])
W, H = 400, 250

# Where the home screen leaves the wallpaper uncovered (viewBox units, measured
# on a 411dp phone, 1 unit ~ 1.32dp): under the app title, left of the search
# button, with the month card's top edge at ~y 137. Pets peek over that edge:
# ears and eyes above it, paws resting on it.
PEEK_X, PEEK_Y, PEEK_S = 232, 128, .78


def svg(defs, body):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" '
        f'preserveAspectRatio="xMidYMid slice" aria-hidden="true">'
        f'<defs>{"".join(defs)}</defs>{"".join(body)}</svg>'
    )


def linear(id_, stops, x1=0, y1=0, x2=0, y2=1):
    s = "".join(f'<stop offset="{o}" stop-color="{c}"/>' for o, c in stops)
    return f'<linearGradient id="{id_}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}">{s}</linearGradient>'


def glow(id_, color, opacity=1.0):
    return (
        f'<radialGradient id="{id_}" cx=".5" cy=".5" r=".5">'
        f'<stop offset="0" stop-color="{color}" stop-opacity="{opacity}"/>'
        f'<stop offset="1" stop-color="{color}" stop-opacity="0"/></radialGradient>'
    )


def rect(fill):
    return f'<rect width="{W}" height="{H}" fill="{fill}"/>'


def blob(cx, cy, rx, ry, gid):
    return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="url(#{gid})"/>'


def stars(seed, n, color="#FFFFFF", y_max=H, r=(0.5, 1.6)):
    rnd = random.Random(seed)
    out = []
    for _ in range(n):
        x, y = rnd.uniform(0, W), rnd.uniform(0, y_max)
        out.append(
            f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rnd.uniform(*r):.2f}" '
            f'fill="{color}" opacity="{rnd.uniform(.35, .95):.2f}"/>'
        )
    return "".join(out)


SPARKLE = "M0 -6L1.4 -1.4L6 0L1.4 1.4L0 6L-1.4 1.4L-6 0L-1.4 -1.4Z"


def sparkle(x, y, s, color, op=0.9):
    return f'<path d="{SPARKLE}" fill="{color}" opacity="{op}" transform="translate({x} {y}) scale({s})"/>'


def paw(x, y, s, rot, color, op):
    return (
        f'<g fill="{color}" opacity="{op}" transform="translate({x} {y}) rotate({rot}) scale({s})">'
        '<ellipse cx="0" cy="4" rx="5" ry="4.2"/>'
        '<circle cx="-5.6" cy="-2.4" r="2"/><circle cx="-2" cy="-6" r="2.1"/>'
        '<circle cx="2" cy="-6" r="2.1"/><circle cx="5.6" cy="-2.4" r="2"/></g>'
    )


def bone(x, y, s, rot, color, op):
    return (
        f'<g fill="{color}" opacity="{op}" transform="translate({x} {y}) rotate({rot}) scale({s})">'
        '<rect x="-10" y="-2.2" width="20" height="4.4" rx="2"/>'
        '<circle cx="-10" cy="-2.6" r="3"/><circle cx="-10" cy="2.6" r="3"/>'
        '<circle cx="10" cy="-2.6" r="3"/><circle cx="10" cy="2.6" r="3"/></g>'
    )


def heart(x, y, s, color, op):
    return (
        f'<path d="M0 3C-6 -2 -4 -7 0 -4C4 -7 6 -2 0 3Z" fill="{color}" opacity="{op}" '
        f'transform="translate({x} {y}) scale({s})"/>'
    )


def scatter(seed, n, fn, avoid=None):
    """Place n decorations, skipping the peek window so the pet stays clean."""
    rnd = random.Random(seed)
    out, tries = [], 0
    while len(out) < n and tries < n * 40:
        tries += 1
        x, y = rnd.uniform(8, W - 8), rnd.uniform(8, H - 8)
        if avoid and avoid[0] < x < avoid[2] and avoid[1] < y < avoid[3]:
            continue
        out.append(fn(rnd, x, y))
    return "".join(out)


AVOID = (PEEK_X - 32, PEEK_Y - 32, PEEK_X + 32, PEEK_Y + 30)


# ---------------------------------------------------------------- characters

def cat(cx, cy, fur, fur_dark, inner, eyes="open", s=1.0, line="#3A2416"):
    k = lambda v: round(v * s, 2)
    p = []
    # body + paws (mostly behind the card; shows in the picker thumbnail)
    p.append(f'<ellipse cx="{cx}" cy="{cy + k(40)}" rx="{k(30)}" ry="{k(26)}" fill="{fur}"/>')
    # ears
    for d in (-1, 1):
        p.append(
            f'<path d="M{cx + d * k(25)} {cy - k(2)}L{cx + d * k(21)} {cy - k(34)}L{cx + d * k(3)} {cy - k(19)}Z" fill="{fur}"/>'
        )
        p.append(
            f'<path d="M{cx + d * k(21)} {cy - k(7)}L{cx + d * k(19)} {cy - k(27)}L{cx + d * k(9)} {cy - k(18)}Z" fill="{inner}"/>'
        )
    # head
    p.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{k(27)}" ry="{k(22)}" fill="{fur}"/>')
    # tabby stripes
    for dx, h in ((-6, 8), (0, 10), (6, 8)):
        p.append(
            f'<path d="M{cx + k(dx)} {cy - k(21)}V{cy - k(21 - h)}" stroke="{fur_dark}" '
            f'stroke-width="{k(2.6)}" stroke-linecap="round"/>'
        )
    # eyes
    for d in (-1, 1):
        ex, ey = cx + d * k(10), cy - k(1)
        if eyes == "open":
            p.append(f'<ellipse cx="{ex}" cy="{ey}" rx="{k(3.6)}" ry="{k(4.6)}" fill="{line}"/>')
            p.append(f'<circle cx="{ex + k(1.2)}" cy="{ey - k(1.6)}" r="{k(1.3)}" fill="#FFFFFF"/>')
        elif eyes == "glow":
            p.append(f'<ellipse cx="{ex}" cy="{ey}" rx="{k(4.4)}" ry="{k(5)}" fill="#FDE047"/>')
            p.append(f'<ellipse cx="{ex}" cy="{ey}" rx="{k(1.3)}" ry="{k(4)}" fill="#1A1206"/>')
        else:  # happy / sleepy
            p.append(
                f'<path d="M{ex - k(4)} {ey}Q{ex} {ey + k(4)} {ex + k(4)} {ey}" fill="none" '
                f'stroke="{line}" stroke-width="{k(2)}" stroke-linecap="round"/>'
            )
    # cheeks
    if eyes != "glow":
        for d in (-1, 1):
            p.append(f'<ellipse cx="{cx + d * k(16)}" cy="{cy + k(7)}" rx="{k(4.5)}" ry="{k(3)}" fill="#FF8FA3" opacity=".45"/>')
    # nose + mouth
    p.append(f'<path d="M{cx - k(3)} {cy + k(5)}H{cx + k(3)}L{cx} {cy + k(8.5)}Z" fill="#F27C95"/>')
    p.append(
        f'<path d="M{cx - k(5)} {cy + k(11)}Q{cx - k(2.5)} {cy + k(13.5)} {cx} {cy + k(9)}'
        f'Q{cx + k(2.5)} {cy + k(13.5)} {cx + k(5)} {cy + k(11)}" fill="none" stroke="{line}" '
        f'stroke-width="{k(1.4)}" stroke-linecap="round"/>'
    )
    # whiskers
    for d in (-1, 1):
        for dy, tilt in ((-1, -3), (2.5, 0), (6, 3)):
            x0 = cx + d * k(15)
            p.append(
                f'<path d="M{x0} {cy + k(5 + dy)}L{x0 + d * k(18)} {cy + k(5 + dy + tilt)}" '
                f'stroke="{line}" stroke-width="{k(.9)}" opacity=".55" stroke-linecap="round"/>'
            )
    # front paws resting on the card edge, either side of the chin
    for d in (-1, 1):
        px = cx + d * k(19)
        p.append(f'<ellipse cx="{px}" cy="{cy + k(13)}" rx="{k(8)}" ry="{k(5.5)}" fill="{fur}"/>')
        for t in (-3, 0, 3):
            p.append(
                f'<path d="M{px + k(t)} {cy + k(15)}V{cy + k(17.5)}" stroke="{fur_dark}" '
                f'stroke-width="{k(1)}" stroke-linecap="round"/>'
            )
    return "".join(p)


def sleeping_cat(cx, cy, fur, fur_dark, s=1.0, line="#3A2416"):
    k = lambda v: round(v * s, 2)
    return (
        f'<path d="M{cx + k(30)} {cy + k(4)}C{cx + k(58)} {cy + k(6)} {cx + k(52)} {cy - k(22)} {cx + k(34)} {cy - k(14)}" '
        f'fill="none" stroke="{fur}" stroke-width="{k(8)}" stroke-linecap="round"/>'
        f'<ellipse cx="{cx}" cy="{cy}" rx="{k(38)}" ry="{k(20)}" fill="{fur}"/>'
        f'<path d="M{cx - k(36)} {cy - k(6)}L{cx - k(34)} {cy - k(28)}L{cx - k(20)} {cy - k(16)}Z" fill="{fur}"/>'
        f'<path d="M{cx - k(18)} {cy - k(14)}L{cx - k(10)} {cy - k(32)}L{cx - k(2)} {cy - k(14)}Z" fill="{fur}"/>'
        f'<ellipse cx="{cx - k(18)}" cy="{cy - k(4)}" rx="{k(20)}" ry="{k(16)}" fill="{fur}"/>'
        f'<path d="M{cx - k(28)} {cy - k(4)}q{k(4)} {k(3)} {k(8)} 0M{cx - k(14)} {cy - k(4)}q{k(4)} {k(3)} {k(8)} 0" '
        f'fill="none" stroke="{line}" stroke-width="{k(1.6)}" stroke-linecap="round"/>'
        f'<path d="M{cx + k(4)} {cy - k(16)}q{k(4)} {k(10)} 0 {k(20)}M{cx + k(14)} {cy - k(17)}q{k(4)} {k(10)} 0 {k(22)}" '
        f'fill="none" stroke="{fur_dark}" stroke-width="{k(2.4)}" stroke-linecap="round"/>'
    )


def dog(cx, cy, fur, ear, muzzle, eyes="open", s=1.0, line="#1F1410"):
    k = lambda v: round(v * s, 2)
    p = []
    p.append(f'<ellipse cx="{cx}" cy="{cy + k(40)}" rx="{k(30)}" ry="{k(26)}" fill="{fur}"/>')
    # floppy ears behind the head edges
    for d in (-1, 1):
        p.append(
            f'<ellipse cx="{cx + d * k(24)}" cy="{cy + k(2)}" rx="{k(9)}" ry="{k(19)}" fill="{ear}" '
            f'transform="rotate({d * 18} {cx + d * k(24)} {cy + k(2)})"/>'
        )
    p.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{k(24)}" ry="{k(22)}" fill="{fur}"/>')
    # blaze + muzzle
    p.append(f'<path d="M{cx - k(3)} {cy - k(21)}Q{cx} {cy - k(23)} {cx + k(3)} {cy - k(21)}L{cx + k(5)} {cy + k(2)}H{cx - k(5)}Z" fill="{muzzle}"/>')
    p.append(f'<ellipse cx="{cx}" cy="{cy + k(9)}" rx="{k(13)}" ry="{k(10)}" fill="{muzzle}"/>')
    # eyes
    for d in (-1, 1):
        ex, ey = cx + d * k(9.5), cy - k(3)
        if eyes == "open":
            p.append(f'<circle cx="{ex}" cy="{ey}" r="{k(3.6)}" fill="{line}"/>')
            p.append(f'<circle cx="{ex + k(1.2)}" cy="{ey - k(1.3)}" r="{k(1.3)}" fill="#FFFFFF"/>')
        else:
            p.append(
                f'<path d="M{ex - k(4)} {ey}Q{ex} {ey + k(3.6)} {ex + k(4)} {ey}" fill="none" '
                f'stroke="{line}" stroke-width="{k(2)}" stroke-linecap="round"/>'
            )
    # nose, mouth, tongue
    p.append(f'<ellipse cx="{cx}" cy="{cy + k(4)}" rx="{k(5.2)}" ry="{k(3.8)}" fill="{line}"/>')
    p.append(f'<ellipse cx="{cx - k(1.5)}" cy="{cy + k(2.8)}" rx="{k(1.6)}" ry="{k(.9)}" fill="#FFFFFF" opacity=".7"/>')
    p.append(
        f'<path d="M{cx} {cy + k(8)}V{cy + k(11)}M{cx - k(6)} {cy + k(11)}Q{cx - k(3)} {cy + k(14)} {cx} {cy + k(11)}'
        f'Q{cx + k(3)} {cy + k(14)} {cx + k(6)} {cy + k(11)}" fill="none" stroke="{line}" '
        f'stroke-width="{k(1.4)}" stroke-linecap="round"/>'
    )
    if eyes == "open":
        p.append(f'<path d="M{cx - k(3.5)} {cy + k(13)}h{k(7)}v{k(4)}a{k(3.5)} {k(3.5)} 0 0 1 {-k(7)} 0z" fill="#F47C8A"/>')
    # cheeks
    for d in (-1, 1):
        p.append(f'<ellipse cx="{cx + d * k(15)}" cy="{cy + k(8)}" rx="{k(4)}" ry="{k(2.6)}" fill="#FF8FA3" opacity=".4"/>')
    # paws on the card edge, either side of the chin
    for d in (-1, 1):
        px = cx + d * k(19)
        p.append(f'<ellipse cx="{px}" cy="{cy + k(14)}" rx="{k(8.5)}" ry="{k(5.5)}" fill="{muzzle}"/>')
        for t in (-3, 0, 3):
            p.append(
                f'<path d="M{px + k(t)} {cy + k(16)}V{cy + k(18.5)}" stroke="{ear}" '
                f'stroke-width="{k(1)}" stroke-linecap="round" opacity=".7"/>'
            )
    return "".join(p)


def zzz(x, y, color):
    out = []
    for i, s in enumerate((1, .8, .6)):
        zx, zy = x + i * 9, y - i * 9
        out.append(
            f'<path d="M{zx} {zy}h{6 * s}l{-6 * s} {6 * s}h{6 * s}" fill="none" stroke="{color}" '
            f'stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" opacity="{.95 - i * .2:.2f}"/>'
        )
    return "".join(out)


def cloud(x, y, s, color, op):
    return (
        f'<g fill="{color}" opacity="{op}" transform="translate({x} {y}) scale({s})">'
        '<ellipse cx="0" cy="0" rx="22" ry="9"/><circle cx="-8" cy="-6" r="9"/>'
        '<circle cx="6" cy="-9" r="11"/></g>'
    )


def moon(x, y, r, color, sky):
    return (
        f'<circle cx="{x}" cy="{y}" r="{r}" fill="{color}"/>'
        f'<circle cx="{x + r * .45}" cy="{y - r * .3}" r="{r * .9}" fill="{sky}"/>'
    )


def waves(color, op, base, amp, n=4):
    out = []
    for i in range(n):
        y = base + i * 22
        d = f"M-20 {y}"
        for j in range(6):
            x0 = -20 + j * 80
            d += f" Q{x0 + 20} {y - amp} {x0 + 40} {y} T{x0 + 80} {y}"
        out.append(f'<path d="{d}" fill="none" stroke="{color}" stroke-width="2" opacity="{op - i * .04:.2f}" stroke-linecap="round"/>')
    return "".join(out)


def ribbon(y, amp, color_id, op, thick=38, phase=0):
    top = f"M-20 {y}"
    bottom = ""
    pts = [(-20 + i * 60, y + (amp if (i + phase) % 2 else -amp)) for i in range(9)]
    top = f"M{pts[0][0]} {pts[0][1]}"
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        top += f" Q{x0 + 30} {y0} {(x0 + x1) / 2} {(y0 + y1) / 2}"
    top += f" L{pts[-1][0]} {pts[-1][1] + thick}"
    for (x0, y0), (x1, y1) in zip(reversed(pts), list(reversed(pts))[1:]):
        bottom += f" Q{x0 - 30} {y0 + thick * 1.4} {(x0 + x1) / 2} {(y0 + y1) / 2 + thick}"
    return f'<path d="{top}{bottom} Z" fill="url(#{color_id})" opacity="{op}"/>'


# ----------------------------------------------------------------- scenes

scenes = {}

# Ocean: deep-to-bright blue diagonal, soft light, gentle wave lines.
scenes["ocean_day"] = svg(
    [linear("bg", [(0, "#0369A1"), (.5, "#0EA5E9"), (1, "#67E8F9")], 0, 0, 1, 1),
     glow("g1", "#FFFFFF", .55), glow("g2", "#22D3EE", .8), glow("g3", "#1E40AF", .5)],
    [rect("url(#bg)"), blob(330, 30, 120, 90, "g1"), blob(70, 210, 160, 90, "g2"),
     blob(40, 20, 120, 80, "g3"), waves("#FFFFFF", .32, 150, 7),
     sparkle(300, 70, .9, "#FFFFFF", .8), sparkle(190, 45, .6, "#FFFFFF", .7),
     sparkle(370, 110, .5, "#FFFFFF", .6)],
)
scenes["ocean_night"] = svg(
    [linear("bg", [(0, "#020B1F"), (.55, "#0B2545"), (1, "#0E4D64")], 0, 0, 1, 1),
     glow("g1", "#22D3EE", .35), glow("g2", "#1D4ED8", .45), glow("m", "#E0F2FE", .5)],
    [rect("url(#bg)"), blob(80, 210, 170, 90, "g1"), blob(340, 40, 140, 90, "g2"),
     stars(11, 55, y_max=140), blob(300, 60, 50, 50, "m"),
     moon(300, 60, 14, "#E0F2FE", "#0D2D55"), waves("#7DD3FC", .25, 150, 7)],
)

# Pastel: cotton-candy mesh of pink, lilac, sky and butter.
scenes["pastel_day"] = svg(
    [linear("bg", [(0, "#FBCFE8"), (.5, "#DDD6FE"), (1, "#BAE6FD")], 0, 0, 1, 1),
     glow("g1", "#F9A8D4", .9), glow("g2", "#C4B5FD", .85), glow("g3", "#FDE68A", .8),
     glow("g4", "#A5F3FC", .8)],
    [rect("url(#bg)"), blob(50, 40, 170, 120, "g1"), blob(300, 130, 170, 120, "g2"),
     blob(360, 10, 110, 80, "g3"), blob(140, 230, 170, 90, "g4"),
     sparkle(220, 50, .8, "#FFFFFF", .9), sparkle(350, 85, .6, "#FFFFFF", .85),
     sparkle(130, 30, .5, "#FFFFFF", .8), sparkle(260, 120, .45, "#FFFFFF", .7)],
)
scenes["pastel_night"] = svg(
    [linear("bg", [(0, "#1E1B4B"), (.5, "#2E1065"), (1, "#0C4A6E")], 0, 0, 1, 1),
     glow("g1", "#DB2777", .5), glow("g2", "#7C3AED", .6), glow("g3", "#0EA5E9", .45)],
    [rect("url(#bg)"), blob(50, 40, 170, 120, "g1"), blob(300, 130, 170, 120, "g2"),
     blob(140, 230, 170, 90, "g3"), stars(23, 45, y_max=160),
     sparkle(220, 50, .7, "#F5D0FE", .8), sparkle(350, 85, .5, "#F5D0FE", .7)],
)

# Aurora: northern-lights ribbons, built from soft glows along a wave.
import math


def aurora(y, amp, gid, n=7, rx=70, ry=16, phase=0.0):
    out = []
    for i in range(n):
        x = -30 + i * (460 / (n - 1))
        yy = y + amp * math.sin(i * 0.9 + phase)
        tilt = math.degrees(math.atan(amp * 0.9 * math.cos(i * 0.9 + phase) / (460 / (n - 1)))) 
        out.append(
            f'<ellipse cx="{x:.1f}" cy="{yy:.1f}" rx="{rx}" ry="{ry}" fill="url(#{gid})" '
            f'transform="rotate({tilt:.1f} {x:.1f} {yy:.1f})"/>'
        )
    return "".join(out)


scenes["aurora_day"] = svg(
    [linear("bg", [(0, "#ECFDF5"), (.5, "#D5FAF1"), (1, "#E6E9FF")]),
     glow("a1", "#34D399", .55), glow("a2", "#818CF8", .5), glow("a3", "#2DD4BF", .45),
     glow("g1", "#FFFFFF", .8)],
    [rect("url(#bg)"), aurora(45, 18, "a1"), aurora(90, 22, "a2", phase=1.4, ry=20),
     aurora(150, 16, "a3", phase=2.6, rx=80), blob(330, 40, 110, 70, "g1"),
     sparkle(80, 50, .6, "#FFFFFF", .9), sparkle(330, 95, .5, "#FFFFFF", .9)],
)
scenes["aurora_night"] = svg(
    [linear("bg", [(0, "#020617"), (.6, "#0B1B3A"), (1, "#0F2A2E")]),
     glow("a1", "#34D399", .7), glow("a2", "#A78BFA", .55), glow("a3", "#22D3EE", .5)],
    [rect("url(#bg)"), stars(37, 70, y_max=H), aurora(45, 18, "a1"),
     aurora(90, 22, "a2", phase=1.4, ry=20), aurora(150, 16, "a3", phase=2.6, rx=80),
     '<path d="M0 250L0 205L50 175L95 200L150 160L205 198L260 170L320 205L360 185L400 200L400 250Z" fill="#020617" opacity=".9"/>'],
)

# Kitty: peach-pink with paw prints; a tabby peeks over the calendar.
paws_light = scatter(5, 26, lambda r, x, y: paw(x, y, r.uniform(.7, 1.1), r.uniform(-40, 40), "#C97B6B", .22), AVOID)
scenes["kitty_day"] = svg(
    [linear("bg", [(0, "#FFE8D6"), (1, "#FFD1DC")]), glow("g1", "#FFF4C2", .9),
     glow("g2", "#FFB8C8", .6)],
    [rect("url(#bg)"), blob(70, 40, 150, 100, "g1"), blob(340, 200, 160, 100, "g2"),
     paws_light, heart(300, 70, 1.3, "#F27C95", .6), heart(190, 60, .9, "#F27C95", .45),
     heart(360, 125, 1, "#F27C95", .5),
     sleeping_cat(130, 205, "#F5B97A", "#D98C4A", 1.1),
     cat(PEEK_X, PEEK_Y, "#F5B97A", "#D98C4A", "#FFC2CF", "open", PEEK_S)],
)
paws_dark = scatter(6, 22, lambda r, x, y: paw(x, y, r.uniform(.7, 1.1), r.uniform(-40, 40), "#C4B5FD", .14), AVOID)
scenes["kitty_night"] = svg(
    [linear("bg", [(0, "#1E1B3A"), (1, "#3B2F5C")]), glow("m", "#FFF1C1", .45)],
    [rect("url(#bg)"), stars(41, 45, y_max=150), paws_dark,
     blob(330, 55, 60, 60, "m"), moon(330, 55, 16, "#FFF1C1", "#262147"),
     sleeping_cat(130, 205, "#5A4E8A", "#463C72", 1.1, "#1E1B3A"),
     cat(PEEK_X, PEEK_Y, "#6A5C9E", "#4E4380", "#9C8BD1", "glow", PEEK_S, line="#120F24")],
)

# Puppy: sky, clouds, bones and paws; a beagle peeks over the calendar.
bones_light = scatter(8, 16, lambda r, x, y: (bone if r.random() < .5 else paw)(
    x, y, r.uniform(.6, .9), r.uniform(-50, 50), "#5B8DEF", .2), AVOID)
scenes["puppy_day"] = svg(
    [linear("bg", [(0, "#BFE3FF"), (1, "#E6F4FF")]), glow("sun", "#FFF3B0", .95)],
    [rect("url(#bg)"), blob(340, 30, 110, 90, "sun"), '<circle cx="340" cy="30" r="18" fill="#FFE27A"/>',
     cloud(70, 55, 1.2, "#FFFFFF", .9), cloud(180, 30, .8, "#FFFFFF", .8), cloud(320, 95, .9, "#FFFFFF", .85),
     bones_light,
     '<path d="M0 250L0 190Q100 150 200 185T400 175L400 250Z" fill="#9AD17A"/>',
     '<path d="M0 250L0 215Q120 185 260 212T400 205L400 250Z" fill="#7CC160"/>',
     dog(PEEK_X, PEEK_Y, "#E0A96D", "#8B5A2B", "#FFF8EE", "open", PEEK_S)],
)
bones_dark = scatter(9, 14, lambda r, x, y: (bone if r.random() < .5 else paw)(
    x, y, r.uniform(.6, .9), r.uniform(-50, 50), "#93C5FD", .12), AVOID)
scenes["puppy_night"] = svg(
    [linear("bg", [(0, "#0B1B3A"), (1, "#1E3A8A")]), glow("m", "#FEF3C7", .4)],
    [rect("url(#bg)"), stars(53, 50, y_max=150), bones_dark,
     blob(60, 50, 55, 55, "m"), moon(60, 50, 15, "#FEF3C7", "#10224A"),
     '<path d="M0 250L0 190Q100 150 200 185T400 175L400 250Z" fill="#1F4E3D"/>',
     '<path d="M0 250L0 215Q120 185 260 212T400 205L400 250Z" fill="#183E31"/>',
     dog(PEEK_X, PEEK_Y, "#B88553", "#6B4423", "#E9DCC8", "sleepy", PEEK_S),
     zzz(PEEK_X + 22, PEEK_Y - 18, "#FEF3C7")],
)


# ------------------------------------------------- Angkor and Buddha scenes
# The hero object stands right of the app title, fully above the month
# card's top edge (y ~137), where the search button used to be.
HERO_X, HERO_BASE = 271, 136
CARD_EDGE = 137


def tower(x, y0, w, h, fill, stroke=None, detail=None):
    d = (f"M{x - w / 2} {y0}L{x - w / 2} {y0 - .3 * h}"
         f"C{x - w / 2} {y0 - .65 * h} {x - .15 * w} {y0 - .8 * h} {x} {y0 - h}"
         f"C{x + .15 * w} {y0 - .8 * h} {x + w / 2} {y0 - .65 * h} {x + w / 2} {y0 - .3 * h}"
         f"L{x + w / 2} {y0}Z")
    st = f' stroke="{stroke}" stroke-width=".9" stroke-linejoin="round"' if stroke else ""
    out = f'<path d="{d}" fill="{fill}"{st}/>'
    if detail:
        for t in (.3, .46, .6, .72):
            half = w / 2 * (1 - (t - .3) * 1.25) if t > .3 else w / 2
            out += (f'<path d="M{x - half:.2f} {y0 - t * h:.2f}H{x + half:.2f}" stroke="{detail}" '
                    f'stroke-width=".7" opacity=".55"/>')
    return out


def angkor(cx, base, fill, stroke=None, detail=None, s=1.0):
    k = lambda v: v * s
    st = f' stroke="{stroke}" stroke-width=".9"' if stroke else ""
    out = []
    # outer towers, galleries, inner towers, central tower (back to front)
    for d in (-1, 1):
        out.append(tower(cx + d * k(24), base - k(12), k(8), k(17), fill, stroke, detail))
    out.append(f'<rect x="{cx - k(30)}" y="{base - k(19)}" width="{k(60)}" height="{k(8)}" fill="{fill}"{st}/>')
    for d in (-1, 1):
        out.append(tower(cx + d * k(13), base - k(14), k(10), k(24), fill, stroke, detail))
    out.append(tower(cx, base - k(15), k(12), k(34), fill, stroke, detail))
    out.append(f'<rect x="{cx - k(26)}" y="{base - k(15)}" width="{k(52)}" height="{k(5)}" fill="{fill}"{st}/>')
    out.append(f'<rect x="{cx - k(33)}" y="{base - k(10)}" width="{k(66)}" height="{k(5)}" fill="{fill}"{st}/>')
    out.append(f'<rect x="{cx - k(38)}" y="{base - k(5)}" width="{k(76)}" height="{k(5)}" fill="{fill}"{st}/>')
    if detail:  # gallery windows
        for i in range(-5, 6):
            out.append(f'<rect x="{cx + i * k(5) - .6:.2f}" y="{base - k(9):.2f}" width="1.2" height="{k(3):.2f}" fill="{detail}" opacity=".5"/>')
    return "".join(out)


def palm(x, base, h, fill, lean=0.0):
    tx, ty = x + lean * h, base - h
    out = [f'<path d="M{x} {base}Q{x + lean * h * .3} {base - h * .5} {tx} {ty}" fill="none" '
           f'stroke="{fill}" stroke-width="{max(1.4, h * .07):.2f}" stroke-linecap="round"/>']
    for ang, ln in ((-160, .55), (-130, .6), (-95, .45), (-60, .6), (-25, .55), (-200, .4), (20, .4)):
        import math
        a = math.radians(ang)
        ex, ey = tx + math.cos(a) * h * ln, ty + math.sin(a) * h * ln + h * .18
        mx, my = tx + math.cos(a) * h * ln * .5, ty + math.sin(a) * h * ln * .5 - h * .08
        out.append(f'<path d="M{tx:.1f} {ty:.1f}Q{mx:.1f} {my:.1f} {ex:.1f} {ey:.1f}" fill="none" '
                   f'stroke="{fill}" stroke-width="{max(1.2, h * .06):.2f}" stroke-linecap="round"/>')
    return "".join(out)


def water(top, bottom, gid):
    return f'<rect x="0" y="{CARD_EDGE}" width="{W}" height="{H - CARD_EDGE}" fill="url(#{gid})"/>'


def reflection(svg_part, axis, op):
    return (f'<g opacity="{op}" transform="translate(0 {2 * axis}) scale(1 -1)">{svg_part}</g>')


def angkor_scene(sky, water_stops, fill, glow_c, sky_obj, palms_c, stroke=None, detail=None,
                 star_seed=None, reflect=.25):
    temple = angkor(HERO_X, HERO_BASE, fill, stroke, detail)
    # Palms on the left only: the settings button covers the right side.
    trees = palm(HERO_X - 45, HERO_BASE, 19, palms_c, -.15) + palm(HERO_X - 38, HERO_BASE, 13, palms_c, .1)
    return svg(
        [linear("sky", sky), linear("wat", water_stops), glow("g", glow_c, .8)],
        [rect("url(#sky)"), stars(star_seed, 60, y_max=CARD_EDGE) if star_seed else "",
         blob(sky_obj[0], sky_obj[1], 70, 50, "g"), sky_obj[2],
         f'<rect x="0" y="{HERO_BASE}" width="{W}" height="{H - HERO_BASE}" fill="url(#wat)"/>',
         reflection(temple + trees, HERO_BASE, reflect), trees, temple],
    )


sun = lambda x, y, r, c: f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}"/>'

scenes["khmerLight_day"] = angkor_scene(
    [(0, "#C7D2FE"), (.55, "#F5D0E6"), (1, "#FDE1C4")], [(0, "#F3D9EC"), (1, "#E9DDF7")],
    "#5B4B8A", "#FFF1C1", (200, 70, sun(200, 70, 13, "#FFE6A8")), "#463A72", detail="#C9BCEB")
night = angkor_scene(
    [(0, "#070D22"), (1, "#1B2652")], [(0, "#141D44"), (1, "#070D22")],
    "#0E1633", "#FFF1C1", (200, 58, moon(200, 58, 11, "#FFF1C1", "#0C1430")), "#0A0F26",
    stroke="#E5B64A", detail="#E5B64A", star_seed=61, reflect=.3)
scenes["khmerLight_night"] = scenes["khmerNight_day"] = scenes["khmerNight_night"] = night
sunset = angkor_scene(
    [(0, "#6B4FA0"), (.5, "#E9708A"), (1, "#FDBA74")], [(0, "#F4A38A"), (1, "#C86A8E")],
    "#4A2848", "#FFD7A0", (HERO_X, HERO_BASE - 22, sun(HERO_X, HERO_BASE - 22, 17, "#FFD7A0")),
    "#3B1F3A", detail="#8C5A7E")
scenes["sunset_day"] = scenes["sunset_night"] = sunset
scenes["royal_day"] = angkor_scene(
    [(0, "#FBF5E6"), (1, "#EBD9A6")], [(0, "#E6D3A0"), (1, "#F4EAD0")],
    "#0E2A6B", "#FFFFFF", (200, 62, sun(200, 62, 12, "#F2C766")), "#0B1E57",
    stroke="#D59A2E", detail="#F2C766")
scenes["royal_night"] = angkor_scene(
    [(0, "#061232"), (1, "#13307A")], [(0, "#0E2560"), (1, "#061232")],
    "#0B1E57", "#F7DA86", (200, 58, moon(200, 58, 11, "#F7DA86", "#081740")), "#061232",
    stroke="#F2C766", detail="#F2C766", star_seed=71, reflect=.3)


def buddha(cx, base, s, fill, line):
    k = lambda v: round(v * s, 2)
    p = []
    # lotus throne
    for i in range(-3, 4):
        x = cx + i * k(7)
        p.append(f'<ellipse cx="{x}" cy="{base - k(4)}" rx="{k(4.6)}" ry="{k(6.5)}" fill="{fill}" '
                 f'transform="rotate({i * 9} {x} {base - k(4)})"/>')
    p.append(f'<rect x="{cx - k(26)}" y="{base - k(2)}" width="{k(52)}" height="{k(2.5)}" rx="{k(1.2)}" fill="{fill}"/>')
    # crossed legs, robe, hands
    p.append(f'<ellipse cx="{cx}" cy="{base - k(11)}" rx="{k(23)}" ry="{k(7)}" fill="{fill}"/>')
    p.append(f'<path d="M{cx - k(13)} {base - k(31)}Q{cx - k(18)} {base - k(21)} {cx - k(20)} {base - k(12)}'
             f'L{cx + k(20)} {base - k(12)}Q{cx + k(18)} {base - k(21)} {cx + k(13)} {base - k(31)}'
             f'Q{cx} {base - k(35)} {cx - k(13)} {base - k(31)}Z" fill="{fill}"/>')
    p.append(f'<path d="M{cx - k(11)} {base - k(30)}Q{cx + k(2)} {base - k(22)} {cx + k(14)} {base - k(14)}" '
             f'fill="none" stroke="{line}" stroke-width="{k(1)}" opacity=".6" stroke-linecap="round"/>')
    p.append(f'<path d="M{cx - k(17)} {base - k(10)}Q{cx} {base - k(6)} {cx + k(17)} {base - k(10)}" '
             f'fill="none" stroke="{line}" stroke-width="{k(.9)}" opacity=".5" stroke-linecap="round"/>')
    p.append(f'<ellipse cx="{cx}" cy="{base - k(14.5)}" rx="{k(7)}" ry="{k(2.8)}" fill="none" '
             f'stroke="{line}" stroke-width="{k(.9)}" opacity=".6"/>')
    # neck, head, ears, ushnisha with flame
    p.append(f'<rect x="{cx - k(3.2)}" y="{base - k(36)}" width="{k(6.4)}" height="{k(5)}" fill="{fill}"/>')
    p.append(f'<ellipse cx="{cx}" cy="{base - k(41)}" rx="{k(6.4)}" ry="{k(7.4)}" fill="{fill}"/>')
    for d in (-1, 1):
        p.append(f'<ellipse cx="{cx + d * k(6.6)}" cy="{base - k(39.5)}" rx="{k(1.6)}" ry="{k(4.6)}" fill="{fill}"/>')
    p.append(f'<ellipse cx="{cx}" cy="{base - k(48)}" rx="{k(4.2)}" ry="{k(3)}" fill="{fill}"/>')
    p.append(f'<path d="M{cx - k(2)} {base - k(50)}Q{cx - k(.5)} {base - k(56)} {cx} {base - k(60)}'
             f'Q{cx + k(.5)} {base - k(56)} {cx + k(2)} {base - k(50)}Z" fill="{fill}"/>')
    # serene closed eyes
    for d in (-1, 1):
        ex = cx + d * k(2.6)
        p.append(f'<path d="M{ex - k(1.6)} {base - k(41.5)}Q{ex} {base - k(40.5)} {ex + k(1.6)} {base - k(41.5)}" '
                 f'fill="none" stroke="{line}" stroke-width="{k(.6)}" opacity=".7" stroke-linecap="round"/>')
    return "".join(p)


def rays(cx, cy, n, r0, r1, color, op):
    import math
    out = []
    for i in range(n):
        a = math.radians(i * 360 / n)
        a1, a2 = a - .05, a + .05
        pts = [(cx + math.cos(a1) * r0, cy + math.sin(a1) * r0), (cx + math.cos(a) * r1, cy + math.sin(a) * r1),
               (cx + math.cos(a2) * r0, cy + math.sin(a2) * r0)]
        out.append('<path d="M' + 'L'.join(f"{x:.1f} {y:.1f}" for x, y in pts) + f'Z" fill="{color}" opacity="{op}"/>')
    return "".join(out)


def bodhi(x, y, s, rot, color, op):
    return (f'<path d="M0 -9C-7 -9 -9 -1 -5 4C-3 7 -1 9 0 15C1 9 3 7 5 4C9 -1 7 -9 0 -9Z" fill="{color}" '
            f'opacity="{op}" transform="translate({x} {y}) rotate({rot}) scale({s})"/>')


def lotus_flower(x, y, s, color, op):
    out = []
    for ang in (-50, -25, 0, 25, 50):
        out.append(f'<ellipse cx="0" cy="-7" rx="3.4" ry="8" transform="rotate({ang})"/>')
    return f'<g fill="{color}" opacity="{op}" transform="translate({x} {y}) scale({s})">{"".join(out)}</g>'


B_S = .77
B_HEAD = (HERO_X, HERO_BASE - 41 * B_S)
leaves_d = scatter(91, 14, lambda r, x, y: bodhi(x, y, r.uniform(.5, .8), r.uniform(-50, 50), "#7FA650", .28),
                   (HERO_X - 40, 70, HERO_X + 40, HERO_BASE + 2))
scenes["buddha_day"] = svg(
    [linear("sky", [(0, "#FFF6DF"), (.6, "#FCE0A2"), (1, "#F8C77A")]),
     linear("gold", [(0, "#F6C453"), (1, "#C98A1B")]), glow("halo", "#FFFBEA", 1), glow("g2", "#FFE7B0", .8),
     linear("wat", [(0, "#F7D9A0"), (1, "#F2E6C8")])],
    [rect("url(#sky)"), blob(80, 40, 140, 90, "g2"), leaves_d,
     rays(*B_HEAD, 28, 16, 70, "#FFFFFF", .35), blob(B_HEAD[0], B_HEAD[1] + 6, 46, 46, "halo"),
     f'<circle cx="{B_HEAD[0]}" cy="{B_HEAD[1]}" r="{11 * B_S * 1.4:.1f}" fill="none" stroke="#E8B04A" stroke-width="1" opacity=".7"/>',
     f'<rect x="0" y="{HERO_BASE}" width="{W}" height="{H - HERO_BASE}" fill="url(#wat)"/>',
     lotus_flower(70, 190, 1.4, "#F49AB5", .7), lotus_flower(330, 205, 1.2, "#F49AB5", .6),
     buddha(HERO_X, HERO_BASE, B_S, "url(#gold)", "#8A5A0E")],
)
leaves_n = scatter(92, 12, lambda r, x, y: bodhi(x, y, r.uniform(.5, .8), r.uniform(-50, 50), "#F6C453", .14),
                   (HERO_X - 40, 70, HERO_X + 40, HERO_BASE + 2))
scenes["buddha_night"] = svg(
    [linear("sky", [(0, "#140B24"), (.6, "#2A1745"), (1, "#3B1E54")]),
     linear("gold", [(0, "#FFD978"), (1, "#D69A2A")]), glow("halo", "#FFE9A8", .9),
     linear("wat", [(0, "#2A1745"), (1, "#140B24")])],
    [rect("url(#sky)"), stars(93, 50, y_max=CARD_EDGE), leaves_n,
     rays(*B_HEAD, 28, 16, 70, "#FFE9A8", .16), blob(B_HEAD[0], B_HEAD[1] + 6, 50, 50, "halo"),
     f'<circle cx="{B_HEAD[0]}" cy="{B_HEAD[1]}" r="{11 * B_S * 1.4:.1f}" fill="none" stroke="#FFD978" stroke-width="1" opacity=".7"/>',
     f'<rect x="0" y="{HERO_BASE}" width="{W}" height="{H - HERO_BASE}" fill="url(#wat)"/>',
     lotus_flower(70, 190, 1.4, "#F49AB5", .45), lotus_flower(330, 205, 1.2, "#F49AB5", .4),
     buddha(HERO_X, HERO_BASE, B_S, "url(#gold)", "#7A4A06")],
)

OUT.mkdir(parents=True, exist_ok=True)
for name, content in scenes.items():
    (OUT / f"{name}.svg").write_text(content)
    print(name, len(content))
