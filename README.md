# Picross

[Download Game for Windows](https://drive.google.com/file/d/1xNR7d7HC3mT0SmbDmE2AKAMxoIQ2MqTF/view?usp=sharing)

A customizable Picross-style puzzle game built with **Godot Game Engine**, written in **GDScript**, and **Python**.

The game lets players solve 4 pre-coded levels, generate a random puzzle, or import from an image file.

## Features

- Interactive Picross-style grid
- Multiple difficulty levels
- Custom board width and height
- Custom number of filled cells with dynamic sizing
- Load puzzles from JSON files
- Generate puzzles from images
- Adjustable image resolution and threshold
- Win/game-complete screen
- Main menu and game scene
- Python/OpenCV image processing

## Image-to-Puzzle Generation

Players can select an image and generate a puzzle from it.

The process is:

```text
Image
  ↓
Godot
  ↓
Python + OpenCV
  ↓
Grayscale / Resize / Threshold
  ↓
Binary Grid
  ↓
JSON
  ↓
Playable Puzzle
```

The Python script cleans and converts the image into a 2D grid of `0` and `1` values.

<img width="1143" height="658" alt="image" src="https://github.com/user-attachments/assets/c26f6480-4261-4c13-8c5a-3480202dfe63" />

<img width="1144" height="664" alt="image" src="https://github.com/user-attachments/assets/6e1bee59-812a-4bc5-ac60-14acc1e61862" />
