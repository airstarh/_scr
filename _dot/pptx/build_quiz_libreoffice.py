import os
import re
import uno
from com.sun.star.awt import Point, Size
from com.sun.star.beans import PropertyValue

ROOT = os.path.abspath(os.path.dirname(__file__))
SOURCE = os.path.join(ROOT, "aitxt")
BACKGROUND = os.path.join(ROOT, "bg.png")
OUT_ODP = os.path.join(ROOT, "Квиз_День_города_Воронеж.odp")
OUT_PPTX = os.path.join(ROOT, "Квиз_День_города_Воронеж.pptx")

W, H = 33867, 19050
WHITE = 0xFFFFFF
GOLD = 0xFFD166
GREEN = 0x55D68B
NAVY = 0x10223A
BLUE = 0x2878B5

CATEGORY_NAMES = [
    "Памятники Воронежа",
    "Вкусный Воронеж",
    "Эпоха Петра",
    "Лица Воронежа",
    "Охраняемые территории",
    "Улицы нашего города",
]


def file_url(path):
    return uno.systemPathToFileUrl(os.path.abspath(path))


def prop(name, value):
    p = PropertyValue()
    p.Name = name
    p.Value = value
    return p


def clean(s):
    s = s.replace("‑", "-").replace("*юон", "он")
    s = re.sub(r"\s+", " ", s).strip()
    return s


def parse_questions():
    lines = open(SOURCE, encoding="utf-8").read().splitlines()
    headings = {
        "1. памятники воронежа": 0,
        "2. «вкусный воронеж»": 1,
        "3. эпоха петра": 2,
        "4. лица воронежа": 3,
        "5. охраняемые территории": 4,
        "6. улицы нашего города": 5,
    }
    groups = [[] for _ in range(6)]
    cat = None
    current = None
    for raw in lines:
        line = clean(raw)
        if not line or re.fullmatch(r"\d\d:\d\d", line):
            continue
        key = line.lower()
        if key in headings:
            if current and cat is not None:
                groups[cat].append(current)
            current = None
            cat = headings[key]
            continue
        if cat is None:
            continue
        qm = re.match(r"^(\d+)\.\s*(.+)", line)
        if qm and not line.lower().startswith(("правильный ответ", "✅")):
            if current:
                groups[cat].append(current)
            current = {"question": qm.group(2), "options": [], "answer": ""}
            continue
        om = re.match(r"^([АБВГ])\)\s*(.+?)[;.]?$", line)
        if om and current is not None:
            current["options"].append(f"{om.group(1)}) {om.group(2).rstrip(';').rstrip('.')}")
            continue
        am = re.match(r"^(?:✅\s*)?Правильный ответ:\s*([АБВГ])(?:\)\s*(.*?))?\.?$", line, re.I)
        if am and current is not None:
            current["answer"] = am.group(1).upper()
            continue
        if current is not None and not current["options"]:
            current["question"] += " " + line
    if current and cat is not None:
        groups[cat].append(current)
    for index, group in enumerate(groups):
        if len(group) != 7:
            raise RuntimeError(f"В разделе {index + 1} найдено {len(group)} вопросов вместо 7")
        for q in group:
            if len(q["options"]) != 4 or q["answer"] not in "АБВГ":
                raise RuntimeError(f"Ошибка разбора вопроса: {q}")
    return groups


def add_shape(doc, page, kind, x, y, w, h):
    shape = doc.createInstance(kind)
    shape.Position = Point(x, y)
    shape.Size = Size(w, h)
    page.add(shape)
    return shape


def add_rect(doc, page, x, y, w, h, color=NAVY, transparency=16, radius=450, line=0xFFFFFF):
    s = add_shape(doc, page, "com.sun.star.drawing.RectangleShape", x, y, w, h)
    s.FillColor = color
    s.FillTransparence = transparency
    s.LineColor = line
    s.LineTransparence = 55
    s.LineWidth = 35
    s.CornerRadius = radius
    return s


