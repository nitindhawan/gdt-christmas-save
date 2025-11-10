#!/usr/bin/env python3
"""
Convert reference puzzle JPG images to PNG format for Save the Christmas game.
Maintains portrait aspect ratio (3:4) as appropriate for portrait mobile game.
"""

from PIL import Image
import os
from pathlib import Path

# Configuration
LEVEL_IMAGE_WIDTH = 2048  # Width for full-size images (height will scale proportionally)
THUMBNAIL_WIDTH = 512     # Width for thumbnails (height will scale proportionally)

# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
REF_PUZZLES_DIR = PROJECT_ROOT / "ref" / "puzzles"
LEVELS_DIR = PROJECT_ROOT / "save-the-christmas" / "assets" / "levels"
THUMBNAILS_DIR = LEVELS_DIR / "thumbnails"

def convert_and_resize_image(input_path, output_path, target_width):
    """
    Load JPG, convert to PNG, and resize maintaining aspect ratio.

    Args:
        input_path: Path to input JPG
        output_path: Path to output PNG
        target_width: Target width in pixels (height scales proportionally)
    """
    # Open image
    img = Image.open(input_path)

    # Calculate new height maintaining aspect ratio
    aspect_ratio = img.height / img.width
    target_height = int(target_width * aspect_ratio)

    # Resize with high-quality resampling
    img_resized = img.resize((target_width, target_height), Image.Resampling.LANCZOS)

    # Convert to RGB if needed (in case of RGBA or other modes)
    if img_resized.mode != 'RGB':
        img_resized = img_resized.convert('RGB')

    # Save as PNG
    img_resized.save(output_path, "PNG", optimize=True)

    return img_resized.width, img_resized.height

def main():
    """Convert all puzzle images to PNGs with proper sizing."""
    # Create output directories
    LEVELS_DIR.mkdir(parents=True, exist_ok=True)
    THUMBNAILS_DIR.mkdir(parents=True, exist_ok=True)

    print("Converting puzzle images to PNG format...")
    print(f"Source: {REF_PUZZLES_DIR}")
    print(f"Target (full): {LEVELS_DIR}")
    print(f"Target (thumbnails): {THUMBNAILS_DIR}")
    print()

    # Get all JPG files from reference folder
    puzzle_files = sorted(REF_PUZZLES_DIR.glob("puzzle*.jpg"))

    if not puzzle_files:
        print("[ERROR] No puzzle*.jpg files found in ref/puzzles/")
        return

    for idx, puzzle_file in enumerate(puzzle_files, start=1):
        level_num = idx

        print(f"Processing {puzzle_file.name}...")

        # Convert and resize full-size image
        level_output = LEVELS_DIR / f"level_{level_num:02d}.png"
        width, height = convert_and_resize_image(
            puzzle_file,
            level_output,
            LEVEL_IMAGE_WIDTH
        )
        print(f"  [OK] Full-size: {level_output.name} ({width}x{height})")

        # Convert and resize thumbnail
        thumb_output = THUMBNAILS_DIR / f"level_{level_num:02d}_thumb.png"
        thumb_w, thumb_h = convert_and_resize_image(
            puzzle_file,
            thumb_output,
            THUMBNAIL_WIDTH
        )
        print(f"  [OK] Thumbnail: {thumb_output.name} ({thumb_w}x{thumb_h})")
        print()

    print(f"[SUCCESS] Successfully converted {len(puzzle_files)} puzzle images!")
    print(f"          Generated {len(puzzle_files)} full-size PNGs and {len(puzzle_files)} thumbnails.")

if __name__ == "__main__":
    main()
