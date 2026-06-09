import re
from pathlib import Path
path = Path('lib/main.dart')
text = path.read_text(encoding='utf-8')
pattern = re.compile(r"(['"])(.*?)(?<!\\)\1", re.S)
found = []
nonascii = set()
for m in pattern.finditer(text):
    s = m.group(2)
    if any('\u0a80' <= c <= '\u0aff' for c in s):
        found.append(s)
    elif any(ord(c) > 127 for c in s):
        nonascii.add(s)
print('=== Gujarati Strings ===')
for s in sorted(set(found)):
    print(repr(s))
print('=== Total Gujarati Strings:', len(set(found)))
print('=== Other Non-ASCII Strings ===')
for s in sorted(nonascii):
    print(repr(s))
