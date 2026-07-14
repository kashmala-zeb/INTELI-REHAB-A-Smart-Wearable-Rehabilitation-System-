from PIL import Image
import colorsys
import numpy as np
import sys

def recolor(input_path, output_path):
    try:
        img = Image.open(input_path).convert("RGBA")
        data = np.array(img)
        
        # Target teal color: RGB(20, 184, 166)
        # We'll just shift the Hue channel for pixels that are blue-ish.
        # Let's convert to HSV
        hsv_data = np.zeros_like(data, dtype=np.float32)
        for i in range(data.shape[0]):
            for j in range(data.shape[1]):
                r, g, b, a = data[i, j]
                h, s, v = colorsys.rgb_to_hsv(r/255.0, g/255.0, b/255.0)
                # Check if it's blue-ish (Hue around 0.5 to 0.7 for standard blue/cyan)
                # Or just any color that isn't skin tone (skin tone is Hue 0.0 to 0.1)
                # If s > 0.1, we shift hue to teal (Hue = 173 degrees = 173/360 = 0.48)
                # Let's be safe and only shift if hue is > 0.1 or < 0.9 and it's not white/black
                if a > 0 and s > 0.05:
                    if h > 0.1 and h < 0.8: # anything not red/yellow/orange (skin/warm colors)
                        h = 173.0 / 360.0 # teal
                        
                r2, g2, b2 = colorsys.hsv_to_rgb(h, s, v)
                data[i, j] = [int(r2*255), int(g2*255), int(b2*255), a]
                
        Image.fromarray(data).save(output_path)
        print("Success")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    recolor("lib/../assets/images/logo.png", "lib/../assets/images/logo.png")
