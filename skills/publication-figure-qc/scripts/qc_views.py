#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

import fitz
from PIL import Image, ImageChops


def render_pdf_first_page(src: Path, dpi: int) -> Image.Image:
    doc = fitz.open(src)
    page = doc[0]
    scale = dpi / 72.0
    pix = page.get_pixmap(matrix=fitz.Matrix(scale, scale), alpha=False)
    mode = "RGB"
    return Image.frombytes(mode, [pix.width, pix.height], pix.samples)


def load_image(src: Path, dpi: int) -> Image.Image:
    if src.suffix.lower() == ".pdf":
        return render_pdf_first_page(src, dpi)
    return Image.open(src).convert("RGB")


MAX_DIMENSION = 2000


def clamp_size(img: Image.Image) -> Image.Image:
    """Downsample so neither dimension exceeds MAX_DIMENSION."""
    w, h = img.size
    if w <= MAX_DIMENSION and h <= MAX_DIMENSION:
        return img
    scale = min(MAX_DIMENSION / w, MAX_DIMENSION / h)
    new_w, new_h = round(w * scale), round(h * scale)
    return img.resize((new_w, new_h), Image.LANCZOS)


def trim_white(img: Image.Image, threshold: int = 250) -> Image.Image:
    bg = Image.new("RGB", img.size, (255, 255, 255))
    diff = ImageChops.difference(img.convert("RGB"), bg)
    bbox = diff.point(lambda x: 255 if x > (255 - threshold) else 0).getbbox()
    return img.crop(bbox) if bbox else img


def crop_image(img: Image.Image, crop_px: str | None, crop_frac: str | None) -> Image.Image:
    if crop_px and crop_frac:
        raise ValueError("Use only one of --crop-px or --crop-frac.")
    if crop_px:
        left, top, right, bottom = [int(v) for v in crop_px.split(",")]
        return img.crop((left, top, right, bottom))
    if crop_frac:
        left, top, right, bottom = [float(v) for v in crop_frac.split(",")]
        width, height = img.size
        return img.crop(
            (
                round(left * width),
                round(top * height),
                round(right * width),
                round(bottom * height),
            )
        )
    return img


