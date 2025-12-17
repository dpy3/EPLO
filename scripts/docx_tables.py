import zipfile
import xml.etree.ElementTree as ET
import sys
from pathlib import Path

NS = {
    'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
}

def read_document_xml(docx_path: Path):
    with zipfile.ZipFile(docx_path) as z:
        with z.open('word/document.xml') as f:
            return ET.fromstring(f.read())

def get_text_from_p(p):
    texts = []
    for t in p.findall('.//w:r/w:t', NS):
        if t.text:
            texts.append(t.text)
    return ''.join(texts).strip()

def extract_tables(docx_path: Path):
    root = read_document_xml(docx_path)
    body_children = list(root.find('.//w:body', NS))
    results = []
    for idx, elem in enumerate(body_children):
        if elem.tag == f'{{{NS["w"]}}}tbl':
            # find preceding paragraph as caption
            caption = ''
            if idx > 0 and body_children[idx-1].tag == f'{{{NS["w"]}}}p':
                caption = get_text_from_p(body_children[idx-1])
            # extract rows
            rows = []
            for tr in elem.findall('.//w:tr', NS):
                row = []
                for tc in tr.findall('.//w:tc', NS):
                    # cell text
                    ctext = []
                    for p in tc.findall('.//w:p', NS):
                        t = get_text_from_p(p)
                        if t:
                            ctext.append(t)
                    row.append(' '.join(ctext).strip())
                rows.append(row)
            results.append({'caption': caption, 'rows': rows})
    return results

def extract_tables_docx(docx_path: Path):
    try:
        import docx as docx_lib
    except Exception:
        return None
    d = docx_lib.Document(str(docx_path))
    results = []
    for tbl in d.tables:
        rows = []
        for tr in tbl.rows:
            row = []
            for tc in tr.cells:
                # python-docx preserves newline separators; normalize whitespace
                txt = (tc.text or '').replace('\r', '\n').replace('\t', ' ')
                txt = ' '.join(txt.split())
                row.append(txt)
            rows.append(row)
        results.append({'caption': '', 'rows': rows})
    return results

def main():
    if len(sys.argv) < 2:
        print('USAGE: docx_tables.py <docx_path> [caption_substr] [out_file] [index] [row_substr]')
        return 1
    docx_path = Path(sys.argv[1])
    cap_filt = sys.argv[2] if len(sys.argv) >= 3 and sys.argv[2] != '' else None
    out = Path(sys.argv[3]) if len(sys.argv) >= 4 and sys.argv[3] != '' else None
    index = None
    if len(sys.argv) >= 5 and sys.argv[4] != '':
        try:
            index = int(sys.argv[4])
        except Exception:
            index = None
    row_filt = sys.argv[5] if len(sys.argv) >= 6 and sys.argv[5] != '' else None
    list_only = (len(sys.argv) >= 7 and sys.argv[6].lower() == 'list')
    tables = extract_tables_docx(docx_path) or extract_tables(docx_path)
    if list_only:
        lines = []
        for i, t in enumerate(tables):
            cap = t['caption']
            # try to detect likely CEC tables containing F1..F12 and Mean Rank
            head = ' | '.join(t['rows'][0]) if t['rows'] else ''
            tags = set(r[0] for r in t['rows'] if r)
            has_funcs = any(s.startswith('F') and s[1:].isdigit() for s in tags)
            has_summary = ('Mean Rank' in tags) or any('Mean Rank' in ' | '.join(r) for r in t['rows'])
            lines.append(f'== TABLE {i+1}: {cap} | has_funcs={has_funcs} | has_summary={has_summary}')
        text = '\n'.join(lines)
        if out:
            out.write_text(text, encoding='utf-8')
        else:
            print(text)
        return 0
    lines = []
    for i, t in enumerate(tables):
        if index is not None and (i+1) != index:
            continue
        cap = t['caption']
        if cap_filt and (cap_filt not in cap):
            continue
        # If row filter provided, ensure at least one row matches
        if row_filt:
            if not any(row_filt in (' '.join(r)) for r in t['rows']):
                continue
        lines.append(f'== TABLE {i+1}: {cap}')
        for r in t['rows']:
            lines.append('| ' + ' | '.join(r) + ' |')
    text = '\n'.join(lines)
    if out:
        out.write_text(text, encoding='utf-8')
    else:
        print(text)
    return 0

if __name__ == '__main__':
    sys.exit(main())