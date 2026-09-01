import cv2
import numpy as np
import json
from pathlib import Path

"""
Instructions:
Place image files in 'Custom_Levels/source_images/' folder. Make sure the outside of the image is light and the actual shape is dark for the image processing to recognize the shape.
Run 'python .\image_processing.py' command in the Custom_Levels directory
Follow command line instructions
JSON level file will be exported to  the Custom_Levels folder. Select the JSON file from this folder when loading a level in game
"""

INPUT_IMAGE_PATH = './source_images/'
OUTPUT_PATH = './'

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

# Get input file name
input_filename = ':'
while not Path(INPUT_IMAGE_PATH + input_filename).exists() or not input_filename:
    files = [f.name for f in Path(INPUT_IMAGE_PATH).iterdir() if f.is_file() and f.name != '.gitkeep']
    print("Choose a file by entering the file name.")
    input_filename = input("Available files: " + str(files) + " ")
    if not Path(INPUT_IMAGE_PATH + input_filename).exists() or not input_filename: print("\033[91mFile not found\033[0m")

# Command input loop
command = 'r'
while(command.lower() == 'r'):

    # Getting user input for parameters
    thresh, width, height = 127, 32, 32 # Default values
    params = input('Enter parameters (separated by spaces), or leave empty for default: threshold (127), width (32), height (32) : ').split(' ')
    if len(params) == 1 and params[0] != '': thresh = int(params[0])
    elif len(params) == 2: thresh, width = int(params[0]), int(params[1])
    elif len(params) == 3: thresh, width, height = int(params[0]), int(params[1]), int(params[2])

    grid = image_to_picross_grid(INPUT_IMAGE_PATH + input_filename, target_width=width, target_height=height, threshold_val=thresh)

    # Print out the clean Picross board grid
    for row in grid:
        print("".join(['■' if val == 1 else '·' for val in row]))

    command = input("Enter key: (R)etry / (E)xport / (C)ancel : ")


# Export to JSON
if command.lower() == 'e':
    output_filename = input("Enter file name: ") # Ask user for file name

    with open(OUTPUT_PATH + output_filename + '.json', "w") as f:
        json.dump(grid, f, indent=4)

    print("Level successfully exported to JSON!")