def analyze_whitespace_raster(img: Image.Image, threshold: int = 250) -> dict:
    """Analyze whitespace in a raster image. Returns measurements dict."""
    import numpy as np

    arr = np.array(img.convert("RGB"))
    is_white = np.all(arr >= threshold, axis=2)
    h, w = is_white.shape

    # Overall whitespace ratio
    total_px = h * w
    white_px = int(np.sum(is_white))

    # Content bounding box
    content_mask = ~is_white
    rows_with_content = np.any(content_mask, axis=1)
    cols_with_content = np.any(content_mask, axis=0)

    if not np.any(rows_with_content):
        return {"error": "No content detected (entirely white image)"}

    top = int(np.argmax(rows_with_content))
    bottom = h - int(np.argmax(rows_with_content[::-1]))
    left = int(np.argmax(cols_with_content))
    right = w - int(np.argmax(cols_with_content[::-1]))

    # Margins in pixels and as percentage
    margins = {
        "top_px": top, "top_pct": round(100.0 * top / h, 1),
        "bottom_px": h - bottom, "bottom_pct": round(100.0 * (h - bottom) / h, 1),
        "left_px": left, "left_pct": round(100.0 * left / w, 1),
        "right_px": w - right, "right_pct": round(100.0 * (w - right) / w, 1),
    }

    # Detect gutters: find runs of all-white rows/columns inside content bbox
    def find_gaps(profile, min_gap: int = 10):
        """Find gaps (runs of zeros) in a 1D content profile."""
        gaps = []
        in_gap = False
        gap_start = 0
        for i, v in enumerate(profile):
            if v == 0 and not in_gap:
                in_gap = True
                gap_start = i
            elif v > 0 and in_gap:
                length = i - gap_start
                if length >= min_gap:
                    gaps.append({"start": gap_start, "end": i, "size_px": length})
                in_gap = False
        if in_gap:
            length = len(profile) - gap_start
            if length >= min_gap:
                gaps.append({"start": gap_start, "end": len(profile), "size_px": length})
        return gaps

    # Content density per row/column inside content bbox
    row_content = np.sum(content_mask[top:bottom, left:right], axis=1)
    col_content = np.sum(content_mask[top:bottom, left:right], axis=0)

    h_gutters = find_gaps(row_content)
    v_gutters = find_gaps(col_content)

    # Adjust gutter positions to full-image coordinates
    for g in h_gutters:
        g["start"] += top
        g["end"] += top
    for g in v_gutters:
        g["start"] += left
        g["end"] += left

    # Gutter consistency
    h_sizes = [g["size_px"] for g in h_gutters]
    v_sizes = [g["size_px"] for g in v_gutters]

    def stats(sizes):
        if not sizes:
            return None
        mean = sum(sizes) / len(sizes)
        if len(sizes) > 1:
            var = sum((s - mean) ** 2 for s in sizes) / (len(sizes) - 1)
            std = var ** 0.5
        else:
            std = 0.0
        return {"count": len(sizes), "sizes_px": sizes, "mean_px": round(mean, 1), "std_px": round(std, 1)}

    # Quadrant whitespace
    mid_y, mid_x = h // 2, w // 2
    quadrants = {}
    for name, (y0, y1, x0, x1) in [
        ("top_left", (0, mid_y, 0, mid_x)),
        ("top_right", (0, mid_y, mid_x, w)),
        ("bottom_left", (mid_y, h, 0, mid_x)),
        ("bottom_right", (mid_y, h, mid_x, w)),
    ]:
        q = is_white[y0:y1, x0:x1]
        quadrants[name] = round(100.0 * np.sum(q) / q.size, 1)

    return {
        "image_size": {"width_px": w, "height_px": h},
        "content_bbox": {"left": left, "top": top, "right": right, "bottom": bottom},
        "whitespace_pct": round(100.0 * white_px / total_px, 1),
        "margins": margins,
        "margin_asymmetry": {
            "horizontal_px": abs(left - (w - right)),
            "vertical_px": abs(top - (h - bottom)),
        },
        "horizontal_gutters": stats(h_sizes),
        "vertical_gutters": stats(v_sizes),
        "quadrant_whitespace_pct": quadrants,
    }


def analyze_whitespace_pdf(src: Path) -> dict:
    """Extract element positions from PDF and compute spatial measurements."""
    doc = fitz.open(src)
    page = doc[0]
    pw, ph = page.rect.width, page.rect.height

    # Collect all element bounding boxes
    elements = []

    # Text blocks
    for block in page.get_text("dict")["blocks"]:
        r = fitz.Rect(block["bbox"])
        if r.width > 0 and r.height > 0:
            elements.append({"type": "text" if block["type"] == 0 else "image", "bbox": block["bbox"]})

    # Drawings
    for d in page.get_drawings():
        r = d["rect"]
        if r.width > 0 and r.height > 0:
            elements.append({"type": "drawing", "bbox": tuple(r)})

    if not elements:
        return {"error": "No elements found in PDF"}

    # Content bounding box (union of all elements)
    all_x0 = min(e["bbox"][0] for e in elements)
    all_y0 = min(e["bbox"][1] for e in elements)
    all_x1 = max(e["bbox"][2] for e in elements)
    all_y1 = max(e["bbox"][3] for e in elements)

    margins = {
        "top_pt": round(all_y0, 1), "top_pct": round(100.0 * all_y0 / ph, 1),
        "bottom_pt": round(ph - all_y1, 1), "bottom_pct": round(100.0 * (ph - all_y1) / ph, 1),
        "left_pt": round(all_x0, 1), "left_pct": round(100.0 * all_x0 / pw, 1),
        "right_pt": round(pw - all_x1, 1), "right_pct": round(100.0 * (pw - all_x1) / pw, 1),
    }

    # Element summary by type
    type_counts = {}
    for e in elements:
        t = e["type"]
        type_counts[t] = type_counts.get(t, 0) + 1

    return {
        "page_size_pt": {"width": round(pw, 1), "height": round(ph, 1)},
        "content_bbox_pt": {
            "left": round(all_x0, 1), "top": round(all_y0, 1),
            "right": round(all_x1, 1), "bottom": round(all_y1, 1),
        },
        "margins": margins,
        "margin_asymmetry_pt": {
            "horizontal": round(abs(all_x0 - (pw - all_x1)), 1),
            "vertical": round(abs(all_y0 - (ph - all_y1)), 1),
        },
        "element_count": len(elements),
        "element_types": type_counts,
    }


