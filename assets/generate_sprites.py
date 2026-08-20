#!/usr/bin/env python3
"""Generate pixel art sprites for Tamabrawler - a cute tamagotchi pet game."""
import os
from PIL import Image

OUT = os.path.join(os.path.dirname(__file__), "images")

# PICO-8 palette (16 colors) - retro vibes
PICO8 = {
    "black":    (0, 0, 0),
    "dark_blue":(29, 43, 83),
    "purple":   (126, 37, 83),
    "dark_green":(0, 135, 81),
    "brown":    (171, 82, 54),
    "dark_gray":(95, 87, 79),
    "light_gray":(194, 195, 199),
    "white":    (255, 241, 232),
    "red":      (255, 0, 77),
    "orange":   (255, 163, 0),
    "yellow":   (255, 236, 39),
    "green":    (0, 228, 54),
    "blue":     (41, 173, 255),
    "indigo":   (131, 118, 156),
    "pink":     (255, 119, 168),
    "peach":    (255, 204, 170),
}

P = PICO8

def new_sprite(w, h, bg_color=(0,0,0,0)):
    """Create a transparent RGBA sprite."""
    img = Image.new("RGBA", (w, h), (0,0,0,0))
    return img

def put(img, x, y, color):
    """Set a pixel at (x,y) to color."""
    if 0 <= x < img.width and 0 <= y < img.height:
        if isinstance(color, tuple) and len(color) == 3:
            color = color + (255,)
        img.putpixel((x, y), color)

def rect(img, x, y, w, h, color):
    """Draw a filled rectangle."""
    for dy in range(h):
        for dx in range(w):
            put(img, x+dx, y+dy, color)

def sprite_pet_idle():
    """Cute round pet standing - 16x16 pixels -> 64x64 at 4x block."""
    img = new_sprite(16, 16)
    # Body - round blob
    for dy in range(4, 12):
        for dx in range(2, 14):
            cx, cy = 8, 7  # center
            # Elliptical body
            if ((dx-cx)**2 / 36 + (dy-cy)**2 / 20) <= 1.0:
                put(img, dx, dy, P["pink"])
    # Head - slightly above body
    for dy in range(2, 6):
        for dx in range(4, 12):
            if ((dx-8)**2 + (dy-4)**2) <= 9:
                put(img, dx, dy, P["peach"])
    # Eyes - big cute eyes
    put(img, 5, 4, P["black"])
    put(img, 6, 4, P["black"])
    put(img, 9, 4, P["black"])
    put(img, 10, 4, P["black"])
    # Eye shine
    put(img, 6, 3, P["white"])
    put(img, 10, 3, P["white"])
    # Mouth - tiny smile
    put(img, 7, 6, P["pink"])
    put(img, 8, 6, P["pink"])
    # Blush
    put(img, 4, 5, P["pink"])
    put(img, 11, 5, P["pink"])
    # Ears
    put(img, 3, 2, P["pink"])
    put(img, 4, 1, P["pink"])
    put(img, 11, 2, P["pink"])
    put(img, 12, 1, P["pink"])
    # Feet
    put(img, 4, 12, P["peach"])
    put(img, 5, 12, P["peach"])
    put(img, 10, 12, P["peach"])
    put(img, 11, 12, P["peach"])
    return img

def sprite_pet_happy():
    """Pet jumping up happily - same but arms up."""
    img = new_sprite(16, 16)
    # Body
    for dy in range(4, 12):
        for dx in range(2, 14):
            cx, cy = 8, 7
            if ((dx-cx)**2 / 36 + (dy-cy)**2 / 20) <= 1.0:
                put(img, dx, dy, P["pink"])
    # Head (slightly higher)
    for dy in range(1, 5):
        for dx in range(4, 12):
            if ((dx-8)**2 + (dy-3)**2) <= 9:
                put(img, dx, dy, P["peach"])
    # Eyes - happy closed (^_^)
    put(img, 5, 3, P["black"])
    put(img, 6, 2, P["black"])
    put(img, 9, 3, P["black"])
    put(img, 10, 2, P["black"])
    # Mouth - wide smile
    put(img, 6, 5, P["red"])
    put(img, 7, 5, P["red"])
    put(img, 8, 5, P["red"])
    put(img, 9, 5, P["red"])
    # Ears
    put(img, 3, 0, P["pink"])
    put(img, 4, 0, P["pink"])
    put(img, 11, 0, P["pink"])
    put(img, 12, 0, P["pink"])
    # Arms up!
    put(img, 1, 4, P["peach"])
    put(img, 14, 4, P["peach"])
    # Feet
    put(img, 4, 12, P["peach"])
    put(img, 5, 12, P["peach"])
    put(img, 10, 12, P["peach"])
    put(img, 11, 12, P["peach"])
    return img

