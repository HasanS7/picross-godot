import cv2
import numpy as np
import json
from pathlib import Path
import sys

custom_levels_dir = Path(__file__).resolve().parent.parent / "Custom_Levels"
OUTPUT_PATH = custom_levels_dir 

def image_to_picross_grid(image_path, target_width=32, target_height=32, threshold_val=127):
    """
    Converts an image into a clean 2D binary grid optimized for Picross,
    removing accidental internal holes and stray background noise.
    """
    # 1. Load image in grayscale
    img_gray = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    # 2. Resize image
    img_small = cv2.resize(img_gray, (target_width, target_height), interpolation=cv2.INTER_AREA)
    
    # 3. Apply a solid Global Threshold (No dithering)
    # We invert the threshold (THRESH_BINARY_INV) so that dark subject features 
    # become '1' (filled blocks) and white backgrounds become '0' (empty spaces).
    _, img_binary = cv2.threshold(img_small, threshold_val, 255, cv2.THRESH_BINARY_INV)
    
    # 4. Use Morphological Operations to close internal holes
    # A 2x2 or 3x3 structuring element acts as a cleaning brush
    kernel = np.ones((2, 2), np.uint8)
    
    # MORPH_CLOSE fills in small black holes inside solid white shapes
    img_cleaned = cv2.morphologyEx(img_binary, cv2.MORPH_CLOSE, kernel)
    
    # Optional: MORPH_OPEN removes tiny single dots floating in empty space
    img_cleaned = cv2.morphologyEx(img_cleaned, cv2.MORPH_OPEN, kernel)
    
    # 5. Convert 255/0 values directly into a 1 and 0 integer matrix
    picross_grid = (img_cleaned // 255).astype(int)
    
    return picross_grid.tolist()

if __name__ == "__main__":
    # Get variables from external
    _, file, width, height, threshold, export = sys.argv
    
    img_filename = file.split('/')[-1]

    grid = image_to_picross_grid(file, int(width), int(height), int(threshold))

    # Print out the clean Picross board grid
    for row in grid:
        print("".join(['#' if val == 1 else '·' for val in row]))

    # If export is true, export the data to JSON file
    if export.lower() == 'true':
        output_filename = Path(img_filename).stem

        with open(OUTPUT_PATH / (output_filename + '.json'), "w") as f:
            json.dump(grid, f, indent=4)

        print("Export complete.")