def cmd_spatial(args: argparse.Namespace) -> None:
    """Run spatial/whitespace analysis and print measurements."""
    import json

    src = Path(args.input)
    results = {}

    # Always do raster analysis (works for both PDF and PNG)
    img = load_image(src, args.dpi)
    results["raster_analysis"] = analyze_whitespace_raster(img)

    # For PDFs, also do vector-level analysis
    if src.suffix.lower() == ".pdf":
        results["vector_analysis"] = analyze_whitespace_pdf(src)

    print(json.dumps(results, indent=2))


def audit_fonts_pdf(src: Path) -> dict:
    """Extract every text span's font metadata from a PDF and report consistency."""
    doc = fitz.open(src)
    page = doc[0]
    text_dict = page.get_text("dict")

    spans = []
    for block in text_dict["blocks"]:
        if block["type"] != 0:
            continue
        for line in block["lines"]:
            for span in line["spans"]:
                text = span["text"].strip()
                if not text:
                    continue
                spans.append({
                    "text": text[:40] + ("..." if len(text) > 40 else ""),
                    "font": span["font"],
                    "size": round(span["size"], 2),
                    "flags": span["flags"],
                    "color": span["color"],
                    "bbox": [round(v, 1) for v in span["bbox"]],
                })

    if not spans:
        return {"error": "No text spans found in PDF"}

    # Decode flags: bit 0=superscript, 1=italic, 2=serif, 3=monospace, 4=bold
    def decode_flags(f):
        parts = []
        if f & 1:
            parts.append("superscript")
        if f & 2:
            parts.append("italic")
        if f & 4:
            parts.append("serif")
        if f & 8:
            parts.append("monospace")
        if f & 16:
            parts.append("bold")
        return parts or ["regular"]

    # Unique font signatures
    font_sigs = {}
    for s in spans:
        sig = f"{s['font']}|{s['size']}|{s['flags']}"
        if sig not in font_sigs:
            font_sigs[sig] = {
                "font": s["font"],
                "size": s["size"],
                "style": decode_flags(s["flags"]),
                "count": 0,
                "sample_texts": [],
            }
        font_sigs[sig]["count"] += 1
        if len(font_sigs[sig]["sample_texts"]) < 3:
            font_sigs[sig]["sample_texts"].append(s["text"])

    # Unique font families (name without style suffix)
    families = set()
    for s in spans:
        # Strip common suffixes like -Bold, -Italic, -BoldItalic
        base = s["font"].split("-")[0].split("+")[-1]
        families.add(base)

    # Size distribution
    sizes = [s["size"] for s in spans]
    unique_sizes = sorted(set(sizes))

    # Warnings
    warnings = []
    if len(families) > 2:
        warnings.append(f"Multiple font families detected ({len(families)}): {sorted(families)} — may look inconsistent")
    if len(unique_sizes) > 5:
        warnings.append(f"Many distinct font sizes ({len(unique_sizes)}): {unique_sizes} — consider consolidating")

    # Check for near-duplicate sizes (differ by < 0.5pt)
    for i in range(len(unique_sizes) - 1):
        diff = unique_sizes[i + 1] - unique_sizes[i]
        if 0 < diff < 0.5:
            warnings.append(f"Near-duplicate sizes: {unique_sizes[i]}pt and {unique_sizes[i+1]}pt (differ by {round(diff, 2)}pt)")

    return {
        "total_spans": len(spans),
        "font_families": sorted(families),
        "unique_sizes_pt": unique_sizes,
        "font_signatures": list(font_sigs.values()),
        "warnings": warnings,
    }


