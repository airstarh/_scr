import os, glob, time, cv2, pytesseract
import numpy as np
from PIL import Image, ImageOps

INPUT_DIR = "./blurred_docs"
OUTPUT_DIR = "./readable_docs"
TARGET_CONFIDENCE = 84.0
MAX_WIDTH = 2400
LANG = "rus+eng"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def load_upright_gray(path):
    pil_img = ImageOps.exif_transpose(Image.open(path)).convert("L")
    gray = np.array(pil_img)
    h, w = gray.shape
    scale = MAX_WIDTH / float(w)
    gray = cv2.resize(gray, None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA if scale < 1 else cv2.INTER_CUBIC)
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
    # Finds the main bright document sheet on a darker background and crops away desk clutter
    h, w = gray.shape
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
    # Straightens tilted pages by maximizing horizontal text-line sharpness
    h, w = gray.shape
    small_w = 800
    scale = small_w / float(w)
    small = cv2.resize(gray, None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA)
    edges = cv2.Canny(small, 50, 150)

    best_angle = 0.0
    best_score = -1.0
    center = (small.shape[1] // 2, small.shape[0] // 2)

    for angle in np.arange(-max_angle, max_angle + 0.5, 0.5):
        M = cv2.getRotationMatrix2D(center, angle, 1.0)
        rotated = cv2.warpAffine(edges, M, (small.shape[1], small.shape[0]), flags=cv2.INTER_NEAREST)
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
    pad_h, pad_w = img.shape
    kh, kw = kernel.shape
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
    # Removes glare and shadows while keeping paper smooth and grain-free
    denoised = cv2.bilateralFilter(gray, d=5, sigmaColor=35, sigmaSpace=35)
    bg = cv2.medianBlur(denoised, 91)
    norm = cv2.divide(denoised, bg, scale=255)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8)).apply(norm)
    return clahe

def enhance_bw_contrast(gray, black_point=92, white_point=196, gamma=1.02):
    # Clean white paper + crisp, normal-weight black letters without bolding
    stretched = np.clip((gray.astype(np.float32) - black_point) / (white_point - black_point), 0.0, 1.0)
    curved = np.power(stretched, gamma)
    return (curved * 255.0).astype(np.uint8)

def get_ocr_score(img):
    data = pytesseract.image_to_data(img, lang=LANG, output_type=pytesseract.Output.DICT, config="--psm 3")
    confs = [int(c) for c, w in zip(data["conf"], data["text"]) if int(c) > 0 and len(w.strip()) > 1]
    if len(confs) < 5:
        return 0.0, ""
    text = " ".join(w for w in data["text"] if w.strip())
    return float(np.mean(confs)), text

def generate_candidates(gray):
    base = clean_document_bg(gray)

    # 1. Smooth unsharp mask (compresses blur without rough pixelation)
    blur = cv2.GaussianBlur(base, (0, 0), 1.6)
    sharp = cv2.addWeighted(base, 2.1, blur, -1.1, 0)
    yield "crisp_smooth_bw", enhance_bw_contrast(sharp)

    # 2. Gentle background-cleaned pass
    yield "clean_bg_bw", enhance_bw_contrast(base)

    # 3. Out-of-focus deconvolution
    for r in (3, 5, 7):
        deblur = wiener_deblur(base, disk_kernel(r), snr=0.02)
        yield f"defocus_r{r}_bw", enhance_bw_contrast(deblur)

    # 4. Motion-shake deconvolution
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

    h, w = gray.shape
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
