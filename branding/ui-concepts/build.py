#!/usr/bin/env python3
"""Builds index.html (UI concepts) from template.html + live data from the local API + the logo SVG.
Run with the API on :3000:  python3 branding/ui-concepts/build.py"""
import json, os, urllib.request
HERE = os.path.dirname(os.path.abspath(__file__))
API = os.environ.get('API', 'http://localhost:3000/api/v1')
get = lambda path: json.load(urllib.request.urlopen(API + path))['data']
data = {'month': get('/calendar/months/2026/11'), 'events': get('/events?from=2026-01-01&to=2026-12-31')}
logo = open(os.path.join(HERE, '..', 'logo', 'khmer-calendar-icon.svg')).read().strip()
logo = logo.replace('<svg ', '<svg width="100%" height="100%" ', 1)
html = open(os.path.join(HERE, 'template.html')).read()
html = html.replace('/*__DATA__*/', json.dumps(data, ensure_ascii=False)).replace('<!--LOGO-->', logo)
open(os.path.join(HERE, 'index.html'), 'w').write(html)
print('wrote index.html with', len(data['month']['days']), 'days and', len(data['events']), 'events')