def cmd_fonts(args: argparse.Namespace) -> None:
    """Audit font consistency in a PDF."""
    import json

    src = Path(args.input)
    if src.suffix.lower() != ".pdf":
        print(json.dumps({"error": "Font audit requires a PDF input"}))
        return
    result = audit_fonts_pdf(src)
    print(json.dumps(result, indent=2))


def render_guides_overlay(src: Path, dpi: int) -> Image.Image:
    """Render a figure with alignment guide lines at element edges."""
    from PIL import ImageDraw

    doc = fitz.open(src)
    page = doc[0]
    scale = dpi / 72.0

    # Render base image
    pix = page.get_pixmap(matrix=fitz.Matrix(scale, scale), alpha=False)
    img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
    draw = ImageDraw.Draw(img)
    w, h = img.size

    # Collect element edges from text blocks, images, drawings
    x_edges = set()
    y_edges = set()

    for block in page.get_text("dict")["blocks"]:
        bbox = block["bbox"]
        x_edges.add(bbox[0])
        x_edges.add(bbox[2])
        y_edges.add(bbox[1])
        y_edges.add(bbox[3])

    for d in page.get_drawings():
        r = d["rect"]
        x_edges.add(r.x0)
        x_edges.add(r.x1)
        y_edges.add(r.y0)
        y_edges.add(r.y1)

    # Draw guide lines (semi-transparent red)
    guide_color = (255, 60, 60)
    for x_pt in x_edges:
        x_px = round(x_pt * scale)
        if 0 <= x_px < w:
            draw.line([(x_px, 0), (x_px, h)], fill=guide_color, width=1)
    for y_pt in y_edges:
        y_px = round(y_pt * scale)
        if 0 <= y_px < h:
            draw.line([(0, y_px), (w, y_px)], fill=guide_color, width=1)

    return img


def cmd_guides(args: argparse.Namespace) -> None:
    """Render figure with alignment guide overlay."""
    src = Path(args.input)
    if src.suffix.lower() != ".pdf":
        # For raster input, we can't extract element edges — just pass through
        print(f"Guides overlay requires PDF input (got {src.suffix})")
        return
    img = render_guides_overlay(src, args.dpi)
    img = clamp_size(img)
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    print(out)


def compute_pixel_diff(img_a: Image.Image, img_b: Image.Image, threshold: int = 10) -> Image.Image:
    """Generate a diff image highlighting pixel differences between two images."""
    import numpy as np

    # Resize to match if needed (use larger dimensions)
    w = max(img_a.width, img_b.width)
    h = max(img_a.height, img_b.height)
    if img_a.size != (w, h):
        img_a = img_a.resize((w, h), Image.LANCZOS)
    if img_b.size != (w, h):
        img_b = img_b.resize((w, h), Image.LANCZOS)

    arr_a = np.array(img_a.convert("RGB")).astype(np.int16)
    arr_b = np.array(img_b.convert("RGB")).astype(np.int16)

    # Per-pixel max channel difference
    diff = np.abs(arr_a - arr_b).max(axis=2)
    changed = diff > threshold

    # Build output: grayscale base with red highlighting changes
    gray = np.array(img_b.convert("L").convert("RGB"))
    # Dim unchanged regions
    result = (gray * 0.4).astype(np.uint8)
    # Highlight changes in red, intensity proportional to diff magnitude
    result[changed, 0] = np.clip(diff[changed] * 3, 80, 255).astype(np.uint8)
    result[changed, 1] = 30
    result[changed, 2] = 30

    # Stats
    total_px = w * h
    changed_px = int(np.sum(changed))
    pct = round(100.0 * changed_px / total_px, 2)
    print(f"Changed pixels: {changed_px}/{total_px} ({pct}%)")

    return Image.fromarray(result)


