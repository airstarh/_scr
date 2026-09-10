# `box-shadow` Parameter Order Explained

```css
box-shadow: 0 0 50px 15px rgba(111, 111, 111, 0.7);
/*          ↑ ↑  ↑    ↑   ↑
            │ │  │    │   └── 5. color
            │ │  │    └────── 4. spread radius
            │ │  └─────────── 3. blur radius
            │ └────────────── 2. vertical offset (Y)
            └──────────────── 1. horizontal offset (X)
*/
```

## The Full Syntax

```css
box-shadow: offset-x offset-y blur-radius spread-radius color;
```

Optionally, you can add `inset` at the **beginning**:

```css
box-shadow: inset offset-x offset-y blur-radius spread-radius color;
```

## Breaking Down Each Parameter

| # | Parameter | Value in your example | Meaning |
|---|-----------|----------------------|---------|
| 1 | **offset-x** | `0` | Horizontal shift. Positive = shadow moves **right**, negative = **left**. |
| 2 | **offset-y** | `0` | Vertical shift. Positive = shadow moves **down**, negative = **up**. |
| 3 | **blur-radius** | `50px` | How soft/blurry the edge is. `0` = sharp edge. Larger = softer, more diffuse. |
| 4 | **spread-radius** | `15px` | Expands (positive) or shrinks (negative) the shadow **before** blurring. |
| 5 | **color** | `rgba(111, 111, 111, 0.7)` | Shadow color. Use `rgba()` / `hsla()` for transparency. |

## What Your Specific Shadow Does

```css
box-shadow: 0 0 50px 15px rgba(111, 111, 111, 0.7);
```

- **`0 0`** → no offset, so the shadow sits **directly behind** the element (a "glow" effect, not a directional shadow).
- **`50px` blur** → very soft, diffuse edges.
- **`15px` spread** → the shadow is expanded 15px in all directions *before* blurring, making it larger than the element itself.
- **`rgba(111, 111, 111, 0.7)`** → medium gray at 70% opacity.

**Result:** A soft, centered, gray glow surrounding the element.

## Visual Guide

```
        offset-y (down +)
             ↓
   ┌──────────────────┐
   │                  │
←──│      element     │──→  offset-x (+ = right)
   │                  │
   └──────────────────┘
             ↑
        offset-y (up −)

blur-radius  → softens the edge (gradient outward)
spread-radius → grows (+) or shrinks (−) the shadow box
```

## Examples to Compare

### Directional shadow (classic drop shadow)
```css
box-shadow: 4px 4px 8px rgba(0, 0, 0, 0.3);
/*          →   ↓    blur   color
   Shadow cast to bottom-right */
```

### Centered glow (like your example)
```css
box-shadow: 0 0 50px 15px rgba(111, 111, 111, 0.7);
/*          – –  blur  spread  color
   Symmetrical glow around the element */
```

### Inner shadow
```css
box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2);
/*          ↑     ↓  ↓    blur
   Shadow inside the element, pushed down slightly */
```

### Hard-edge shadow (no blur)
```css
box-shadow: 6px 6px 0 #000;
/*          →   ↓   0 = sharp
   Solid offset block, retro/skeuomorphic look */
```

## Rules to Remember

1. **Order matters** — always: `x → y → blur → spread → color`.
2. **`x` and `y` are required.** `blur`, `spread`, and `color` are optional.
3. **`0` means no offset** — the shadow stays centered.
4. **Positive spread grows**, negative spread shrinks the shadow.
5. **`inset` must come first** (before offsets) to make it an inner shadow.
6. **Color defaults to the browser's text color** if omitted (rarely what you want — always specify).
7. **Multiple shadows** — separate with commas, first one is on top:
   ```css
   box-shadow:
     0 1px 2px rgba(0,0,0,.1),
     0 4px 8px rgba(0,0,0,.08),
     0 8px 16px rgba(0,0,0,.06);
   ```
8. **Blur vs spread**: blur softens the edge outward; spread scales the shadow *before* blurring. A big blur with no spread = fuzzy edges. A big spread with small blur = a larger, still-defined shape.

## Quick Mental Model

```
blur   = how fuzzy the edge is
spread = how much bigger/smaller the shadow box is
offset = where the shadow is positioned relative to the element
color  = what the shadow looks like (use alpha for realism)
```
