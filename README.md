# RAW Photo Batch Processor v2.0

A professional-grade bash script for batch processing RAW files with **AI-like intelligent analysis**, multi-format support, parallel processing, and comprehensive editing tools.

---

## Table of Contents

1. [What's New in v2.0](#whats-new-in-v20)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Quick Start](#quick-start)
6. [Command Line Reference](#command-line-reference)
7. [Presets](#presets)
8. [Adjustment Controls](#adjustment-controls)
9. [Output Options](#output-options)
10. [Analysis & Preview Modes](#analysis--preview-modes)
11. [Intelligent Processing Pipeline](#intelligent-processing-pipeline)
12. [Configuration File](#configuration-file)
13. [Examples](#examples)
14. [Technical Reference](#technical-reference)
15. [Troubleshooting](#troubleshooting)
16. [Supported RAW Formats](#supported-raw-formats)

---

## What's New in v2.0

### Multi-Format RAW Support
Process files from any major camera manufacturer without configuration changes:
- **Canon**: CR2, CR3
- **Nikon**: NEF
- **Sony**: ARW
- **Fujifilm**: RAF
- **Olympus**: ORF
- **Panasonic**: RW2
- **Pentax**: PEF
- **Samsung**: SRW
- **Adobe**: DNG
- **Hasselblad**: 3FR
- **Phase One**: IIQ

### Intelligent Features
- **EXIF-Based Intelligence** - Uses ISO, aperture, shutter speed, and focal length for smart decisions
- **Face Detection** - Automatically detects portraits and applies optimized settings
- **Scene Detection** - Identifies landscape, portrait, night, indoor, and macro scenes
- **Adaptive Noise Reduction** - ISO-based automatic noise reduction
- **Blur Detection** - Measures sharpness and adjusts accordingly
- **Histogram Analysis** - Advanced exposure analysis with clipping detection

### Performance
- **Parallel Processing** - Multi-core support for dramatically faster batch processing
- **Progress Bar with ETA** - Visual progress with accurate time estimates

### Metadata
- **EXIF Preservation** - Copies EXIF, IPTC, and XMP metadata to output files

---

## Features

### Core Features
- **Multi-Format RAW Support** - Process CR2, NEF, ARW, ORF, RAF, DNG, and more
- **Intelligent Per-Image Analysis** - Automatically analyzes each photo and calculates optimal corrections
- **7 Professional Presets** - One-click styles for different photography types
- **Batch Processing** - Process hundreds of RAW files automatically
- **High-Quality Output** - Maximum quality JPEG, PNG, or TIFF output

### Intelligent Detection (v2.0)
- **Face Detection** - Detects portraits and auto-applies flattering settings
- **Scene Detection** - Identifies landscape, portrait, night, indoor, macro scenes
- **Blur Detection** - Measures image sharpness using Laplacian variance
- **EXIF Intelligence** - Uses camera data for smarter processing decisions
- **Histogram Analysis** - Detects clipping and exposure distribution

### Advanced Adjustments
- **Exposure Control** - Brightness, highlights, shadows
- **Contrast & Clarity** - Fine-tune image punch and local contrast
- **White Balance** - Temperature and tint adjustments
- **Color Control** - Saturation and vibrance
- **Noise Reduction** - Adjustable or automatic ISO-based removal
- **Sharpening** - Professional unsharp mask with adaptive control

### Output Options
- **Resize** - By dimension or percentage
- **Watermarks** - Text overlay with positioning
- **Web Versions** - Auto-generate optimized copies
- **Multiple Formats** - JPEG, PNG, TIFF
- **Custom Output Directory** - Organize processed files
- **Metadata Preservation** - Keep EXIF, IPTC, XMP data

### Performance Features (v2.0)
- **Parallel Processing** - Use multiple CPU cores
- **Progress Bar** - Visual progress with percentage
- **ETA Calculation** - Accurate time remaining estimates
- **Auto CPU Detection** - Automatically uses optimal core count

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

### ExifTool (Recommended for v2.0 features)

Required for EXIF intelligence and metadata preservation:

```bash
# macOS (using Homebrew)
brew install exiftool

# Ubuntu/Debian
sudo apt-get install libimage-exiftool-perl

# Fedora/RHEL
sudo dnf install perl-Image-ExifTool
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
exiftool -ver
bc --version
```

---

## Installation

### From GitHub

```bash
# Clone the repository
git clone https://github.com/marcosfermin/process_raw_photos.git
cd process_raw_photos

# Make executable
chmod +x process_raw_photos.sh

# Verify it works
./process_raw_photos.sh --help
```

### Manual Installation

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
./process_raw_photos.sh
```

### Process All RAW Formats

```bash
# Auto-detect and process all supported RAW formats
./process_raw_photos.sh --auto-format

# Process only Nikon files
./process_raw_photos.sh --format NEF

# Process only Sony files
./process_raw_photos.sh --format ARW
```

### Use Parallel Processing (v2.0)

```bash
# Use 4 CPU cores
./process_raw_photos.sh --parallel 4

# Auto-detect and use all available cores
./process_raw_photos.sh --parallel 0
```

### Use a Preset

```bash
./process_raw_photos.sh --preset portrait
./process_raw_photos.sh --preset vivid
./process_raw_photos.sh --preset bw
```

### Analyze Before Processing

```bash
# See detailed analysis including scene detection, EXIF data, and recommendations
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
| `--noise-reduction VALUE` | 0 to 100 | Noise reduction strength (or use adaptive) |
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

#### Intelligent Processing (v2.0)

| Option | Description |
|--------|-------------|
| `--parallel N` | Use N parallel jobs (0 = auto-detect CPU cores) |
| `--format EXT` | RAW format to process (CR2, NEF, ARW, etc.) |
| `--auto-format` | Auto-detect all RAW formats in directory (default) |
| `--no-face-detection` | Disable automatic face detection |
| `--no-scene-detection` | Disable automatic scene detection |
| `--no-adaptive-noise` | Disable ISO-based noise reduction |
| `--no-blur-detection` | Disable blur detection |
| `--preserve-metadata` | Preserve EXIF/IPTC/XMP metadata (default: on) |
| `--no-preserve-metadata` | Don't copy metadata to output files |

---

## Presets

Presets provide one-click styles optimized for different types of photography.

### Available Presets

| Preset | Description | Best For |
|--------|-------------|----------|
| `auto` | Intelligent per-image analysis with scene detection (default) | General use, mixed content |
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
Scene Detection: ON
Face Detection: ON
- Analyzes exposure, contrast, and color cast per image
- Detects scene type and applies appropriate adjustments
- Detects faces and applies portrait optimizations
- Uses EXIF data for ISO-based noise reduction
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

Reduces digital noise (grain) in images. In v2.0, this can be automatic based on ISO.

| Value | Range | Effect |
|-------|-------|--------|
| 0 | - | No noise reduction (or use adaptive) |
| 1-29 | Light | Single despeckle pass |
| 30-59 | Medium | Double despeckle pass |
| 60-100 | Heavy | Blur-based reduction with resharpening |

**Adaptive Noise Reduction (v2.0)**

When ExifTool is available and `--no-adaptive-noise` is not set, noise reduction is automatically calculated based on ISO:

| ISO Range | Auto NR Level |
|-----------|---------------|
| 0-400 | 0 (none) |
| 401-800 | 10 |
| 801-1600 | 25 |
| 1601-3200 | 40 |
| 3201-6400 | 55 |
| 6401-12800 | 70 |
| 12800+ | 85 |

```bash
# Manual noise reduction
./process_raw_photos.sh --noise-reduction 50

# Disable adaptive (use manual only)
./process_raw_photos.sh --no-adaptive-noise --noise-reduction 30
```

#### Sharpening (`--sharpen`)

Controls the sharpening amount applied after processing. In v2.0, this adapts based on blur detection.

| Value | Effect |
|-------|--------|
| 0 | No sharpening |
| 0.3 | Subtle sharpening |
| 0.5 | Standard sharpening (default) |
| 0.7 | Strong sharpening |
| 1.0+ | Very strong sharpening |

**Adaptive Sharpening (v2.0)**

When blur detection is enabled:
- Blurry images: Sharpening increased by 50% (max 1.0)
- Very sharp images: Sharpening reduced by 30% to avoid artifacts

```bash
# Manual sharpening
./process_raw_photos.sh --sharpen 0.8

# Disable adaptive sharpening
./process_raw_photos.sh --no-blur-detection --sharpen 0.5
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

### Metadata Preservation (`--preserve-metadata`)

Copy EXIF, IPTC, and XMP metadata from RAW files to output JPEGs.

```bash
# Preserve all metadata (default when ExifTool is available)
./process_raw_photos.sh --preserve-metadata

# Don't preserve metadata
./process_raw_photos.sh --no-preserve-metadata
```

---

## Analysis & Preview Modes

### Analysis Mode (`--analyze`)

Analyze all images without processing. Shows detailed metrics and recommended corrections for each image, including v2.0 intelligent detection results.

```bash
./process_raw_photos.sh --analyze
```

#### Output Example (v2.0)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Image: IMG_0001.CR2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Camera/EXIF Data:
  Camera:             Canon EOS R5
  Lens:               RF24-70mm F2.8 L IS USM
  ISO:                800
  Aperture:           2.8
  Shutter:            1/200
  Focal Length:       50mm
  Flash:              Not fired

Intelligent Detection:
  Scene Type:         portrait (90% confidence)
  Faces Detected:     Yes
  Sharpness Score:    156.3 (Sharp)

Exposure Analysis:
  Mean Brightness:    95.3 / 255
  Dynamic Range:      12.0 - 248.5
  Contrast (StdDev):  52.4
  Status:             underexposed

Histogram Analysis:
  Shadow Clipping:    3.5%
  Highlight Clipping: 1.2%
  Midtone Peak:       95
  Distribution:       left-heavy

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
  Noise Reduction:    10 (based on ISO 800)
  Sharpening:         0.5
  Scene Preset:       portrait mode recommended
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
1. Displays full analysis of the image (including v2.0 intelligent detection)
2. Shows recommended corrections
3. Processes the single file
4. Reports success and output file size

---

## Intelligent Processing Pipeline

When intelligent analysis is enabled (default), each image goes through this enhanced v2.0 pipeline:

### 1. EXIF Data Extraction (v2.0)

Extracts camera metadata for intelligent decisions:

| Data | Used For |
|------|----------|
| ISO | Adaptive noise reduction |
| Aperture | Depth of field estimation |
| Shutter Speed | Motion blur detection |
| Focal Length | Scene type hints |
| Camera Model | Camera-specific tuning |
| Flash | Indoor scene detection |

### 2. Face Detection (v2.0)

Analyzes image for portrait characteristics:
- Skin tone detection via HSL color analysis
- Centered subject detection
- If faces detected: applies portrait-optimized settings

### 3. Scene Detection (v2.0)

Automatically identifies scene type:

| Scene | Detection Method | Applied Adjustments |
|-------|------------------|---------------------|
| Portrait | Face detected, centered subject | Softer, reduced sharpening |
| Landscape | Wide aspect ratio, blue/green colors | Increased saturation, clarity |
| Night | Low brightness, high ISO | Shadow lift, extra noise reduction |
| Indoor | Flash fired, low saturation | Warmer temperature |
| Macro | Short focal length, high center detail | Maximum sharpness, vibrance |

### 4. Blur Detection (v2.0)

Measures image sharpness using Laplacian variance:
- High variance = sharp image (reduce sharpening)
- Low variance = blurry image (increase sharpening)

### 5. Histogram Analysis (v2.0)

Advanced exposure analysis:

| Metric | Description | Used For |
|--------|-------------|----------|
| Shadow Clipping | % of pure black pixels | Shadow recovery |
| Highlight Clipping | % of pure white pixels | Highlight recovery |
| Midtone Peak | Position of histogram center | Exposure adjustment |
| Distribution | left-heavy, normal, right-heavy | Correction strategy |

### 6. Standard Image Analysis

For each image, the script analyzes:

| Metric | Description | Used For |
|--------|-------------|----------|
| Mean Brightness | Average luminosity (0-255) | Exposure correction |
| Standard Deviation | Contrast indicator | Contrast adjustment |
| Min/Max Values | Dynamic range | Clipping detection |
| Channel Means (R/G/B) | Per-channel averages | Color cast detection |

### 7. Correction Calculation

Based on all analysis, the script calculates optimal corrections:

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
| High ISO | Apply noise reduction |
| Low sharpness | Increase sharpening |

### 8. Processing Order

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
10. **Noise Reduction** - Adaptive or manual
11. **Sharpening** - Adaptive unsharp mask
12. **Resize** - If requested
13. **Watermark** - If requested
14. **Save** - With quality settings
15. **Web Version** - If requested
16. **Metadata Preservation** - Copy EXIF/IPTC/XMP

---

## Configuration File

Default values can be modified by editing the script's configuration section:

```bash
#-------------------------------------------------------------------------------
# CONFIGURATION SECTION
#-------------------------------------------------------------------------------

# Input file extension
INPUT_EXTENSION="CR2"

# Multi-format support (v2.0)
AUTO_DETECT_FORMAT=true
SUPPORTED_RAW_FORMATS=("CR2" "CR3" "NEF" "ARW" "ORF" "RAF" "DNG" "RW2" "PEF" "SRW" "3FR" "IIQ")

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

# v2.0 Intelligent Processing Options
PARALLEL_JOBS=1              # 0 = auto-detect CPU cores
ENABLE_FACE_DETECTION=true
ENABLE_SCENE_DETECTION=true
ENABLE_ADAPTIVE_NOISE=true
ENABLE_BLUR_DETECTION=true
PRESERVE_EXIF=true

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

# Process with no enhancements (straight RAW to JPEG conversion)
./process_raw_photos.sh -n

# Show help
./process_raw_photos.sh --help

# Show version
./process_raw_photos.sh --version
```

---

### Multi-Format Examples (v2.0)

```bash
# Process all RAW formats found in directory (default behavior)
./process_raw_photos.sh --auto-format

# Process only Canon CR2 files
./process_raw_photos.sh --format CR2

# Process only Canon CR3 files (newer Canon cameras)
./process_raw_photos.sh --format CR3

# Process only Nikon NEF files
./process_raw_photos.sh --format NEF

# Process only Sony ARW files
./process_raw_photos.sh --format ARW

# Process only Fujifilm RAF files
./process_raw_photos.sh --format RAF

# Process only Olympus ORF files
./process_raw_photos.sh --format ORF

# Process only Panasonic RW2 files
./process_raw_photos.sh --format RW2

# Process only Adobe DNG files
./process_raw_photos.sh --format DNG

# Process only Pentax PEF files
./process_raw_photos.sh --format PEF

# Process all formats from a multi-camera shoot
./process_raw_photos.sh --auto-format --parallel 0
```

---

### Parallel Processing Examples (v2.0)

```bash
# Use 2 CPU cores (light load)
./process_raw_photos.sh --parallel 2

# Use 4 CPU cores (balanced)
./process_raw_photos.sh --parallel 4

# Use 8 CPU cores (heavy load)
./process_raw_photos.sh --parallel 8

# Auto-detect and use all available cores (fastest)
./process_raw_photos.sh --parallel 0

# Fast processing with all cores and vivid preset
./process_raw_photos.sh --parallel 0 --preset vivid

# Parallel processing with web version generation
./process_raw_photos.sh --parallel 0 --web-version

# Maximum speed: all cores, quiet mode, no extra features
./process_raw_photos.sh --parallel 0 --quiet --no-face-detection --no-scene-detection
```

---

### Preset Examples

```bash
# Auto preset (intelligent analysis - default)
./process_raw_photos.sh --preset auto

# Portrait - soft, flattering, skin-friendly
./process_raw_photos.sh --preset portrait

# Vivid - punchy colors, high contrast
./process_raw_photos.sh --preset vivid

# Soft - dreamy, muted, low contrast
./process_raw_photos.sh --preset soft

# Black & White - professional monochrome
./process_raw_photos.sh --preset bw

# Vintage - warm, faded, nostalgic
./process_raw_photos.sh --preset vintage

# Natural - minimal processing, true to life
./process_raw_photos.sh --preset natural
```

---

### Tone Adjustment Examples

```bash
# Increase contrast for flat images
./process_raw_photos.sh --contrast 30

# Decrease contrast for softer look
./process_raw_photos.sh --contrast -20

# Maximum contrast for dramatic effect
./process_raw_photos.sh --contrast 50

# Recover blown highlights
./process_raw_photos.sh --highlights -40

# Boost highlights for airy look
./process_raw_photos.sh --highlights 20

# Lift shadows to reveal detail
./process_raw_photos.sh --shadows 35

# Deepen shadows for drama
./process_raw_photos.sh --shadows -25

# Add clarity/punch to midtones
./process_raw_photos.sh --clarity 30

# Soften for portraits (negative clarity)
./process_raw_photos.sh --clarity -20

# Combined: lift shadows and recover highlights (HDR-like)
./process_raw_photos.sh --shadows 40 --highlights -30

# Combined: high contrast with shadow detail
./process_raw_photos.sh --contrast 25 --shadows 20
```

---

### White Balance Examples

```bash
# Warm up cold/blue photos
./process_raw_photos.sh --temperature 30

# Cool down warm/orange photos
./process_raw_photos.sh --temperature -25

# Very warm (golden hour simulation)
./process_raw_photos.sh --temperature 50

# Very cool (blue hour simulation)
./process_raw_photos.sh --temperature -40

# Correct green color cast (add magenta)
./process_raw_photos.sh --tint 15

# Correct magenta color cast (add green)
./process_raw_photos.sh --tint -15

# Combined: warm with slight magenta (sunset look)
./process_raw_photos.sh --temperature 35 --tint 10

# Combined: cool with slight green (forest shade)
./process_raw_photos.sh --temperature -20 --tint -10
```

---

### Color Adjustment Examples

```bash
# Boost saturation for vivid colors
./process_raw_photos.sh --saturation 130

# Reduce saturation for muted look
./process_raw_photos.sh --saturation 80

# Desaturate completely (another way to do B&W)
./process_raw_photos.sh --saturation 0

# Add vibrance (protects skin tones)
./process_raw_photos.sh --vibrance 40

# Maximum vibrance
./process_raw_photos.sh --vibrance 100

# Combined: moderate saturation with high vibrance
./process_raw_photos.sh --saturation 110 --vibrance 50

# Portrait-friendly: reduced saturation, added vibrance
./process_raw_photos.sh --saturation 90 --vibrance 30
```

---

### Noise Reduction Examples

```bash
# Light noise reduction (ISO 800-1600)
./process_raw_photos.sh --noise-reduction 20

# Medium noise reduction (ISO 1600-3200)
./process_raw_photos.sh --noise-reduction 40

# Heavy noise reduction (ISO 3200-6400)
./process_raw_photos.sh --noise-reduction 60

# Maximum noise reduction (ISO 6400+)
./process_raw_photos.sh --noise-reduction 85

# Noise reduction with reduced sharpening
./process_raw_photos.sh --noise-reduction 50 --sharpen 0.3

# Let adaptive noise reduction handle it (based on ISO)
./process_raw_photos.sh  # automatic when ExifTool is available

# Disable adaptive, use manual only
./process_raw_photos.sh --no-adaptive-noise --noise-reduction 40
```

---

### Sharpening Examples

```bash
# Subtle sharpening (portraits)
./process_raw_photos.sh --sharpen 0.3

# Standard sharpening (default)
./process_raw_photos.sh --sharpen 0.5

# Strong sharpening (landscapes, architecture)
./process_raw_photos.sh --sharpen 0.7

# Very strong sharpening (macro, product)
./process_raw_photos.sh --sharpen 1.0

# No sharpening
./process_raw_photos.sh --sharpen 0

# Let adaptive sharpening handle it (based on blur detection)
./process_raw_photos.sh  # automatic

# Disable adaptive sharpening
./process_raw_photos.sh --no-blur-detection --sharpen 0.5
```

---

### Resize Examples

```bash
# Resize to max 4000px (full resolution for prints)
./process_raw_photos.sh --resize 4000

# Resize to max 3000px (high quality web)
./process_raw_photos.sh --resize 3000

# Resize to max 2000px (standard web)
./process_raw_photos.sh --resize 2000

# Resize to max 1920px (full HD)
./process_raw_photos.sh --resize 1920

# Resize to max 1200px (blog/social media)
./process_raw_photos.sh --resize 1200

# Resize to max 800px (thumbnails)
./process_raw_photos.sh --resize 800

# Resize to 50% of original
./process_raw_photos.sh --resize 50%

# Resize to 25% of original
./process_raw_photos.sh --resize 25%
```

---

### Output Format Examples

```bash
# Output as JPEG (default)
./process_raw_photos.sh --format jpg

# Output as PNG (lossless, larger files)
./process_raw_photos.sh --format png

# Output as TIFF (print-ready, archival)
./process_raw_photos.sh --format tiff

# JPEG with maximum quality (default)
./process_raw_photos.sh --quality 100

# JPEG with high quality (slightly smaller)
./process_raw_photos.sh --quality 95

# JPEG with good quality (web-friendly)
./process_raw_photos.sh --quality 85

# JPEG with acceptable quality (small files)
./process_raw_photos.sh --quality 70
```

---

### Output Directory Examples

```bash
# Save to "processed" folder
./process_raw_photos.sh --output-dir ./processed

# Save to "edited" folder
./process_raw_photos.sh --output-dir ./edited

# Save to folder with date
./process_raw_photos.sh --output-dir "./2025-01-15 Edited"

# Save to folder with event name
./process_raw_photos.sh --output-dir "./Wedding - Smith Family"

# Save to absolute path
./process_raw_photos.sh --output-dir /Users/photographer/Exports

# Save to external drive
./process_raw_photos.sh --output-dir "/Volumes/External HD/Photos"

# Save to Dropbox
./process_raw_photos.sh --output-dir ~/Dropbox/Photos/Edited

# Save to Google Drive
./process_raw_photos.sh --output-dir "/Users/name/Google Drive/Photos"
```

---

### Watermark Examples

```bash
# Simple text watermark
./process_raw_photos.sh --watermark "Photo by John"

# Copyright watermark
./process_raw_photos.sh --watermark "© 2025 Studio Name"

# Website watermark
./process_raw_photos.sh --watermark "www.photographer.com"

# Watermark bottom-right (default)
./process_raw_photos.sh --watermark "Studio X" --watermark-position bottomright

# Watermark bottom-left
./process_raw_photos.sh --watermark "Studio X" --watermark-position bottomleft

# Watermark top-right
./process_raw_photos.sh --watermark "Studio X" --watermark-position topright

# Watermark top-left
./process_raw_photos.sh --watermark "Studio X" --watermark-position topleft

# Watermark center
./process_raw_photos.sh --watermark "PROOF" --watermark-position center

# Subtle watermark (low opacity)
./process_raw_photos.sh --watermark "Studio X" --watermark-opacity 30

# Bold watermark (high opacity)
./process_raw_photos.sh --watermark "SAMPLE" --watermark-opacity 70

# Full watermark with all options
./process_raw_photos.sh --watermark "© 2025 My Studio" --watermark-position bottomright --watermark-opacity 40
```

---

### Web Version Examples

```bash
# Create web versions with defaults (1200px, 85% quality)
./process_raw_photos.sh --web-version

# Web version at 1920px (full HD)
./process_raw_photos.sh --web-version --web-size 1920

# Web version at 800px (thumbnails/social)
./process_raw_photos.sh --web-version --web-size 800

# Web version at lower quality (faster loading)
./process_raw_photos.sh --web-version --web-quality 75

# Web version at higher quality
./process_raw_photos.sh --web-version --web-quality 90

# Full resolution + web version
./process_raw_photos.sh --web-version --resize 4000 --web-size 1200
```

---

### Analysis & Preview Examples

```bash
# Analyze all images (no processing)
./process_raw_photos.sh --analyze

# Preview single image with default settings
./process_raw_photos.sh --preview IMG_0001.CR2

# Preview with specific preset
./process_raw_photos.sh --preview IMG_0001.CR2 --preset portrait

# Preview with adjustments
./process_raw_photos.sh --preview IMG_0001.CR2 --contrast 20 --vibrance 30

# Preview with full settings
./process_raw_photos.sh --preview IMG_0001.CR2 --preset vivid --shadows 20 --highlights -10 --resize 2000

# Preview Nikon file
./process_raw_photos.sh --preview DSC_0001.NEF --preset landscape

# Preview Sony file
./process_raw_photos.sh --preview DSC00001.ARW --preset natural
```

---

### Intelligent Features Control (v2.0)

```bash
# Full intelligent processing (default)
./process_raw_photos.sh

# Disable face detection
./process_raw_photos.sh --no-face-detection

# Disable scene detection
./process_raw_photos.sh --no-scene-detection

# Disable adaptive noise reduction
./process_raw_photos.sh --no-adaptive-noise

# Disable blur detection
./process_raw_photos.sh --no-blur-detection

# Disable all intelligent features
./process_raw_photos.sh --no-face-detection --no-scene-detection --no-adaptive-noise --no-blur-detection

# Disable intelligent per-image analysis
./process_raw_photos.sh --no-analysis

# Preserve metadata (default when ExifTool available)
./process_raw_photos.sh --preserve-metadata

# Don't preserve metadata
./process_raw_photos.sh --no-preserve-metadata
```

---

### Portrait Photography Examples

```bash
# Basic portrait processing
./process_raw_photos.sh --preset portrait

# Portrait with skin smoothing
./process_raw_photos.sh --preset portrait --clarity -15

# Portrait with eye pop
./process_raw_photos.sh --preset portrait --clarity -10 --sharpen 0.4

# Portrait with warm skin tones
./process_raw_photos.sh --preset portrait --temperature 15

# High-key portrait
./process_raw_photos.sh --preset portrait --shadows 30 --highlights 10

# Low-key portrait
./process_raw_photos.sh --preset portrait --shadows -10 --contrast 15

# Portrait for print
./process_raw_photos.sh --preset portrait --format tiff --resize 4000

# Portrait for Instagram
./process_raw_photos.sh --preset portrait --resize 1080 --quality 90

# Headshot with watermark
./process_raw_photos.sh --preset portrait --watermark "© Photographer Name"

# Batch portrait session
./process_raw_photos.sh --preset portrait --parallel 0 --web-version --output-dir "./Portraits - Edited"

# Family portrait session
./process_raw_photos.sh \
  --preset portrait \
  --vibrance 20 \
  --clarity -10 \
  --resize 4000 \
  --web-version \
  --web-size 1200 \
  --output-dir "./Family Session"

# Corporate headshots
./process_raw_photos.sh \
  --preset portrait \
  --contrast 5 \
  --clarity -5 \
  --saturation 95 \
  --resize 3000 \
  --output-dir "./Corporate Headshots"
```

---

### Wedding Photography Examples

```bash
# Wedding - getting ready shots
./process_raw_photos.sh --preset portrait --shadows 15 --temperature 10

# Wedding - ceremony (mixed lighting)
./process_raw_photos.sh --preset auto --parallel 0

# Wedding - reception (low light)
./process_raw_photos.sh --preset portrait --shadows 25 --noise-reduction 40

# Wedding - outdoor portraits
./process_raw_photos.sh --preset portrait --highlights -20 --vibrance 25

# Wedding - dance floor
./process_raw_photos.sh --preset auto --noise-reduction 50 --sharpen 0.4

# Wedding - full workflow
./process_raw_photos.sh \
  --preset portrait \
  --auto-format \
  --parallel 0 \
  --resize 4000 \
  --web-version \
  --web-size 1500 \
  --preserve-metadata \
  --output-dir "./Wedding - Smith & Johnson"

# Wedding - client preview (watermarked)
./process_raw_photos.sh \
  --preset portrait \
  --resize 1500 \
  --watermark "PROOF - Studio Name" \
  --watermark-position center \
  --watermark-opacity 30 \
  --output-dir "./Wedding - Proofs"

# Wedding - print delivery
./process_raw_photos.sh \
  --preset portrait \
  --format tiff \
  --resize 6000 \
  --output-dir "./Wedding - Print Files"

# Wedding - social media teaser
./process_raw_photos.sh \
  --preset portrait \
  --vibrance 30 \
  --resize 1080 \
  --watermark "© Studio Name" \
  --output-dir "./Wedding - Social"
```

---

### Landscape Photography Examples

```bash
# Basic landscape
./process_raw_photos.sh --preset vivid

# Landscape with extra punch
./process_raw_photos.sh --preset vivid --clarity 35 --vibrance 50

# Sunrise/sunset landscapes
./process_raw_photos.sh --preset vivid --temperature 20 --saturation 120

# Blue hour landscapes
./process_raw_photos.sh --preset vivid --temperature -15 --saturation 115

# Moody landscape
./process_raw_photos.sh --preset vivid --contrast 25 --saturation 90 --shadows -10

# Misty/foggy landscape
./process_raw_photos.sh --preset soft --contrast -10 --saturation 85

# Mountain landscape
./process_raw_photos.sh --preset vivid --clarity 40 --highlights -25 --shadows 30

# Beach landscape
./process_raw_photos.sh --preset vivid --highlights -20 --temperature 10

# Forest landscape
./process_raw_photos.sh --preset vivid --shadows 25 --vibrance 40 --temperature -10

# Desert landscape
./process_raw_photos.sh --preset vivid --temperature 25 --contrast 20 --clarity 30

# Landscape for print
./process_raw_photos.sh \
  --preset vivid \
  --clarity 30 \
  --format tiff \
  --resize 8000 \
  --output-dir "./Landscapes - Print"

# Landscape for web gallery
./process_raw_photos.sh \
  --preset vivid \
  --resize 2500 \
  --web-version \
  --watermark "© Nature Photos" \
  --output-dir "./Landscapes - Web"
```

---

### Event Photography Examples

```bash
# Corporate event
./process_raw_photos.sh \
  --preset auto \
  --parallel 0 \
  --resize 3000 \
  --output-dir "./Corporate Event"

# Conference/seminar
./process_raw_photos.sh \
  --preset natural \
  --shadows 20 \
  --noise-reduction 30 \
  --parallel 0 \
  --output-dir "./Conference 2025"

# Birthday party
./process_raw_photos.sh \
  --preset portrait \
  --vibrance 30 \
  --parallel 0 \
  --web-version \
  --output-dir "./Birthday Party"

# Graduation ceremony
./process_raw_photos.sh \
  --preset portrait \
  --resize 4000 \
  --web-version \
  --watermark "Graduation 2025" \
  --output-dir "./Graduation"

# Sports event
./process_raw_photos.sh \
  --preset vivid \
  --contrast 15 \
  --sharpen 0.7 \
  --parallel 0 \
  --output-dir "./Sports Event"

# Concert/live music
./process_raw_photos.sh \
  --preset vivid \
  --shadows 30 \
  --noise-reduction 50 \
  --saturation 120 \
  --output-dir "./Concert Photos"

# Quinceañera / Sweet 16
./process_raw_photos.sh \
  --preset portrait \
  --vibrance 25 \
  --temperature 10 \
  --parallel 0 \
  --resize 4000 \
  --web-version \
  --output-dir "./Quinceañera - Maria"

# School event
./process_raw_photos.sh \
  --preset auto \
  --parallel 0 \
  --resize 3000 \
  --web-version \
  --web-size 1000 \
  --output-dir "./School Event"
```

---

### Product Photography Examples

```bash
# Basic product shot
./process_raw_photos.sh --preset vivid --clarity 25

# White background product
./process_raw_photos.sh --preset vivid --highlights 10 --contrast 15

# Jewelry photography
./process_raw_photos.sh \
  --preset vivid \
  --clarity 35 \
  --sharpen 0.8 \
  --saturation 110 \
  --format png

# Food photography
./process_raw_photos.sh \
  --preset vivid \
  --temperature 15 \
  --saturation 115 \
  --vibrance 40 \
  --clarity 20

# Clothing/fashion product
./process_raw_photos.sh \
  --preset natural \
  --contrast 10 \
  --clarity 15 \
  --format png \
  --resize 2500

# Electronics product
./process_raw_photos.sh \
  --preset vivid \
  --contrast 20 \
  --clarity 30 \
  --sharpen 0.7 \
  --format png

# E-commerce batch processing
./process_raw_photos.sh \
  --preset vivid \
  --contrast 15 \
  --clarity 25 \
  --format png \
  --resize 2000 \
  --parallel 0 \
  --output-dir "./Products - Web Ready"

# Amazon/eBay listing photos
./process_raw_photos.sh \
  --preset vivid \
  --highlights 5 \
  --contrast 15 \
  --resize 1500 \
  --quality 95 \
  --output-dir "./Listings"
```

---

### Real Estate Photography Examples

```bash
# Interior shots
./process_raw_photos.sh \
  --preset natural \
  --shadows 30 \
  --highlights -20 \
  --temperature 5

# Exterior shots
./process_raw_photos.sh \
  --preset vivid \
  --clarity 20 \
  --vibrance 25

# HDR-style processing
./process_raw_photos.sh \
  --shadows 40 \
  --highlights -35 \
  --clarity 25 \
  --saturation 110

# Full real estate workflow
./process_raw_photos.sh \
  --preset natural \
  --shadows 35 \
  --highlights -25 \
  --vibrance 20 \
  --resize 3000 \
  --web-version \
  --web-size 1200 \
  --parallel 0 \
  --output-dir "./Property - 123 Main St"

# MLS-ready photos
./process_raw_photos.sh \
  --preset natural \
  --shadows 30 \
  --highlights -20 \
  --resize 2048 \
  --quality 90 \
  --output-dir "./MLS Photos"
```

---

### Black & White Examples

```bash
# Standard B&W conversion
./process_raw_photos.sh --preset bw

# High contrast B&W
./process_raw_photos.sh --preset bw --contrast 30

# Low contrast B&W (vintage feel)
./process_raw_photos.sh --preset bw --contrast -10

# Film noir style
./process_raw_photos.sh --preset bw --contrast 40 --shadows -20

# High-key B&W
./process_raw_photos.sh --preset bw --shadows 30 --highlights 15

# Low-key B&W
./process_raw_photos.sh --preset bw --shadows -15 --contrast 25

# B&W portrait
./process_raw_photos.sh --preset bw --clarity -10 --contrast 15

# B&W landscape
./process_raw_photos.sh --preset bw --clarity 30 --contrast 25

# B&W street photography
./process_raw_photos.sh --preset bw --contrast 20 --clarity 20 --sharpen 0.6

# Fine art B&W print
./process_raw_photos.sh \
  --preset bw \
  --contrast 20 \
  --clarity 25 \
  --format tiff \
  --resize 6000 \
  --output-dir "./BW Fine Art"
```

---

### Vintage/Retro Style Examples

```bash
# Standard vintage look
./process_raw_photos.sh --preset vintage

# Faded film look
./process_raw_photos.sh --preset vintage --highlights 20 --saturation 80

# 70s warm vintage
./process_raw_photos.sh --preset vintage --temperature 35 --saturation 85

# Cross-processed look
./process_raw_photos.sh --temperature 20 --tint 15 --contrast 15 --saturation 110

# Polaroid-style
./process_raw_photos.sh --preset vintage --contrast -15 --highlights 25 --saturation 85

# Kodachrome-inspired
./process_raw_photos.sh --preset vivid --temperature 15 --saturation 120 --contrast 20

# Portra-style (portrait film)
./process_raw_photos.sh --preset portrait --temperature 10 --saturation 95 --contrast -5

# Cinematic vintage
./process_raw_photos.sh \
  --preset vintage \
  --temperature 20 \
  --contrast 10 \
  --highlights 15 \
  --saturation 85
```

---

### Night Photography Examples

```bash
# Night cityscape
./process_raw_photos.sh \
  --shadows 30 \
  --highlights -25 \
  --noise-reduction 40 \
  --vibrance 30

# Night portrait
./process_raw_photos.sh \
  --preset portrait \
  --shadows 25 \
  --noise-reduction 50 \
  --sharpen 0.4

# Astrophotography / stars
./process_raw_photos.sh \
  --shadows 40 \
  --contrast 20 \
  --noise-reduction 30 \
  --saturation 110

# Light trails
./process_raw_photos.sh \
  --preset vivid \
  --contrast 20 \
  --saturation 120 \
  --clarity 25

# Neon/urban night
./process_raw_photos.sh \
  --preset vivid \
  --saturation 130 \
  --vibrance 50 \
  --contrast 25

# Blue hour
./process_raw_photos.sh \
  --preset vivid \
  --temperature -20 \
  --saturation 115 \
  --shadows 25
```

---

### Macro Photography Examples

```bash
# Basic macro
./process_raw_photos.sh --clarity 30 --sharpen 0.8

# Flower macro
./process_raw_photos.sh \
  --preset vivid \
  --clarity 25 \
  --sharpen 0.8 \
  --vibrance 40

# Insect macro
./process_raw_photos.sh \
  --clarity 35 \
  --sharpen 0.9 \
  --contrast 15 \
  --vibrance 30

# Product macro (jewelry, watches)
./process_raw_photos.sh \
  --preset vivid \
  --clarity 30 \
  --sharpen 0.8 \
  --contrast 20 \
  --format png

# Water droplet macro
./process_raw_photos.sh \
  --clarity 35 \
  --sharpen 0.9 \
  --highlights -15 \
  --vibrance 35
```

---

### Studio Photography Examples

```bash
# Beauty/fashion shoot
./process_raw_photos.sh \
  --preset portrait \
  --clarity -15 \
  --vibrance 20 \
  --highlights -10

# Model portfolio
./process_raw_photos.sh \
  --preset portrait \
  --contrast 10 \
  --clarity -10 \
  --resize 4000 \
  --output-dir "./Portfolio"

# Catalog/lookbook
./process_raw_photos.sh \
  --preset natural \
  --contrast 10 \
  --clarity 10 \
  --format png \
  --resize 3000

# High fashion editorial
./process_raw_photos.sh \
  --preset vivid \
  --contrast 20 \
  --clarity 15 \
  --saturation 105

# Fitness photography
./process_raw_photos.sh \
  --preset vivid \
  --contrast 25 \
  --clarity 30 \
  --sharpen 0.7
```

---

### Social Media Optimization Examples

```bash
# Instagram feed (square crop would need additional tool)
./process_raw_photos.sh --preset vivid --resize 1080 --quality 90

# Instagram Stories
./process_raw_photos.sh --preset vivid --resize 1920 --quality 85

# Facebook
./process_raw_photos.sh --preset auto --resize 2048 --quality 85

# Twitter/X
./process_raw_photos.sh --preset vivid --resize 1500 --quality 85

# LinkedIn
./process_raw_photos.sh --preset natural --resize 1920 --quality 90

# Pinterest
./process_raw_photos.sh --preset vivid --vibrance 40 --resize 1500

# Social media batch
./process_raw_photos.sh \
  --preset vivid \
  --vibrance 30 \
  --resize 2048 \
  --quality 85 \
  --parallel 0 \
  --output-dir "./Social Media Ready"
```

---

### Print Preparation Examples

```bash
# Standard print (8x10, 11x14)
./process_raw_photos.sh \
  --format tiff \
  --resize 4000 \
  --output-dir "./Print Ready"

# Large print (16x20, 20x24)
./process_raw_photos.sh \
  --format tiff \
  --resize 6000 \
  --output-dir "./Large Prints"

# Canvas/wall art
./process_raw_photos.sh \
  --preset vivid \
  --format tiff \
  --resize 8000 \
  --output-dir "./Canvas Prints"

# Photo book
./process_raw_photos.sh \
  --format jpg \
  --quality 100 \
  --resize 4000 \
  --output-dir "./Photo Book"

# Fine art giclée print
./process_raw_photos.sh \
  --format tiff \
  --resize 10000 \
  --output-dir "./Fine Art Prints"

# Album prints
./process_raw_photos.sh \
  --preset portrait \
  --format tiff \
  --resize 5000 \
  --output-dir "./Album"
```

---

### Automation & Scripting Examples

```bash
# Quiet mode for cron jobs
./process_raw_photos.sh --quiet --output-dir ./auto_processed

# Background processing
nohup ./process_raw_photos.sh --parallel 0 --output-dir ./batch &

# Process and notify (macOS)
./process_raw_photos.sh --parallel 0 && osascript -e 'display notification "Processing complete" with title "RAW Processor"'

# Process multiple directories
for dir in ./shoot1 ./shoot2 ./shoot3; do
  ./process_raw_photos.sh --parallel 0 --output-dir "${dir}_edited" "$dir"
done

# Process with date-based output folder
./process_raw_photos.sh --output-dir "./processed_$(date +%Y%m%d)"

# Weekly backup processing
./process_raw_photos.sh \
  --quiet \
  --parallel 0 \
  --output-dir "/backup/photos/$(date +%Y)/week_$(date +%V)" \
  /path/to/new/photos
```

---

### Professional Workflow Examples

```bash
# Client delivery workflow
./process_raw_photos.sh \
  --preset portrait \
  --parallel 0 \
  --resize 4000 \
  --web-version \
  --web-size 1500 \
  --preserve-metadata \
  --output-dir "./Client Delivery"

# Stock photography submission
./process_raw_photos.sh \
  --preset natural \
  --preserve-metadata \
  --format jpg \
  --quality 100 \
  --resize 6000 \
  --output-dir "./Stock Submissions"

# Magazine submission
./process_raw_photos.sh \
  --preset natural \
  --format tiff \
  --resize 5000 \
  --output-dir "./Magazine Submission"

# Photojournalism
./process_raw_photos.sh \
  --preset natural \
  --preserve-metadata \
  --resize 4000 \
  --output-dir "./News Photos"

# Archive with full quality
./process_raw_photos.sh \
  --preset natural \
  --format tiff \
  --preserve-metadata \
  --output-dir "./Archive"
```

---

### Complete Project Workflows

```bash
# Complete wedding workflow
./process_raw_photos.sh \
  --preset portrait \
  --auto-format \
  --parallel 0 \
  --shadows 15 \
  --highlights -15 \
  --vibrance 20 \
  --resize 5000 \
  --web-version \
  --web-size 1500 \
  --preserve-metadata \
  --watermark "© Studio Name 2025" \
  --watermark-position bottomright \
  --watermark-opacity 40 \
  --output-dir "./Wedding - Complete Delivery"

# Complete portrait session workflow
./process_raw_photos.sh \
  --preset portrait \
  --parallel 0 \
  --clarity -10 \
  --vibrance 25 \
  --resize 4000 \
  --web-version \
  --web-size 1200 \
  --preserve-metadata \
  --output-dir "./Portrait Session - Final"

# Complete landscape project
./process_raw_photos.sh \
  --preset vivid \
  --parallel 0 \
  --clarity 30 \
  --vibrance 40 \
  --shadows 20 \
  --highlights -20 \
  --format tiff \
  --resize 8000 \
  --web-version \
  --web-size 2000 \
  --watermark "© Landscape Photographer" \
  --output-dir "./Landscape Collection"

# Complete event coverage
./process_raw_photos.sh \
  --preset auto \
  --auto-format \
  --parallel 0 \
  --resize 4000 \
  --web-version \
  --web-size 1200 \
  --preserve-metadata \
  --output-dir "./Event - Full Coverage"

# Complete product catalog
./process_raw_photos.sh \
  --preset vivid \
  --parallel 0 \
  --contrast 15 \
  --clarity 25 \
  --format png \
  --resize 2500 \
  --output-dir "./Product Catalog"
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

### Blur Detection (v2.0)

Uses Laplacian variance to measure sharpness:
```
variance = stddev(convolve(image, laplacian_kernel)) * 10000
```

| Variance | Interpretation | Action |
|----------|----------------|--------|
| < 100 | Blurry | Increase sharpening |
| 100-200 | Normal | Standard sharpening |
| > 200 | Very sharp | Reduce sharpening |

### Scene Detection (v2.0)

Decision tree using multiple factors:

1. **Night**: Mean brightness < 60 AND (ISO > 1600 OR brightness < 40)
2. **Macro**: Focal length < 35mm AND high center detail
3. **Portrait**: Face detected OR centered bright subject
4. **Landscape**: Aspect ratio > 1.4 AND (blue > green OR high saturation)
5. **Indoor**: Flash fired OR saturation < 35%

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

| System | Sequential | Parallel (4 cores) | Parallel (8 cores) |
|--------|------------|-------------------|-------------------|
| Apple Silicon (M1/M2/M3) | ~3 sec/image | ~1 sec/image | ~0.5 sec/image |
| Intel Core i7 | ~5 sec/image | ~1.5 sec/image | ~0.8 sec/image |
| Intel Core i5 | ~7 sec/image | ~2 sec/image | ~1.2 sec/image |

Additional operations add time:
- Intelligent analysis: +0.5 sec/image
- Scene/face detection: +0.3 sec/image
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

#### "ExifTool not found" (v2.0 warning)

Install ExifTool for full v2.0 features:
```bash
# macOS
brew install exiftool

# Ubuntu
sudo apt-get install libimage-exiftool-perl
```

Without ExifTool, the following features are disabled:
- EXIF-based intelligence
- Adaptive noise reduction
- Metadata preservation

#### "bc: command not found"

Install bc calculator:
```bash
# macOS
brew install bc

# Ubuntu
sudo apt-get install bc
```

#### "No RAW files found"

- Check you're in the correct directory
- With `--auto-format`: ensure files have supported extensions
- With `--format EXT`: verify the extension matches your files
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

3. Disable scene detection:
   ```bash
   ./process_raw_photos.sh --no-scene-detection
   ```

4. Use straight conversion:
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

# Disable adaptive sharpening
./process_raw_photos.sh --no-blur-detection
```

#### Noisy images

```bash
# Manual noise reduction
./process_raw_photos.sh --noise-reduction 50

# Let ISO-based adaptive handle it
./process_raw_photos.sh  # (automatic with ExifTool)
```

### Performance Issues

#### Processing is slow

- Use parallel processing: `--parallel 0` (auto-detect cores)
- RAW files are large (~25MB each)
- Intelligent analysis adds ~0.5s per image
- Use `--quiet` mode for slightly faster processing

#### Running out of disk space

- Ensure 2x the size of input files available
- Use `--output-dir` to save to a different drive
- Lower quality slightly: `--quality 90`

---

## Supported RAW Formats

### Auto-Detected Formats (v2.0)

With `--auto-format` (default), the script automatically detects and processes all these formats:

| Camera Brand | Extensions | Notes |
|--------------|------------|-------|
| Canon | CR2, CR3 | Full support |
| Nikon | NEF | Full support |
| Sony | ARW | Full support |
| Fujifilm | RAF | Full support |
| Olympus | ORF | Full support |
| Panasonic | RW2 | Full support |
| Pentax | PEF | Full support |
| Samsung | SRW | Full support |
| Adobe | DNG | Universal RAW format |
| Hasselblad | 3FR | Medium format |
| Phase One | IIQ | Medium format |

### Single-Format Processing

To process only a specific format:

```bash
# Canon CR2
./process_raw_photos.sh --format CR2

# Nikon NEF
./process_raw_photos.sh --format NEF

# Sony ARW
./process_raw_photos.sh --format ARW

# Adobe DNG
./process_raw_photos.sh --format DNG
```

### Adding New Formats

To add support for additional formats, edit the configuration:

```bash
# Edit the script
nano process_raw_photos.sh

# Find and modify:
SUPPORTED_RAW_FORMATS=("CR2" "CR3" "NEF" "ARW" "ORF" "RAF" "DNG" "RW2" "PEF" "SRW" "3FR" "IIQ" "NEW_FORMAT")
```

---

## Version History

### v2.0 (December 2025)
- **Multi-format RAW support** - CR2, CR3, NEF, ARW, ORF, RAF, DNG, RW2, PEF, SRW, 3FR, IIQ
- **EXIF-based intelligence** - Uses camera metadata for smart decisions
- **Face detection** - Auto-detects portraits
- **Scene detection** - Identifies landscape, portrait, night, indoor, macro
- **Adaptive noise reduction** - ISO-based automatic noise reduction
- **Blur detection** - Measures sharpness and adjusts accordingly
- **Histogram analysis** - Advanced exposure analysis
- **Parallel processing** - Multi-core support
- **Progress bar with ETA** - Visual progress tracking
- **Metadata preservation** - EXIF, IPTC, XMP support

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
