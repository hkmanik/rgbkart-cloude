# Draws the 20 RGBKart category pictures (flat illustrations, no text) as SVG files.
# Run:  python3 make_category_art.py   → writes ../../site/assets/categories/<slug>.svg
# Canvas 400×300. The main objects stay inside the middle (x 60–340, y 50–255) so a 16:9 crop still shows them.
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'site', 'assets', 'categories')
os.makedirs(OUT, exist_ok=True)

def page(bg1, bg2, body, blob='#ffffff'):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300" width="400" height="300">
<defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{bg1}"/><stop offset="1" stop-color="{bg2}"/></linearGradient></defs>
<rect width="400" height="300" fill="url(#bg)"/>
<circle cx="335" cy="55" r="70" fill="{blob}" opacity=".35"/><circle cx="55" cy="250" r="55" fill="{blob}" opacity=".3"/>
<circle cx="80" cy="70" r="6" fill="{blob}" opacity=".7"/><circle cx="320" cy="235" r="8" fill="{blob}" opacity=".6"/><circle cx="355" cy="150" r="4" fill="{blob}" opacity=".8"/>
<ellipse cx="200" cy="258" rx="135" ry="12" fill="#000" opacity=".10"/>
{body}
</svg>'''

ART = {}

# 1 Mobiles & Tablets: tablet behind, phone in front
ART['mobiles-and-tablets'] = page('#FFE3D3', '#FFC9A8', '''
<rect x="95" y="62" width="150" height="192" rx="16" fill="#2B2D42"/><rect x="104" y="73" width="132" height="168" rx="8" fill="#8EC5FF"/>
<rect x="104" y="73" width="132" height="60" rx="8" fill="#B9DBFF"/><circle cx="170" cy="248" r="3" fill="#555"/>
<rect x="118" y="150" width="34" height="34" rx="8" fill="#F5C400"/><rect x="160" y="150" width="34" height="34" rx="8" fill="#00802B"/><rect x="118" y="192" width="34" height="34" rx="8" fill="#E30613"/>
<rect x="210" y="98" width="92" height="160" rx="16" fill="#1D1E2C"/><rect x="217" y="108" width="78" height="140" rx="10" fill="#FF8FA3"/>
<rect x="217" y="108" width="78" height="70" rx="10" fill="#FFB3C1"/><rect x="243" y="112" width="26" height="5" rx="2.5" fill="#1D1E2C"/>
<circle cx="256" cy="150" r="18" fill="#fff" opacity=".85"/><path d="M249 141 l16 9 l-16 9z" fill="#E30613"/>
<rect x="226" y="196" width="60" height="7" rx="3.5" fill="#fff" opacity=".8"/><rect x="226" y="210" width="42" height="7" rx="3.5" fill="#fff" opacity=".6"/>''', '#FFF4EC')

# 2 Computers & Laptops: monitor + laptop
ART['computers-and-laptops'] = page('#E3F7DF', '#B9EBB0', '''
<rect x="78" y="60" width="170" height="112" rx="10" fill="#26323D"/><rect x="87" y="69" width="152" height="94" rx="4" fill="#5BC0EB"/>
<path d="M87 140 l40-32 l30 22 l34-36 l48 46 v23 h-152z" fill="#2F9E44"/><circle cx="210" cy="92" r="11" fill="#F5C400"/>
<rect x="152" y="172" width="22" height="32" fill="#3D4A55"/><rect x="122" y="202" width="82" height="9" rx="4.5" fill="#3D4A55"/>
<rect x="190" y="132" width="132" height="86" rx="8" fill="#3A3F47"/><rect x="198" y="140" width="116" height="70" rx="3" fill="#E9F5FF"/>
<rect x="208" y="150" width="58" height="8" rx="4" fill="#00802B"/><rect x="208" y="166" width="90" height="6" rx="3" fill="#9FB3C8"/><rect x="208" y="178" width="76" height="6" rx="3" fill="#9FB3C8"/><rect x="208" y="190" width="40" height="10" rx="3" fill="#E30613"/>
<path d="M172 218 h168 l-12 20 h-144z" fill="#C9CED6"/><rect x="236" y="222" width="40" height="5" rx="2.5" fill="#9AA1AB"/>''', '#F4FFF1')

# 3 Gaming & RGB Setup: RGB keyboard + gamepad
ART['gaming-and-rgb-setup'] = page('#E5DBFF', '#C3AEFF', '''
<rect x="70" y="170" width="260" height="62" rx="10" fill="#1E1B2E"/>
<rect x="70" y="226" width="260" height="6" rx="3" fill="url(#rgb)"/>
<defs><linearGradient id="rgb" x1="0" x2="1"><stop offset="0" stop-color="#E30613"/><stop offset=".33" stop-color="#F5C400"/><stop offset=".66" stop-color="#00C853"/><stop offset="1" stop-color="#2979FF"/></linearGradient></defs>
''' + ''.join(f'<rect x="{82 + i * 20}" y="{180 + r * 14}" width="16" height="10" rx="2" fill="{["#FF5C8A", "#FFD23F", "#3EE07A", "#4DA3FF", "#B583FF"][(i + r) % 5]}"/>' for r in range(3) for i in range(12)) + '''
<path d="M118 92 q-32 0 -40 46 q-6 34 18 36 q14 0 24 -22 h80 q10 22 24 22 q24 -2 18 -36 q-8 -46 -40 -46z" fill="#2D2A44"/>
<circle cx="128" cy="124" r="15" fill="#3B3757"/><rect x="124" y="112" width="8" height="24" rx="2" fill="#B583FF"/><rect x="116" y="120" width="24" height="8" rx="2" fill="#B583FF"/>
<circle cx="206" cy="114" r="7" fill="#FF5C8A"/><circle cx="222" cy="128" r="7" fill="#3EE07A"/><circle cx="190" cy="128" r="7" fill="#4DA3FF"/><circle cx="206" cy="142" r="7" fill="#FFD23F"/>
<circle cx="150" cy="150" r="9" fill="#151322"/><circle cx="180" cy="150" r="9" fill="#151322"/>
<path d="M270 70 l8 16 l18 3 l-13 12 l3 18 l-16-9 l-16 9 l3-18 l-13-12 l18-3z" fill="#F5C400"/>''', '#F3EEFF')

# 4 TV, Audio & Video: TV + speaker + headphones
ART['tv-audio-and-video'] = page('#D7F3FA', '#A6E1F0', '''
<rect x="70" y="62" width="200" height="128" rx="10" fill="#1F2A36"/><rect x="79" y="71" width="182" height="110" rx="4" fill="#FF9F43"/>
<circle cx="220" cy="100" r="18" fill="#FFE29A"/><path d="M79 160 q50-40 90 -10 q40 30 92 -5 v36 h-182z" fill="#00802B"/><path d="M79 172 q60-22 182 0 v9 h-182z" fill="#006622"/>
<rect x="150" y="190" width="40" height="14" fill="#2C3A47"/><rect x="118" y="202" width="104" height="10" rx="5" fill="#2C3A47"/>
<rect x="286" y="110" width="52" height="128" rx="10" fill="#34495E"/><circle cx="312" cy="140" r="12" fill="#1C2833"/><circle cx="312" cy="140" r="5" fill="#5D6D7E"/>
<circle cx="312" cy="196" r="22" fill="#1C2833"/><circle cx="312" cy="196" r="9" fill="#5D6D7E"/>
<path d="M88 236 q0-40 40-40 q40 0 40 40" fill="none" stroke="#E30613" stroke-width="9" stroke-linecap="round"/>
<rect x="78" y="226" width="22" height="30" rx="8" fill="#B3000C"/><rect x="156" y="226" width="22" height="30" rx="8" fill="#B3000C"/>''', '#EFFBFE')

# 5 Cameras & Drones: camera + drone
ART['cameras-and-drones'] = page('#FFF2C7', '#FFDF7E', '''
<rect x="82" y="128" width="150" height="104" rx="14" fill="#2E2E38"/><rect x="104" y="114" width="46" height="20" rx="5" fill="#2E2E38"/>
<rect x="82" y="150" width="150" height="14" fill="#44444F"/><rect x="198" y="136" width="20" height="10" rx="3" fill="#E30613"/>
<circle cx="157" cy="183" r="38" fill="#1B1B22"/><circle cx="157" cy="183" r="28" fill="#3A4A6B"/><circle cx="157" cy="183" r="16" fill="#1E2A44"/><circle cx="149" cy="175" r="6" fill="#9FC4FF" opacity=".8"/>
<rect x="232" y="80" width="80" height="8" rx="4" fill="#5A5A66"/><rect x="232" y="98" width="80" height="8" rx="4" fill="#5A5A66" opacity="0"/>
<rect x="250" y="88" width="44" height="26" rx="9" fill="#ECEFF4"/><circle cx="272" cy="106" r="7" fill="#2E2E38"/>
<rect x="228" y="86" width="26" height="5" rx="2.5" fill="#5A5A66"/><rect x="290" y="86" width="26" height="5" rx="2.5" fill="#5A5A66"/>
<ellipse cx="228" cy="78" rx="24" ry="4" fill="#2E2E38" opacity=".6"/><ellipse cx="316" cy="78" rx="24" ry="4" fill="#2E2E38" opacity=".6"/>
<rect x="225" y="78" width="6" height="10" fill="#5A5A66"/><rect x="313" y="78" width="6" height="10" fill="#5A5A66"/>''', '#FFFBEA')

# 6 Home Appliances: fridge + washing machine
ART['home-appliances'] = page('#E2ECFF', '#B7CCF7', '''
<rect x="92" y="52" width="104" height="200" rx="12" fill="#F4F6F9"/><rect x="92" y="52" width="104" height="200" rx="12" fill="none" stroke="#C7CDD6" stroke-width="3"/>
<line x1="94" y1="118" x2="194" y2="118" stroke="#C7CDD6" stroke-width="3"/><rect x="176" y="70" width="7" height="34" rx="3.5" fill="#9AA4B2"/><rect x="176" y="132" width="7" height="50" rx="3.5" fill="#9AA4B2"/>
<rect x="104" y="64" width="22" height="8" rx="4" fill="#00802B"/>
<rect x="210" y="120" width="112" height="132" rx="12" fill="#FFFFFF"/><rect x="210" y="120" width="112" height="132" rx="12" fill="none" stroke="#C7CDD6" stroke-width="3"/>
<rect x="210" y="120" width="112" height="26" rx="12" fill="#E9EDF3"/><circle cx="296" cy="133" r="7" fill="#E30613"/><rect x="222" y="130" width="34" height="6" rx="3" fill="#9AA4B2"/>
<circle cx="266" cy="198" r="38" fill="#C7CDD6"/><circle cx="266" cy="198" r="30" fill="#7FB3FF"/><path d="M238 205 q14-14 28 0 q14 14 28 0 v8 q-14 24 -56 0z" fill="#3D7BE0" opacity=".8"/><circle cx="256" cy="186" r="7" fill="#fff" opacity=".6"/>''', '#F2F6FF')

# 7 Kitchen Appliances: blender + rice cooker
ART['kitchen-appliances'] = page('#FFE0E0', '#FFB8B8', '''
<path d="M98 72 h76 l-10 112 h-56z" fill="#DFF3FF" opacity=".9"/><path d="M104 120 h64 l-6 64 h-52z" fill="#7BD389"/><path d="M106 140 h60 l-4 44 h-50z" fill="#4CAF50"/>
<rect x="92" y="62" width="88" height="14" rx="6" fill="#3D3D45"/><rect x="100" y="182" width="72" height="16" rx="4" fill="#C9CCD3"/>
<path d="M92 196 h88 l8 54 h-104z" fill="#E30613"/><circle cx="136" cy="224" r="10" fill="#fff"/><circle cx="136" cy="224" r="4" fill="#E30613"/>
<ellipse cx="262" cy="156" rx="72" ry="18" fill="#F4F6F9"/><rect x="190" y="156" width="144" height="86" rx="34" fill="#FFFFFF"/><ellipse cx="262" cy="156" rx="72" ry="18" fill="#E8ECF1"/>
<rect x="244" y="132" width="36" height="14" rx="7" fill="#3D3D45"/><rect x="236" y="198" width="52" height="22" rx="6" fill="#00802B"/><circle cx="250" cy="209" r="4" fill="#F5C400"/><circle cx="274" cy="209" r="4" fill="#fff"/>
<path d="M232 118 q8-14 0 -26 M262 114 q8-14 0 -26 M292 118 q8-14 0 -26" fill="none" stroke="#fff" stroke-width="5" stroke-linecap="round" opacity=".9"/>''', '#FFF2F2')

# 8 Men's Fashion: shirt on hanger + panjabi + tie
ART['men-s-fashion'] = page('#DCE7FF', '#AFC3F5', '''
<path d="M150 56 q0-12 12-12 q12 0 12 12 q0 8 -12 14" fill="none" stroke="#5A5F6B" stroke-width="5" stroke-linecap="round"/>
<path d="M162 70 l-74 30 l18 40 l20-8 v116 h72 v-116 l20 8 l18-40z" fill="#3A6FD8"/>
<path d="M140 79 l22 22 l22-22" fill="#fff"/><path d="M162 101 l-9 12 l9 86 l9 -86z" fill="#E30613"/><path d="M155 101 h14 l-7 10z" fill="#B3000C"/>
<path d="M88 100 l18 40 l14 -6 l-12 -38z" fill="#2F5BB8"/><path d="M236 100 l-18 40 l-14 -6 l12 -38z" fill="#2F5BB8"/>
<path d="M246 76 q0-12 12-12 q12 0 12 12 q0 8 -12 14" fill="none" stroke="#5A5F6B" stroke-width="5" stroke-linecap="round"/>
<path d="M258 90 l-50 22 l14 34 l12-5 v114 h48 v-114 l12 5 l14-34z" fill="#F5F0E1"/><path d="M252 96 h12 v70 h-12z" fill="#E7DFC6"/>
<circle cx="258" cy="112" r="2.6" fill="#B08D57"/><circle cx="258" cy="126" r="2.6" fill="#B08D57"/><circle cx="258" cy="140" r="2.6" fill="#B08D57"/>
<path d="M234 230 q24 10 48 0" fill="none" stroke="#C9A96E" stroke-width="4"/>''', '#EEF3FF')

# 9 Women's Fashion: dress + handbag + saree drape
ART['women-s-fashion'] = page('#FFDDEF', '#FFB0D6', '''
<path d="M140 54 q0-12 12-12 q12 0 12 12 q0 8 -12 14" fill="none" stroke="#5A5F6B" stroke-width="5" stroke-linecap="round"/>
<path d="M134 70 h36 l10 52 l46 128 h-148 l46-128z" fill="#E30613"/><path d="M134 70 h36 l4 22 h-44z" fill="#B3000C"/>
<path d="M124 122 h56 l4 12 h-64z" fill="#F5C400"/>
<path d="M96 196 q56 18 112 0" fill="none" stroke="#FF7FA8" stroke-width="5" opacity=".9"/><path d="M90 226 q62 18 124 0" fill="none" stroke="#FF7FA8" stroke-width="5" opacity=".9"/>
<path d="M248 150 q0-32 26-32 q26 0 26 32" fill="none" stroke="#7A3E1D" stroke-width="7"/>
<rect x="226" y="146" width="96" height="92" rx="14" fill="#A0522D"/><rect x="226" y="146" width="96" height="30" rx="14" fill="#8B4513"/><rect x="266" y="166" width="16" height="14" rx="3" fill="#F5C400"/>
<circle cx="110" cy="80" r="5" fill="#fff"/><circle cx="300" cy="96" r="4" fill="#fff"/>''', '#FFF0F8')

# 10 Kids & Baby: teddy + bottle + rattle
ART['kids-and-baby'] = page('#E0F7F1', '#AEE9D9', '''
<circle cx="140" cy="118" r="20" fill="#C68B59"/><circle cx="200" cy="118" r="20" fill="#C68B59"/><circle cx="140" cy="118" r="10" fill="#E8B98A"/><circle cx="200" cy="118" r="10" fill="#E8B98A"/>
<ellipse cx="170" cy="210" rx="56" ry="48" fill="#C68B59"/><ellipse cx="170" cy="216" rx="30" ry="28" fill="#E8B98A"/>
<circle cx="170" cy="148" r="42" fill="#C68B59"/><ellipse cx="170" cy="162" rx="18" ry="13" fill="#E8B98A"/><circle cx="170" cy="157" r="5" fill="#3B2A1E"/>
<circle cx="154" cy="140" r="5" fill="#3B2A1E"/><circle cx="186" cy="140" r="5" fill="#3B2A1E"/><path d="M162 168 q8 7 16 0" fill="none" stroke="#3B2A1E" stroke-width="3" stroke-linecap="round"/>
<path d="M150 186 l20 10 l20-10 l-6 16 h-28z" fill="#E30613"/>
<rect x="258" y="110" width="40" height="120" rx="16" fill="#FFFFFF"/><rect x="258" y="170" width="40" height="60" rx="16" fill="#FFF3C4"/><rect x="254" y="98" width="48" height="18" rx="6" fill="#4DA3FF"/><path d="M268 98 q10-26 20 0z" fill="#FFD9A8"/>
<line x1="268" y1="140" x2="282" y2="140" stroke="#9AA4B2" stroke-width="3"/><line x1="268" y1="156" x2="282" y2="156" stroke="#9AA4B2" stroke-width="3"/>
<circle cx="98" cy="196" r="18" fill="#F5C400"/><circle cx="98" cy="196" r="8" fill="#FFE27A"/><rect x="94" y="212" width="8" height="34" rx="4" fill="#FF7FA8"/>''', '#F0FFFB')

# 11 Shoes: sneaker + heel
ART['shoes'] = page('#FFF0D9', '#FFD39A', '''
<g transform="translate(4 54) scale(.82)"><path d="M64 214 q0-46 40-56 l40-6 q16 26 50 30 l60 8 q34 6 36 34 v6 h-226z" fill="#FFFFFF"/>
<path d="M64 214 h226 v14 q0 6 -6 6 h-214 q-6 0 -6 -6z" fill="#E30613"/>
<path d="M104 158 l40-6 q16 26 50 30 l-18 26 q-46 -2 -72 -30z" fill="#00802B"/>
<line x1="132" y1="160" x2="150" y2="150" stroke="#2B2B2B" stroke-width="3"/><line x1="140" y1="172" x2="160" y2="160" stroke="#2B2B2B" stroke-width="3"/><line x1="150" y1="182" x2="172" y2="170" stroke="#2B2B2B" stroke-width="3"/></g>
<g transform="translate(20 0)"><path d="M212 246 Q208 222 232 216 L262 212 Q284 206 300 186 Q310 172 322 176 Q332 182 326 198 L318 202 Q292 214 272 236 Q262 246 246 246 Z" fill="#2B2D42"/>
<path d="M266 214 Q290 204 304 188 Q312 180 318 186" fill="none" stroke="#4A4E69" stroke-width="5" stroke-linecap="round"/>
<path d="M306 202 L320 200 L317 246 L311 246 Z" fill="#F5C400"/><rect x="306" y="244" width="16" height="4" rx="2" fill="#2B2D42"/>
<circle cx="240" cy="228" r="5" fill="#F5C400"/></g>''', '#FFF8EC')

# 12 Watches, Bags & Accessories: watch + sunglasses + wallet
ART['watches-bags-and-accessories'] = page('#EDE6DA', '#D8C7A8', '''
<rect x="120" y="54" width="44" height="60" rx="10" fill="#6B4F3A"/><rect x="120" y="190" width="44" height="62" rx="10" fill="#6B4F3A"/>
<circle cx="142" cy="152" r="52" fill="#C9A227"/><circle cx="142" cy="152" r="44" fill="#FFFDF5"/>
<line x1="142" y1="152" x2="142" y2="122" stroke="#2B2B2B" stroke-width="5" stroke-linecap="round"/><line x1="142" y1="152" x2="164" y2="164" stroke="#2B2B2B" stroke-width="4" stroke-linecap="round"/><circle cx="142" cy="152" r="5" fill="#E30613"/>
<circle cx="142" cy="114" r="3" fill="#888"/><circle cx="142" cy="190" r="3" fill="#888"/><circle cx="104" cy="152" r="3" fill="#888"/><circle cx="180" cy="152" r="3" fill="#888"/>
<rect x="200" y="176" width="124" height="72" rx="10" fill="#8B4513"/><rect x="200" y="176" width="124" height="22" rx="10" fill="#A0522D"/><rect x="290" y="198" width="34" height="22" rx="4" fill="#6B3410"/><circle cx="302" cy="209" r="4" fill="#F5C400"/>
<path d="M206 118 h44 q4 30 -22 30 q-24 0 -22 -30z M266 118 h44 q4 30 -22 30 q-24 0 -22 -30z" fill="#1E2A3A"/><path d="M250 122 q8 -6 16 0" fill="none" stroke="#1E2A3A" stroke-width="5"/>
<path d="M214 124 l12 0 l-14 16z" fill="#6FA8DC" opacity=".6"/><path d="M274 124 l12 0 l-14 16z" fill="#6FA8DC" opacity=".6"/>''', '#FAF6EE')

# 13 Health & Beauty: lipstick, cream jar, serum bottle, flower
ART['health-and-beauty'] = page('#FBE0F0', '#F2B6D8', '''
<rect x="92" y="158" width="44" height="88" rx="6" fill="#C9A227"/><rect x="98" y="120" width="32" height="44" rx="4" fill="#E9E9EF"/><path d="M100 120 v-26 l28 -14 v40z" fill="#C2185B"/>
<rect x="152" y="96" width="62" height="150" rx="14" fill="#FFFFFF"/><rect x="152" y="140" width="62" height="70" fill="#FFD6E8"/><rect x="170" y="70" width="26" height="30" rx="4" fill="#2B2D42"/><rect x="176" y="54" width="14" height="20" rx="5" fill="#00802B"/>
<ellipse cx="183" cy="175" rx="16" ry="10" fill="#fff" opacity=".7"/>
<rect x="230" y="186" width="96" height="60" rx="14" fill="#FFFFFF"/><rect x="226" y="172" width="104" height="22" rx="10" fill="#F5C400"/><rect x="250" y="208" width="56" height="14" rx="7" fill="#FFE3EF"/>
<circle cx="292" cy="120" r="12" fill="#FF7FA8"/><circle cx="276" cy="110" r="12" fill="#FF9BBB"/><circle cx="308" cy="110" r="12" fill="#FF9BBB"/><circle cx="284" cy="94" r="12" fill="#FF7FA8"/><circle cx="300" cy="94" r="12" fill="#FF7FA8"/><circle cx="292" cy="104" r="8" fill="#F5C400"/>
<path d="M292 132 q-4 22 2 40" fill="none" stroke="#2F9E44" stroke-width="4"/>''', '#FFF2F9')

# 14 Groceries: shopping bag with vegetables and bread
ART['groceries'] = page('#E8F8D8', '#C2EB9C', '''
<path d="M120 76 q-26 -10 -30 18 q30 6 30 -18z" fill="#2F9E44"/><rect x="112" y="72" width="16" height="76" rx="8" fill="#FF8C1A" transform="rotate(-18 120 110)"/>
<circle cx="186" cy="96" r="30" fill="#E30613"/><path d="M186 66 q6 -14 18 -14" fill="none" stroke="#2F9E44" stroke-width="5" stroke-linecap="round"/><circle cx="176" cy="88" r="8" fill="#fff" opacity=".35"/>
<ellipse cx="248" cy="96" rx="40" ry="20" fill="#E0A458" transform="rotate(-20 248 96)"/><path d="M226 100 l8 -14 M244 94 l8 -14 M262 88 l8 -14" stroke="#C47F2A" stroke-width="4" stroke-linecap="round"/>
<circle cx="280" cy="128" r="16" fill="#7BD389"/><circle cx="292" cy="118" r="14" fill="#4CAF50"/>
<path d="M90 124 h220 l-18 128 h-184z" fill="#00802B"/><path d="M90 124 h220 l-4 20 h-212z" fill="#006622"/>
<rect x="150" y="164" width="100" height="56" rx="12" fill="#F5C400"/><path d="M174 192 q26 -22 52 0 q-26 22 -52 0z" fill="#00802B"/>''', '#F4FDEB')

# 15 Home & Living: sofa + floor lamp + plant
ART['home-and-living'] = page('#F3E9DC', '#E3CBA8', '''
<rect x="88" y="132" width="196" height="64" rx="18" fill="#00802B"/><rect x="74" y="160" width="38" height="70" rx="14" fill="#006622"/><rect x="262" y="160" width="38" height="70" rx="14" fill="#006622"/>
<rect x="104" y="180" width="166" height="44" rx="12" fill="#1F9D55"/><line x1="187" y1="182" x2="187" y2="222" stroke="#006622" stroke-width="3"/>
<rect x="132" y="150" width="34" height="30" rx="8" fill="#F5C400"/><rect x="208" y="150" width="34" height="30" rx="8" fill="#E30613"/>
<rect x="86" y="228" width="10" height="20" fill="#5D4037"/><rect x="278" y="228" width="10" height="20" fill="#5D4037"/>
<rect x="326" y="96" width="5" height="150" fill="#4A4A4A"/><path d="M308 64 h42 l12 36 h-66z" fill="#FFE082"/><ellipse cx="328" cy="246" rx="18" ry="5" fill="#4A4A4A"/>
<rect x="44" y="200" width="34" height="46" rx="6" fill="#C0784C"/><path d="M61 200 q-24 -30 -14 -60 q14 22 14 60z" fill="#2F9E44"/><path d="M61 200 q22 -34 8 -66 q-12 28 -8 66z" fill="#4CAF50"/>''', '#FBF5EE')

# 16 Sports & Fitness: cricket bat + ball + football + dumbbell
ART['sports-and-fitness'] = page('#DDF3E4', '#A9DFBB', '''
<g transform="rotate(-30 150 150)"><rect x="140" y="40" width="20" height="60" rx="6" fill="#2B2D42"/><rect x="130" y="96" width="40" height="130" rx="12" fill="#F2D6A2"/><rect x="134" y="96" width="32" height="12" fill="#E6C17A"/></g>
<circle cx="214" cy="104" r="17" fill="#E30613"/><path d="M200 96 q14 8 28 0" fill="none" stroke="#fff" stroke-width="2.5"/>
<circle cx="268" cy="196" r="44" fill="#FFFFFF"/><path d="M268 174 l18 13 l-7 21 h-22 l-7 -21z" fill="#2B2D42"/><path d="M268 152 v22 M286 187 l22 -6 M279 208 l12 18 M257 208 l-12 18 M250 187 l-22 -6" stroke="#2B2D42" stroke-width="4"/>
<rect x="70" y="222" width="110" height="10" rx="5" fill="#5A5F6B"/><rect x="62" y="206" width="18" height="42" rx="5" fill="#2B2D42"/><rect x="170" y="206" width="18" height="42" rx="5" fill="#2B2D42"/><rect x="50" y="212" width="12" height="30" rx="4" fill="#2B2D42"/><rect x="188" y="212" width="12" height="30" rx="4" fill="#2B2D42"/>''', '#F0FBF4')

# 17 Books & Stationery: book stack + pencil + notebook
ART['books-and-stationery'] = page('#E8EEFF', '#BCCBFF', '''
<rect x="92" y="208" width="170" height="34" rx="5" fill="#E30613"/><rect x="92" y="208" width="14" height="34" fill="#B3000C"/><rect x="250" y="212" width="8" height="26" fill="#FFF6E5"/>
<rect x="104" y="172" width="150" height="34" rx="5" fill="#00802B"/><rect x="104" y="172" width="14" height="34" fill="#006622"/><rect x="242" y="176" width="8" height="26" fill="#FFF6E5"/>
<rect x="96" y="136" width="160" height="34" rx="5" fill="#F5C400"/><rect x="96" y="136" width="14" height="34" fill="#D4A900"/><rect x="244" y="140" width="8" height="26" fill="#FFF6E5"/>
<rect x="124" y="114" width="96" height="20" rx="4" fill="#3A6FD8"/><rect x="132" y="120" width="40" height="6" rx="3" fill="#fff" opacity=".7"/>
<g transform="rotate(35 300 140)"><rect x="290" y="60" width="20" height="140" fill="#F5C400"/><rect x="290" y="60" width="20" height="16" fill="#FF8FA3"/><rect x="290" y="76" width="20" height="6" fill="#C9CED6"/><path d="M290 200 h20 l-10 24z" fill="#F2D6A2"/><path d="M296 214 h8 l-4 10z" fill="#2B2D42"/></g>''', '#F2F5FF')

# 18 Toys & Games: blocks + toy car + ball
ART['toys-and-games'] = page('#FFF4CC', '#FFE38A', '''
<rect x="78" y="190" width="56" height="56" rx="8" fill="#E30613"/><rect x="134" y="190" width="56" height="56" rx="8" fill="#2979FF"/><rect x="106" y="134" width="56" height="56" rx="8" fill="#00802B"/>
<circle cx="106" cy="218" r="12" fill="#fff" opacity=".9"/><path d="M152 206 h20 v24 h-20z" fill="#fff" opacity=".9"/><path d="M134 146 l12 32 h-24z" fill="#fff" opacity=".9"/>
<path d="M214 196 l20 -34 h56 l26 34 h18 q8 0 8 8 v22 h-140 v-22 q0 -8 12 -8z" fill="#FF6D00"/><path d="M240 168 h22 v28 h-38z M270 168 h18 l20 28 h-38z" fill="#BEE3FF"/>
<circle cx="236" cy="230" r="17" fill="#2B2D42"/><circle cx="236" cy="230" r="7" fill="#C9CED6"/><circle cx="314" cy="230" r="17" fill="#2B2D42"/><circle cx="314" cy="230" r="7" fill="#C9CED6"/>
<circle cx="262" cy="96" r="34" fill="#FF7FA8"/><path d="M228 96 h68 M262 62 q-22 34 0 68 M262 62 q22 34 0 68" fill="none" stroke="#fff" stroke-width="5"/>''', '#FFFBEA')

# 19 Automotive & Motorbike: motorbike + helmet
ART['automotive-and-motorbike'] = page('#E6E9EF', '#C3CAD6', '''
<circle cx="108" cy="214" r="34" fill="#2B2D42"/><circle cx="108" cy="214" r="18" fill="#C9CED6"/><circle cx="108" cy="214" r="6" fill="#2B2D42"/>
<circle cx="262" cy="214" r="34" fill="#2B2D42"/><circle cx="262" cy="214" r="18" fill="#C9CED6"/><circle cx="262" cy="214" r="6" fill="#2B2D42"/>
<path d="M108 214 l44 -60 h70 l40 60" fill="none" stroke="#5A5F6B" stroke-width="8" stroke-linejoin="round"/>
<path d="M140 150 q20 -26 64 -26 h30 q18 0 22 18 l-8 14 h-92z" fill="#E30613"/><path d="M196 120 q20 -6 40 0 l-4 10 h-36z" fill="#2B2D42"/>
<rect x="168" y="176" width="52" height="30" rx="6" fill="#5A5F6B"/><line x1="262" y1="214" x2="244" y2="128" stroke="#5A5F6B" stroke-width="8" stroke-linecap="round"/><path d="M232 122 l14 6 l16 -4" fill="none" stroke="#2B2D42" stroke-width="7" stroke-linecap="round"/><circle cx="256" cy="146" r="9" fill="#F5C400"/>
<path d="M130 138 q14 -10 40 -8 l-6 16 h-40z" fill="#2B2D42"/><rect x="112" y="196" width="72" height="8" rx="4" fill="#9AA4B2"/>
<g transform="translate(14 130)"><path d="M286 96 q0 -40 34 -40 q30 0 30 36 v20 h-64z" fill="#00802B"/><path d="M300 86 h50 v14 h-50z" fill="#1E2A3A" opacity=".85"/><rect x="284" y="110" width="68" height="8" rx="4" fill="#006622"/></g>''', '#F4F6F9')

# 20 Tools & Hardware: drill + wrench + toolbox
ART['tools-and-hardware'] = page('#FFE9D1', '#FFC98F', '''
<rect x="190" y="176" width="140" height="72" rx="8" fill="#E30613"/><rect x="190" y="176" width="140" height="18" rx="8" fill="#B3000C"/><path d="M234 176 v-16 q0 -8 8 -8 h36 q8 0 8 8 v16" fill="none" stroke="#2B2D42" stroke-width="7"/>
<rect x="250" y="206" width="20" height="12" rx="3" fill="#F5C400"/>
<path d="M78 112 h98 q12 0 12 12 v18 q0 12 -12 12 h-98z" fill="#F5C400"/><rect x="176" y="122" width="34" height="14" rx="3" fill="#5A5F6B"/><rect x="208" y="126" width="34" height="6" fill="#9AA4B2"/>
<path d="M104 154 h40 l-8 78 h-30z" fill="#2B2D42"/><rect x="96" y="226" width="54" height="22" rx="6" fill="#3D3D45"/><rect x="88" y="120" width="20" height="26" rx="4" fill="#2B2D42"/>
<defs><mask id="jaw"><rect width="400" height="300" fill="#fff"/><rect x="330" y="66" width="16" height="24" fill="#000" transform="rotate(-40 338 78)"/></mask></defs>
<g mask="url(#jaw)"><rect x="236" y="96" width="104" height="16" rx="8" fill="#9AA4B2" transform="rotate(-40 288 104)"/><circle cx="334" cy="72" r="19" fill="#9AA4B2"/><circle cx="242" cy="148" r="15" fill="#9AA4B2"/><circle cx="242" cy="148" r="7" fill="#FFE9D1"/></g>''', '#FFF6EC')

for slug, svg in ART.items():
    open(os.path.join(OUT, slug + '.svg'), 'w').write(svg)
print('wrote', len(ART), 'pictures to', os.path.normpath(OUT))
