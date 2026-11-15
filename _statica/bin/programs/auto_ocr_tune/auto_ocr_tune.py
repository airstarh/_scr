import os, glob, cv2, pytesseract
import numpy as np

INPUT_DIR = "./blurred_docs"
OUTPUT_DIR = "./readable_docs"
TARGET_CONFIDENCE = 78.0  # Stop early once average word confidence hits this %
os.makedirs(OUTPUT_DIR, exist_ok=True)

def get_ocr_score(img):
    data = pytesseract.image_to_data(img, output_type=pytesseract.Output.DICT, config="--psm 6")
    confs = [int(c) for c, w in zip(data["conf"], data["text"]) if int(c) > 0 and len(w.strip()) > 1]
    if len(confs) < 5:  # Ignore noise if fewer than 5 real words are found
        return 0.0, ""
    text = " ".join(w for w in data["text"] if w.strip())
    return float(np.mean(confs)), text

def generate_candidates(gray):
    # 1. Raw grayscale & 2x upscale (helps Tesseract read small blurred text)
    up = cv2.resize(gray, None, fx=2.0, fy=2.0, interpolation=cv2.INTER_CUBIC)
    yield "upscaled", up

    # 2. Test different sharpening strengths + adaptive thresholds
    for sigma in [1.0, 2.0, 3.0]:
        blur = cv2.GaussianBlur(up, (0, 0), sigma)
        sharp = cv2.addWeighted(up, 1.8, blur, -0.8, 0)
        yield f"sharp_s{sigma}", sharp

        for block_size in [21, 35, 51]:
            for c_val in [8, 15]:
                thresh = cv2.adaptiveThreshold(
                    sharp, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, block_size, c_val
                )
                yield f"sharp_s{sigma}_b{block_size}_c{c_val}", thresh

for path in sorted(glob.glob(f"{INPUT_DIR}/*.*")):
    img = cv2.imread(path)
    if img is None:
        continue
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    best_score, best_img, best_name, best_text = -1.0, gray, "original", ""
    for name, candidate in generate_candidates(gray):
        score, text = get_ocr_score(candidate)
        if score > best_score:
            best_score, best_img, best_name, best_text = score, candidate, name, text
        if best_score >= TARGET_CONFIDENCE:
            break  # Stop immediately once the image is clearly readable

    fname = os.path.basename(path)
    cv2.imwrite(f"{OUTPUT_DIR}/{fname}", best_img)
    with open(f"{OUTPUT_DIR}/{fname}.txt", "w") as f:
        f.write(best_text)
    print(f"{fname}: best={best_name} (confidence={best_score:.1f}%)")
