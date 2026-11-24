#!/usr/bin/env python3
"""Builds index.html from template.html + data.json (Nov 2026 calendar) + the Kbach Kor logo."""
import json, os
HERE = os.path.dirname(os.path.abspath(__file__))
data = json.load(open(os.path.join(HERE, 'data.json')))
logo = open(os.path.join(HERE, '..', 'logo', 'khmer-calendar-icon.svg')).read().strip().replace('<svg ', '<svg width="100%" height="100%" ', 1)
html = open(os.path.join(HERE, 'template.html')).read().replace('/*__DATA__*/', json.dumps(data, ensure_ascii=False)).replace('<!--LOGO-->', logo)
open(os.path.join(HERE, 'index.html'), 'w').write(html)
print('wrote index.html')
