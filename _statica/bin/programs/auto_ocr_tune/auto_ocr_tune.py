import os, glob, time, cv2, pytesseract
import numpy as np
from PIL import Image, ImageOps

INPUT_DIR = "./blurred_docs"
OUTPUT_DIR = "./readable_docs"
TARGET_CONFIDENCE = 86.0
MAX_WIDTH = 2800
LANG = "rus+eng"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def load_upright_gray(path):
    pil_img = ImageOps.exif_transpose(Image.open(path)).convert("L")
    gray = np.array(pil_img)
    h, w = gray.shape[:2]
    scale = MAX_WIDTH / float(w)
    gray = cv2.resize(
        gray, None, fx=scale, fy=scale,
        interpolation=cv2.INTER_AREA if scale < 1 else cv2.INTER_LANCZOS4
    )
    try:
        osd = pytesseract.image_to_osd(gray, output_type=pytesseract.Output.DICT)
        rot = osd.get("rotate", 0)
        if rot == 90:
            gray = cv2.rotate(gray, cv2.ROTATE_90_CLOCKWISE)
        elif rot == 180:
            gray = cv2.rotate(gray, cv2.ROTATE_180)
        elif rot == 270:
            gray = cv2.rotate(gray, cv2.ROTATE_90_COUNTERCLOCKWISE)
    except Exception:
        pass
    return gray

def auto_crop_page(gray):
    h, w = gray.shape[:2]
    blur = cv2.GaussianBlur(gray, (21, 21), 0)
    _, mask = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return gray
    largest = max(contours, key=cv2.contourArea)
    if cv2.contourArea(largest) < (h * w * 0.25):
        return gray
    x, y, cw, ch = cv2.boundingRect(largest)
    pad = 15
    x1, y1 = max(0, x - pad), max(0, y - pad)
    x2, y2 = min(w, x + cw + pad), min(h, y + ch + pad)
    return gray[y1:y2, x1:x2]