def cmd_diff(args: argparse.Namespace) -> None:
    """Generate a before/after pixel diff image."""
    img_a = load_image(Path(args.before), args.dpi)
    img_b = load_image(Path(args.after), args.dpi)
    result = compute_pixel_diff(img_a, img_b, args.threshold)
    result = clamp_size(result)
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    result.save(out)
    print(out)


def cmd_render(args: argparse.Namespace) -> None:
    img = load_image(Path(args.input), args.dpi)
    img = crop_image(img, args.crop_px, args.crop_frac)
    if args.trim_white:
        img = trim_white(img)
    img = clamp_size(img)
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    print(out)


def cmd_strip(args: argparse.Namespace) -> None:
    images = [Image.open(Path(p)).convert("RGB") for p in args.inputs]
    if args.trim_white:
        images = [trim_white(img) for img in images]

    if args.orientation == "horizontal":
        width = sum(img.width for img in images)
        height = max(img.height for img in images)
        canvas = Image.new("RGB", (width, height), "white")
        x = 0
        for img in images:
            canvas.paste(img, (x, 0))
            x += img.width
    else:
        width = max(img.width for img in images)
        height = sum(img.height for img in images)
        canvas = Image.new("RGB", (width, height), "white")
        y = 0
        for img in images:
            canvas.paste(img, (0, y))
            y += img.height

    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas = clamp_size(canvas)
    canvas.save(out)
    print(out)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Create publication-QC view artifacts from PDFs or images.")
    sub = parser.add_subparsers(dest="command", required=True)

    render = sub.add_parser("render", help="Render a PDF or copy/crop an image into a QC PNG.")
    render.add_argument("input", help="Input PDF or image path")
    render.add_argument("output", help="Output image path")
    render.add_argument("--dpi", type=int, default=300, help="DPI for PDF rendering")
    render.add_argument("--crop-px", help="Crop rectangle as left,top,right,bottom in pixels")
    render.add_argument("--crop-frac", help="Crop rectangle as left,top,right,bottom as 0-1 fractions")
    render.add_argument("--trim-white", action="store_true", help="Trim surrounding white space")
    render.set_defaults(func=cmd_render)

    strip = sub.add_parser("strip", help="Combine multiple PNGs into a strip view.")
    strip.add_argument("output", help="Output image path")
    strip.add_argument("inputs", nargs="+", help="Input image paths")
    strip.add_argument("--orientation", choices=["horizontal", "vertical"], default="horizontal")
    strip.add_argument("--trim-white", action="store_true", help="Trim white space on each input first")
    strip.set_defaults(func=cmd_strip)

    spatial = sub.add_parser("spatial", help="Analyze whitespace, margins, gutters, and element positions.")
    spatial.add_argument("input", help="Input PDF or image path")
    spatial.add_argument("--dpi", type=int, default=300, help="DPI for rasterizing PDF (for raster analysis)")
    spatial.set_defaults(func=cmd_spatial)

    fonts = sub.add_parser("fonts", help="Audit font consistency in a PDF (families, sizes, weights).")
    fonts.add_argument("input", help="Input PDF path")
    fonts.set_defaults(func=cmd_fonts)

    guides = sub.add_parser("guides", help="Render PDF with red alignment guide lines at element edges.")
    guides.add_argument("input", help="Input PDF path")
    guides.add_argument("output", help="Output image path")
    guides.add_argument("--dpi", type=int, default=300, help="DPI for rendering")
    guides.set_defaults(func=cmd_guides)

    diff = sub.add_parser("diff", help="Generate a before/after pixel diff image.")
    diff.add_argument("before", help="Before image or PDF path")
    diff.add_argument("after", help="After image or PDF path")
    diff.add_argument("output", help="Output diff image path")
    diff.add_argument("--dpi", type=int, default=300, help="DPI for PDF rendering")
    diff.add_argument("--threshold", type=int, default=10, help="Per-channel difference threshold (0-255)")
    diff.set_defaults(func=cmd_diff)

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