def sprite_pet_sleep():
    """Pet sleeping - curled up."""
    img = new_sprite(16, 16)
    # Curled body (more horizontal)
    for dy in range(5, 11):
        for dx in range(3, 13):
            if ((dx-8)**2 / 25 + (dy-8)**2 / 12) <= 1.0:
                put(img, dx, dy, P["pink"])
    # Head
    for dy in range(3, 7):
        for dx in range(10, 15):
            if ((dx-12)**2 + (dy-5)**2) <= 6:
                put(img, dx, dy, P["peach"])
    # Closed eyes (lines)
    put(img, 11, 4, P["black"])
    put(img, 12, 4, P["black"])
    put(img, 13, 4, P["black"])
    # Zzz
    put(img, 14, 1, P["blue"])
    put(img, 13, 0, P["blue"])
    put(img, 11, 1, P["blue"])
    # Tail curled
    put(img, 2, 6, P["pink"])
    put(img, 1, 7, P["pink"])
    put(img, 2, 8, P["pink"])
    return img

def sprite_pet_attack():
    """Pet in battle stance - fierce but still cute."""
    img = new_sprite(16, 16)
    # Body (slightly leaning forward)
    for dy in range(4, 12):
        for dx in range(2, 14):
            cx, cy = 8, 7
            if ((dx-cx)**2 / 36 + (dy-cy)**2 / 20) <= 1.0:
                put(img, dx, dy, P["pink"])
    # Head
    for dy in range(2, 6):
        for dx in range(4, 14):
            if ((dx-8)**2 + (dy-4)**2) <= 9:
                put(img, dx, dy, P["peach"])
    # Angry eyes (angled down >.<)
    put(img, 5, 4, P["black"])
    put(img, 6, 4, P["black"])
    put(img, 7, 3, P["black"])
    put(img, 9, 4, P["black"])
    put(img, 10, 4, P["black"])
    put(img, 11, 3, P["black"])
    # Angry eyebrows
    put(img, 3, 1, P["black"])
    put(img, 4, 2, P["black"])
    put(img, 5, 3, P["black"])
    put(img, 11, 3, P["black"])
    put(img, 12, 2, P["black"])
    put(img, 13, 1, P["black"])
    # Battle cry mouth
    put(img, 7, 6, P["red"])
    put(img, 8, 6, P["white"])
    put(img, 9, 6, P["red"])
    # Fist
    put(img, 14, 5, P["peach"])
    put(img, 15, 4, P["peach"])
    put(img, 15, 5, P["peach"])
    # Feet
    put(img, 4, 12, P["peach"])
    put(img, 5, 12, P["peach"])
    put(img, 10, 12, P["peach"])
    put(img, 11, 12, P["peach"])
    return img

def sprite_enemy_slime():
    """Cute slime enemy."""
    img = new_sprite(16, 16)
    # Body - blob
    for dy in range(4, 12):
        for dx in range(3, 13):
            if ((dx-8)**2 / 25 + (dy-7)**2 / 30) <= 1.0:
                put(img, dx, dy, P["green"])
    # Eyes
    put(img, 6, 5, P["white"])
    put(img, 7, 5, P["white"])
    put(img, 9, 5, P["white"])
    put(img, 10, 5, P["white"])
    put(img, 6, 5, P["black"])
    put(img, 9, 5, P["black"])
    # Mouth
    put(img, 7, 7, P["dark_green"])
    put(img, 8, 7, P["dark_green"])
    return img

def sprite_enemy_bat():
    """Cute bat enemy."""
    img = new_sprite(16, 16)
    # Body
    for dy in range(4, 10):
        for dx in range(5, 11):
            if ((dx-8)**2 + (dy-7)**2) <= 9:
                put(img, dx, dy, P["purple"])
    # Wings
    put(img, 2, 5, P["purple"])
    put(img, 1, 5, P["purple"])
    put(img, 0, 6, P["purple"])
    put(img, 0, 7, P["purple"])
    put(img, 13, 5, P["purple"])
    put(img, 14, 5, P["purple"])
    put(img, 15, 6, P["purple"])
    put(img, 15, 7, P["purple"])
    # Eyes
    put(img, 6, 5, P["red"])
    put(img, 7, 5, P["red"])
    put(img, 9, 5, P["red"])
    put(img, 10, 5, P["red"])
    put(img, 6, 5, P["white"])
    put(img, 7, 5, P["white"])
    put(img, 9, 5, P["white"])
    put(img, 10, 5, P["white"])
    put(img, 6, 5, P["black"])
    put(img, 9, 5, P["black"])
    # Ears
    put(img, 5, 2, P["purple"])
    put(img, 6, 1, P["purple"])
    put(img, 10, 2, P["purple"])
    put(img, 9, 1, P["purple"])
    return img