def auto_deskew(gray, max_angle=12.0):
    h, w = gray.shape[:2]
    small_w = 800
    scale = small_w / float(w)
    small = cv2.resize(gray, None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA)
    edges = cv2.Canny(small, 50, 150)

    best_angle = 0.0
    best_score = -1.0
    sh, sw = small.shape[:2]
    center = (sw // 2, sh // 2)

    for angle in np.arange(-max_angle, max_angle + 0.5, 0.5):
        M = cv2.getRotationMatrix2D(center, angle, 1.0)
        rotated = cv2.warpAffine(edges, M, (sw, sh), flags=cv2.INTER_NEAREST)
        row_sums = np.sum(rotated, axis=1, dtype=np.float64)
        score = np.var(row_sums)
        if score > best_score:
            best_score = score
            best_angle = angle

    if abs(best_angle) < 0.3:
        return gray

    full_center = (w // 2, h // 2)
    M_full = cv2.getRotationMatrix2D(full_center, best_angle, 1.0)
    return cv2.warpAffine(gray, M_full, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)

def wiener_deblur(gray, kernel, snr=0.015):
    img = gray.astype(np.float32) / 255.0
    pad_h, pad_w = img.shape[:2]
    kh, kw = kernel.shape[:2]
    psf = np.zeros((pad_h, pad_w), dtype=np.float32)
    psf[:kh, :kw] = kernel / kernel.sum()
    psf = np.roll(psf, (-kh // 2, -kw // 2), axis=(0, 1))

    H = np.fft.fft2(psf)
    G = np.fft.fft2(img)
    F_hat = np.conj(H) * G / (np.abs(H) ** 2 + snr)
    res = np.real(np.fft.ifft2(F_hat))
    return np.clip(res * 255.0, 0, 255).astype(np.uint8)

def disk_kernel(radius):
    L = np.arange(-radius, radius + 1)
    X, Y = np.meshgrid(L, L)
    return ((X**2 + Y**2) <= radius**2).astype(np.float32)

def motion_kernel(length, angle):
    k = np.zeros((length, length), dtype=np.float32)
    k[length // 2, :] = 1.0
    M = cv2.getRotationMatrix2D((length / 2 - 0.5, length / 2 - 0.5), angle, 1.0)
    return cv2.warpAffine(k, M, (length, length))

def clean_document_bg(gray):
    bg = cv2.medianBlur(gray, 61)
    norm = cv2.divide(gray, bg, scale=255)
    clahe = cv2.createCLAHE(clipLimit=2.4, tileGridSize=(12, 12)).apply(norm)
    return clahe

def enhance_bw_contrast(gray, black_point=96, white_point=196, gamma=1.05):
    stretched = np.clip((gray.astype(np.float32) - black_point) / (white_point - black_point), 0.0, 1.0)
    curved = np.power(stretched, gamma)
    return (curved * 255.0).astype(np.uint8)

def blend_by_focus(sharp_img, deblur_img, raw_gray):
    lap = np.abs(cv2.Laplacian(raw_gray, cv2.CV_32F))
    focus_map = cv2.GaussianBlur(lap, (0, 0), 65)
    f_min, f_max = np.percentile(focus_map, 10), np.percentile(focus_map, 90)
    if f_max - f_min < 1e-5:
        return deblur_img
    blur_weight = 1.0 - np.clip((focus_map - f_min) / (f_max - f_min), 0.0, 1.0)
    blended = deblur_img.astype(np.float32) * blur_weight + sharp_img.astype(np.float32) * (1.0 - blur_weight)
    return np.clip(blended, 0, 255).astype(np.uint8)

def get_ocr_score(img):
    h, w = img.shape[:2]
    data = pytesseract.image_to_data(img, lang=LANG, output_type=pytesseract.Output.DICT, config="--psm 3")
    top_confs, bot_confs, words = [], [], []
    for c, w_txt, top in zip(data["conf"], data["text"], data["top"]):
        w_clean = w_txt.strip()
        if w_clean:
            words.append(w_clean)
        if int(c) > 0 and len(w_clean) > 1:
            if top < h * 0.42:
                top_confs.append(int(c))
            else:
                bot_confs.append(int(c))
    if len(bot_confs) < 5:
        return 0.0, ""
    bot_score = float(np.mean(bot_confs))
    top_score = float(np.mean(top_confs)) if len(top_confs) >= 3 else bot_score
    combined = 0.65 * top_score + 0.35 * bot_score
    return combined, " ".join(words)

def generate_candidates(gray):
    base = clean_document_bg(gray)

    fine_blur = cv2.GaussianBlur(base, (0, 0), 1.0)
    fine_sharp = cv2.addWeighted(base, 1.65, fine_blur, -0.65, 0)
    med_blur = cv2.GaussianBlur(fine_sharp, (0, 0), 2.2)
    dual_sharp = cv2.addWeighted(fine_sharp, 1.5, med_blur, -0.5, 0)

    for r in (3, 4, 5):
        deblur = wiener_deblur(base, disk_kernel(r), snr=0.018)
        d_blur = cv2.GaussianBlur(deblur, (0, 0), 1.0)
        deblur_crisp = cv2.addWeighted(deblur, 1.4, d_blur, -0.4, 0)
        adaptive = blend_by_focus(dual_sharp, deblur_crisp, gray)
        yield f"focus_blend_r{r}", enhance_bw_contrast(adaptive)

    for r in (4, 6):
        deblur = wiener_deblur(base, disk_kernel(r), snr=0.02)
        yield f"full_defocus_r{r}", enhance_bw_contrast(deblur)

    yield "dual_sharp_bw", enhance_bw_contrast(dual_sharp)

    for angle in (0, 45, 90, 135):
        m_deblur = wiener_deblur(base, motion_kernel(11, angle), snr=0.02)
        yield f"motion_a{angle}_bw", enhance_bw_contrast(m_deblur)

for path in sorted(glob.glob(f"{INPUT_DIR}/*.*")):
    fname = os.path.basename(path)
    try:
        gray = load_upright_gray(path)
        gray = auto_crop_page(gray)
        gray = auto_deskew(gray)
    except Exception as e:
        print(f"Skipping {fname}: {e}")
        continue

    h, w = gray.shape[:2]
    print(f"Processing {fname} ({w}x{h})...")
    best_score, best_img, best_name, best_text = -1.0, gray, "original", ""

    for name, candidate in generate_candidates(gray):
        t0 = time.time()
        score, text = get_ocr_score(candidate)
        print(f"  -> {name}: {score:.1f}% ({time.time() - t0:.1f}s)")
        if score > best_score:
            best_score, best_img, best_name, best_text = score, candidate, name, text
        if best_score >= TARGET_CONFIDENCE:
            break

    cv2.imwrite(f"{OUTPUT_DIR}/{fname}", best_img)
    with open(f"{OUTPUT_DIR}/{fname}.txt", "w", encoding="utf-8") as f:
        f.write(best_text)
    print(f"DONE {fname}: best={best_name} (confidence={best_score:.1f}%)\n")
