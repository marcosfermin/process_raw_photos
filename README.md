# RAW Photo Batch Processor v1.0

A professional-grade bash script for batch processing Canon RAW (.CR2) files with **intelligent per-image analysis**, professional presets, and comprehensive editing tools.

---

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Quick Start](#quick-start)
5. [Command Line Reference](#command-line-reference)
6. [Presets](#presets)
7. [Adjustment Controls](#adjustment-controls)
8. [Output Options](#output-options)
9. [Analysis & Preview Modes](#analysis--preview-modes)
10. [Intelligent Processing Pipeline](#intelligent-processing-pipeline)
11. [Configuration File](#configuration-file)
12. [Examples](#examples)
13. [Technical Reference](#technical-reference)
14. [Troubleshooting](#troubleshooting)
15. [Supported RAW Formats](#supported-raw-formats)

---

## Features

### Core Features
- **Intelligent Per-Image Analysis** - Automatically analyzes each photo and calculates optimal corrections
- **7 Professional Presets** - One-click styles for different photography types
- **Batch Processing** - Process hundreds of RAW files automatically
- **High-Quality Output** - Maximum quality JPEG, PNG, or TIFF output

### Advanced Adjustments
- **Exposure Control** - Brightness, highlights, shadows
- **Contrast & Clarity** - Fine-tune image punch and local contrast
- **White Balance** - Temperature and tint adjustments
- **Color Control** - Saturation and vibrance
- **Noise Reduction** - Adjustable noise removal
- **Sharpening** - Professional unsharp mask

### Output Options
- **Resize** - By dimension or percentage
- **Watermarks** - Text overlay with positioning
- **Web Versions** - Auto-generate optimized copies
- **Multiple Formats** - JPEG, PNG, TIFF
- **Custom Output Directory** - Organize processed files

### Workflow Features
- **Analysis Mode** - Preview corrections without processing
- **Preview Mode** - Test settings on a single image
- **Detailed Logging** - Track processing results
- **Progress Display** - Real-time status updates

---

## Requirements

### ImageMagick (Required)

```bash
# macOS (using Homebrew)
brew install imagemagick

# Ubuntu/Debian
sudo apt-get install imagemagick

# Fedora/RHEL
sudo dnf install ImageMagick

# Windows
# Download from: https://imagemagick.org/script/download.php
```

### bc Calculator (Required)

Usually pre-installed on macOS and Linux. If not:

```bash
# Ubuntu/Debian
sudo apt-get install bc

# macOS (if missing)
brew install bc
```

### Verify Installation

```bash
magick -version
bc --version
```

---

## Installation

1. Download the script to your desired location
2. Make it executable:

```bash
chmod +x process_raw_photos.sh
```

3. Optionally, add to your PATH for global access:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/script/directory"
```

---

## Quick Start

### Basic Usage (Intelligent Auto-Processing)

```bash
# Navigate to your photos directory
cd /path/to/your/photos

# Run with intelligent analysis (default)
/path/to/process_raw_photos.sh
```

### Use a Preset

```bash
./process_raw_photos.sh --preset portrait
./process_raw_photos.sh --preset vivid
./process_raw_photos.sh --preset bw
```

### Analyze Before Processing

```bash
# See what corrections would be applied
./process_raw_photos.sh --analyze

# Test on a single file
./process_raw_photos.sh --preview IMG_0001.CR2
```

### Process with Custom Settings

```bash
./process_raw_photos.sh --temperature 20 --contrast 15 --vibrance 30
```

---

## Command Line Reference

### Syntax

```
./process_raw_photos.sh [OPTIONS] [input_directory] [output_suffix]
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `input_directory` | Directory containing RAW files | Current directory |
| `output_suffix` | Suffix added to output filenames | `_edited` |

### All Options

#### Basic Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Display help message with all options |
| `-v, --version` | Show version information |
| `-q, --quiet` | Suppress progress output (logging still works) |
| `-n, --no-enhance` | Skip all enhancements, straight conversion only |

#### Presets

| Option | Description |
|--------|-------------|
| `--preset NAME` | Apply a preset style (see [Presets](#presets)) |

#### Tone Adjustments

| Option | Range | Description |
|--------|-------|-------------|
| `--contrast VALUE` | -100 to +100 | Adjust overall contrast |
| `--highlights VALUE` | -100 to +100 | Recover/boost highlights (negative = recover) |
| `--shadows VALUE` | -100 to +100 | Lift/deepen shadows (positive = lift) |
| `--clarity VALUE` | -100 to +100 | Local contrast / midtone punch |

#### White Balance

| Option | Range | Description |
|--------|-------|-------------|
| `--temperature VALUE` | -100 to +100 | Color temperature (negative = cool/blue, positive = warm/yellow) |
| `--tint VALUE` | -100 to +100 | Tint (negative = green, positive = magenta) |

#### Color Adjustments

| Option | Range | Description |
|--------|-------|-------------|
| `--saturation VALUE` | 0 to 200 | Overall saturation (100 = normal) |
| `--vibrance VALUE` | 0 to 100 | Smart saturation (protects skin tones) |

#### Correction

| Option | Range | Description |
|--------|-------|-------------|
| `--noise-reduction VALUE` | 0 to 100 | Noise reduction strength |
| `--sharpen VALUE` | 0 to 2 | Sharpening amount (default: 0.5) |

#### Output Options

| Option | Description |
|--------|-------------|
| `--resize VALUE` | Max dimension (e.g., `2000`) or percentage (e.g., `50%`) |
| `--format FORMAT` | Output format: `jpg`, `png`, `tiff` (default: `jpg`) |
| `--quality VALUE` | JPEG quality 1-100 (default: 100) |
| `--output-dir PATH` | Custom output directory |
| `--watermark "TEXT"` | Add text watermark |
| `--watermark-position POS` | Position: `topleft`, `topright`, `bottomleft`, `bottomright`, `center` |
| `--watermark-opacity VAL` | Watermark opacity 0-100 (default: 50) |
| `--web-version` | Also create smaller web-optimized copy |
| `--web-size VALUE` | Max dimension for web version (default: 1200) |
| `--web-quality VALUE` | Quality for web version (default: 85) |

#### Analysis/Preview

| Option | Description |
|--------|-------------|
| `--analyze` | Analyze all images without processing (shows recommendations) |
| `--preview FILE` | Process single file to test settings |
| `--no-analysis` | Disable intelligent per-image analysis |

---

## Presets

Presets provide one-click styles optimized for different types of photography.

### Available Presets

| Preset | Description | Best For |
|--------|-------------|----------|
| `auto` | Intelligent per-image analysis and correction (default) | General use, mixed lighting |
| `portrait` | Soft, flattering look with skin-friendly settings | People, headshots, events |
| `vivid` | Punchy colors, high saturation and contrast | Landscapes, products, food |
| `soft` | Dreamy, muted tones with low contrast | Artistic, romantic, lifestyle |
| `bw` | Professional black & white conversion | Classic, dramatic portraits |
| `vintage` | Warm, faded look with reduced saturation | Nostalgic, retro aesthetic |
| `natural` | Minimal processing, true to life colors | Documentary, journalism |

### Preset Details

#### `auto` (Default)
```
Intelligent Analysis: ON
- Analyzes exposure, contrast, and color cast per image
- Calculates optimal corrections automatically
- Adapts to each image's unique characteristics
```

#### `portrait`
```
Contrast: -10
Highlights: -20 (recover)
Shadows: +15 (lift)
Saturation: 95% (slightly reduced)
Vibrance: +20
Clarity: -15 (soften)
Sharpening: 0.3 (subtle)
Intelligent Analysis: ON (for exposure)
```

#### `vivid`
```
Contrast: +20
Highlights: -10
Shadows: +10
Saturation: 125%
Vibrance: +40
Clarity: +25
Sharpening: 0.7 (strong)
Intelligent Analysis: OFF (fixed settings)
```

#### `soft`
```
Contrast: -15
Highlights: +10
Shadows: +20
Saturation: 85%
Vibrance: 0
Clarity: -25 (very soft)
Sharpening: 0.2 (minimal)
Intelligent Analysis: OFF
```

#### `bw`
```
Saturation: 0% (full desaturation)
Contrast: +15
Clarity: +20
Sharpening: 0.6
Intelligent Analysis: ON (for exposure)
```

#### `vintage`
```
Temperature: +25 (warm)
Contrast: -5
Highlights: +15 (faded)
Shadows: +10
Saturation: 90%
Vibrance: -10
Intelligent Analysis: OFF
```

#### `natural`
```
Contrast: 0
Highlights: 0
Shadows: 0
Saturation: 100%
Vibrance: 0
Clarity: 0
Sharpening: 0.3
Intelligent Analysis: OFF
```

### Using Presets

```bash
# Use portrait preset
./process_raw_photos.sh --preset portrait

# Use preset with modifications
./process_raw_photos.sh --preset portrait --vibrance 40

# Use preset with output options
./process_raw_photos.sh --preset vivid --resize 2000 --web-version
```

---

## Adjustment Controls

### Tone Adjustments

#### Contrast (`--contrast`)

Controls the difference between light and dark areas.

| Value | Effect |
|-------|--------|
| -100 | Very flat, low contrast |
| -50 | Reduced contrast |
| 0 | No change |
| +50 | Increased contrast |
| +100 | Maximum contrast |

```bash
./process_raw_photos.sh --contrast 25
```

#### Highlights (`--highlights`)

Controls the brightest areas of the image.

| Value | Effect |
|-------|--------|
| -100 | Maximum highlight recovery |
| -50 | Moderate recovery |
| 0 | No change |
| +50 | Brighter highlights |
| +100 | Maximum highlight boost |

```bash
# Recover blown highlights
./process_raw_photos.sh --highlights -30

# Brighten highlights
./process_raw_photos.sh --highlights 20
```

#### Shadows (`--shadows`)

Controls the darkest areas of the image.

| Value | Effect |
|-------|--------|
| -100 | Deepened shadows (darker) |
| -50 | Moderately darker shadows |
| 0 | No change |
| +50 | Lifted shadows (brighter) |
| +100 | Maximum shadow lift |

```bash
# Lift shadows to reveal detail
./process_raw_photos.sh --shadows 30

# Deepen shadows for drama
./process_raw_photos.sh --shadows -20
```

#### Clarity (`--clarity`)

Controls local contrast / midtone punch.

| Value | Effect |
|-------|--------|
| -100 | Very soft, dreamy |
| -50 | Softened |
| 0 | No change |
| +50 | Punchy, defined |
| +100 | Maximum clarity |

```bash
# Add punch to landscapes
./process_raw_photos.sh --clarity 40

# Soften for portraits
./process_raw_photos.sh --clarity -20
```

### White Balance

#### Temperature (`--temperature`)

Adjusts the color temperature from cool (blue) to warm (yellow/orange).

| Value | Effect |
|-------|--------|
| -100 | Very cool (strong blue tint) |
| -50 | Cool |
| 0 | No change |
| +50 | Warm |
| +100 | Very warm (strong yellow/orange) |

```bash
# Warm up a cold photo
./process_raw_photos.sh --temperature 30

# Cool down an overly warm photo
./process_raw_photos.sh --temperature -20
```

#### Tint (`--tint`)

Adjusts the green/magenta balance.

| Value | Effect |
|-------|--------|
| -100 | Strong green tint |
| -50 | Green shift |
| 0 | No change |
| +50 | Magenta shift |
| +100 | Strong magenta tint |

```bash
# Correct fluorescent green cast
./process_raw_photos.sh --tint 15
```

### Color Adjustments

#### Saturation (`--saturation`)

Controls overall color intensity.

| Value | Effect |
|-------|--------|
| 0 | Grayscale (no color) |
| 50 | Half saturation |
| 100 | Normal (no change) |
| 150 | Increased saturation |
| 200 | Maximum saturation |

```bash
# Boost colors
./process_raw_photos.sh --saturation 120

# Reduce for muted look
./process_raw_photos.sh --saturation 80
```

#### Vibrance (`--vibrance`)

Smart saturation that boosts less-saturated colors more than already-saturated ones. Protects skin tones from over-saturation.

| Value | Effect |
|-------|--------|
| 0 | No vibrance boost |
| 25 | Subtle boost |
| 50 | Moderate boost |
| 75 | Strong boost |
| 100 | Maximum boost |

```bash
# Add pop while protecting skin
./process_raw_photos.sh --vibrance 40
```

### Correction

#### Noise Reduction (`--noise-reduction`)

Reduces digital noise (grain) in images.

| Value | Range | Effect |
|-------|-------|--------|
| 0 | - | No noise reduction |
| 1-29 | Light | Single despeckle pass |
| 30-59 | Medium | Double despeckle pass |
| 60-100 | Heavy | Blur-based reduction with resharpening |

```bash
# Light noise reduction
./process_raw_photos.sh --noise-reduction 20

# Heavy noise reduction for high-ISO images
./process_raw_photos.sh --noise-reduction 70
```

#### Sharpening (`--sharpen`)

Controls the sharpening amount applied after processing.

| Value | Effect |
|-------|--------|
| 0 | No sharpening |
| 0.3 | Subtle sharpening |
| 0.5 | Standard sharpening (default) |
| 0.7 | Strong sharpening |
| 1.0+ | Very strong sharpening |

```bash
# Subtle sharpening for portraits
./process_raw_photos.sh --sharpen 0.3

# Strong sharpening for landscapes
./process_raw_photos.sh --sharpen 0.8
```

---

## Output Options

### Resize (`--resize`)

Resize images to a maximum dimension or percentage.

```bash
# Max dimension of 2000 pixels (maintains aspect ratio)
./process_raw_photos.sh --resize 2000

# Resize to 50% of original
./process_raw_photos.sh --resize 50%

# Resize to 25% for thumbnails
./process_raw_photos.sh --resize 25%
```

### Format (`--format`)

Change the output format.

| Format | Extension | Best For |
|--------|-----------|----------|
| `jpg` | .jpg | Web, sharing, general use (default) |
| `png` | .png | Graphics, transparency needed |
| `tiff` | .tiff | Print, archival, further editing |

```bash
# Output as PNG
./process_raw_photos.sh --format png

# Output as TIFF for printing
./process_raw_photos.sh --format tiff
```

### Quality (`--quality`)

Set JPEG compression quality.

| Value | Size | Quality |
|-------|------|---------|
| 100 | Largest | Maximum (default) |
| 90 | Large | Excellent |
| 80 | Medium | Very good |
| 70 | Smaller | Good |
| 60 | Small | Acceptable |

```bash
# Slightly smaller files
./process_raw_photos.sh --quality 90

# Smaller files for web
./process_raw_photos.sh --quality 80
```

### Output Directory (`--output-dir`)

Save processed files to a different directory.

```bash
# Save to a "processed" folder
./process_raw_photos.sh --output-dir ./processed

# Save to an absolute path
./process_raw_photos.sh --output-dir /Users/name/Photos/Edited
```

### Watermark (`--watermark`)

Add a text watermark to images.

```bash
# Simple watermark
./process_raw_photos.sh --watermark "Photo by John"

# Watermark with position
./process_raw_photos.sh --watermark "Studio X" --watermark-position bottomleft

# Watermark with opacity
./process_raw_photos.sh --watermark "Copyright 2025" --watermark-opacity 30
```

#### Watermark Positions

| Position | Location |
|----------|----------|
| `topleft` | Top-left corner |
| `topright` | Top-right corner |
| `bottomleft` | Bottom-left corner |
| `bottomright` | Bottom-right corner (default) |
| `center` | Center of image |

### Web Version (`--web-version`)

Automatically create smaller, web-optimized copies.

```bash
# Create web versions with defaults (1200px, 85% quality)
./process_raw_photos.sh --web-version

# Custom web version settings
./process_raw_photos.sh --web-version --web-size 800 --web-quality 75
```

Output files:
- `IMG_0001_edited.jpg` (full size)
- `IMG_0001_edited_web.jpg` (web version)

---

## Analysis & Preview Modes

### Analysis Mode (`--analyze`)

Analyze all images without processing. Shows detailed metrics and recommended corrections for each image.

```bash
./process_raw_photos.sh --analyze
```

#### Output Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Image: IMG_0001.CR2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Exposure Analysis:
  Mean Brightness:    95.3 / 255
  Dynamic Range:      12.0 - 248.5
  Contrast (StdDev):  52.4
  Status:             underexposed

Highlight/Shadow Clipping:
  Clipped Highlights: 1.2%
  Clipped Shadows:    3.5%

Color Analysis:
  Red Channel:        98.2
  Green Channel:      94.1
  Blue Channel:       93.6
  Color Cast:         warm

Recommended Corrections:
  Brightness:         115%
  Contrast:           5
  Highlights:         0
  Shadows:            7
  Temperature:        -15
```

### Preview Mode (`--preview`)

Process a single file to test your settings before batch processing.

```bash
# Preview with default settings
./process_raw_photos.sh --preview IMG_0001.CR2

# Preview with specific settings
./process_raw_photos.sh --preview IMG_0001.CR2 --preset portrait --vibrance 30

# Preview with output options
./process_raw_photos.sh --preview IMG_0001.CR2 --resize 2000 --watermark "Test"
```

Preview mode:
1. Displays full analysis of the image
2. Shows recommended corrections
3. Processes the single file
4. Reports success and output file size

---

## Intelligent Processing Pipeline

When intelligent analysis is enabled (default), each image goes through this pipeline:

### 1. Image Analysis

For each image, the script analyzes:

| Metric | Description | Used For |
|--------|-------------|----------|
| Mean Brightness | Average luminosity (0-255) | Exposure correction |
| Standard Deviation | Contrast indicator | Contrast adjustment |
| Min/Max Values | Dynamic range | Clipping detection |
| Channel Means (R/G/B) | Per-channel averages | Color cast detection |
| Clipped Highlights | % of pure white pixels | Highlight recovery |
| Clipped Shadows | % of pure black pixels | Shadow recovery |

### 2. Correction Calculation

Based on analysis, the script calculates:

| Condition | Correction |
|-----------|------------|
| Mean < 80 (dark) | Increase brightness proportionally |
| Mean > 180 (bright) | Decrease brightness |
| StdDev < 40 (flat) | Boost contrast |
| StdDev > 70 (contrasty) | Reduce contrast slightly |
| Highlights > 2% clipped | Recover highlights |
| Shadows > 2% clipped | Lift shadows |
| Warm color cast | Cool temperature adjustment |
| Cool color cast | Warm temperature adjustment |

### 3. Processing Order

Enhancements are applied in this specific order for optimal results:

1. **White Balance** - Temperature and tint corrections
2. **Auto-Level** - Histogram stretching
3. **Auto-Gamma** - Midtone brightness
4. **Highlight Recovery** - Compress bright values if needed
5. **Shadow Recovery** - Lift dark values if needed
6. **Contrast** - Sigmoidal contrast adjustment
7. **Clarity** - Local contrast enhancement
8. **Modulate** - Brightness and saturation
9. **Vibrance** - Smart saturation boost
10. **Noise Reduction** - If enabled
11. **Sharpening** - Unsharp mask
12. **Resize** - If requested
13. **Watermark** - If requested
14. **Save** - With quality settings
15. **Web Version** - If requested

---

## Configuration File

Default values can be modified by editing the script's configuration section:

```bash
#-------------------------------------------------------------------------------
# CONFIGURATION SECTION
#-------------------------------------------------------------------------------

# Input file extension
INPUT_EXTENSION="CR2"

# Output settings
OUTPUT_FORMAT="jpg"
JPEG_QUALITY=100
DEFAULT_SUFFIX="_edited"

# Enhancement parameters
SATURATION_BOOST=105
BRIGHTNESS=100
HUE_ROTATION=100

# Sharpening parameters
SHARPEN_RADIUS=0.5
SHARPEN_SIGMA=0.5
SHARPEN_AMOUNT=0.5
SHARPEN_THRESHOLD=0.05

# Advanced adjustments (defaults)
CONTRAST=0
HIGHLIGHTS=0
SHADOWS=0
CLARITY=0
TEMPERATURE=0
TINT=0
VIBRANCE=0
NOISE_REDUCTION=0

# Output options (defaults)
RESIZE=""
OUTPUT_DIR=""
WATERMARK_TEXT=""
WATERMARK_POSITION="bottomright"
WATERMARK_OPACITY=50
CREATE_WEB_VERSION=false
WEB_MAX_SIZE=1200
WEB_QUALITY=85

# Processing mode (defaults)
PRESET="auto"
USE_INTELLIGENT_ANALYSIS=true

# Logging
LOG_FILE="processing_log.txt"
ENABLE_LOGGING=true
```

---

## Examples

### Basic Examples

```bash
# Process current directory with intelligent analysis
./process_raw_photos.sh

# Process a specific directory
./process_raw_photos.sh /path/to/photos

# Custom output suffix
./process_raw_photos.sh /path/to/photos _final
# Output: IMG_0001_final.jpg
```

### Preset Examples

```bash
# Portrait session
./process_raw_photos.sh --preset portrait

# Landscape photography
./process_raw_photos.sh --preset vivid --clarity 30

# Black and white conversion
./process_raw_photos.sh --preset bw

# Minimal processing
./process_raw_photos.sh --preset natural
```

### Adjustment Examples

```bash
# Correct underexposed images
./process_raw_photos.sh --shadows 30 --contrast 10

# Fix overexposed images
./process_raw_photos.sh --highlights -40

# Warm up cold indoor photos
./process_raw_photos.sh --temperature 25

# Add color pop
./process_raw_photos.sh --vibrance 40 --saturation 110

# High-ISO noise reduction
./process_raw_photos.sh --noise-reduction 50 --sharpen 0.4
```

### Output Examples

```bash
# Resize for web
./process_raw_photos.sh --resize 1920 --quality 85

# Create print-ready files
./process_raw_photos.sh --format tiff --quality 100

# Organize output
./process_raw_photos.sh --output-dir ./processed --web-version

# Add photographer credit
./process_raw_photos.sh --watermark "Photo by Jane Doe" --watermark-position bottomright
```

### Workflow Examples

```bash
# Analyze before processing
./process_raw_photos.sh --analyze

# Test settings on one image
./process_raw_photos.sh --preview IMG_0001.CR2 --preset portrait --vibrance 30

# Full production workflow
./process_raw_photos.sh \
  --preset portrait \
  --vibrance 25 \
  --resize 3000 \
  --output-dir ./final \
  --watermark "Studio Name" \
  --web-version \
  --web-size 1200

# Quiet mode for scripts
./process_raw_photos.sh --quiet --output-dir ./batch_output
```

### Combined Examples

```bash
# Event photography workflow
./process_raw_photos.sh \
  --preset portrait \
  --noise-reduction 20 \
  --resize 4000 \
  --output-dir "./Event Name - Edited" \
  --web-version \
  --watermark "Event Photos 2025"

# Product photography
./process_raw_photos.sh \
  --preset vivid \
  --contrast 15 \
  --clarity 25 \
  --saturation 115 \
  --format png \
  --resize 2000

# Fine art black & white
./process_raw_photos.sh \
  --preset bw \
  --contrast 20 \
  --clarity 30 \
  --format tiff
```

---

## Technical Reference

### ImageMagick Operations

#### Auto-Level (`-auto-level`)

Stretches the histogram to use full dynamic range:
- Maps darkest pixel to 0 (black)
- Maps brightest pixel to 255 (white)
- Scales all other values proportionally

#### Auto-Gamma (`-auto-gamma`)

Calculates optimal gamma based on mean intensity:
```
gamma = log(mean/maxval) / log(0.5)
```

#### Temperature Adjustment

Implemented via channel multiplication:
- Warm: Boost R, reduce B
- Cool: Boost B, reduce R

```
Red multiplier = 1 + (temperature / 400)
Blue multiplier = 1 - (temperature / 400)
```

#### Contrast (Sigmoidal)

Uses sigmoidal contrast for natural-looking results:
```
-sigmoidal-contrast {strength}x50%
```

#### Highlight Recovery

Compresses white point:
```
-level 0%,{100 - highlights/2}%
```

#### Shadow Recovery

Adjusts gamma for shadow areas:
```
-gamma {1 + shadows/100}
```

#### Clarity

Local contrast via large-radius unsharp mask:
```
-unsharp 50x30+{clarity/50}+0.02
```

#### Vibrance

Smart saturation using HSL manipulation:
- Boosts less-saturated colors more
- Protects already-saturated colors (like skin tones)

#### Noise Reduction

Three levels based on value:
- Light (1-29): Single despeckle
- Medium (30-59): Double despeckle
- Heavy (60-100): Blur + resharpen

#### Unsharp Mask

```
-unsharp {radius}x{sigma}+{amount}+{threshold}
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| radius | 0.5 | Blur kernel size (pixels) |
| sigma | 0.5 | Blur standard deviation |
| amount | 0.5 | Sharpening strength |
| threshold | 0.05 | Minimum contrast to sharpen |

### Log File Format

```
═══════════════════════════════════════════════════════════════════
RAW Photo Batch Processor - Processing Log
Started: Sun Dec 22 10:00:00 EST 2025
Directory: /Users/name/Photos
Total Files: 100
═══════════════════════════════════════════════════════════════════

[2025-12-22 10:00:01] Processing: IMG_0001.CR2
[2025-12-22 10:00:04]   SUCCESS: Created IMG_0001_edited.jpg (18.5 MB)
[2025-12-22 10:00:04] Processing: IMG_0002.CR2
[2025-12-22 10:00:07]   SUCCESS: Created IMG_0002_edited.jpg (19.2 MB)
...

═══════════════════════════════════════════════════════════════════
Processing completed: Sun Dec 22 10:35:00 EST 2025
Total: 100 | Success: 100 | Failed: 0
═══════════════════════════════════════════════════════════════════
```

### Performance

#### Processing Speed

| System | Speed | 100 Images |
|--------|-------|------------|
| Apple Silicon (M1/M2/M3) | ~3 sec/image | ~5 minutes |
| Intel Core i7 | ~5 sec/image | ~8 minutes |
| Intel Core i5 | ~7 sec/image | ~12 minutes |

Additional operations add time:
- Intelligent analysis: +0.5 sec/image
- Web version: +1 sec/image
- Noise reduction: +1-3 sec/image

#### Disk Space

| Input | Output | With Web Version |
|-------|--------|------------------|
| 25MB CR2 | ~20MB JPG | +~500KB web |
| 100 files (2.5GB) | ~2GB | +~50MB |

---

## Troubleshooting

### Common Issues

#### "ImageMagick is not installed"

Install ImageMagick:
```bash
# macOS
brew install imagemagick

# Ubuntu
sudo apt-get install imagemagick
```

#### "bc: command not found"

Install bc calculator:
```bash
# macOS
brew install bc

# Ubuntu
sudo apt-get install bc
```

#### "No .CR2 files found"

- Check you're in the correct directory
- Verify files have `.CR2` extension
- The match is case-insensitive (CR2, cr2, Cr2 all work)

#### "Permission denied"

Make the script executable:
```bash
chmod +x process_raw_photos.sh
```

#### "Syntax error" or script fails

Ensure the script has Unix line endings:
```bash
# Fix line endings
sed -i '' 's/\r$//' process_raw_photos.sh
```

### Quality Issues

#### Colors look wrong

1. Try different presets:
   ```bash
   ./process_raw_photos.sh --preset natural
   ```

2. Disable intelligent analysis:
   ```bash
   ./process_raw_photos.sh --no-analysis
   ```

3. Use straight conversion:
   ```bash
   ./process_raw_photos.sh -n
   ```

#### Images too bright/dark

1. Check the analysis:
   ```bash
   ./process_raw_photos.sh --analyze
   ```

2. Adjust manually:
   ```bash
   # For dark images
   ./process_raw_photos.sh --shadows 30

   # For bright images
   ./process_raw_photos.sh --highlights -30
   ```

#### Too much/little sharpening

```bash
# Reduce sharpening
./process_raw_photos.sh --sharpen 0.3

# Increase sharpening
./process_raw_photos.sh --sharpen 0.8
```

#### Noisy images

```bash
./process_raw_photos.sh --noise-reduction 50
```

### Performance Issues

#### Processing is slow

- RAW files are large (~25MB each)
- Intelligent analysis adds ~0.5s per image
- Consider running overnight for large batches
- Use `--quiet` mode for slightly faster processing

#### Running out of disk space

- Ensure 2x the size of input files available
- Use `--output-dir` to save to a different drive
- Lower quality slightly: `--quality 90`

---

## Supported RAW Formats

The script is configured for Canon `.CR2` by default. Modify `INPUT_EXTENSION` for other formats:

| Camera Brand | Extensions | Setting |
|--------------|------------|---------|
| Canon | CR2, CR3 | `INPUT_EXTENSION="CR2"` |
| Nikon | NEF, NRW | `INPUT_EXTENSION="NEF"` |
| Sony | ARW, SRF | `INPUT_EXTENSION="ARW"` |
| Fujifilm | RAF | `INPUT_EXTENSION="RAF"` |
| Olympus | ORF | `INPUT_EXTENSION="ORF"` |
| Panasonic | RW2 | `INPUT_EXTENSION="RW2"` |
| Pentax | PEF, DNG | `INPUT_EXTENSION="PEF"` |
| Adobe | DNG | `INPUT_EXTENSION="DNG"` |
| Leica | DNG, RWL | `INPUT_EXTENSION="DNG"` |

To change the format:
```bash
# Edit the script
nano process_raw_photos.sh

# Find and modify:
INPUT_EXTENSION="NEF"  # Change to your format
```

---

## Version History

### v1.0 (December 2025)
- Initial release
- Intelligent per-image analysis
- 7 professional presets (auto, portrait, vivid, soft, bw, vintage, natural)
- Advanced adjustment controls (contrast, highlights, shadows, clarity)
- White balance control (temperature, tint)
- Vibrance and noise reduction
- Output options (resize, watermark, web versions)
- Analysis and preview modes
- Full processing pipeline
- Batch processing support

---

## License

This project is licensed under the **GNU General Public License v3.0** (GPL-3.0).

You are free to:
- **Use** - Run the software for any purpose
- **Study** - Examine the source code and learn from it
- **Share** - Redistribute copies
- **Modify** - Make changes and distribute your modified versions

Under the following conditions:
- **Disclose source** - Source code must be made available when distributing
- **Same license** - Modifications must be released under GPL-3.0
- **State changes** - Changes made to the code must be documented
- **License notice** - Include the original license and copyright notice

For the full license text, see: [GNU GPL v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)

Copyright (C) 2025 Marcos Fermin

## Credits

Created by Marcos Fermin - [marcosfermin.com](https://marcosfermin.com)