def sprite_enemy_goblin():
    """Small goblin enemy."""
    img = new_sprite(16, 16)
    # Body
    for dy in range(5, 12):
        for dx in range(3, 13):
            if ((dx-8)**2 / 25 + (dy-8)**2 / 16) <= 1.0:
                put(img, dx, dy, P["dark_green"])
    # Head
    for dy in range(1, 6):
        for dx in range(4, 12):
            if ((dx-8)**2 + (dy-3)**2) <= 9:
                put(img, dx, dy, P["green"])
    # Eyes - mean
    put(img, 5, 3, P["red"])
    put(img, 6, 3, P["red"])
    put(img, 9, 3, P["red"])
    put(img, 10, 3, P["red"])
    # Mouth
    put(img, 6, 5, P["dark_green"])
    put(img, 7, 5, P["dark_green"])
    put(img, 8, 5, P["dark_green"])
    put(img, 9, 5, P["dark_green"])
    # Feet
    put(img, 4, 12, P["dark_green"])
    put(img, 5, 12, P["dark_green"])
    put(img, 10, 12, P["dark_green"])
    put(img, 11, 12, P["dark_green"])
    return img

def icon_heart():
    """Heart icon - 8x8."""
    img = new_sprite(8, 8)
    put(img, 2, 1, P["red"]); put(img, 5, 1, P["red"])
    put(img, 1, 2, P["red"]); put(img, 2, 2, P["red"]); put(img, 3, 2, P["red"]); 
    put(img, 4, 2, P["red"]); put(img, 5, 2, P["red"]); put(img, 6, 2, P["red"])
    put(img, 2, 3, P["red"]); put(img, 3, 3, P["red"]); put(img, 4, 3, P["red"])
    put(img, 5, 3, P["red"])
    put(img, 3, 4, P["red"]); put(img, 4, 4, P["red"])
    put(img, 3, 5, P["red"])
    return img

def icon_apple():
    """Food/apple icon - 8x8."""
    img = new_sprite(8, 8)
    put(img, 3, 0, P["brown"]); put(img, 4, 0, P["brown"])
    put(img, 2, 1, P["brown"]); put(img, 4, 1, P["green"])
    # Body
    for dy in range(2, 6):
        for dx in range(2, 6):
            if ((dx-3.5)**2 + (dy-3.5)**2) <= 4:
                put(img, dx, dy, P["red"])
    put(img, 1, 3, P["red"]); put(img, 1, 4, P["red"])
    put(img, 6, 3, P["red"]); put(img, 6, 4, P["red"])
    return img

def icon_bed():
    """Bed/sleep icon - 8x8."""
    img = new_sprite(8, 8)
    rect(img, 1, 4, 6, 3, P["blue"])
    rect(img, 1, 3, 3, 1, P["indigo"])
    rect(img, 3, 3, 4, 1, P["purple"])
    # Pillow
    put(img, 1, 4, P["white"])
    put(img, 2, 4, P["white"])
    return img

def icon_sword():
    """Sword icon for battle - 8x8."""
    img = new_sprite(8, 8)
    # Blade
    put(img, 4, 0, P["light_gray"])
    put(img, 4, 1, P["light_gray"])
    put(img, 3, 2, P["light_gray"]); put(img, 4, 2, P["white"]); put(img, 5, 2, P["light_gray"])
    put(img, 4, 3, P["light_gray"])
    # Guard
    put(img, 2, 4, P["yellow"]); put(img, 3, 4, P["yellow"]); put(img, 4, 4, P["yellow"])
    put(img, 5, 4, P["yellow"]); put(img, 6, 4, P["yellow"])
    # Handle
    put(img, 4, 5, P["brown"])
    put(img, 4, 6, P["brown"])
    return img

def pixel_upscale(img, block=4):
    """Upscale pixel art with nearest-neighbor (no interpolation)."""
    w, h = img.size
    return img.resize((w*block, h*block), 0)  # Image.NEAREST

def save_sprite(name, sprite_fn, block=4):
    """Generate sprite, upscale, and save as PNG."""
    img = sprite_fn()
    upscaled = pixel_upscale(img, block)
    path = os.path.join(OUT, name)
    upscaled.save(path)
    print(f"✅ Saved {name} ({img.width}x{img.height} -> {upscaled.width}x{upscaled.height})")
    return path

def main():
    os.makedirs(OUT, exist_ok=True)
    
    # Pet sprites
    save_sprite("pet_idle.png", sprite_pet_idle, 4)      # 64x64
    save_sprite("pet_happy.png", sprite_pet_happy, 4)     # 64x64
    save_sprite("pet_sleep.png", sprite_pet_sleep, 4)     # 64x64
    save_sprite("pet_attack.png", sprite_pet_attack, 4)   # 64x64
    
    # Enemy sprites
    save_sprite("enemy_slime.png", sprite_enemy_slime, 4)   # 64x64
    save_sprite("enemy_bat.png", sprite_enemy_bat, 4)       # 64x64
    save_sprite("enemy_goblin.png", sprite_enemy_goblin, 4) # 64x64
    
    # UI Icons (16x16 with block=2)
    save_sprite("icon_heart.png", icon_heart, 2)    # 16x16
    save_sprite("icon_apple.png", icon_apple, 2)    # 16x16
    save_sprite("icon_bed.png", icon_bed, 2)        # 16x16
    save_sprite("icon_sword.png", icon_sword, 2)    # 16x16

if __name__ == "__main__":
    main()