def add_text(doc, page, text, x, y, w, h, size=24, color=WHITE, bold=False,
             align=1, valign=2, fill=None, transparency=0, border=None, link=None):
    if fill is None:
        s = add_shape(doc, page, "com.sun.star.drawing.TextShape", x, y, w, h)
        s.FillStyle = 0
        s.LineStyle = 0
    else:
        s = add_rect(doc, page, x, y, w, h, fill, transparency, 350, border or fill)
    s.String = text
    s.CharFontName = "Liberation Sans"
    s.CharHeight = float(size)
    s.CharColor = color
    s.CharWeight = 150.0 if bold else 100.0
    s.ParaAdjust = align
    s.TextVerticalAdjust = valign
    s.TextLeftDistance = 280
    s.TextRightDistance = 280
    s.TextUpperDistance = 120
    s.TextLowerDistance = 120
    if link:
        s.String = ""
        field = doc.createInstance("com.sun.star.text.textfield.URL")
        field.URL = link
        field.Representation = text
        field.TargetFrame = ""
        cursor = s.createTextCursor()
        s.insertTextContent(cursor, field, False)
        cursor.gotoEnd(True)
        cursor.CharFontName = "Liberation Sans"
        cursor.CharHeight = float(size)
        cursor.CharColor = color
        cursor.CharWeight = 150.0 if bold else 100.0
        cursor.CharUnderline = 0
    return s


def add_background(doc, page):
    bg = add_shape(doc, page, "com.sun.star.drawing.GraphicObjectShape", 0, 0, W, H)
    bg.GraphicURL = file_url(BACKGROUND)
    bg.MoveProtect = True
    bg.SizeProtect = True


def new_slide(doc, pages, number):
    if number == 1:
        page = pages.getByIndex(0)
    else:
        page = pages.insertNewByIndex(pages.getCount())
    page.Width = W
    page.Height = H
    page.Name = f"page{number}"
    add_background(doc, page)
    return page


def question_font(text):
    n = len(text)
    if n > 190:
        return 23
    if n > 140:
        return 26
    if n > 95:
        return 29
    return 33


def option_font(options):
    n = max(map(len, options))
    if n > 105:
        return 18
    if n > 75:
        return 20
    if n > 52:
        return 22
    return 24


def build_question_slide(doc, page, cat_name, points, item, reveal, board_slide=2):
    add_rect(doc, page, 900, 500, 32067, 17850, NAVY, 12, 450, 0xB9D8F0)
    add_text(doc, page, cat_name.upper(), 1300, 750, 24300, 900, 20, GOLD, True, 0, 2)
    add_text(doc, page, f"{points} БАЛЛОВ", 26700, 720, 4900, 900, 22, WHITE, True, 1, 2,
             BLUE, 4, 0xB9D8F0)
    add_text(doc, page, item["question"], 1450, 1900, 30900, 3900,
             question_font(item["question"]), WHITE, True, 1, 2)
    colors = [0x1C395B, 0x21476C, 0x1C395B, 0x21476C]
    y0, gap, box_h = 6250, 2150, 1740
    letters = "АБВГ"
    for i, option in enumerate(item["options"]):
        correct = letters[i] == item["answer"]
        fill = GREEN if reveal and correct else colors[i]
        txt_color = 0x0A2B1D if reveal and correct else WHITE
        prefix = "✓  " if reveal and correct else ""
        add_text(doc, page, prefix + option, 1900, y0 + i * gap, 30050, box_h,
                 option_font(item["options"]), txt_color, reveal and correct, 0, 2,
                 fill, 5, 0xB9D8F0)
    add_text(doc, page, "← К игровому полю", 1200, 16650, 6100, 1000, 18, WHITE, True, 1, 2,
             BLUE, 4, 0xB9D8F0, f"#page{board_slide}")
    if reveal:
        answer_text = f"Правильный ответ: {item['answer']}"
        add_text(doc, page, answer_text, 11650, 16650, 10500, 1000, 20, 0x0A2B1D, True, 1, 2,
                 GREEN, 1, GREEN)
    else:
        add_text(doc, page, "Показать ответ →", 25700, 16650, 6200, 1000, 18, WHITE, True, 1, 2,
                 BLUE, 4, 0xB9D8F0, f"#page{int(re.search(r'\d+', page.Name).group()) + 1}")


