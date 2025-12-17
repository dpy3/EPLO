import zipfile
import xml.etree.ElementTree as ET
import sys
from pathlib import Path

def extract_docx_text(docx_path: Path):
    with zipfile.ZipFile(docx_path) as z:
        with z.open('word/document.xml') as f:
            xml = f.read()
    # Namespaces
    ns = {
        'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    }
    root = ET.fromstring(xml)
    items = []
    for p in root.findall('.//w:body/w:p', ns):
        # style
        style = None
        pPr = p.find('w:pPr', ns)
        if pPr is not None:
            pStyle = pPr.find('w:pStyle', ns)
            if pStyle is not None and 'val' in pStyle.attrib.get(f'{{{ns["w"]}}}val', ''):
                style = pStyle.attrib[f'{{{ns["w"]}}}val']
            else:
                style = pStyle.attrib.get(f'{{{ns["w"]}}}val') if pStyle is not None else None
        # text aggregation
        runs = []
        for r in p.findall('.//w:r', ns):
            t = r.find('w:t', ns)
            if t is not None and t.text:
                runs.append(t.text)
        text = ''.join(runs).strip()
        if text:
            items.append((style, text))
    return items

def main():
    if len(sys.argv) < 2:
        print('USAGE: docx_parse.py <docx_path> [limit]')
        return 1
    docx_path = Path(sys.argv[1])
    limit = None
    if len(sys.argv) >= 3:
        try:
            limit = int(sys.argv[2])
        except Exception:
            limit = None
    items = extract_docx_text(docx_path)
    if limit is not None:
        items = items[:limit]
    for i, (style, text) in enumerate(items):
        s = style or ''
        print(f'{i:03d} [{s}]: {text}')
    return 0

if __name__ == '__main__':
    sys.exit(main())