import os
from pathlib import Path
from PIL import Image, ImageFilter, ImageOps, ImageEnhance

def enhance_pngs(folder: Path) -> list[str]:
    reports = []
    pngs = [p for p in folder.iterdir() if p.suffix.lower() == ".png"]
    for p in pngs:
        try:
            img = Image.open(p)
            img.load()
            w, h = img.size
            long_side = max(w, h)
            scale = 2.0 if long_side < 2000 else (1.5 if long_side < 3500 else 1.0)
            if scale != 1.0:
                img = img.resize((int(w*scale), int(h*scale)), Image.LANCZOS)
            img = ImageOps.autocontrast(img, cutoff=1)
            img = ImageEnhance.Color(img).enhance(1.05)
            img = ImageEnhance.Sharpness(img).enhance(1.25)
            img = img.filter(ImageFilter.UnsharpMask(radius=1.4, percent=130, threshold=3))
            if img.mode not in ("RGB", "RGBA"):
                img = img.convert("RGB")
            before = p.stat().st_size
            img.save(p, format="PNG", optimize=True, compress_level=9, dpi=(600, 600))
            after = p.stat().st_size
            reports.append(f"{p.name}: {w}x{h} -> {img.size[0]}x{img.size[1]} | {before} -> {after} bytes")
        except Exception as e:
            reports.append(f"FAILED {p.name}: {e}")
    return reports

def main():
    folder = Path(r"e:\postgraduate\first year\EPLO\EPLO_figures")
    results = enhance_pngs(folder)
    print("Processed files:")
    for line in sorted(results):
        print(line)

if __name__ == "__main__":
    main()

