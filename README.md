# Flappy Bird — Turing
A Flappy Bird clone built from scratch in Turing with sprite-based rendering, sine-wave jump physics, and a secret ending at score 100.

![demo](assets/demo.gif)

---

## Overview
Full reimplementation of Flappy Bird using Turing's built-in graphics modules, compositing 20+ BMP sprites per frame with double-buffered rendering. Built as a high school CS project to explore game loops, collision detection, and animation without any game engine. The day/night background cycle, sprite-digit score display, and a hidden congratulations sequence at score 100 push it beyond a basic clone.

---

## Features
- Animated 3-frame bird wing-flap cycle (down / middle / up)
- Sine-wave jump arc using trigonometric interpolation for a natural feel
- Randomized pipe gap heights on every reset
- Seamlessly scrolling ground tile
- Day/night background cycling every 25 points
- Sprite-based score display using individual BMP digit images (0–99)
- Session high score tracked across restarts
- Double-buffered rendering — zero flicker
- Hidden win condition at score 100

---

## Getting Started

### Prerequisites
- [Turing IDE](https://compsci.ca/holtsoft/) (Windows) or [Open Turing](https://github.com/Open-Turing-Project/OpenTuring) (macOS/Linux)
- All BMP asset files placed in the same directory as the `.t` source file (not tracked in this repo)

### Run
```bash
# clone the repo
git clone https://github.com/taehyunnnnn/flappyBird.turing

# navigate into it
cd flappyBird.turing
```
Then open `Flappy Bird Final.t` in the Turing IDE and press **F1** (Run).

---

## Controls
| Input | Action |
|---|---|
| `Space` | Start game / Flap / Restart after death |

---

## What I Learned
- Implementing a game loop that separates physics and collision updates from render calls inside a timed tick
- AABB collision detection by computing axis-aligned bounding box overlaps from coordinate deltas
- Trigonometric animation — using `sind(angle)` over a 0°–180° sweep to produce a smooth, natural jump arc
- Sprite compositing — layering multiple BMP images each frame to build a full scene without a scene graph
- Double buffering with `View.Set("offscreenonly")` and `View.Update` to eliminate screen tearing

---

## Author
**Taehyun Im**
[GitHub](https://github.com/taehyunnnnn) · [Portfolio](https://taehyun.pages.dev) · [LinkedIn](https://linkedin.com/in/taehyunim)

---

## Acknowledgments
- Co-built with **Nihaal Nijjar** — January 2023
- Inspired by the original Flappy Bird by .GEARS Studios
- BMP sprite assets sourced separately (not tracked in this repo)
