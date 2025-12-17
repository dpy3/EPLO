import sys
from pathlib import Path

def extract_text_pdf(path: Path) -> str:
    from pdfminer.high_level import extract_text
    return extract_text(str(path))

def main():
    if len(sys.argv) < 2:
        print('USAGE: pdf_extract.py <pdf_path> [find_pattern] [head_chars]')
        return 1
    pdf_path = Path(sys.argv[1])
    patt = sys.argv[2] if len(sys.argv) >= 3 else None
    head = int(sys.argv[3]) if len(sys.argv) >= 4 else 2000
    text = extract_text_pdf(pdf_path)
    print(text[:head])
    if patt:
        import re
        print('---MATCHES---')
        for m in re.finditer(patt, text, flags=re.I):
            s = m.start()
            e = min(len(text), m.end()+200)
            print(text[s:e])
    return 0

if __name__ == '__main__':
    sys.exit(main())