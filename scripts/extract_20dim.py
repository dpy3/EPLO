import sys
from pathlib import Path

def find_20dim_table(docx_path: Path):
    import docx
    d = docx.Document(str(docx_path))
    candidates = []
    for idx, tbl in enumerate(d.tables):
        rows = []
        for tr in tbl.rows:
            row = []
            for tc in tr.cells:
                txt = (tc.text or '').strip()
                txt = ' '.join(txt.split())
                row.append(txt)
            rows.append(row)
        # detect tables with function tags and Mean Rank
        tags = [r[0] for r in rows if r]
        has_funcs = any(t.startswith('F') and t[1:].isdigit() for t in tags)
        has_mean = any('Mean Rank' in ' '.join(r) for r in rows)
        if has_funcs and has_mean:
            candidates.append((idx, rows))
    return candidates

def main():
    if len(sys.argv) < 3:
        print('USAGE: extract_20dim.py <docx_path> <out_path>')
        return 1
    docx_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    cands = find_20dim_table(docx_path)
    if not cands:
        print('NO TABLE FOUND')
        return 2
    # write all candidates
    lines = []
    for idx, rows in cands:
        lines.append(f'==TABLE {idx+1}')
        for r in rows:
            lines.append('| ' + ' | '.join(r) + ' |')
    out_path.write_text('\n'.join(lines), encoding='utf-8')
    print('WROTE', out_path)
    return 0

if __name__ == '__main__':
    sys.exit(main())