def main():
    groups = parse_questions()
    local_ctx = uno.getComponentContext()
    resolver = local_ctx.ServiceManager.createInstanceWithContext(
        "com.sun.star.bridge.UnoUrlResolver", local_ctx)
    ctx = resolver.resolve("uno:socket,host=127.0.0.1,port=2002;urp;StarOffice.ComponentContext")
    smgr = ctx.ServiceManager
    desktop = smgr.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
    doc = desktop.loadComponentFromURL("private:factory/simpress", "_blank", 0, (prop("Hidden", True),))
    pages = doc.getDrawPages()

    # 1. Титульный слайд
    page = new_slide(doc, pages, 1)
    add_rect(doc, page, 2400, 2550, 29067, 13300, NAVY, 18, 700, 0xDDECF8)
    add_text(doc, page, "КВИЗ НА ТЕМУ:", 4300, 4700, 25200, 1300, 30, GOLD, True, 1, 2)
    add_text(doc, page, "ДЕНЬ ГОРОДА", 3000, 6200, 27800, 2600, 54, WHITE, True, 1, 2)
    add_text(doc, page, "ВОРОНЕЖ", 6500, 9000, 20800, 1400, 28, GOLD, True, 1, 2)
    add_text(doc, page, "НАЧАТЬ ИГРУ  →", 11100, 12400, 11600, 1400, 22, WHITE, True, 1, 2,
             BLUE, 2, 0xDDECF8, "#page2")

    # 2. Игровое поле
    page = new_slide(doc, pages, 2)
    add_rect(doc, page, 650, 350, 32567, 18350, NAVY, 12, 450, 0xDDECF8)
    add_text(doc, page, "ВЫБЕРИТЕ ТЕМУ И СТОИМОСТЬ ВОПРОСА", 1300, 600, 31300, 1100,
             28, WHITE, True, 1, 2)
    margin, gap = 1100, 180
    col_w = (W - 2 * margin - 5 * gap) // 6
    header_y, header_h = 2050, 2500
    row_h, row_gap = 1700, 210
    accents = [0x1D6FA5, 0xC9821D, 0x6D4BA8, 0xB64656, 0x247C69, 0x8B6239]
    for c, cat_name in enumerate(CATEGORY_NAMES):
        x = margin + c * (col_w + gap)
        add_text(doc, page, cat_name, x, header_y, col_w, header_h, 17, WHITE, True, 1, 2,
                 accents[c], 3, 0xDDECF8)
        for r, points in enumerate(range(50, 351, 50)):
            slide_no = 3 + (c * 7 + r) * 2
            y = header_y + header_h + 240 + r * (row_h + row_gap)
            add_text(doc, page, str(points), x, y, col_w, row_h, 28, GOLD, True, 1, 2,
                     0x173555, 4, accents[c], f"#page{slide_no}")
    add_text(doc, page, "ЗАВЕРШИТЬ ИГРУ", 13700, 17650, 6500, 780, 15, WHITE, True, 1, 2,
             BLUE, 4, 0xDDECF8, "#page87")

    # 3–86. Вопросы и ответы
    slide_no = 3
    for c, group in enumerate(groups):
        for r, item in enumerate(group):
            q_page = new_slide(doc, pages, slide_no)
            build_question_slide(doc, q_page, CATEGORY_NAMES[c], (r + 1) * 50, item, False)
            slide_no += 1
            a_page = new_slide(doc, pages, slide_no)
            build_question_slide(doc, a_page, CATEGORY_NAMES[c], (r + 1) * 50, item, True)
            slide_no += 1

    # 87. Финал
    page = new_slide(doc, pages, 87)
    add_rect(doc, page, 2700, 3200, 28467, 12650, NAVY, 16, 700, 0xDDECF8)
    add_text(doc, page, "СПАСИБО", 4000, 5500, 25800, 2400, 56, WHITE, True, 1, 2)
    add_text(doc, page, "ЗА ИГРУ!", 4000, 7900, 25800, 2200, 52, GOLD, True, 1, 2)
    add_text(doc, page, "До новых встреч в Воронеже", 6000, 11200, 21800, 1200, 24, WHITE, False, 1, 2)
    add_text(doc, page, "↶ Сыграть ещё раз", 11200, 13900, 11400, 1100, 20, WHITE, True, 1, 2,
             BLUE, 3, 0xDDECF8, "#page2")

    doc.storeAsURL(file_url(OUT_ODP), (prop("FilterName", "impress8"), prop("Overwrite", True)))
    doc.storeToURL(file_url(OUT_PPTX), (prop("FilterName", "Impress MS PowerPoint 2007 XML"), prop("Overwrite", True)))
    doc.close(True)
    print(OUT_ODP)
    print(OUT_PPTX)


if __name__ == "__main__":
    main()
