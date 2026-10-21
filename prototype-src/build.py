#!/usr/bin/env python3
"""Rebuild site/prototype/index.html from the files in this folder. Run:  python prototype-src/build.py"""
from pathlib import Path
root = Path(__file__).parent
src = sorted(root.glob("0*"))
parts = [p.read_text(encoding="utf-8") for p in src]
head_and_styles = parts[0]
cut = head_and_styles.index('<div id="app">')
head, body_start = head_and_styles[:cut], head_and_styles[cut:]
html = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<link rel="icon" href="assets/favicon/favicon.ico" sizes="any">
<link rel="icon" type="image/png" sizes="32x32" href="assets/favicon/favicon-32.png">
<link rel="apple-touch-icon" href="assets/favicon/favicon-180.png">
<style>:root{{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}}body{{margin:0;font-size:14px}}img{{max-width:100%}}[hidden]{{display:none!important}}</style>
{head}</head>
<body>
{body_start}
{''.join(parts[1:])}
</body>
</html>
"""
(root.parent / "site" / "prototype" / "index.html").write_text(html, encoding="utf-8")
print("index.html rebuilt:", len(html)//1024, "KB")
