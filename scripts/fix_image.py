from pathlib import Path
from PIL import Image, ImageFilter, ImageOps, ImageEnhance

def enhance(path: Path, out_path: Path) -> str:
    img = Image.open(path)
    img.load()
    w, h = img.size
    long_side = max(w, h)
    scale = 2.0 if long_side < 2000 else 1.5
    img = img.resize((int(w*scale), int(h*scale)), Image.LANCZOS)
    img = ImageOps.autocontrast(img, cutoff=1)
    img = ImageEnhance.Color(img).enhance(1.05)
    img = ImageEnhance.Sharpness(img).enhance(1.25)
    img = img.filter(ImageFilter.UnsharpMask(radius=1.4, percent=130, threshold=3))
    if img.mode not in ("RGB", "RGBA"):
        img = img.convert("RGB")
    img.save(out_path, format="PNG", optimize=True, compress_level=9, dpi=(600, 600))
    return f"Enhanced {path.name}: {w}x{h} -> {img.size[0]}x{img.size[1]} saved to {out_path}"

def main():
    src = Path(r"e:\postgraduate\first year\EPLO\EPLO_figures\Multiple disk clutch brake design.png")
    dst = src.with_name("multiple_disk_clutch_brake_fixed.png")
    print(enhance(src, dst))

if __name__ == "__main__":
    main()

