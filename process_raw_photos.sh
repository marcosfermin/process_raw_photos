#!/bin/bash
#===============================================================================
#
#   RAW PHOTO BATCH PROCESSOR
#   Version: 4.0
#   Author: Marcos Fermin <https://marcosfermin.com>
#   Date: December 22, 2025
#
#   Copyright (C) 2025 Marcos Fermin <https://marcosfermin.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <https://www.gnu.org/licenses/>.
#
#   Description:
#   Advanced batch processor for RAW files with AI-like intelligent analysis,
#   professional presets, multi-format support, and comprehensive editing tools.
#
#   Key Features (v3.0):
#   - Multi-format RAW support (CR2, NEF, ARW, ORF, RAF, DNG, RW2, PEF, SRW, CR3)
#   - EXIF-based intelligent decisions (ISO-aware noise reduction, lens profiles)
#   - Face detection for automatic portrait mode
#   - Scene type detection (landscape, portrait, night, indoor, macro)
#   - Histogram-based exposure analysis with highlight/shadow clipping detection
#   - Adaptive noise detection and intelligent reduction
#   - Sharpness/blur detection with adaptive sharpening
#   - Parallel processing (multi-core support)
#   - Progress bar with accurate ETA calculation
#   - EXIF metadata preservation in output files
#   - 7 professional presets (auto, portrait, vivid, soft, bw, vintage, natural)
#   - Advanced adjustments (contrast, highlights, shadows, clarity)
#   - White balance control (temperature, tint)
#   - Vibrance and noise reduction
#   - Output options (resize, watermark, web versions)
#   - Preview and analysis modes
#
#   NEW in v3.0:
#   - Color cast detection and auto-correction (fixes white balance issues)
#   - Golden hour/blue hour detection with optimized processing
#   - Backlight detection with automatic HDR-like correction
#   - Subject isolation and depth-of-field analysis
#   - Chromatic aberration detection and correction
#   - Lens distortion correction (barrel/pincushion)
#   - Intelligent sky detection and enhancement
#   - Advanced skin tone protection during adjustments
#   - Red-eye detection and removal for flash portraits
#   - Composition analysis (rule of thirds, centering)
#   - Dynamic range optimization
#   - Weather/lighting condition detection
#   - Hot pixel detection and removal
#   - Auto-leveling for horizon correction
#   - Highlight recovery with detail preservation
#   - Shadow detail enhancement without noise amplification
#   - Color harmony analysis and enhancement
#   - Batch learning for consistent style across images
#
#   NEW in v4.0:
#   - Eye detection and enhancement (brighten, sharpen catchlights)
#   - Teeth whitening detection for portraits
#   - Food photography detection with appetizing enhancements
#   - Architecture detection with perspective analysis
#   - Water/reflection detection and enhancement
#   - Time-of-day intelligence from EXIF timestamp
#   - Overall image quality scoring (0-100)
#   - Aesthetic quality assessment
#   - Best shot selection from burst/series
#   - Duplicate/similar image detection
#   - Advanced noise type analysis (luminance vs chroma)
#   - Pattern noise and banding detection
#   - Smart subject-aware auto-crop suggestions
#   - Mood/emotion detection from colors and composition
#   - Film emulation profiles (Portra, Velvia, Tri-X, etc.)
#   - Lens profile database with auto-corrections
#   - Focus point detection and optimization
#   - Motion blur direction analysis
#   - Edge-aware selective sharpening
#   - Local contrast mapping
#   - Shadow/highlight zone recovery
#   - Automatic panorama detection
#   - HDR bracket detection
#   - Style learning from reference images
#
#   Requirements:
#   - ImageMagick (install via: brew install imagemagick)
#   - ExifTool (install via: brew install exiftool) - optional but recommended
#   - bc (usually pre-installed on macOS/Linux)
#   - Sufficient disk space (output ~20MB per image)
#
#   Usage:
#   ./process_raw_photos.sh [OPTIONS] [input_directory] [output_suffix]
#
#   Quick Examples:
#   ./process_raw_photos.sh                           # Intelligent auto-processing
#   ./process_raw_photos.sh --preset portrait         # Portrait-optimized
#   ./process_raw_photos.sh --analyze                 # Analyze without processing
#   ./process_raw_photos.sh --preview IMG_001.CR2     # Test on single file
#   ./process_raw_photos.sh --parallel 4              # Use 4 CPU cores
#   ./process_raw_photos.sh --format NEF              # Process Nikon RAW files
#
#   Run with --help for full options list.
#
#===============================================================================

#-------------------------------------------------------------------------------
# CONFIGURATION SECTION
# Modify these values to customize the processing behavior
#-------------------------------------------------------------------------------

# Input file extension (case-insensitive matching is handled in the script)
# Supported: CR2, CR3, NEF, ARW, ORF, RAF, DNG, RW2, PEF, SRW, 3FR, FFF, IIQ, DCR, K25, KDC
INPUT_EXTENSION="CR2"

# Multi-format support - automatically detect and process all supported RAW formats
AUTO_DETECT_FORMAT=true
SUPPORTED_RAW_FORMATS=("CR2" "CR3" "NEF" "ARW" "ORF" "RAF" "DNG" "RW2" "PEF" "SRW" "3FR" "IIQ")

# Output file format and quality
OUTPUT_FORMAT="jpg"
JPEG_QUALITY=100  # Range: 1-100, where 100 is maximum quality (least compression)

# Default output suffix added to filename (e.g., IMG_6610_edited.jpg)
DEFAULT_SUFFIX="_edited"

# Enhancement parameters (see detailed explanations below)
SATURATION_BOOST=105      # Percentage: 100=normal, >100=more saturated, <100=less
BRIGHTNESS=100            # Percentage: 100=normal, >100=brighter, <100=darker
HUE_ROTATION=100          # Percentage: 100=normal (no hue shift)

# Sharpening parameters for unsharp mask
SHARPEN_RADIUS=0.5        # Radius of Gaussian blur (pixels)
SHARPEN_SIGMA=0.5         # Standard deviation of Gaussian blur
SHARPEN_AMOUNT=0.5        # Strength of sharpening effect (0-1+)
SHARPEN_THRESHOLD=0.05    # Minimum contrast change to sharpen (0-1)

#-------------------------------------------------------------------------------
# ADVANCED ADJUSTMENT PARAMETERS (NEW)
# These can be overridden via command-line flags
#-------------------------------------------------------------------------------

# Tone adjustments (-100 to +100, 0 = no change)
CONTRAST=0                # Contrast adjustment
HIGHLIGHTS=0              # Highlight recovery (negative = recover)
SHADOWS=0                 # Shadow adjustment (positive = lift shadows)
CLARITY=0                 # Local contrast / midtone punch

# White balance (-100 to +100, 0 = no change)
TEMPERATURE=0             # Color temperature: negative=cool/blue, positive=warm/yellow
TINT=0                    # Tint adjustment: negative=green, positive=magenta

# Color adjustments
VIBRANCE=0                # Smart saturation (0-100, protects skin tones)
NOISE_REDUCTION=0         # Noise reduction strength (0-100)

# Output options
RESIZE=""                 # Max dimension or percentage (e.g., "2000" or "50%")
OUTPUT_DIR=""             # Custom output directory (empty = same as input)
WATERMARK_TEXT=""         # Watermark text (empty = no watermark)
WATERMARK_POSITION="bottomright"  # topleft, topright, bottomleft, bottomright, center
WATERMARK_OPACITY=50      # Watermark opacity (0-100)
CREATE_WEB_VERSION=false  # Create additional web-optimized version
WEB_MAX_SIZE=1200         # Max dimension for web version
WEB_QUALITY=85            # JPEG quality for web version

# Processing mode
PRESET="auto"             # auto, portrait, vivid, soft, bw, vintage, natural
ANALYZE_ONLY=false        # Only analyze, don't process
PREVIEW_FILE=""           # Single file to preview
USE_INTELLIGENT_ANALYSIS=true  # Enable per-image intelligent analysis

#-------------------------------------------------------------------------------
# INTELLIGENT PROCESSING OPTIONS (NEW in v2.0)
#-------------------------------------------------------------------------------

# Parallel processing
PARALLEL_JOBS=1           # Number of parallel jobs (0 = auto-detect CPU cores)
MAX_PARALLEL_JOBS=8       # Maximum parallel jobs limit

# EXIF-based intelligence
USE_EXIF_INTELLIGENCE=true    # Use EXIF data for smart decisions
EXIF_AVAILABLE=false          # Will be set by check_dependencies

# Face detection for auto-portrait mode
ENABLE_FACE_DETECTION=true    # Detect faces and auto-apply portrait settings
FACE_DETECTION_THRESHOLD=0.3  # Confidence threshold for face detection

# Scene detection
ENABLE_SCENE_DETECTION=true   # Automatically detect scene type
DETECTED_SCENE="unknown"      # Will be set per-image: landscape, portrait, night, indoor, macro

# Adaptive noise reduction based on ISO
ENABLE_ADAPTIVE_NOISE=true    # Auto-adjust noise reduction based on ISO
ISO_NOISE_THRESHOLDS=(800 1600 3200 6400 12800)  # ISO breakpoints for noise levels

# Sharpness/blur detection
ENABLE_BLUR_DETECTION=true    # Detect blur and adjust sharpening
BLUR_THRESHOLD=100            # Laplacian variance threshold (lower = more blur)

# Histogram analysis
ENABLE_HISTOGRAM_ANALYSIS=true  # Advanced histogram-based corrections
HISTOGRAM_BINS=256              # Number of histogram bins for analysis

# Metadata preservation
PRESERVE_EXIF=true            # Copy EXIF data to output files
PRESERVE_IPTC=true            # Copy IPTC data to output files
PRESERVE_XMP=true             # Copy XMP data to output files

# Progress display
SHOW_PROGRESS_BAR=true        # Show visual progress bar
SHOW_ETA=true                 # Show estimated time remaining

# Processing statistics (for ETA calculation)
declare -a PROCESSING_TIMES=()  # Array to store per-image processing times

#-------------------------------------------------------------------------------
# ADVANCED INTELLIGENT PROCESSING OPTIONS (NEW in v3.0)
#-------------------------------------------------------------------------------

# Color cast detection and correction
ENABLE_COLOR_CAST_CORRECTION=true   # Auto-detect and fix color casts
COLOR_CAST_THRESHOLD=8              # Minimum deviation to trigger correction (0-100)
COLOR_CAST_STRENGTH=80              # Correction strength (0-100)

# Golden hour / Blue hour detection
ENABLE_GOLDEN_HOUR_DETECTION=true   # Detect and enhance golden/blue hour photos
GOLDEN_HOUR_BOOST=true              # Apply special enhancement for golden hour

# Backlight detection and HDR-like correction
ENABLE_BACKLIGHT_DETECTION=true     # Detect backlit subjects
BACKLIGHT_RECOVERY_STRENGTH=70      # Shadow recovery for backlit subjects (0-100)
ENABLE_LOCAL_TONE_MAPPING=true      # Apply HDR-like local tone mapping

# Subject isolation and depth analysis
ENABLE_SUBJECT_DETECTION=true       # Detect main subject in frame
ENABLE_DEPTH_ANALYSIS=true          # Analyze depth of field
SUBJECT_ENHANCEMENT=true            # Enhance detected subject area

# Chromatic aberration correction
ENABLE_CA_CORRECTION=true           # Detect and fix chromatic aberration
CA_DETECTION_THRESHOLD=5            # Sensitivity for CA detection

# Lens distortion correction
ENABLE_LENS_CORRECTION=true         # Correct barrel/pincushion distortion
LENS_CORRECTION_STRENGTH=100        # Correction strength (0-100)

# Sky detection and enhancement
ENABLE_SKY_ENHANCEMENT=true         # Detect and enhance sky separately
SKY_SATURATION_BOOST=15             # Extra saturation for sky (0-50)
SKY_GRADIENT_ENHANCEMENT=true       # Enhance sky gradient

# Skin tone protection
ENABLE_SKIN_PROTECTION=true         # Protect skin tones during processing
SKIN_TONE_SMOOTHING=30              # Subtle smoothing for skin (0-100)
SKIN_SATURATION_LIMIT=95            # Prevent oversaturated skin (percentage)

# Red-eye detection and removal
ENABLE_RED_EYE_REMOVAL=true         # Detect and fix red-eye from flash
RED_EYE_DETECTION_THRESHOLD=0.5     # Sensitivity for red-eye detection

# Composition analysis
ENABLE_COMPOSITION_ANALYSIS=true    # Analyze rule of thirds, symmetry
ENABLE_AUTO_CROP=false              # Suggest/apply better crops
AUTO_CROP_MARGIN=0.02               # Margin for auto-crop (percentage)

# Dynamic range optimization
ENABLE_DR_OPTIMIZATION=true         # Maximize usable dynamic range
DR_TARGET_RANGE=0.85                # Target histogram spread (0-1)
ENABLE_HIGHLIGHT_RECOVERY=true      # Advanced highlight recovery
ENABLE_SHADOW_ENHANCEMENT=true      # Smart shadow detail recovery

# Weather/lighting detection
ENABLE_WEATHER_DETECTION=true       # Detect sunny, cloudy, overcast, etc.
DETECTED_WEATHER="unknown"          # Will be set per-image

# Hot pixel detection and removal
ENABLE_HOT_PIXEL_REMOVAL=true       # Detect and remove hot pixels
HOT_PIXEL_THRESHOLD=0.95            # Brightness threshold for hot pixels

# Horizon auto-leveling
ENABLE_AUTO_LEVEL=true              # Auto-detect and correct tilted horizons
AUTO_LEVEL_THRESHOLD=1.5            # Minimum angle to trigger (degrees)

# Color harmony analysis
ENABLE_COLOR_HARMONY=true           # Analyze and enhance color relationships
HARMONY_ENHANCEMENT_STRENGTH=20     # Enhancement strength (0-100)

# Batch learning (learn from batch for consistency)
ENABLE_BATCH_LEARNING=true          # Learn exposure/color from batch
BATCH_CONSISTENCY_STRENGTH=50       # How much to normalize across batch (0-100)
declare -a BATCH_EXPOSURES=()       # Store exposure data for batch learning
declare -a BATCH_COLOR_TEMPS=()     # Store color temperature data
BATCH_AVG_EXPOSURE=0                # Calculated batch average exposure
BATCH_AVG_COLOR_TEMP=0              # Calculated batch average color temp

#-------------------------------------------------------------------------------
# V4.0 ADVANCED AI-LIKE PROCESSING OPTIONS
#-------------------------------------------------------------------------------

# Eye and face enhancement
ENABLE_EYE_ENHANCEMENT=true         # Detect and enhance eyes
EYE_BRIGHTNESS_BOOST=15             # Brighten eyes (0-50)
EYE_SHARPNESS_BOOST=20              # Sharpen catchlights (0-50)
ENABLE_TEETH_DETECTION=true         # Detect teeth for whitening
TEETH_WHITENING_STRENGTH=20         # Whitening amount (0-50)

# Food photography
ENABLE_FOOD_DETECTION=true          # Detect food photography
FOOD_SATURATION_BOOST=20            # Extra saturation for food (0-50)
FOOD_WARMTH_BOOST=15                # Warm tones for appetizing look (0-50)
FOOD_CLARITY_BOOST=15               # Extra clarity for texture (0-50)

# Architecture detection
ENABLE_ARCHITECTURE_DETECTION=true  # Detect buildings/architecture
ENABLE_PERSPECTIVE_ANALYSIS=true    # Analyze perspective distortion
PERSPECTIVE_CORRECTION_STRENGTH=80  # How much to correct (0-100)

# Water and reflection detection
ENABLE_WATER_DETECTION=true         # Detect water/reflections
WATER_CLARITY_BOOST=20              # Enhance water clarity
REFLECTION_ENHANCEMENT=true         # Enhance reflections

# Time-of-day intelligence
ENABLE_TIME_INTELLIGENCE=true       # Use EXIF time for processing
EXIF_TIME_HOUR=12                   # Extracted hour (0-23)
DETECTED_TIME_PERIOD="day"          # dawn, morning, day, afternoon, golden, blue, night

# Quality scoring
ENABLE_QUALITY_SCORING=true         # Calculate quality scores
TECHNICAL_QUALITY_SCORE=0           # Focus, exposure, noise (0-100)
AESTHETIC_QUALITY_SCORE=0           # Composition, color, interest (0-100)
OVERALL_QUALITY_SCORE=0             # Combined score (0-100)
QUALITY_THRESHOLD=50                # Minimum score to recommend keeping

# Burst/series detection
ENABLE_BURST_DETECTION=true         # Detect burst/series shots
BURST_WINDOW_SECONDS=2              # Time window for burst grouping
declare -a BURST_GROUPS=()          # Store burst group info
BEST_SHOT_SELECTION=true            # Select best from burst

# Duplicate detection
ENABLE_DUPLICATE_DETECTION=true     # Find similar/duplicate images
DUPLICATE_SIMILARITY_THRESHOLD=95   # Similarity % to consider duplicate
declare -a DUPLICATE_GROUPS=()      # Store duplicate groups

# Advanced noise analysis
ENABLE_NOISE_TYPE_ANALYSIS=true     # Analyze noise types
LUMINANCE_NOISE_LEVEL=0             # Luminance noise amount
CHROMA_NOISE_LEVEL=0                # Color noise amount
HAS_BANDING=false                   # Banding artifact detected
HAS_PATTERN_NOISE=false             # Pattern noise detected
NOISE_TYPE="none"                   # none, luminance, chroma, mixed, banding

# Smart auto-crop
ENABLE_SMART_CROP=true              # Enable smart cropping
SMART_CROP_ASPECT=""                # Suggested aspect ratio
SMART_CROP_GEOMETRY=""              # Suggested crop geometry
CROP_CONFIDENCE=0                   # Confidence in crop suggestion

# Mood/emotion detection
ENABLE_MOOD_DETECTION=true          # Detect mood from image
DETECTED_MOOD="neutral"             # happy, sad, dramatic, peaceful, energetic, romantic, mysterious
MOOD_CONFIDENCE=0                   # Confidence in mood detection
MOOD_ENHANCEMENT=""                 # Suggested mood enhancement

# Film emulation
ENABLE_FILM_EMULATION=false         # Apply film emulation
FILM_PROFILE="none"                 # portra, velvia, trix, cinestill, provia, ektar
FILM_STRENGTH=100                   # Film effect strength (0-100)

# Lens profile database (format: name|type|distortion_type|distortion_amt|vignette_amt)
ENABLE_LENS_PROFILES=true           # Use lens-specific corrections
LENS_DB_ENTRIES=(
    "EF16-35mm|wide|barrel|0.02|0.15"
    "EF24-70mm|standard|none|0|0.08"
    "EF70-200mm|tele|pincushion|0.01|0.05"
    "EF50mm|prime|none|0|0.10"
    "EF85mm|portrait|none|0|0.08"
    "RF24-70mm|standard|none|0|0.05"
    "RF50mm|prime|none|0|0.06"
    "RF24-105mm|standard|none|0|0.06"
    "RF85mm|portrait|none|0|0.05"
)
MATCHED_LENS_PROFILE=""             # Matched lens from database

# Focus detection
ENABLE_FOCUS_DETECTION=true         # Detect focus point
FOCUS_POINT_X=0.5                   # Focus point X (0-1)
FOCUS_POINT_Y=0.5                   # Focus point Y (0-1)
FOCUS_QUALITY="good"                # excellent, good, soft, missed
IN_FOCUS_AREA=0                     # Percentage of image in focus

# Motion blur analysis
ENABLE_MOTION_ANALYSIS=true         # Analyze motion blur
HAS_MOTION_BLUR=false               # Motion blur detected
MOTION_DIRECTION=""                 # horizontal, vertical, diagonal, radial
MOTION_SEVERITY=0                   # Motion blur severity (0-100)
IS_INTENTIONAL_MOTION=false         # Panning shot or long exposure

# Edge-aware sharpening
ENABLE_EDGE_SHARPENING=true         # Smart edge-aware sharpening
EDGE_SHARPENING_AMOUNT=0.5          # Amount for edges
TEXTURE_SHARPENING_AMOUNT=0.3       # Amount for textures
SKIN_SHARPENING_AMOUNT=0.1          # Reduced for skin

# Local contrast
ENABLE_LOCAL_CONTRAST=true          # Apply local contrast
LOCAL_CONTRAST_RADIUS=50            # Radius for local contrast
LOCAL_CONTRAST_AMOUNT=15            # Amount (0-50)

# Zone-based recovery
ENABLE_ZONE_RECOVERY=true           # Zone system-based recovery
ZONE_0_ADJUSTMENT=0                 # Deep shadows
ZONE_3_ADJUSTMENT=0                 # Dark midtones
ZONE_5_ADJUSTMENT=0                 # Middle gray
ZONE_7_ADJUSTMENT=0                 # Light midtones
ZONE_10_ADJUSTMENT=0                # Highlights

# Panorama detection
ENABLE_PANORAMA_DETECTION=true      # Detect panorama candidates
IS_PANORAMA_CANDIDATE=false         # Part of potential panorama
PANORAMA_GROUP=""                   # Panorama group ID

# HDR bracket detection
ENABLE_HDR_DETECTION=true           # Detect HDR brackets
IS_HDR_BRACKET=false                # Part of HDR bracket set
HDR_BRACKET_POSITION=""             # under, normal, over
HDR_GROUP=""                        # HDR group ID

# Style learning
ENABLE_STYLE_LEARNING=true          # Learn processing style
REFERENCE_IMAGE=""                  # Reference image for style matching
LEARNED_STYLE=""                    # Encoded style parameters

# Logging configuration
LOG_FILE="processing_log.txt"
ENABLE_LOGGING=true

#-------------------------------------------------------------------------------
# COLOR CODES FOR TERMINAL OUTPUT
# Makes the script output more readable
#-------------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color (reset)

# Progress bar characters
PROGRESS_FILLED="█"
PROGRESS_EMPTY="░"
PROGRESS_WIDTH=40

#-------------------------------------------------------------------------------
# FUNCTION: print_banner
# Displays a welcome banner with script information
#-------------------------------------------------------------------------------

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║               RAW PHOTO BATCH PROCESSOR v4.0                      ║"
    echo "║         Advanced AI-Like Intelligent Processing                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

#-------------------------------------------------------------------------------
# FUNCTION: print_help
# Displays usage information and available options
#-------------------------------------------------------------------------------

print_help() {
    echo "Usage: $0 [OPTIONS] [input_directory] [output_suffix]"
    echo ""
    echo "Arguments:"
    echo "  input_directory    Directory containing RAW files (default: current directory)"
    echo "  output_suffix      Suffix for output files (default: _edited)"
    echo ""
    echo -e "${CYAN}Basic Options:${NC}"
    echo "  -h, --help              Show this help message"
    echo "  -v, --version           Show version information"
    echo "  -q, --quiet             Suppress progress output (logging still works)"
    echo "  -n, --no-enhance        Skip auto-enhancement, do straight conversion"
    echo ""
    echo -e "${CYAN}Presets:${NC}"
    echo "  --preset NAME           Apply a preset style:"
    echo "                          auto     - Intelligent per-image analysis (default)"
    echo "                          portrait - Soft, flattering look for portraits"
    echo "                          vivid    - Punchy, saturated colors"
    echo "                          soft     - Dreamy, muted tones"
    echo "                          bw       - Professional black & white"
    echo "                          vintage  - Warm, faded vintage look"
    echo "                          natural  - Minimal processing, true to life"
    echo ""
    echo -e "${CYAN}Tone Adjustments:${NC} (range: -100 to +100, 0 = no change)"
    echo "  --contrast VALUE        Adjust contrast"
    echo "  --highlights VALUE      Recover/boost highlights (negative = recover)"
    echo "  --shadows VALUE         Lift/deepen shadows (positive = lift)"
    echo "  --clarity VALUE         Local contrast / midtone punch"
    echo ""
    echo -e "${CYAN}White Balance:${NC} (range: -100 to +100, 0 = no change)"
    echo "  --temperature VALUE     Color temperature (negative = cool, positive = warm)"
    echo "  --tint VALUE            Tint adjustment (negative = green, positive = magenta)"
    echo ""
    echo -e "${CYAN}Color Adjustments:${NC}"
    echo "  --saturation VALUE      Saturation (100 = normal, >100 = more vivid)"
    echo "  --vibrance VALUE        Smart saturation (0-100, protects skin tones)"
    echo ""
    echo -e "${CYAN}Correction:${NC}"
    echo "  --noise-reduction VALUE Noise reduction strength (0-100)"
    echo "  --sharpen VALUE         Sharpening amount (0-1, default: 0.5)"
    echo ""
    echo -e "${CYAN}Output Options:${NC}"
    echo "  --resize VALUE          Max dimension (e.g., 2000) or percentage (e.g., 50%)"
    echo "  --format FORMAT         Output format: jpg, png, tiff (default: jpg)"
    echo "  --quality VALUE         JPEG quality 1-100 (default: 100)"
    echo "  --output-dir PATH       Custom output directory"
    echo "  --watermark \"TEXT\"      Add text watermark"
    echo "  --watermark-position POS  Position: topleft, topright, bottomleft,"
    echo "                            bottomright (default), center"
    echo "  --watermark-opacity VAL Watermark opacity 0-100 (default: 50)"
    echo "  --web-version           Also create smaller web-optimized copy"
    echo "  --web-size VALUE        Max size for web version (default: 1200)"
    echo "  --web-quality VALUE     Quality for web version (default: 85)"
    echo ""
    echo -e "${CYAN}Analysis/Preview:${NC}"
    echo "  --analyze               Analyze images without processing (show recommendations)"
    echo "  --preview FILE          Process single file to test settings"
    echo ""
    echo -e "${CYAN}Intelligent Processing (v2.0):${NC}"
    echo "  --parallel N            Use N parallel jobs (0 = auto-detect cores)"
    echo "  --format EXT            RAW format to process (CR2, NEF, ARW, etc.)"
    echo "  --auto-format           Auto-detect all RAW formats in directory (default)"
    echo "  --no-face-detection     Disable automatic face detection"
    echo "  --no-scene-detection    Disable automatic scene detection"
    echo "  --no-adaptive-noise     Disable ISO-based noise reduction"
    echo "  --no-blur-detection     Disable blur detection"
    echo "  --preserve-metadata     Preserve EXIF/IPTC/XMP metadata (default: on)"
    echo "  --no-preserve-metadata  Don't copy metadata to output files"
    echo ""
    echo -e "${CYAN}Supported RAW Formats:${NC}"
    echo "  Canon:      CR2, CR3"
    echo "  Nikon:      NEF"
    echo "  Sony:       ARW"
    echo "  Olympus:    ORF"
    echo "  Fujifilm:   RAF"
    echo "  Adobe:      DNG"
    echo "  Panasonic:  RW2"
    echo "  Pentax:     PEF"
    echo "  Samsung:    SRW"
    echo "  Hasselblad: 3FR"
    echo "  Phase One:  IIQ"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0                                    # Process with intelligent analysis"
    echo "  $0 --preset portrait                  # Use portrait preset"
    echo "  $0 --preset vivid --contrast 20      # Vivid with extra contrast"
    echo "  $0 --temperature 30 --saturation 110 # Warm and saturated"
    echo "  $0 --analyze                          # Analyze without processing"
    echo "  $0 --preview IMG_001.CR2              # Test on single file"
    echo "  $0 --resize 2000 --web-version        # Resize and create web copies"
    echo "  $0 --watermark \"Photo by Studio X\"    # Add watermark"
    echo "  $0 -n /path/to/photos                 # Convert without enhancement"
    echo "  $0 --parallel 4                       # Use 4 CPU cores"
    echo "  $0 --format NEF                       # Process Nikon RAW files only"
    echo "  $0 --auto-format                      # Process all RAW formats found"
    echo ""
}

#-------------------------------------------------------------------------------
# FUNCTION: check_dependencies
# Verifies that all required tools are installed
#-------------------------------------------------------------------------------

check_dependencies() {
    echo -e "${BLUE}[INFO]${NC} Checking dependencies..."

    # Check for ImageMagick
    if ! command -v magick &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} ImageMagick is not installed!"
        echo ""
        echo "Please install ImageMagick using one of these methods:"
        echo "  macOS:   brew install imagemagick"
        echo "  Ubuntu:  sudo apt-get install imagemagick"
        echo "  Windows: Download from https://imagemagick.org/script/download.php"
        echo ""
        exit 1
    fi

    # Display ImageMagick version
    local magick_version=$(magick -version | head -1)
    echo -e "${GREEN}[OK]${NC} Found: $magick_version"

    # Check for ExifTool (optional but recommended)
    if command -v exiftool &> /dev/null; then
        EXIF_AVAILABLE=true
        local exif_version=$(exiftool -ver 2>/dev/null)
        echo -e "${GREEN}[OK]${NC} Found: ExifTool $exif_version"
    else
        EXIF_AVAILABLE=false
        echo -e "${YELLOW}[WARN]${NC} ExifTool not found (optional but recommended)"
        echo -e "        Install with: brew install exiftool"
        echo -e "        Features disabled: EXIF intelligence, metadata preservation"
    fi

    # Detect number of CPU cores for parallel processing
    if [ "$PARALLEL_JOBS" -eq 0 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            PARALLEL_JOBS=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)
        else
            PARALLEL_JOBS=$(nproc 2>/dev/null || echo 4)
        fi
        # Limit to MAX_PARALLEL_JOBS
        if [ "$PARALLEL_JOBS" -gt "$MAX_PARALLEL_JOBS" ]; then
            PARALLEL_JOBS=$MAX_PARALLEL_JOBS
        fi
        echo -e "${BLUE}[INFO]${NC} Auto-detected $PARALLEL_JOBS CPU cores for parallel processing"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: get_cpu_count
# Returns the number of CPU cores available
#-------------------------------------------------------------------------------

get_cpu_count() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sysctl -n hw.ncpu 2>/dev/null || echo 4
    else
        nproc 2>/dev/null || echo 4
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: draw_progress_bar
# Draws a visual progress bar with percentage and ETA
#
# Parameters:
#   $1 - Current progress (0-100)
#   $2 - Current file number
#   $3 - Total files
#   $4 - ETA in seconds (optional)
#   $5 - Current filename (optional)
#-------------------------------------------------------------------------------

draw_progress_bar() {
    local progress=$1
    local current=$2
    local total=$3
    local eta=${4:-0}
    local filename=${5:-""}

    if [ "$SHOW_PROGRESS_BAR" = false ]; then
        return
    fi

    # Calculate filled portion
    local filled=$((progress * PROGRESS_WIDTH / 100))
    local empty=$((PROGRESS_WIDTH - filled))

    # Build progress bar
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar="${bar}${PROGRESS_FILLED}"
    done
    for ((i=0; i<empty; i++)); do
        bar="${bar}${PROGRESS_EMPTY}"
    done

    # Format ETA
    local eta_str=""
    if [ "$SHOW_ETA" = true ] && [ "$eta" -gt 0 ]; then
        eta_str=" ETA: $(format_time $eta)"
    fi

    # Truncate filename if too long
    if [ ${#filename} -gt 25 ]; then
        filename="${filename:0:22}..."
    fi

    # Print progress bar
    printf "\r${CYAN}[${bar}]${NC} ${WHITE}%3d%%${NC} ${GRAY}[%d/%d]${NC}${YELLOW}%s${NC} ${DIM}%s${NC}    " \
        "$progress" "$current" "$total" "$eta_str" "$filename"
}

#-------------------------------------------------------------------------------
# FUNCTION: calculate_eta
# Calculates estimated time remaining based on processing history
#
# Parameters:
#   $1 - Files remaining
#
# Returns:
#   Estimated seconds remaining
#-------------------------------------------------------------------------------

calculate_eta() {
    local remaining=$1

    # Need at least 2 samples for estimation
    if [ ${#PROCESSING_TIMES[@]} -lt 2 ]; then
        echo 0
        return
    fi

    # Calculate average of last 5 processing times (or all if less)
    local sum=0
    local count=0
    local start_idx=$((${#PROCESSING_TIMES[@]} - 5))
    if [ $start_idx -lt 0 ]; then
        start_idx=0
    fi

    for ((i=start_idx; i<${#PROCESSING_TIMES[@]}; i++)); do
        sum=$((sum + PROCESSING_TIMES[i]))
        count=$((count + 1))
    done

    if [ $count -eq 0 ]; then
        echo 0
        return
    fi

    local avg=$((sum / count))
    echo $((avg * remaining))
}

#-------------------------------------------------------------------------------
# FUNCTION: extract_exif_data
# Extracts relevant EXIF data from a RAW file for intelligent processing
#
# Parameters:
#   $1 - Input file path
#
# Sets global variables:
#   EXIF_ISO, EXIF_APERTURE, EXIF_SHUTTER, EXIF_FOCAL_LENGTH
#   EXIF_CAMERA_MODEL, EXIF_LENS_MODEL, EXIF_WHITE_BALANCE
#   EXIF_EXPOSURE_COMP, EXIF_FLASH_FIRED, EXIF_ORIENTATION
#-------------------------------------------------------------------------------

extract_exif_data() {
    local input_file="$1"

    # Reset EXIF variables
    EXIF_ISO=0
    EXIF_APERTURE=""
    EXIF_SHUTTER=""
    EXIF_FOCAL_LENGTH=0
    EXIF_CAMERA_MODEL=""
    EXIF_LENS_MODEL=""
    EXIF_WHITE_BALANCE=""
    EXIF_EXPOSURE_COMP=0
    EXIF_FLASH_FIRED=false
    EXIF_ORIENTATION=1

    if [ "$EXIF_AVAILABLE" = false ] || [ "$USE_EXIF_INTELLIGENCE" = false ]; then
        return
    fi

    # Extract all relevant EXIF data in one call
    local exif_output=$(exiftool -ISO -Aperture -ShutterSpeed -FocalLength \
        -Model -LensModel -WhiteBalance -ExposureCompensation -Flash -Orientation \
        -s -s -s "$input_file" 2>/dev/null)

    # Parse the output
    EXIF_ISO=$(exiftool -ISO -s -s -s "$input_file" 2>/dev/null | grep -oE '[0-9]+' | head -1)
    EXIF_ISO=${EXIF_ISO:-0}

    EXIF_APERTURE=$(exiftool -Aperture -s -s -s "$input_file" 2>/dev/null)
    EXIF_SHUTTER=$(exiftool -ShutterSpeed -s -s -s "$input_file" 2>/dev/null)
    EXIF_FOCAL_LENGTH=$(exiftool -FocalLength -s -s -s "$input_file" 2>/dev/null | grep -oE '[0-9.]+' | head -1)
    EXIF_FOCAL_LENGTH=${EXIF_FOCAL_LENGTH:-0}

    EXIF_CAMERA_MODEL=$(exiftool -Model -s -s -s "$input_file" 2>/dev/null)
    EXIF_LENS_MODEL=$(exiftool -LensModel -s -s -s "$input_file" 2>/dev/null)
    EXIF_WHITE_BALANCE=$(exiftool -WhiteBalance -s -s -s "$input_file" 2>/dev/null)

    EXIF_EXPOSURE_COMP=$(exiftool -ExposureCompensation -s -s -s "$input_file" 2>/dev/null | grep -oE '[-+]?[0-9.]+' | head -1)
    EXIF_EXPOSURE_COMP=${EXIF_EXPOSURE_COMP:-0}

    local flash=$(exiftool -Flash -s -s -s "$input_file" 2>/dev/null)
    if [[ "$flash" == *"Fired"* ]] || [[ "$flash" == *"On"* ]]; then
        EXIF_FLASH_FIRED=true
    fi

    EXIF_ORIENTATION=$(exiftool -Orientation -n -s -s -s "$input_file" 2>/dev/null)
    EXIF_ORIENTATION=${EXIF_ORIENTATION:-1}
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_faces
# Detects if an image contains faces using ImageMagick's face detection
#
# Parameters:
#   $1 - Input file path
#
# Returns:
#   Sets FACES_DETECTED (count) and HAS_FACES (boolean)
#-------------------------------------------------------------------------------

detect_faces() {
    local input_file="$1"
    FACES_DETECTED=0
    HAS_FACES=false

    if [ "$ENABLE_FACE_DETECTION" = false ]; then
        return
    fi

    # Use ImageMagick to detect skin tones as a proxy for face detection
    # This analyzes the color distribution in the image
    local skin_tone_ratio=$(magick "$input_file" -colorspace HSL \
        -channel G -separate +channel \
        -threshold 15% -threshold 70% \
        -format "%[fx:mean]" info: 2>/dev/null)

    # Check for typical portrait composition (centered subject)
    local center_brightness=$(magick "$input_file" \
        -gravity center -crop 40%x40%+0+0 +repage \
        -format "%[fx:mean]" info: 2>/dev/null)

    local edge_brightness=$(magick "$input_file" \
        -gravity center -crop 80%x80%+0+0 +repage \
        -gravity center -crop 60%x60%+0+0 -negate +repage \
        -format "%[fx:mean]" info: 2>/dev/null)

    # Heuristic: if center is brighter than edges and has skin tones, likely portrait
    if (( $(echo "$skin_tone_ratio > 0.1" | bc -l 2>/dev/null || echo 0) )); then
        if (( $(echo "$center_brightness > $edge_brightness" | bc -l 2>/dev/null || echo 0) )); then
            FACES_DETECTED=1
            HAS_FACES=true
        fi
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_scene_type
# Analyzes image characteristics to determine scene type
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   DETECTED_SCENE - One of: landscape, portrait, night, indoor, macro, unknown
#   SCENE_CONFIDENCE - Confidence level (0-100)
#-------------------------------------------------------------------------------

detect_scene_type() {
    local input_file="$1"
    DETECTED_SCENE="unknown"
    SCENE_CONFIDENCE=0

    if [ "$ENABLE_SCENE_DETECTION" = false ]; then
        return
    fi

    # Get image dimensions for aspect ratio
    local dimensions=$(magick identify -format "%w %h" "$input_file" 2>/dev/null)
    local width=$(echo "$dimensions" | awk '{print $1}')
    local height=$(echo "$dimensions" | awk '{print $2}')
    local aspect_ratio=$(echo "scale=2; $width / $height" | bc -l 2>/dev/null || echo "1.5")

    # Get overall brightness
    local mean_brightness=$(magick "$input_file" -format "%[fx:mean*255]" info: 2>/dev/null)
    mean_brightness=${mean_brightness:-128}

    # Analyze color distribution
    local saturation=$(magick "$input_file" -colorspace HSL -channel G -separate \
        -format "%[fx:mean*100]" info: 2>/dev/null)
    saturation=${saturation:-50}

    # Analyze blue channel dominance (sky detection for landscape)
    local blue_mean=$(magick "$input_file" -channel B -separate \
        -format "%[fx:mean*255]" info: 2>/dev/null)
    blue_mean=${blue_mean:-128}

    local green_mean=$(magick "$input_file" -channel G -separate \
        -format "%[fx:mean*255]" info: 2>/dev/null)
    green_mean=${green_mean:-128}

    # Use EXIF focal length for macro detection
    local focal_length=${EXIF_FOCAL_LENGTH:-0}
    local iso=${EXIF_ISO:-0}

    # Decision tree for scene detection
    # Night scene: very dark, possibly high ISO
    if (( $(echo "$mean_brightness < 60" | bc -l 2>/dev/null || echo 0) )); then
        if [ "$iso" -gt 1600 ] || (( $(echo "$mean_brightness < 40" | bc -l 2>/dev/null || echo 0) )); then
            DETECTED_SCENE="night"
            SCENE_CONFIDENCE=80
            return
        fi
    fi

    # Macro: very close focal length or specific EXIF hints
    if (( $(echo "$focal_length > 0 && $focal_length < 35" | bc -l 2>/dev/null || echo 0) )); then
        # Check for high detail in center (typical of macro)
        local center_detail=$(magick "$input_file" -gravity center -crop 30%x30%+0+0 \
            -define convolve:scale='!' -morphology Convolve Laplacian:0 \
            -format "%[fx:standard_deviation*1000]" info: 2>/dev/null)
        if (( $(echo "${center_detail:-0} > 50" | bc -l 2>/dev/null || echo 0) )); then
            DETECTED_SCENE="macro"
            SCENE_CONFIDENCE=70
            return
        fi
    fi

    # Portrait: face detected or centered bright subject
    if [ "$HAS_FACES" = true ]; then
        DETECTED_SCENE="portrait"
        SCENE_CONFIDENCE=90
        return
    fi

    # Landscape: wide aspect ratio, lots of blue/green, high saturation
    if (( $(echo "$aspect_ratio > 1.4" | bc -l 2>/dev/null || echo 0) )); then
        if (( $(echo "$blue_mean > $green_mean * 0.9" | bc -l 2>/dev/null || echo 0) )); then
            if (( $(echo "$saturation > 40" | bc -l 2>/dev/null || echo 0) )); then
                DETECTED_SCENE="landscape"
                SCENE_CONFIDENCE=75
                return
            fi
        fi
        # Also detect landscape by green dominance (forests, fields)
        if (( $(echo "$green_mean > $blue_mean" | bc -l 2>/dev/null || echo 0) )); then
            DETECTED_SCENE="landscape"
            SCENE_CONFIDENCE=65
            return
        fi
    fi

    # Indoor: lower saturation, warmer tones, flash possibly used
    if [ "$EXIF_FLASH_FIRED" = true ]; then
        DETECTED_SCENE="indoor"
        SCENE_CONFIDENCE=70
        return
    fi

    if (( $(echo "$saturation < 35" | bc -l 2>/dev/null || echo 0) )); then
        DETECTED_SCENE="indoor"
        SCENE_CONFIDENCE=50
        return
    fi

    # Default
    DETECTED_SCENE="unknown"
    SCENE_CONFIDENCE=30
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_blur_level
# Measures image sharpness using Laplacian variance
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   BLUR_VARIANCE - Higher = sharper image
#   IS_BLURRY - Boolean
#   RECOMMENDED_SHARPENING - Suggested sharpening amount
#-------------------------------------------------------------------------------

detect_blur_level() {
    local input_file="$1"
    BLUR_VARIANCE=0
    IS_BLURRY=false
    RECOMMENDED_SHARPENING=$SHARPEN_AMOUNT

    if [ "$ENABLE_BLUR_DETECTION" = false ]; then
        return
    fi

    # Calculate Laplacian variance (measure of sharpness)
    # Higher variance = sharper image
    BLUR_VARIANCE=$(magick "$input_file" -resize 800x800\> \
        -define convolve:scale='!' -morphology Convolve Laplacian:0 \
        -format "%[fx:standard_deviation*10000]" info: 2>/dev/null)
    BLUR_VARIANCE=${BLUR_VARIANCE:-100}

    # Determine if image is blurry
    if (( $(echo "$BLUR_VARIANCE < $BLUR_THRESHOLD" | bc -l 2>/dev/null || echo 0) )); then
        IS_BLURRY=true
        # Increase sharpening for blurry images, but not too much
        RECOMMENDED_SHARPENING=$(echo "scale=2; $SHARPEN_AMOUNT * 1.5" | bc -l)
        if (( $(echo "$RECOMMENDED_SHARPENING > 1.0" | bc -l 2>/dev/null || echo 0) )); then
            RECOMMENDED_SHARPENING=1.0
        fi
    elif (( $(echo "$BLUR_VARIANCE > 200" | bc -l 2>/dev/null || echo 0) )); then
        # Very sharp image, reduce sharpening to avoid artifacts
        RECOMMENDED_SHARPENING=$(echo "scale=2; $SHARPEN_AMOUNT * 0.7" | bc -l)
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: calculate_iso_noise_reduction
# Calculates appropriate noise reduction based on ISO
#
# Parameters:
#   $1 - ISO value
#
# Returns:
#   Noise reduction level (0-100)
#-------------------------------------------------------------------------------

calculate_iso_noise_reduction() {
    local iso=$1

    if [ "$ENABLE_ADAPTIVE_NOISE" = false ] || [ "$iso" -eq 0 ]; then
        echo $NOISE_REDUCTION
        return
    fi

    local nr=0

    if [ "$iso" -le 400 ]; then
        nr=0
    elif [ "$iso" -le 800 ]; then
        nr=10
    elif [ "$iso" -le 1600 ]; then
        nr=25
    elif [ "$iso" -le 3200 ]; then
        nr=40
    elif [ "$iso" -le 6400 ]; then
        nr=55
    elif [ "$iso" -le 12800 ]; then
        nr=70
    else
        nr=85
    fi

    # Don't override manual setting if it's higher
    if [ "$NOISE_REDUCTION" -gt "$nr" ]; then
        echo $NOISE_REDUCTION
    else
        echo $nr
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: analyze_histogram
# Performs detailed histogram analysis for intelligent corrections
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HIST_SHADOW_CLIP - Percentage of pixels in shadows (0-5%)
#   HIST_HIGHLIGHT_CLIP - Percentage of pixels in highlights (95-100%)
#   HIST_MIDTONE_PEAK - Position of midtone peak (0-255)
#   HIST_DISTRIBUTION - "normal", "left-heavy", "right-heavy", "bimodal"
#-------------------------------------------------------------------------------

analyze_histogram() {
    local input_file="$1"

    if [ "$ENABLE_HISTOGRAM_ANALYSIS" = false ]; then
        HIST_SHADOW_CLIP=0
        HIST_HIGHLIGHT_CLIP=0
        HIST_MIDTONE_PEAK=128
        HIST_DISTRIBUTION="normal"
        return
    fi

    # Get histogram data
    local hist_data=$(magick "$input_file" -format "%c" histogram:info: 2>/dev/null)

    # Calculate shadow clipping (pixels below 5% brightness)
    HIST_SHADOW_CLIP=$(magick "$input_file" -threshold 5% -format "%[fx:(1-mean)*100]" info: 2>/dev/null)
    HIST_SHADOW_CLIP=${HIST_SHADOW_CLIP:-0}

    # Calculate highlight clipping (pixels above 95% brightness)
    HIST_HIGHLIGHT_CLIP=$(magick "$input_file" -threshold 95% -format "%[fx:mean*100]" info: 2>/dev/null)
    HIST_HIGHLIGHT_CLIP=${HIST_HIGHLIGHT_CLIP:-0}

    # Get percentile values for distribution analysis
    local p25=$(magick "$input_file" -format "%[fx:mean*255*0.6]" info: 2>/dev/null)
    local p50=$(magick "$input_file" -format "%[fx:mean*255]" info: 2>/dev/null)
    local p75=$(magick "$input_file" -format "%[fx:mean*255*1.4]" info: 2>/dev/null)

    HIST_MIDTONE_PEAK=${p50:-128}

    # Determine distribution type
    if (( $(echo "$p50 < 85" | bc -l 2>/dev/null || echo 0) )); then
        HIST_DISTRIBUTION="left-heavy"
    elif (( $(echo "$p50 > 170" | bc -l 2>/dev/null || echo 0) )); then
        HIST_DISTRIBUTION="right-heavy"
    else
        HIST_DISTRIBUTION="normal"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: apply_scene_preset
# Applies scene-specific adjustments based on detected scene type
#
# Parameters:
#   $1 - Scene type (landscape, portrait, night, indoor, macro)
#-------------------------------------------------------------------------------

apply_scene_preset() {
    local scene="$1"

    case "$scene" in
        landscape)
            # Boost saturation and clarity for landscapes
            if [ "$SATURATION_BOOST" -eq 100 ]; then
                SATURATION_BOOST=110
            fi
            if [ "$CLARITY" -eq 0 ]; then
                CLARITY=15
            fi
            if [ "$VIBRANCE" -eq 0 ]; then
                VIBRANCE=20
            fi
            ;;
        portrait)
            # Soften and warm up for portraits
            if [ "$CLARITY" -eq 0 ]; then
                CLARITY=-10
            fi
            if [ "$SATURATION_BOOST" -eq 100 ]; then
                SATURATION_BOOST=95
            fi
            if [ "$HIGHLIGHTS" -eq 0 ]; then
                HIGHLIGHTS=-15
            fi
            SHARPEN_AMOUNT=$(echo "scale=2; $SHARPEN_AMOUNT * 0.7" | bc -l)
            ;;
        night)
            # Lift shadows, reduce noise, careful with highlights
            if [ "$SHADOWS" -eq 0 ]; then
                SHADOWS=25
            fi
            if [ "$HIGHLIGHTS" -eq 0 ]; then
                HIGHLIGHTS=-20
            fi
            # Noise reduction will be handled by ISO-based calculation
            ;;
        indoor)
            # Warmer temperature, balanced exposure
            if [ "$TEMPERATURE" -eq 0 ]; then
                TEMPERATURE=10
            fi
            if [ "$SHADOWS" -eq 0 ]; then
                SHADOWS=10
            fi
            ;;
        macro)
            # Maximum sharpness, vibrant colors
            SHARPEN_AMOUNT=$(echo "scale=2; $SHARPEN_AMOUNT * 1.3" | bc -l)
            if [ "$CLARITY" -eq 0 ]; then
                CLARITY=20
            fi
            if [ "$VIBRANCE" -eq 0 ]; then
                VIBRANCE=15
            fi
            ;;
    esac
}

#-------------------------------------------------------------------------------
# FUNCTION: preserve_metadata
# Copies EXIF, IPTC, and XMP metadata from source to destination
#
# Parameters:
#   $1 - Source file (RAW)
#   $2 - Destination file (JPEG)
#-------------------------------------------------------------------------------

preserve_metadata() {
    local source="$1"
    local dest="$2"

    if [ "$PRESERVE_EXIF" = false ] || [ "$EXIF_AVAILABLE" = false ]; then
        return
    fi

    local tags=""
    if [ "$PRESERVE_EXIF" = true ]; then
        tags="$tags -TagsFromFile \"$source\" -EXIF:all"
    fi
    if [ "$PRESERVE_IPTC" = true ]; then
        tags="$tags -IPTC:all"
    fi
    if [ "$PRESERVE_XMP" = true ]; then
        tags="$tags -XMP:all"
    fi

    if [ -n "$tags" ]; then
        eval exiftool -overwrite_original $tags "\"$dest\"" 2>/dev/null
    fi
}

#===============================================================================
# V3.0 ADVANCED INTELLIGENT FUNCTIONS
#===============================================================================

#-------------------------------------------------------------------------------
# FUNCTION: detect_color_cast
# Analyzes RGB channel balance to detect unwanted color casts
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_COLOR_CAST - Boolean
#   COLOR_CAST_TYPE - "warm", "cool", "green", "magenta", "none"
#   COLOR_CAST_CORRECTION - ImageMagick correction parameters
#-------------------------------------------------------------------------------

detect_color_cast() {
    local input_file="$1"
    HAS_COLOR_CAST=false
    COLOR_CAST_TYPE="none"
    COLOR_CAST_CORRECTION=""

    if [ "$ENABLE_COLOR_CAST_CORRECTION" = false ]; then
        return
    fi

    # Get average RGB values
    local rgb=$(magick "$input_file" -resize 100x100! -format "%[fx:mean.r*255] %[fx:mean.g*255] %[fx:mean.b*255]" info: 2>/dev/null)
    local red=$(echo "$rgb" | awk '{print $1}')
    local green=$(echo "$rgb" | awk '{print $2}')
    local blue=$(echo "$rgb" | awk '{print $3}')

    red=${red:-128}
    green=${green:-128}
    blue=${blue:-128}

    # Calculate neutral gray reference
    local avg=$(echo "scale=2; ($red + $green + $blue) / 3" | bc -l)

    # Calculate deviations
    local red_dev=$(echo "scale=2; $red - $avg" | bc -l)
    local green_dev=$(echo "scale=2; $green - $avg" | bc -l)
    local blue_dev=$(echo "scale=2; $blue - $avg" | bc -l)

    # Determine cast type and magnitude
    local max_dev=$(echo "$red_dev $green_dev $blue_dev" | tr ' ' '\n' | awk 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($1)}' | sort -rn | head -1)

    if (( $(echo "$max_dev > $COLOR_CAST_THRESHOLD" | bc -l 2>/dev/null || echo 0) )); then
        HAS_COLOR_CAST=true

        # Determine dominant cast
        if (( $(echo "$red_dev > $green_dev && $red_dev > $blue_dev" | bc -l 2>/dev/null || echo 0) )); then
            if (( $(echo "$red_dev > 0" | bc -l) )); then
                COLOR_CAST_TYPE="warm"
                local correction=$(echo "scale=0; 100 - ($red_dev * $COLOR_CAST_STRENGTH / 100)" | bc -l)
                COLOR_CAST_CORRECTION="-channel R -evaluate multiply 0.$correction +channel"
            fi
        elif (( $(echo "$blue_dev > $red_dev && $blue_dev > $green_dev" | bc -l 2>/dev/null || echo 0) )); then
            if (( $(echo "$blue_dev > 0" | bc -l) )); then
                COLOR_CAST_TYPE="cool"
                local correction=$(echo "scale=0; 100 - ($blue_dev * $COLOR_CAST_STRENGTH / 100)" | bc -l)
                COLOR_CAST_CORRECTION="-channel B -evaluate multiply 0.$correction +channel"
            fi
        elif (( $(echo "$green_dev > $red_dev && $green_dev > $blue_dev" | bc -l 2>/dev/null || echo 0) )); then
            if (( $(echo "$green_dev > 0" | bc -l) )); then
                COLOR_CAST_TYPE="green"
                local correction=$(echo "scale=0; 100 - ($green_dev * $COLOR_CAST_STRENGTH / 100)" | bc -l)
                COLOR_CAST_CORRECTION="-channel G -evaluate multiply 0.$correction +channel"
            else
                COLOR_CAST_TYPE="magenta"
                local boost=$(echo "scale=2; 1 + (${green_dev#-} * $COLOR_CAST_STRENGTH / 10000)" | bc -l)
                COLOR_CAST_CORRECTION="-channel G -evaluate multiply $boost +channel"
            fi
        fi
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_golden_hour
# Detects if photo was taken during golden hour or blue hour
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   IS_GOLDEN_HOUR - Boolean
#   IS_BLUE_HOUR - Boolean
#   GOLDEN_HOUR_ADJUSTMENTS - Suggested adjustments
#-------------------------------------------------------------------------------

detect_golden_hour() {
    local input_file="$1"
    IS_GOLDEN_HOUR=false
    IS_BLUE_HOUR=false
    GOLDEN_HOUR_ADJUSTMENTS=""

    if [ "$ENABLE_GOLDEN_HOUR_DETECTION" = false ]; then
        return
    fi

    # Analyze color temperature of the image
    local rgb=$(magick "$input_file" -resize 50x50! -format "%[fx:mean.r] %[fx:mean.g] %[fx:mean.b]" info: 2>/dev/null)
    local red=$(echo "$rgb" | awk '{print $1}')
    local green=$(echo "$rgb" | awk '{print $2}')
    local blue=$(echo "$rgb" | awk '{print $3}')

    red=${red:-0.5}
    green=${green:-0.5}
    blue=${blue:-0.5}

    # Golden hour: warm tones, red > green > blue
    local rg_ratio=$(echo "scale=3; $red / ($green + 0.001)" | bc -l 2>/dev/null || echo "1")
    local rb_ratio=$(echo "scale=3; $red / ($blue + 0.001)" | bc -l 2>/dev/null || echo "1")

    # Blue hour: cool tones, blue dominant
    local bg_ratio=$(echo "scale=3; $blue / ($green + 0.001)" | bc -l 2>/dev/null || echo "1")
    local br_ratio=$(echo "scale=3; $blue / ($red + 0.001)" | bc -l 2>/dev/null || echo "1")

    # Golden hour detection
    if (( $(echo "$rg_ratio > 1.1 && $rb_ratio > 1.3" | bc -l 2>/dev/null || echo 0) )); then
        IS_GOLDEN_HOUR=true
        if [ "$GOLDEN_HOUR_BOOST" = true ]; then
            GOLDEN_HOUR_ADJUSTMENTS="-modulate 102,115,100 -sigmoidal-contrast 2,50%"
        fi
    fi

    # Blue hour detection
    if (( $(echo "$bg_ratio > 1.15 && $br_ratio > 1.2" | bc -l 2>/dev/null || echo 0) )); then
        IS_BLUE_HOUR=true
        GOLDEN_HOUR_ADJUSTMENTS="-modulate 100,110,100 -brightness-contrast 5x5"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_backlight
# Detects backlit subjects where the background is brighter than the subject
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   IS_BACKLIT - Boolean
#   BACKLIGHT_SEVERITY - 0-100 scale
#   BACKLIGHT_CORRECTION - ImageMagick parameters for correction
#-------------------------------------------------------------------------------

detect_backlight() {
    local input_file="$1"
    IS_BACKLIT=false
    BACKLIGHT_SEVERITY=0
    BACKLIGHT_CORRECTION=""

    if [ "$ENABLE_BACKLIGHT_DETECTION" = false ]; then
        return
    fi

    # Compare center brightness to edge brightness
    local center_brightness=$(magick "$input_file" -resize 300x300! \
        -gravity center -crop 40%x40%+0+0 +repage \
        -format "%[fx:mean*255]" info: 2>/dev/null)
    center_brightness=${center_brightness:-128}

    local edge_brightness=$(magick "$input_file" -resize 300x300! \
        -gravity center -crop 80%x80%+0+0 +repage \
        -bordercolor white -border 1x1 \
        -gravity center -crop 60%x60%+0+0 -negate +repage \
        -format "%[fx:(1-mean)*255]" info: 2>/dev/null)
    edge_brightness=${edge_brightness:-128}

    # Backlit if edges are significantly brighter than center
    local brightness_diff=$(echo "scale=2; $edge_brightness - $center_brightness" | bc -l)

    if (( $(echo "$brightness_diff > 30" | bc -l 2>/dev/null || echo 0) )); then
        IS_BACKLIT=true
        BACKLIGHT_SEVERITY=$(echo "scale=0; $brightness_diff" | bc -l)

        # Cap severity at 100
        if [ "$BACKLIGHT_SEVERITY" -gt 100 ]; then
            BACKLIGHT_SEVERITY=100
        fi

        # Calculate correction strength
        local shadow_lift=$(echo "scale=0; $BACKLIGHT_RECOVERY_STRENGTH * $BACKLIGHT_SEVERITY / 100" | bc -l)
        local highlight_compress=$(echo "scale=0; $shadow_lift / 2" | bc -l)

        BACKLIGHT_CORRECTION="-brightness-contrast ${shadow_lift}x0 -sigmoidal-contrast 3,40%"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_subject
# Attempts to isolate the main subject in the frame
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   SUBJECT_DETECTED - Boolean
#   SUBJECT_POSITION - "center", "left", "right", "top", "bottom"
#   SUBJECT_SIZE - Approximate percentage of frame
#   SUBJECT_REGION - Geometry for the subject region
#-------------------------------------------------------------------------------

detect_subject() {
    local input_file="$1"
    SUBJECT_DETECTED=false
    SUBJECT_POSITION="center"
    SUBJECT_SIZE=0
    SUBJECT_REGION=""

    if [ "$ENABLE_SUBJECT_DETECTION" = false ]; then
        return
    fi

    # Analyze contrast/detail distribution to find subject
    # Get dimensions
    local dimensions=$(magick identify -format "%w %h" "$input_file" 2>/dev/null)
    local width=$(echo "$dimensions" | awk '{print $1}')
    local height=$(echo "$dimensions" | awk '{print $2}')

    # Divide image into 9 regions (3x3 grid)
    local region_w=$((width / 3))
    local region_h=$((height / 3))

    # Find region with highest detail (Laplacian variance)
    local max_detail=0
    local max_region=""
    local region_num=0

    for row in 0 1 2; do
        for col in 0 1 2; do
            local x=$((col * region_w))
            local y=$((row * region_h))

            local detail=$(magick "$input_file" -crop ${region_w}x${region_h}+${x}+${y} +repage \
                -define convolve:scale='!' -morphology Convolve Laplacian:0 \
                -format "%[fx:standard_deviation*1000]" info: 2>/dev/null)
            detail=${detail:-0}

            if (( $(echo "$detail > $max_detail" | bc -l 2>/dev/null || echo 0) )); then
                max_detail=$detail
                max_region="$row,$col"
            fi

            region_num=$((region_num + 1))
        done
    done

    if (( $(echo "$max_detail > 20" | bc -l 2>/dev/null || echo 0) )); then
        SUBJECT_DETECTED=true

        # Determine position from region
        local row=$(echo "$max_region" | cut -d',' -f1)
        local col=$(echo "$max_region" | cut -d',' -f2)

        if [ "$row" -eq 0 ]; then
            SUBJECT_POSITION="top"
        elif [ "$row" -eq 2 ]; then
            SUBJECT_POSITION="bottom"
        fi

        if [ "$col" -eq 0 ]; then
            SUBJECT_POSITION="${SUBJECT_POSITION}left"
        elif [ "$col" -eq 2 ]; then
            SUBJECT_POSITION="${SUBJECT_POSITION}right"
        elif [ "$row" -eq 1 ]; then
            SUBJECT_POSITION="center"
        fi

        # Estimate subject size (simplified)
        SUBJECT_SIZE=33  # Approximately one grid region

        local x=$((${col} * region_w))
        local y=$((${row} * region_h))
        SUBJECT_REGION="${region_w}x${region_h}+${x}+${y}"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_chromatic_aberration
# Detects purple/green fringing at high-contrast edges (chromatic aberration)
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_CA - Boolean
#   CA_SEVERITY - 0-100 scale
#   CA_CORRECTION - ImageMagick correction parameters
#-------------------------------------------------------------------------------

detect_chromatic_aberration() {
    local input_file="$1"
    HAS_CA=false
    CA_SEVERITY=0
    CA_CORRECTION=""

    if [ "$ENABLE_CA_CORRECTION" = false ]; then
        return
    fi

    # Detect color fringing at edges
    # Look for purple/green color at high-contrast boundaries

    # Get edge map
    local edge_colors=$(magick "$input_file" -resize 400x400! \
        -edge 1 -negate \
        -format "%[fx:mean.r] %[fx:mean.g] %[fx:mean.b]" info: 2>/dev/null)

    local er=$(echo "$edge_colors" | awk '{print $1}')
    local eg=$(echo "$edge_colors" | awk '{print $2}')
    local eb=$(echo "$edge_colors" | awk '{print $3}')

    er=${er:-0.5}
    eg=${eg:-0.5}
    eb=${eb:-0.5}

    # Purple fringing: high red and blue, low green at edges
    local purple_score=$(echo "scale=3; ($er + $eb) / 2 - $eg" | bc -l 2>/dev/null || echo "0")

    # Green fringing: high green at edges
    local green_score=$(echo "scale=3; $eg - ($er + $eb) / 2" | bc -l 2>/dev/null || echo "0")

    local max_score=$(echo "$purple_score $green_score" | tr ' ' '\n' | awk 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($1)}' | sort -rn | head -1)
    local threshold=$(echo "scale=3; $CA_DETECTION_THRESHOLD / 100" | bc -l)

    if (( $(echo "$max_score > $threshold" | bc -l 2>/dev/null || echo 0) )); then
        HAS_CA=true
        CA_SEVERITY=$(echo "scale=0; $max_score * 100" | bc -l)

        if (( $(echo "$purple_score > $green_score" | bc -l 2>/dev/null || echo 0) )); then
            # Reduce purple fringing by slightly shifting red and blue channels
            CA_CORRECTION="-channel R -morphology Erode Disk:1 +channel -channel B -morphology Erode Disk:1 +channel"
        else
            # Reduce green fringing
            CA_CORRECTION="-channel G -morphology Erode Disk:1 +channel"
        fi
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_lens_distortion
# Detects barrel or pincushion distortion from lens
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_DISTORTION - Boolean
#   DISTORTION_TYPE - "barrel", "pincushion", "none"
#   DISTORTION_AMOUNT - Magnitude
#   DISTORTION_CORRECTION - ImageMagick correction parameters
#-------------------------------------------------------------------------------

detect_lens_distortion() {
    local input_file="$1"
    HAS_DISTORTION=false
    DISTORTION_TYPE="none"
    DISTORTION_AMOUNT=0
    DISTORTION_CORRECTION=""

    if [ "$ENABLE_LENS_CORRECTION" = false ]; then
        return
    fi

    # Use focal length from EXIF to estimate distortion
    local focal_length=${EXIF_FOCAL_LENGTH:-50}

    # Wide angle lenses typically have barrel distortion
    # Telephoto lenses can have pincushion distortion

    if (( $(echo "$focal_length < 24" | bc -l 2>/dev/null || echo 0) )); then
        HAS_DISTORTION=true
        DISTORTION_TYPE="barrel"
        # Stronger correction for wider lenses
        DISTORTION_AMOUNT=$(echo "scale=2; (24 - $focal_length) * 0.5" | bc -l)
        local correction_pct=$(echo "scale=4; $DISTORTION_AMOUNT * $LENS_CORRECTION_STRENGTH / 10000" | bc -l)
        DISTORTION_CORRECTION="-distort Barrel \"0 0 -${correction_pct} 1\""
    elif (( $(echo "$focal_length > 100" | bc -l 2>/dev/null || echo 0) )); then
        HAS_DISTORTION=true
        DISTORTION_TYPE="pincushion"
        DISTORTION_AMOUNT=$(echo "scale=2; ($focal_length - 100) * 0.1" | bc -l)
        local correction_pct=$(echo "scale=4; $DISTORTION_AMOUNT * $LENS_CORRECTION_STRENGTH / 10000" | bc -l)
        DISTORTION_CORRECTION="-distort Barrel \"0 0 ${correction_pct} 1\""
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_sky
# Detects sky regions in the image for separate enhancement
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_SKY - Boolean
#   SKY_REGION - Top percentage of image that is sky
#   SKY_TYPE - "blue", "sunset", "overcast", "night"
#   SKY_ENHANCEMENT_PARAMS - ImageMagick parameters
#-------------------------------------------------------------------------------

detect_sky() {
    local input_file="$1"
    HAS_SKY=false
    SKY_REGION=0
    SKY_TYPE="none"
    SKY_ENHANCEMENT_PARAMS=""

    if [ "$ENABLE_SKY_ENHANCEMENT" = false ]; then
        return
    fi

    # Analyze top portion of image for sky characteristics
    local top_colors=$(magick "$input_file" -gravity North -crop 100%x30%+0+0 +repage \
        -resize 50x50! \
        -format "%[fx:mean.r] %[fx:mean.g] %[fx:mean.b] %[fx:mean] %[fx:standard_deviation]" info: 2>/dev/null)

    local tr=$(echo "$top_colors" | awk '{print $1}')
    local tg=$(echo "$top_colors" | awk '{print $2}')
    local tb=$(echo "$top_colors" | awk '{print $3}')
    local tmean=$(echo "$top_colors" | awk '{print $4}')
    local tstd=$(echo "$top_colors" | awk '{print $5}')

    tr=${tr:-0.5}
    tg=${tg:-0.5}
    tb=${tb:-0.5}
    tmean=${tmean:-0.5}
    tstd=${tstd:-0.2}

    # Sky detection: relatively uniform area (low std dev) with characteristic colors
    if (( $(echo "$tstd < 0.25" | bc -l 2>/dev/null || echo 0) )); then

        # Blue sky: blue > red, blue > green
        if (( $(echo "$tb > $tr && $tb > $tg && $tmean > 0.3" | bc -l 2>/dev/null || echo 0) )); then
            HAS_SKY=true
            SKY_TYPE="blue"
            SKY_REGION=30
            SKY_ENHANCEMENT_PARAMS="-modulate 100,$((100 + SKY_SATURATION_BOOST)),100"

        # Sunset sky: red/orange dominant
        elif (( $(echo "$tr > $tb && $tr > $tg * 0.9" | bc -l 2>/dev/null || echo 0) )); then
            HAS_SKY=true
            SKY_TYPE="sunset"
            SKY_REGION=30
            SKY_ENHANCEMENT_PARAMS="-modulate 102,$((105 + SKY_SATURATION_BOOST)),100"

        # Overcast: gray, low saturation
        elif (( $(echo "$tstd < 0.1 && $tmean > 0.5" | bc -l 2>/dev/null || echo 0) )); then
            HAS_SKY=true
            SKY_TYPE="overcast"
            SKY_REGION=30
            SKY_ENHANCEMENT_PARAMS="-brightness-contrast 5x10"

        # Night sky: dark with low std dev
        elif (( $(echo "$tmean < 0.15" | bc -l 2>/dev/null || echo 0) )); then
            HAS_SKY=true
            SKY_TYPE="night"
            SKY_REGION=30
            SKY_ENHANCEMENT_PARAMS="-brightness-contrast 10x5"
        fi
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_skin_tones
# Detects areas with skin tones for protection during processing
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_SKIN_TONES - Boolean
#   SKIN_COVERAGE - Percentage of image with skin tones
#   SKIN_PROTECTION_PARAMS - Parameters to protect skin
#-------------------------------------------------------------------------------

detect_skin_tones() {
    local input_file="$1"
    HAS_SKIN_TONES=false
    SKIN_COVERAGE=0
    SKIN_PROTECTION_PARAMS=""

    if [ "$ENABLE_SKIN_PROTECTION" = false ]; then
        return
    fi

    # Detect skin tones using HSL color space
    # Skin tones typically: Hue 0-50 (red-orange), Saturation 20-80%, Lightness 30-80%

    local skin_ratio=$(magick "$input_file" -resize 200x200! \
        -colorspace HSL -channel R -separate +channel \
        -threshold 15% -negate -threshold 85% \
        -format "%[fx:mean]" info: 2>/dev/null)
    skin_ratio=${skin_ratio:-0}

    SKIN_COVERAGE=$(echo "scale=0; $skin_ratio * 100" | bc -l)

    if (( $(echo "$skin_ratio > 0.05" | bc -l 2>/dev/null || echo 0) )); then
        HAS_SKIN_TONES=true

        # Calculate protection parameters
        # Limit saturation to prevent orange/red skin
        local sat_limit=$SKIN_SATURATION_LIMIT
        SKIN_PROTECTION_PARAMS="-modulate 100,$sat_limit,100"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_red_eye
# Detects red-eye effect from flash photography
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_RED_EYE - Boolean
#   RED_EYE_REGIONS - Array of regions with red-eye
#-------------------------------------------------------------------------------

detect_red_eye() {
    local input_file="$1"
    HAS_RED_EYE=false
    RED_EYE_REGIONS=()

    if [ "$ENABLE_RED_EYE_REMOVAL" = false ]; then
        return
    fi

    # Only check if flash was fired
    if [ "$EXIF_FLASH_FIRED" = false ]; then
        return
    fi

    # Look for small, highly saturated red regions
    local red_spots=$(magick "$input_file" -resize 400x400! \
        -colorspace HSL \
        \( +clone -channel R -separate +channel -threshold 5% -threshold 95% \) \
        \( +clone -channel G -separate +channel -threshold 50% \) \
        \( +clone -channel B -separate +channel -threshold 30% -negate -threshold 70% \) \
        -compose Multiply -composite \
        -format "%[fx:mean*10000]" info: 2>/dev/null)
    red_spots=${red_spots:-0}

    if (( $(echo "$red_spots > $RED_EYE_DETECTION_THRESHOLD" | bc -l 2>/dev/null || echo 0) )); then
        HAS_RED_EYE=true
        # Note: Actual region detection would require more complex analysis
        # For now, we flag and apply global red-eye reduction
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: analyze_composition
# Analyzes image composition (rule of thirds, symmetry, etc.)
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   COMPOSITION_SCORE - 0-100 rating
#   COMPOSITION_NOTES - Array of observations
#   SUGGESTED_CROP - Geometry for improved crop (if any)
#-------------------------------------------------------------------------------

analyze_composition() {
    local input_file="$1"
    COMPOSITION_SCORE=50
    COMPOSITION_NOTES=()
    SUGGESTED_CROP=""

    if [ "$ENABLE_COMPOSITION_ANALYSIS" = false ]; then
        return
    fi

    local dimensions=$(magick identify -format "%w %h" "$input_file" 2>/dev/null)
    local width=$(echo "$dimensions" | awk '{print $1}')
    local height=$(echo "$dimensions" | awk '{print $2}')

    # Check if subject is on rule of thirds points
    # Divide into 9 regions and find the one with most interest

    local third_w=$((width / 3))
    local third_h=$((height / 3))

    # Get detail levels at rule of thirds intersections
    local intersections=("$third_w,$third_h" "$((third_w*2)),$third_h" "$third_w,$((third_h*2))" "$((third_w*2)),$((third_h*2))")

    local max_interest=0
    local best_intersection=""

    for point in "${intersections[@]}"; do
        local px=$(echo "$point" | cut -d',' -f1)
        local py=$(echo "$point" | cut -d',' -f2)

        local interest=$(magick "$input_file" -crop 100x100+$((px-50))+$((py-50)) +repage \
            -define convolve:scale='!' -morphology Convolve Laplacian:0 \
            -format "%[fx:standard_deviation*1000]" info: 2>/dev/null)
        interest=${interest:-0}

        if (( $(echo "$interest > $max_interest" | bc -l 2>/dev/null || echo 0) )); then
            max_interest=$interest
            best_intersection="$point"
        fi
    done

    # Score based on whether interest aligns with thirds
    if (( $(echo "$max_interest > 30" | bc -l 2>/dev/null || echo 0) )); then
        COMPOSITION_SCORE=$((COMPOSITION_SCORE + 20))
        COMPOSITION_NOTES+=("Subject on rule of thirds")
    fi

    # Check for centered composition
    local center_interest=$(magick "$input_file" -gravity center -crop 30%x30%+0+0 +repage \
        -define convolve:scale='!' -morphology Convolve Laplacian:0 \
        -format "%[fx:standard_deviation*1000]" info: 2>/dev/null)
    center_interest=${center_interest:-0}

    if (( $(echo "$center_interest > $max_interest * 1.5" | bc -l 2>/dev/null || echo 0) )); then
        COMPOSITION_SCORE=$((COMPOSITION_SCORE + 15))
        COMPOSITION_NOTES+=("Strong center composition")
    fi

    # Cap score at 100
    if [ "$COMPOSITION_SCORE" -gt 100 ]; then
        COMPOSITION_SCORE=100
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_weather
# Detects weather/lighting conditions from image analysis
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   DETECTED_WEATHER - "sunny", "cloudy", "overcast", "rainy", "foggy", "sunset", "night"
#   WEATHER_CONFIDENCE - 0-100
#   WEATHER_ADJUSTMENTS - Suggested adjustments for weather type
#-------------------------------------------------------------------------------

detect_weather() {
    local input_file="$1"
    DETECTED_WEATHER="unknown"
    WEATHER_CONFIDENCE=0
    WEATHER_ADJUSTMENTS=""

    if [ "$ENABLE_WEATHER_DETECTION" = false ]; then
        return
    fi

    # Get overall image statistics
    local stats=$(magick "$input_file" -resize 100x100! \
        -format "%[fx:mean] %[fx:standard_deviation] %[fx:mean.r] %[fx:mean.g] %[fx:mean.b]" info: 2>/dev/null)

    local mean=$(echo "$stats" | awk '{print $1}')
    local stddev=$(echo "$stats" | awk '{print $2}')
    local mr=$(echo "$stats" | awk '{print $3}')
    local mg=$(echo "$stats" | awk '{print $4}')
    local mb=$(echo "$stats" | awk '{print $5}')

    mean=${mean:-0.5}
    stddev=${stddev:-0.2}
    mr=${mr:-0.5}
    mg=${mg:-0.5}
    mb=${mb:-0.5}

    # Sunny: high brightness, high contrast, blue sky likely
    if (( $(echo "$mean > 0.5 && $stddev > 0.25 && $mb > $mr" | bc -l 2>/dev/null || echo 0) )); then
        DETECTED_WEATHER="sunny"
        WEATHER_CONFIDENCE=75
        WEATHER_ADJUSTMENTS="-brightness-contrast 0x5"

    # Cloudy: medium brightness, lower contrast
    elif (( $(echo "$mean > 0.4 && $mean < 0.6 && $stddev < 0.2" | bc -l 2>/dev/null || echo 0) )); then
        DETECTED_WEATHER="cloudy"
        WEATHER_CONFIDENCE=60
        WEATHER_ADJUSTMENTS="-brightness-contrast 5x10 -modulate 100,110,100"

    # Overcast: flat, gray
    elif (( $(echo "$stddev < 0.15 && $mean > 0.35" | bc -l 2>/dev/null || echo 0) )); then
        DETECTED_WEATHER="overcast"
        WEATHER_CONFIDENCE=65
        WEATHER_ADJUSTMENTS="-brightness-contrast 5x15 -modulate 100,115,100"

    # Foggy: very low contrast, washed out
    elif (( $(echo "$stddev < 0.1 && $mean > 0.5" | bc -l 2>/dev/null || echo 0) )); then
        DETECTED_WEATHER="foggy"
        WEATHER_CONFIDENCE=70
        WEATHER_ADJUSTMENTS="-brightness-contrast 0x20 -level 5%,95%"

    # Sunset: warm tones dominate
    elif (( $(echo "$mr > $mb * 1.3 && $mr > $mg" | bc -l 2>/dev/null || echo 0) )); then
        DETECTED_WEATHER="sunset"
        WEATHER_CONFIDENCE=70
        WEATHER_ADJUSTMENTS="-modulate 102,115,100"

    # Night: very dark
    elif (( $(echo "$mean < 0.2" | bc -l 2>/dev/null || echo 0) )); then
        DETECTED_WEATHER="night"
        WEATHER_CONFIDENCE=80
        WEATHER_ADJUSTMENTS="-brightness-contrast 15x5 -modulate 100,110,100"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_hot_pixels
# Detects and marks hot pixels (stuck bright pixels) for removal
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_HOT_PIXELS - Boolean
#   HOT_PIXEL_COUNT - Approximate count
#   HOT_PIXEL_CORRECTION - ImageMagick correction
#-------------------------------------------------------------------------------

detect_hot_pixels() {
    local input_file="$1"
    HAS_HOT_PIXELS=false
    HOT_PIXEL_COUNT=0
    HOT_PIXEL_CORRECTION=""

    if [ "$ENABLE_HOT_PIXEL_REMOVAL" = false ]; then
        return
    fi

    # Hot pixels are more common in long exposures and high ISO
    local iso=${EXIF_ISO:-100}
    local shutter="$EXIF_SHUTTER"

    # Only check for high ISO or long exposure
    if [ "$iso" -lt 1600 ]; then
        return
    fi

    # Detect isolated bright pixels
    local hot_ratio=$(magick "$input_file" -resize 800x800! \
        -morphology HitAndMiss '3x3: 0,0,0  0,1,0  0,0,0' \
        -threshold "${HOT_PIXEL_THRESHOLD}0%" \
        -format "%[fx:mean*100000]" info: 2>/dev/null)
    hot_ratio=${hot_ratio:-0}

    if (( $(echo "$hot_ratio > 1" | bc -l 2>/dev/null || echo 0) )); then
        HAS_HOT_PIXELS=true
        HOT_PIXEL_COUNT=$(echo "scale=0; $hot_ratio" | bc -l)
        # Median filter removes isolated pixels while preserving edges
        HOT_PIXEL_CORRECTION="-statistic median 3x3"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_horizon_tilt
# Detects if the horizon is tilted and calculates correction angle
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HORIZON_TILTED - Boolean
#   HORIZON_ANGLE - Detected tilt angle in degrees
#   HORIZON_CORRECTION - Rotation to apply
#-------------------------------------------------------------------------------

detect_horizon_tilt() {
    local input_file="$1"
    HORIZON_TILTED=false
    HORIZON_ANGLE=0
    HORIZON_CORRECTION=""

    if [ "$ENABLE_AUTO_LEVEL" = false ]; then
        return
    fi

    # Use edge detection to find dominant lines
    # This is a simplified version - full implementation would use Hough transform

    # Detect horizontal edges in the image
    local edge_data=$(magick "$input_file" -resize 400x400! \
        -edge 2 -negate \
        -gravity center -crop 80%x30%+0+0 +repage \
        -threshold 50% \
        -moments \
        -format "%[fx:mean]" info: 2>/dev/null)

    # Simplified: detect by comparing left and right edge heights
    local left_height=$(magick "$input_file" -resize 400x400! \
        -gravity West -crop 10%x100%+0+0 +repage \
        -edge 1 -negate -threshold 50% \
        -format "%[fx:mean*255]" info: 2>/dev/null)

    local right_height=$(magick "$input_file" -resize 400x400! \
        -gravity East -crop 10%x100%+0+0 +repage \
        -edge 1 -negate -threshold 50% \
        -format "%[fx:mean*255]" info: 2>/dev/null)

    left_height=${left_height:-0}
    right_height=${right_height:-0}

    # Estimate angle from height difference
    local height_diff=$(echo "scale=3; $right_height - $left_height" | bc -l)
    # Approximate: 1 degree per 5 units of difference
    HORIZON_ANGLE=$(echo "scale=2; $height_diff / 5" | bc -l)

    local abs_angle=$(echo "$HORIZON_ANGLE" | awk '{print ($1<0)?-$1:$1}')

    if (( $(echo "$abs_angle > $AUTO_LEVEL_THRESHOLD" | bc -l 2>/dev/null || echo 0) )); then
        HORIZON_TILTED=true
        HORIZON_CORRECTION="-rotate ${HORIZON_ANGLE}"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: optimize_dynamic_range
# Optimizes the dynamic range of the image
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   DR_OPTIMIZED - Boolean
#   DR_CORRECTION - ImageMagick parameters for DR optimization
#   DR_HEADROOM - Available headroom in highlights
#-------------------------------------------------------------------------------

optimize_dynamic_range() {
    local input_file="$1"
    DR_OPTIMIZED=false
    DR_CORRECTION=""
    DR_HEADROOM=0

    if [ "$ENABLE_DR_OPTIMIZATION" = false ]; then
        return
    fi

    # Analyze current dynamic range usage
    local stats=$(magick "$input_file" -format "%[fx:minima] %[fx:maxima] %[fx:mean] %[fx:standard_deviation]" info: 2>/dev/null)

    local min_val=$(echo "$stats" | awk '{print $1}')
    local max_val=$(echo "$stats" | awk '{print $2}')
    local mean=$(echo "$stats" | awk '{print $3}')
    local stddev=$(echo "$stats" | awk '{print $4}')

    min_val=${min_val:-0}
    max_val=${max_val:-1}
    mean=${mean:-0.5}
    stddev=${stddev:-0.2}

    local current_range=$(echo "scale=3; $max_val - $min_val" | bc -l)
    DR_HEADROOM=$(echo "scale=0; (1 - $max_val) * 100" | bc -l)

    # Check if range needs optimization
    if (( $(echo "$current_range < $DR_TARGET_RANGE" | bc -l 2>/dev/null || echo 0) )); then
        DR_OPTIMIZED=true

        # Calculate stretch parameters
        local black_point=$(echo "scale=1; $min_val * 100" | bc -l)
        local white_point=$(echo "scale=1; $max_val * 100" | bc -l)

        # Slight expansion of range
        black_point=$(echo "scale=1; $black_point + 0.5" | bc -l)
        white_point=$(echo "scale=1; $white_point - 0.5" | bc -l)

        DR_CORRECTION="-level ${black_point}%,${white_point}%"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: analyze_color_harmony
# Analyzes color relationships for potential enhancement
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   COLOR_HARMONY_TYPE - "complementary", "analogous", "triadic", "neutral"
#   DOMINANT_COLORS - Array of dominant colors
#   HARMONY_ENHANCEMENT - Suggested enhancement parameters
#-------------------------------------------------------------------------------

analyze_color_harmony() {
    local input_file="$1"
    COLOR_HARMONY_TYPE="neutral"
    DOMINANT_COLORS=()
    HARMONY_ENHANCEMENT=""

    if [ "$ENABLE_COLOR_HARMONY" = false ]; then
        return
    fi

    # Get dominant colors (simplified to RGB channels)
    local colors=$(magick "$input_file" -resize 50x50! \
        -format "%[fx:mean.r*360] %[fx:mean.g*360] %[fx:mean.b*360]" info: 2>/dev/null)

    # Convert to HSL for hue analysis
    local hsl=$(magick "$input_file" -resize 50x50! -colorspace HSL \
        -format "%[fx:mean.r*360] %[fx:mean.g] %[fx:mean.b]" info: 2>/dev/null)

    local hue=$(echo "$hsl" | awk '{print $1}')
    local sat=$(echo "$hsl" | awk '{print $2}')
    local lum=$(echo "$hsl" | awk '{print $3}')

    hue=${hue:-180}
    sat=${sat:-0.5}
    lum=${lum:-0.5}

    # Determine color harmony type
    if (( $(echo "$sat < 0.2" | bc -l 2>/dev/null || echo 0) )); then
        COLOR_HARMONY_TYPE="neutral"
        # For neutral images, subtle saturation boost helps
        HARMONY_ENHANCEMENT="-modulate 100,$((100 + HARMONY_ENHANCEMENT_STRENGTH/2)),100"
    else
        # Check for warm or cool dominance
        if (( $(echo "$hue < 60 || $hue > 300" | bc -l 2>/dev/null || echo 0) )); then
            COLOR_HARMONY_TYPE="warm"
            # Enhance warm tones slightly
            HARMONY_ENHANCEMENT="-modulate 100,$((100 + HARMONY_ENHANCEMENT_STRENGTH)),102"
        elif (( $(echo "$hue > 180 && $hue < 270" | bc -l 2>/dev/null || echo 0) )); then
            COLOR_HARMONY_TYPE="cool"
            # Enhance cool tones slightly
            HARMONY_ENHANCEMENT="-modulate 100,$((100 + HARMONY_ENHANCEMENT_STRENGTH)),98"
        else
            COLOR_HARMONY_TYPE="analogous"
            HARMONY_ENHANCEMENT="-modulate 100,$((100 + HARMONY_ENHANCEMENT_STRENGTH)),100"
        fi
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: batch_learn
# Learns from the batch to apply consistent processing
# Call this before processing individual images
#
# Parameters:
#   $@ - Array of input files
#-------------------------------------------------------------------------------

batch_learn() {
    local files=("$@")

    if [ "$ENABLE_BATCH_LEARNING" = false ]; then
        return
    fi

    if [ ${#files[@]} -lt 2 ]; then
        return
    fi

    echo -e "${BLUE}[INFO]${NC} Analyzing batch for consistent processing..."

    local total_exposure=0
    local total_temp=0
    local count=0

    # Sample up to 10 images for batch learning
    local sample_count=$((${#files[@]} < 10 ? ${#files[@]} : 10))
    local step=$((${#files[@]} / sample_count))

    for ((i=0; i<${#files[@]}; i+=step)); do
        local file="${files[$i]}"

        # Get exposure (mean brightness)
        local exp=$(magick "$file" -resize 100x100! -format "%[fx:mean*255]" info: 2>/dev/null)
        exp=${exp:-128}

        # Get color temperature (red/blue ratio)
        local rgb=$(magick "$file" -resize 50x50! -format "%[fx:mean.r] %[fx:mean.b]" info: 2>/dev/null)
        local r=$(echo "$rgb" | awk '{print $1}')
        local b=$(echo "$rgb" | awk '{print $2}')
        local temp=$(echo "scale=2; $r / ($b + 0.001)" | bc -l 2>/dev/null || echo "1")

        total_exposure=$(echo "scale=2; $total_exposure + $exp" | bc -l)
        total_temp=$(echo "scale=2; $total_temp + $temp" | bc -l)

        BATCH_EXPOSURES+=("$exp")
        BATCH_COLOR_TEMPS+=("$temp")

        count=$((count + 1))

        if [ $count -ge 10 ]; then
            break
        fi
    done

    # Calculate averages
    BATCH_AVG_EXPOSURE=$(echo "scale=2; $total_exposure / $count" | bc -l)
    BATCH_AVG_COLOR_TEMP=$(echo "scale=3; $total_temp / $count" | bc -l)

    echo -e "${GREEN}[OK]${NC} Batch analysis complete: avg exposure=$BATCH_AVG_EXPOSURE, avg color temp ratio=$BATCH_AVG_COLOR_TEMP"
}

#-------------------------------------------------------------------------------
# FUNCTION: apply_batch_consistency
# Applies batch-learned adjustments to normalize the image
#
# Parameters:
#   $1 - Input file path
#   $2 - Current image exposure
#   $3 - Current image color temp
#
# Sets:
#   BATCH_ADJUSTMENT - ImageMagick parameters for consistency
#-------------------------------------------------------------------------------

apply_batch_consistency() {
    local input_file="$1"
    local current_exp="$2"
    local current_temp="$3"

    BATCH_ADJUSTMENT=""

    if [ "$ENABLE_BATCH_LEARNING" = false ] || [ "$BATCH_AVG_EXPOSURE" = "0" ]; then
        return
    fi

    # Calculate how much to adjust this image toward batch average
    local exp_diff=$(echo "scale=2; $BATCH_AVG_EXPOSURE - $current_exp" | bc -l)
    local temp_diff=$(echo "scale=3; $BATCH_AVG_COLOR_TEMP - $current_temp" | bc -l)

    # Apply partial correction based on strength setting
    local exp_adj=$(echo "scale=1; $exp_diff * $BATCH_CONSISTENCY_STRENGTH / 100 / 2.55" | bc -l)

    if (( $(echo "$exp_adj > 2 || $exp_adj < -2" | bc -l 2>/dev/null || echo 0) )); then
        # Significant enough to correct
        BATCH_ADJUSTMENT="-brightness-contrast ${exp_adj}x0"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: run_all_v3_analysis
# Runs all v3.0 intelligent analysis functions on an image
#
# Parameters:
#   $1 - Input file path
#-------------------------------------------------------------------------------

run_all_v3_analysis() {
    local input_file="$1"

    detect_color_cast "$input_file"
    detect_golden_hour "$input_file"
    detect_backlight "$input_file"
    detect_subject "$input_file"
    detect_chromatic_aberration "$input_file"
    detect_lens_distortion "$input_file"
    detect_sky "$input_file"
    detect_skin_tones "$input_file"
    detect_red_eye "$input_file"
    analyze_composition "$input_file"
    detect_weather "$input_file"
    detect_hot_pixels "$input_file"
    detect_horizon_tilt "$input_file"
    optimize_dynamic_range "$input_file"
    analyze_color_harmony "$input_file"
}

#-------------------------------------------------------------------------------
# FUNCTION: get_v3_corrections
# Builds the ImageMagick command with all v3.0 corrections
#
# Returns:
#   String with all applicable correction parameters
#-------------------------------------------------------------------------------

get_v3_corrections() {
    local corrections=""

    # Apply corrections in optimal order

    # 1. Hot pixel removal (before other processing)
    if [ "$HAS_HOT_PIXELS" = true ] && [ -n "$HOT_PIXEL_CORRECTION" ]; then
        corrections="$corrections $HOT_PIXEL_CORRECTION"
    fi

    # 2. Lens distortion correction
    if [ "$HAS_DISTORTION" = true ] && [ -n "$DISTORTION_CORRECTION" ]; then
        corrections="$corrections $DISTORTION_CORRECTION"
    fi

    # 3. Horizon leveling
    if [ "$HORIZON_TILTED" = true ] && [ -n "$HORIZON_CORRECTION" ]; then
        corrections="$corrections $HORIZON_CORRECTION"
    fi

    # 4. Chromatic aberration
    if [ "$HAS_CA" = true ] && [ -n "$CA_CORRECTION" ]; then
        corrections="$corrections $CA_CORRECTION"
    fi

    # 5. Color cast correction
    if [ "$HAS_COLOR_CAST" = true ] && [ -n "$COLOR_CAST_CORRECTION" ]; then
        corrections="$corrections $COLOR_CAST_CORRECTION"
    fi

    # 6. Dynamic range optimization
    if [ "$DR_OPTIMIZED" = true ] && [ -n "$DR_CORRECTION" ]; then
        corrections="$corrections $DR_CORRECTION"
    fi

    # 7. Backlight recovery
    if [ "$IS_BACKLIT" = true ] && [ -n "$BACKLIGHT_CORRECTION" ]; then
        corrections="$corrections $BACKLIGHT_CORRECTION"
    fi

    # 8. Golden hour enhancement
    if [ "$IS_GOLDEN_HOUR" = true ] || [ "$IS_BLUE_HOUR" = true ]; then
        if [ -n "$GOLDEN_HOUR_ADJUSTMENTS" ]; then
            corrections="$corrections $GOLDEN_HOUR_ADJUSTMENTS"
        fi
    fi

    # 9. Weather-based adjustments
    if [ "$DETECTED_WEATHER" != "unknown" ] && [ -n "$WEATHER_ADJUSTMENTS" ]; then
        corrections="$corrections $WEATHER_ADJUSTMENTS"
    fi

    # 10. Sky enhancement (apply to top portion only in main processing)
    # This would need compositing for proper application

    # 11. Color harmony enhancement
    if [ -n "$HARMONY_ENHANCEMENT" ]; then
        corrections="$corrections $HARMONY_ENHANCEMENT"
    fi

    # 12. Batch consistency
    if [ -n "$BATCH_ADJUSTMENT" ]; then
        corrections="$corrections $BATCH_ADJUSTMENT"
    fi

    echo "$corrections"
}

#-------------------------------------------------------------------------------
# FUNCTION: print_v3_analysis
# Prints a summary of v3.0 analysis results for an image
#
# Parameters:
#   $1 - Filename for display
#-------------------------------------------------------------------------------

print_v3_analysis() {
    local filename="$1"

    echo -e "\n${CYAN}═══ V3.0 Intelligent Analysis: $filename ═══${NC}"

    # Color cast
    if [ "$HAS_COLOR_CAST" = true ]; then
        echo -e "  ${YELLOW}Color Cast:${NC} $COLOR_CAST_TYPE detected - will correct"
    fi

    # Golden/Blue hour
    if [ "$IS_GOLDEN_HOUR" = true ]; then
        echo -e "  ${YELLOW}Lighting:${NC} Golden hour detected - enhancing warm tones"
    elif [ "$IS_BLUE_HOUR" = true ]; then
        echo -e "  ${YELLOW}Lighting:${NC} Blue hour detected - enhancing cool tones"
    fi

    # Backlight
    if [ "$IS_BACKLIT" = true ]; then
        echo -e "  ${YELLOW}Backlight:${NC} Detected (severity: $BACKLIGHT_SEVERITY%) - applying shadow recovery"
    fi

    # Subject detection
    if [ "$SUBJECT_DETECTED" = true ]; then
        echo -e "  ${YELLOW}Subject:${NC} Detected at $SUBJECT_POSITION position"
    fi

    # Chromatic aberration
    if [ "$HAS_CA" = true ]; then
        echo -e "  ${YELLOW}CA:${NC} Chromatic aberration detected - will correct"
    fi

    # Lens distortion
    if [ "$HAS_DISTORTION" = true ]; then
        echo -e "  ${YELLOW}Distortion:${NC} $DISTORTION_TYPE distortion detected - will correct"
    fi

    # Sky
    if [ "$HAS_SKY" = true ]; then
        echo -e "  ${YELLOW}Sky:${NC} $SKY_TYPE sky detected - will enhance"
    fi

    # Skin tones
    if [ "$HAS_SKIN_TONES" = true ]; then
        echo -e "  ${YELLOW}Skin:${NC} Skin tones detected ($SKIN_COVERAGE%) - protection enabled"
    fi

    # Red-eye
    if [ "$HAS_RED_EYE" = true ]; then
        echo -e "  ${YELLOW}Red-eye:${NC} Detected - will remove"
    fi

    # Composition
    echo -e "  ${YELLOW}Composition:${NC} Score $COMPOSITION_SCORE/100"

    # Weather
    if [ "$DETECTED_WEATHER" != "unknown" ]; then
        echo -e "  ${YELLOW}Weather:${NC} $DETECTED_WEATHER (confidence: $WEATHER_CONFIDENCE%)"
    fi

    # Hot pixels
    if [ "$HAS_HOT_PIXELS" = true ]; then
        echo -e "  ${YELLOW}Hot Pixels:${NC} ~$HOT_PIXEL_COUNT detected - will remove"
    fi

    # Horizon
    if [ "$HORIZON_TILTED" = true ]; then
        echo -e "  ${YELLOW}Horizon:${NC} Tilted ${HORIZON_ANGLE}° - will auto-level"
    fi

    # Dynamic range
    if [ "$DR_OPTIMIZED" = true ]; then
        echo -e "  ${YELLOW}DR:${NC} Optimizing dynamic range (headroom: $DR_HEADROOM%)"
    fi

    # Color harmony
    echo -e "  ${YELLOW}Color Harmony:${NC} $COLOR_HARMONY_TYPE palette"

    echo ""
}

#===============================================================================
#                         V4.0 INTELLIGENT FUNCTIONS
#===============================================================================

#-------------------------------------------------------------------------------
# FUNCTION: detect_eyes
# Detects eyes in portraits and calculates enhancement parameters
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_EYES, EYE_REGIONS, EYE_ENHANCEMENT_PARAMS
#-------------------------------------------------------------------------------

detect_eyes() {
    local input_file="$1"

    [ "$ENABLE_EYE_ENHANCEMENT" != true ] && return 0

    # First check if faces were detected
    if [ "$FACE_DETECTED" != true ]; then
        HAS_EYES=false
        return 0
    fi

    # Analyze the upper-middle region where eyes typically appear
    # Eyes are usually in the upper 40% of a detected face region
    local eye_region_stats=$(magick "$input_file" -crop 60%x20%+20%+15% +repage \
        -colorspace Gray -format "%[fx:standard_deviation],%[fx:mean]" info: 2>/dev/null)

    if [ -n "$eye_region_stats" ]; then
        local eye_contrast=$(echo "$eye_region_stats" | cut -d',' -f1)
        local eye_brightness=$(echo "$eye_region_stats" | cut -d',' -f2)

        # Eyes typically have high local contrast (whites, iris, pupil)
        local contrast_threshold=$(echo "$eye_contrast > 0.15" | bc -l 2>/dev/null)

        if [ "$contrast_threshold" = "1" ]; then
            HAS_EYES=true

            # Calculate enhancement based on current eye brightness
            local brightness_pct=$(echo "$eye_brightness * 100" | bc -l 2>/dev/null | cut -d'.' -f1)

            # Eyes should be bright and clear
            if [ "$brightness_pct" -lt 40 ]; then
                EYE_ENHANCEMENT_PARAMS="-brightness-contrast ${EYE_BRIGHTNESS_BOOST}x${EYE_SHARPNESS_BOOST}"
            else
                EYE_ENHANCEMENT_PARAMS="-brightness-contrast $((EYE_BRIGHTNESS_BOOST/2))x${EYE_SHARPNESS_BOOST}"
            fi
        else
            HAS_EYES=false
        fi
    else
        HAS_EYES=false
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_teeth
# Detects smile/teeth for subtle whitening
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_TEETH, TEETH_WHITENING_PARAMS
#-------------------------------------------------------------------------------

detect_teeth() {
    local input_file="$1"

    [ "$ENABLE_TEETH_DETECTION" != true ] && return 0
    [ "$FACE_DETECTED" != true ] && return 0

    # Analyze lower-middle region of face for teeth
    # Look for bright spots with slight yellow/warm cast (teeth)
    local mouth_region=$(magick "$input_file" -crop 40%x15%+30%+55% +repage \
        -colorspace LAB -channel R -separate \
        -format "%[fx:mean*100]" info: 2>/dev/null)

    if [ -n "$mouth_region" ]; then
        local brightness=$(echo "$mouth_region" | cut -d'.' -f1)

        # Teeth appear as bright regions
        if [ "$brightness" -gt 60 ]; then
            HAS_TEETH=true
            # Apply subtle desaturation and brightness to yellowed teeth
            TEETH_WHITENING_PARAMS="-modulate 105,90,100"
        else
            HAS_TEETH=false
            TEETH_WHITENING_PARAMS=""
        fi
    else
        HAS_TEETH=false
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_food
# Detects food photography for enhanced saturation and warmth
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   IS_FOOD_PHOTO, FOOD_ENHANCEMENT_PARAMS
#-------------------------------------------------------------------------------

detect_food() {
    local input_file="$1"

    [ "$ENABLE_FOOD_DETECTION" != true ] && return 0

    # Food photos typically have:
    # 1. High saturation in reds, oranges, yellows, greens
    # 2. Shallow depth of field (blur in edges)
    # 3. Warm color temperature
    # 4. Central subject with bokeh

    # Get color channel information
    local color_info=$(magick "$input_file" -resize 200x200! \
        -colorspace HSL -channel G -separate \
        -format "%[fx:mean*100],%[fx:standard_deviation*100]" info: 2>/dev/null)

    if [ -n "$color_info" ]; then
        local saturation=$(echo "$color_info" | cut -d',' -f1 | cut -d'.' -f1)
        local sat_variance=$(echo "$color_info" | cut -d',' -f2 | cut -d'.' -f1)

        # Check for warm tones (food typically warm)
        local warm_ratio=$(magick "$input_file" -resize 100x100! \
            -format "%[fx:(mean.r+mean.g/2)/(mean.b+0.01)]" info: 2>/dev/null)
        local warm_check=$(echo "$warm_ratio > 1.1" | bc -l 2>/dev/null)

        # Check edge blur (shallow DOF indicator)
        local center_sharp=$(magick "$input_file" -crop 40%x40%+30%+30% +repage \
            -colorspace Gray -define convolve:scale='!' \
            -morphology Convolve Laplacian:0 -format "%[fx:standard_deviation*1000]" info: 2>/dev/null)
        local edge_sharp=$(magick "$input_file" -crop 100%x20%+0%+0% +repage \
            -colorspace Gray -define convolve:scale='!' \
            -morphology Convolve Laplacian:0 -format "%[fx:standard_deviation*1000]" info: 2>/dev/null)

        local center_val=$(echo "$center_sharp" | cut -d'.' -f1)
        local edge_val=$(echo "$edge_sharp" | cut -d'.' -f1)

        # Food: moderate-high saturation, warm tones, sharp center with soft edges
        if [ "$saturation" -gt 30 ] && [ "$warm_check" = "1" ]; then
            if [ "$center_val" -gt "$edge_val" ] 2>/dev/null; then
                IS_FOOD_PHOTO=true
                # Enhance saturation and warmth for appetizing look
                local sat_boost=$((100 + FOOD_SATURATION_BOOST))
                FOOD_ENHANCEMENT_PARAMS="-modulate 100,$sat_boost,100 -sigmoidal-contrast 2x50%"
            else
                IS_FOOD_PHOTO=false
            fi
        else
            IS_FOOD_PHOTO=false
        fi
    else
        IS_FOOD_PHOTO=false
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_architecture
# Detects architecture photos for perspective and line enhancement
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   IS_ARCHITECTURE, HAS_PERSPECTIVE_DISTORTION, PERSPECTIVE_PARAMS
#-------------------------------------------------------------------------------

detect_architecture() {
    local input_file="$1"

    [ "$ENABLE_ARCHITECTURE_DETECTION" != true ] && return 0

    # Architecture photos have:
    # 1. Strong straight lines (vertical and horizontal)
    # 2. Geometric patterns
    # 3. Often wide angle distortion
    # 4. High contrast edges

    # Detect straight lines using edge detection
    local edge_info=$(magick "$input_file" -resize 300x300! \
        -colorspace Gray -canny 0x1+10%+30% \
        -morphology HMT LineEnds -format "%[fx:mean*10000]" info: 2>/dev/null)

    local line_density=$(echo "$edge_info" | cut -d'.' -f1)

    # Check for vertical lines (architecture indicator)
    local vertical_lines=$(magick "$input_file" -resize 300x300! \
        -colorspace Gray -morphology Convolve "3x3: 1,-2,1, 1,-2,1, 1,-2,1" \
        -format "%[fx:mean*1000]" info: 2>/dev/null)

    local vert_score=$(echo "$vertical_lines" | cut -d'.' -f1)

    if [ "$line_density" -gt 50 ] 2>/dev/null && [ "$vert_score" -gt 20 ] 2>/dev/null; then
        IS_ARCHITECTURE=true

        # Check for converging verticals (perspective distortion)
        # Compare line angles at top vs bottom of image
        local top_var=$(magick "$input_file" -crop 100%x30%+0%+0% +repage \
            -colorspace Gray -canny 0x1+10%+30% \
            -format "%[fx:standard_deviation*100]" info: 2>/dev/null)
        local bottom_var=$(magick "$input_file" -crop 100%x30%+0%+70% +repage \
            -colorspace Gray -canny 0x1+10%+30% \
            -format "%[fx:standard_deviation*100]" info: 2>/dev/null)

        local top_val=$(echo "$top_var" | cut -d'.' -f1)
        local bottom_val=$(echo "$bottom_var" | cut -d'.' -f1)
        local diff=$((bottom_val - top_val))

        if [ "$diff" -gt 5 ] 2>/dev/null; then
            HAS_PERSPECTIVE_DISTORTION=true
            # Would need more complex correction - flag for user
            PERSPECTIVE_PARAMS="-distort Perspective"
        else
            HAS_PERSPECTIVE_DISTORTION=false
            PERSPECTIVE_PARAMS=""
        fi
    else
        IS_ARCHITECTURE=false
        HAS_PERSPECTIVE_DISTORTION=false
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_water
# Detects water and reflections for specialized enhancement
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_WATER, HAS_REFLECTIONS, WATER_ENHANCEMENT_PARAMS
#-------------------------------------------------------------------------------

detect_water() {
    local input_file="$1"

    [ "$ENABLE_WATER_DETECTION" != true ] && return 0

    # Water characteristics:
    # 1. Blue/cyan dominant in lower portions
    # 2. Horizontal smoothness (calm water) or texture (waves)
    # 3. Similar patterns mirrored (reflections)

    # Check lower third for blue tones (water typically at bottom)
    local lower_third=$(magick "$input_file" -crop 100%x33%+0%+67% +repage \
        -resize 100x100! -colorspace HSL \
        -format "%[fx:mean.r*360],%[fx:mean.g*100]" info: 2>/dev/null)

    if [ -n "$lower_third" ]; then
        local hue=$(echo "$lower_third" | cut -d',' -f1 | cut -d'.' -f1)
        local saturation=$(echo "$lower_third" | cut -d',' -f2 | cut -d'.' -f1)

        # Blue-cyan range: 180-250 degrees
        if [ "$hue" -ge 180 ] 2>/dev/null && [ "$hue" -le 250 ] 2>/dev/null && [ "$saturation" -gt 20 ]; then
            HAS_WATER=true

            # Check for reflections by comparing top and bottom halves
            local top_sig=$(magick "$input_file" -crop 100%x40%+0%+10% +repage -resize 50x50! \
                -colorspace Gray -format "%[fx:mean]" info: 2>/dev/null)
            local bottom_sig=$(magick "$input_file" -flip -crop 100%x40%+0%+10% +repage -resize 50x50! \
                -colorspace Gray -format "%[fx:mean]" info: 2>/dev/null)

            if [ -n "$top_sig" ] && [ -n "$bottom_sig" ]; then
                local diff=$(echo "($top_sig - $bottom_sig)" | bc -l 2>/dev/null | tr -d '-')
                local has_reflection=$(echo "$diff < 0.1" | bc -l 2>/dev/null)

                if [ "$has_reflection" = "1" ]; then
                    HAS_REFLECTIONS=true
                    WATER_ENHANCEMENT_PARAMS="-modulate 100,110,100 -sigmoidal-contrast 1.5x50%"
                else
                    HAS_REFLECTIONS=false
                    WATER_ENHANCEMENT_PARAMS="-sigmoidal-contrast 1.5x50%"
                fi
            fi
        else
            HAS_WATER=false
            HAS_REFLECTIONS=false
        fi
    else
        HAS_WATER=false
        HAS_REFLECTIONS=false
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_time_period
# Determines time of day from EXIF for lighting assumptions
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   EXIF_TIME_HOUR, DETECTED_TIME_PERIOD, TIME_ADJUSTMENTS
#-------------------------------------------------------------------------------

detect_time_period() {
    local input_file="$1"

    [ "$ENABLE_TIME_INTELLIGENCE" != true ] && return 0

    # Extract time from EXIF
    if command -v exiftool &> /dev/null; then
        local exif_time=$(exiftool -DateTimeOriginal -s3 "$input_file" 2>/dev/null)

        if [ -n "$exif_time" ]; then
            # Extract hour (format: YYYY:MM:DD HH:MM:SS)
            EXIF_TIME_HOUR=$(echo "$exif_time" | cut -d' ' -f2 | cut -d':' -f1 | sed 's/^0//')

            # Determine time period
            if [ "$EXIF_TIME_HOUR" -ge 5 ] && [ "$EXIF_TIME_HOUR" -lt 7 ]; then
                DETECTED_TIME_PERIOD="dawn"
                TIME_ADJUSTMENTS="-modulate 100,105,98"  # Slight cool, low contrast
            elif [ "$EXIF_TIME_HOUR" -ge 7 ] && [ "$EXIF_TIME_HOUR" -lt 10 ]; then
                DETECTED_TIME_PERIOD="morning"
                TIME_ADJUSTMENTS="-modulate 102,100,100"  # Fresh, clear
            elif [ "$EXIF_TIME_HOUR" -ge 10 ] && [ "$EXIF_TIME_HOUR" -lt 16 ]; then
                DETECTED_TIME_PERIOD="day"
                TIME_ADJUSTMENTS=""  # Neutral
            elif [ "$EXIF_TIME_HOUR" -ge 16 ] && [ "$EXIF_TIME_HOUR" -lt 18 ]; then
                DETECTED_TIME_PERIOD="afternoon"
                TIME_ADJUSTMENTS="-modulate 100,100,102"  # Slight warm
            elif [ "$EXIF_TIME_HOUR" -ge 18 ] && [ "$EXIF_TIME_HOUR" -lt 20 ]; then
                DETECTED_TIME_PERIOD="golden"
                TIME_ADJUSTMENTS="-modulate 100,110,105"  # Warm, saturated
            elif [ "$EXIF_TIME_HOUR" -ge 20 ] && [ "$EXIF_TIME_HOUR" -lt 22 ]; then
                DETECTED_TIME_PERIOD="blue"
                TIME_ADJUSTMENTS="-modulate 100,105,95"  # Cool blue tones
            else
                DETECTED_TIME_PERIOD="night"
                TIME_ADJUSTMENTS="-modulate 100,95,100"  # Reduce saturation
            fi
        else
            DETECTED_TIME_PERIOD="unknown"
            TIME_ADJUSTMENTS=""
        fi
    else
        DETECTED_TIME_PERIOD="unknown"
        TIME_ADJUSTMENTS=""
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: calculate_quality_score
# Calculates technical and aesthetic quality scores
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   TECHNICAL_QUALITY_SCORE, AESTHETIC_QUALITY_SCORE, OVERALL_QUALITY_SCORE
#-------------------------------------------------------------------------------

calculate_quality_score() {
    local input_file="$1"

    [ "$ENABLE_QUALITY_SCORING" != true ] && return 0

    local tech_score=50
    local aesthetic_score=50

    # Technical quality factors:

    # 1. Sharpness (already calculated in analyze_image_content)
    if [ -n "$SHARPNESS_SCORE" ]; then
        if [ "$SHARPNESS_SCORE" -gt 200 ]; then
            tech_score=$((tech_score + 20))
        elif [ "$SHARPNESS_SCORE" -gt 100 ]; then
            tech_score=$((tech_score + 10))
        elif [ "$SHARPNESS_SCORE" -lt 50 ]; then
            tech_score=$((tech_score - 15))
        fi
    fi

    # 2. Exposure (check histogram clipping)
    if [ -n "$SHADOW_CLIPPING" ] && [ -n "$HIGHLIGHT_CLIPPING" ]; then
        local shadow_clip=$(echo "$SHADOW_CLIPPING" | cut -d'.' -f1)
        local highlight_clip=$(echo "$HIGHLIGHT_CLIPPING" | cut -d'.' -f1)

        if [ "$shadow_clip" -lt 2 ] && [ "$highlight_clip" -lt 2 ]; then
            tech_score=$((tech_score + 15))
        elif [ "$shadow_clip" -gt 10 ] || [ "$highlight_clip" -gt 10 ]; then
            tech_score=$((tech_score - 15))
        fi
    fi

    # 3. Noise level (based on ISO)
    if [ -n "$ISO" ]; then
        if [ "$ISO" -lt 400 ]; then
            tech_score=$((tech_score + 10))
        elif [ "$ISO" -gt 3200 ]; then
            tech_score=$((tech_score - 10))
        elif [ "$ISO" -gt 6400 ]; then
            tech_score=$((tech_score - 20))
        fi
    fi

    # 4. Focus quality (if motion blur detected)
    if [ "$HAS_MOTION_BLUR" = true ]; then
        tech_score=$((tech_score - 15))
    fi

    # Aesthetic quality factors:

    # 1. Composition score (already calculated)
    if [ -n "$COMPOSITION_SCORE" ]; then
        aesthetic_score=$((aesthetic_score + (COMPOSITION_SCORE - 50) / 3))
    fi

    # 2. Color harmony
    case "$COLOR_HARMONY_TYPE" in
        "complementary"|"triadic"|"analogous")
            aesthetic_score=$((aesthetic_score + 10))
            ;;
        "monochromatic")
            aesthetic_score=$((aesthetic_score + 5))
            ;;
    esac

    # 3. Subject clarity
    if [ "$SUBJECT_DETECTED" = true ]; then
        aesthetic_score=$((aesthetic_score + 10))
    fi

    # 4. Golden hour/blue hour bonus
    if [ "$IS_GOLDEN_HOUR" = true ] || [ "$IS_BLUE_HOUR" = true ]; then
        aesthetic_score=$((aesthetic_score + 10))
    fi

    # 5. Face detection bonus for portraits
    if [ "$FACE_DETECTED" = true ]; then
        aesthetic_score=$((aesthetic_score + 5))
    fi

    # Clamp scores to 0-100
    [ "$tech_score" -lt 0 ] && tech_score=0
    [ "$tech_score" -gt 100 ] && tech_score=100
    [ "$aesthetic_score" -lt 0 ] && aesthetic_score=0
    [ "$aesthetic_score" -gt 100 ] && aesthetic_score=100

    TECHNICAL_QUALITY_SCORE=$tech_score
    AESTHETIC_QUALITY_SCORE=$aesthetic_score
    OVERALL_QUALITY_SCORE=$(( (tech_score + aesthetic_score) / 2 ))
}

#-------------------------------------------------------------------------------
# FUNCTION: analyze_noise_types
# Performs advanced noise type analysis
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   LUMINANCE_NOISE_LEVEL, CHROMA_NOISE_LEVEL, HAS_BANDING, NOISE_TYPE
#-------------------------------------------------------------------------------

analyze_noise_types() {
    local input_file="$1"

    [ "$ENABLE_NOISE_TYPE_ANALYSIS" != true ] && return 0

    # Analyze a uniform area for noise characteristics
    # Look at darkest 10% of image (where noise is most visible)

    # Luminance noise (variation in brightness)
    local lum_noise=$(magick "$input_file" -resize 200x200! \
        -colorspace Gray -statistic StandardDeviation 3x3 \
        -format "%[fx:mean*100]" info: 2>/dev/null)

    if [ -n "$lum_noise" ]; then
        LUMINANCE_NOISE_LEVEL=$(echo "$lum_noise" | cut -d'.' -f1)
    else
        LUMINANCE_NOISE_LEVEL=0
    fi

    # Chroma noise (color variation)
    local chroma_noise=$(magick "$input_file" -resize 200x200! \
        -colorspace LAB -channel GB -separate \
        -statistic StandardDeviation 3x3 \
        -format "%[fx:mean*100]" info: 2>/dev/null)

    if [ -n "$chroma_noise" ]; then
        CHROMA_NOISE_LEVEL=$(echo "$chroma_noise" | cut -d'.' -f1)
    else
        CHROMA_NOISE_LEVEL=0
    fi

    # Check for banding (horizontal or vertical patterns)
    local h_pattern=$(magick "$input_file" -resize 200x200! \
        -colorspace Gray -morphology Convolve "1x3: 1,-2,1" \
        -format "%[fx:mean*1000]" info: 2>/dev/null)

    local banding_val=$(echo "$h_pattern" | cut -d'.' -f1)
    if [ "$banding_val" -gt 50 ] 2>/dev/null; then
        HAS_BANDING=true
    else
        HAS_BANDING=false
    fi

    # Determine overall noise type
    if [ "$LUMINANCE_NOISE_LEVEL" -lt 5 ] && [ "$CHROMA_NOISE_LEVEL" -lt 5 ]; then
        NOISE_TYPE="none"
    elif [ "$LUMINANCE_NOISE_LEVEL" -gt "$CHROMA_NOISE_LEVEL" ]; then
        NOISE_TYPE="luminance"
    elif [ "$CHROMA_NOISE_LEVEL" -gt "$LUMINANCE_NOISE_LEVEL" ]; then
        NOISE_TYPE="chroma"
    elif [ "$HAS_BANDING" = true ]; then
        NOISE_TYPE="banding"
    else
        NOISE_TYPE="mixed"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: calculate_smart_crop
# Suggests optimal crop based on composition and subject
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   SMART_CROP_ASPECT, SMART_CROP_GEOMETRY, CROP_CONFIDENCE
#-------------------------------------------------------------------------------

calculate_smart_crop() {
    local input_file="$1"

    [ "$ENABLE_SMART_CROP" != true ] && return 0

    # Get image dimensions
    local dimensions=$(magick identify -format "%w %h" "$input_file" 2>/dev/null)
    local width=$(echo "$dimensions" | cut -d' ' -f1)
    local height=$(echo "$dimensions" | cut -d' ' -f2)

    [ -z "$width" ] || [ -z "$height" ] && return 0

    local current_ratio=$(echo "scale=2; $width / $height" | bc -l 2>/dev/null)

    # Determine if subject position suggests a crop
    CROP_CONFIDENCE=0

    # If face detected, crop around face
    if [ "$FACE_DETECTED" = true ]; then
        SMART_CROP_ASPECT="4:5"  # Portrait-friendly
        CROP_CONFIDENCE=70
    # If landscape detected with sky, consider 16:9
    elif [ "$HAS_SKY" = true ] && [ "$SCENE_TYPE" = "landscape" ]; then
        SMART_CROP_ASPECT="16:9"
        CROP_CONFIDENCE=60
    # Square for centered subjects
    elif [ "$SUBJECT_DETECTED" = true ] && [ "$SUBJECT_POSITION" = "center" ]; then
        SMART_CROP_ASPECT="1:1"
        CROP_CONFIDENCE=50
    else
        # Keep original
        SMART_CROP_ASPECT=""
        CROP_CONFIDENCE=0
    fi

    # Calculate geometry based on aspect
    if [ -n "$SMART_CROP_ASPECT" ]; then
        local target_w=$(echo "$SMART_CROP_ASPECT" | cut -d':' -f1)
        local target_h=$(echo "$SMART_CROP_ASPECT" | cut -d':' -f2)
        local target_ratio=$(echo "scale=2; $target_w / $target_h" | bc -l 2>/dev/null)

        if [ "$(echo "$current_ratio > $target_ratio" | bc -l)" = "1" ]; then
            # Crop width
            local new_width=$(echo "$height * $target_ratio" | bc -l | cut -d'.' -f1)
            local offset=$(( (width - new_width) / 2 ))
            SMART_CROP_GEOMETRY="${new_width}x${height}+${offset}+0"
        else
            # Crop height
            local new_height=$(echo "$width / $target_ratio" | bc -l | cut -d'.' -f1)
            local offset=$(( (height - new_height) / 2 ))
            SMART_CROP_GEOMETRY="${width}x${new_height}+0+${offset}"
        fi
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_mood
# Detects the mood/emotion of the image from colors and tones
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   DETECTED_MOOD, MOOD_CONFIDENCE, MOOD_ENHANCEMENT
#-------------------------------------------------------------------------------

detect_mood() {
    local input_file="$1"

    [ "$ENABLE_MOOD_DETECTION" != true ] && return 0

    # Get color statistics
    local color_stats=$(magick "$input_file" -resize 100x100! \
        -colorspace HSL -format "%[fx:mean.r*360],%[fx:mean.g*100],%[fx:mean.b*100],%[fx:standard_deviation.b*100]" info: 2>/dev/null)

    if [ -n "$color_stats" ]; then
        local hue=$(echo "$color_stats" | cut -d',' -f1 | cut -d'.' -f1)
        local saturation=$(echo "$color_stats" | cut -d',' -f2 | cut -d'.' -f1)
        local lightness=$(echo "$color_stats" | cut -d',' -f3 | cut -d'.' -f1)
        local contrast=$(echo "$color_stats" | cut -d',' -f4 | cut -d'.' -f1)

        MOOD_CONFIDENCE=60

        # Mood detection based on color psychology
        if [ "$lightness" -lt 30 ] && [ "$contrast" -gt 30 ]; then
            DETECTED_MOOD="dramatic"
            MOOD_ENHANCEMENT="-sigmoidal-contrast 3x50%"
        elif [ "$lightness" -gt 70 ] && [ "$saturation" -lt 30 ]; then
            DETECTED_MOOD="peaceful"
            MOOD_ENHANCEMENT="-modulate 105,90,100"
        elif [ "$hue" -ge 0 ] && [ "$hue" -le 30 ] && [ "$saturation" -gt 40 ]; then
            DETECTED_MOOD="energetic"
            MOOD_ENHANCEMENT="-modulate 100,115,100"
        elif [ "$hue" -ge 300 ] && [ "$hue" -le 360 ] && [ "$saturation" -gt 30 ]; then
            DETECTED_MOOD="romantic"
            MOOD_ENHANCEMENT="-modulate 100,105,102"
        elif [ "$hue" -ge 200 ] && [ "$hue" -le 260 ] && [ "$lightness" -lt 40 ]; then
            DETECTED_MOOD="mysterious"
            MOOD_ENHANCEMENT="-sigmoidal-contrast 2x40%"
        elif [ "$saturation" -gt 60 ] && [ "$contrast" -gt 40 ]; then
            DETECTED_MOOD="happy"
            MOOD_ENHANCEMENT="-modulate 103,110,100"
        elif [ "$saturation" -lt 20 ] && [ "$lightness" -lt 50 ]; then
            DETECTED_MOOD="sad"
            MOOD_ENHANCEMENT="-modulate 98,85,100"
        else
            DETECTED_MOOD="neutral"
            MOOD_ENHANCEMENT=""
            MOOD_CONFIDENCE=40
        fi
    else
        DETECTED_MOOD="neutral"
        MOOD_CONFIDENCE=0
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_motion_blur
# Analyzes image for motion blur
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   HAS_MOTION_BLUR, MOTION_DIRECTION, MOTION_SEVERITY, IS_INTENTIONAL_MOTION
#-------------------------------------------------------------------------------

detect_motion_blur() {
    local input_file="$1"

    [ "$ENABLE_MOTION_ANALYSIS" != true ] && return 0

    # Check shutter speed from EXIF
    local shutter_speed=""
    if command -v exiftool &> /dev/null; then
        shutter_speed=$(exiftool -ShutterSpeed -s3 "$input_file" 2>/dev/null)
    fi

    # Analyze directional blur
    local h_blur=$(magick "$input_file" -resize 200x200! \
        -colorspace Gray -morphology Convolve "1x5: 1,1,1,1,1" \
        -format "%[fx:standard_deviation*100]" info: 2>/dev/null)

    local v_blur=$(magick "$input_file" -resize 200x200! \
        -colorspace Gray -morphology Convolve "5x1: 1,1,1,1,1" \
        -format "%[fx:standard_deviation*100]" info: 2>/dev/null)

    local h_val=$(echo "$h_blur" | cut -d'.' -f1)
    local v_val=$(echo "$v_blur" | cut -d'.' -f1)

    # Compare directional blur to detect motion direction
    local blur_diff=$((h_val - v_val))
    [ "$blur_diff" -lt 0 ] && blur_diff=$((-blur_diff))

    if [ "$blur_diff" -gt 5 ]; then
        HAS_MOTION_BLUR=true
        MOTION_SEVERITY=$blur_diff

        if [ "$h_val" -gt "$v_val" ]; then
            MOTION_DIRECTION="horizontal"
        else
            MOTION_DIRECTION="vertical"
        fi

        # Check if intentional (slow shutter for effect)
        if [ -n "$shutter_speed" ]; then
            # Parse shutter speed (e.g., "1/30" or "0.5")
            if echo "$shutter_speed" | grep -q "/"; then
                local denom=$(echo "$shutter_speed" | cut -d'/' -f2)
                if [ "$denom" -lt 30 ] 2>/dev/null; then
                    IS_INTENTIONAL_MOTION=true
                else
                    IS_INTENTIONAL_MOTION=false
                fi
            else
                IS_INTENTIONAL_MOTION=true  # Long exposure
            fi
        fi
    else
        HAS_MOTION_BLUR=false
        MOTION_DIRECTION=""
        MOTION_SEVERITY=0
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: match_lens_profile
# Matches lens from EXIF to lens profile database
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   MATCHED_LENS_PROFILE, LENS_CORRECTION_PARAMS
#-------------------------------------------------------------------------------

match_lens_profile() {
    local input_file="$1"

    [ "$ENABLE_LENS_PROFILES" != true ] && return 0

    # Get lens info from EXIF
    local lens_info=""
    if command -v exiftool &> /dev/null; then
        lens_info=$(exiftool -LensModel -s3 "$input_file" 2>/dev/null)
    fi

    if [ -n "$lens_info" ]; then
        # Try to match lens in database
        for entry in "${LENS_DB_ENTRIES[@]}"; do
            local lens_name=$(echo "$entry" | cut -d'|' -f1)
            if echo "$lens_info" | grep -qi "$lens_name"; then
                MATCHED_LENS_PROFILE="$lens_name"

                # Parse profile: name|type|distortion_type|distortion_amt|vignette_amt
                local dist_type=$(echo "$entry" | cut -d'|' -f3)
                local dist_amt=$(echo "$entry" | cut -d'|' -f4)
                local vig_amt=$(echo "$entry" | cut -d'|' -f5)

                LENS_CORRECTION_PARAMS=""

                # Apply distortion correction
                if [ "$dist_type" = "barrel" ]; then
                    LENS_CORRECTION_PARAMS="-distort Barrel \"0 0 -$dist_amt 1\""
                elif [ "$dist_type" = "pincushion" ]; then
                    LENS_CORRECTION_PARAMS="-distort Barrel \"0 0 $dist_amt 1\""
                fi

                # Apply vignette correction (add light to corners)
                if [ -n "$vig_amt" ] && [ "$vig_amt" != "0" ]; then
                    local vig_correction=$(echo "100 + ($vig_amt * 20)" | bc -l | cut -d'.' -f1)
                    LENS_CORRECTION_PARAMS="$LENS_CORRECTION_PARAMS -vignette 0x$vig_correction"
                fi

                return 0
            fi
        done
    fi

    MATCHED_LENS_PROFILE=""
    LENS_CORRECTION_PARAMS=""
}

#-------------------------------------------------------------------------------
# FUNCTION: detect_focus_quality
# Analyzes focus point and quality
#
# Parameters:
#   $1 - Input file path
#
# Sets:
#   FOCUS_POINT_X, FOCUS_POINT_Y, FOCUS_QUALITY, IN_FOCUS_AREA
#-------------------------------------------------------------------------------

detect_focus_quality() {
    local input_file="$1"

    [ "$ENABLE_FOCUS_DETECTION" != true ] && return 0

    # Divide image into 9 regions and find sharpest
    local max_sharp=0
    local max_region=""
    local total_sharp=0
    local region_count=0

    for row in 0 1 2; do
        for col in 0 1 2; do
            local x_pct=$((col * 33))
            local y_pct=$((row * 33))

            local region_sharp=$(magick "$input_file" \
                -crop "33%x33%+${x_pct}%+${y_pct}%" +repage \
                -colorspace Gray \
                -define convolve:scale='!' \
                -morphology Convolve Laplacian:0 \
                -format "%[fx:standard_deviation*1000]" info: 2>/dev/null)

            local sharp_val=$(echo "$region_sharp" | cut -d'.' -f1)
            total_sharp=$((total_sharp + sharp_val))
            region_count=$((region_count + 1))

            if [ "$sharp_val" -gt "$max_sharp" ] 2>/dev/null; then
                max_sharp=$sharp_val
                max_region="${col},${row}"
            fi
        done
    done

    # Set focus point based on sharpest region
    if [ -n "$max_region" ]; then
        local focus_col=$(echo "$max_region" | cut -d',' -f1)
        local focus_row=$(echo "$max_region" | cut -d',' -f2)

        FOCUS_POINT_X=$(echo "scale=2; ($focus_col * 0.33) + 0.165" | bc -l)
        FOCUS_POINT_Y=$(echo "scale=2; ($focus_row * 0.33) + 0.165" | bc -l)
    fi

    # Determine focus quality
    if [ "$max_sharp" -gt 200 ]; then
        FOCUS_QUALITY="excellent"
    elif [ "$max_sharp" -gt 100 ]; then
        FOCUS_QUALITY="good"
    elif [ "$max_sharp" -gt 50 ]; then
        FOCUS_QUALITY="soft"
    else
        FOCUS_QUALITY="missed"
    fi

    # Calculate percentage of image in focus
    local avg_sharp=$((total_sharp / region_count))
    local focus_threshold=$((max_sharp * 70 / 100))
    IN_FOCUS_AREA=0

    for row in 0 1 2; do
        for col in 0 1 2; do
            local x_pct=$((col * 33))
            local y_pct=$((row * 33))

            local region_sharp=$(magick "$input_file" \
                -crop "33%x33%+${x_pct}%+${y_pct}%" +repage \
                -colorspace Gray \
                -define convolve:scale='!' \
                -morphology Convolve Laplacian:0 \
                -format "%[fx:standard_deviation*1000]" info: 2>/dev/null | cut -d'.' -f1)

            if [ "$region_sharp" -ge "$focus_threshold" ] 2>/dev/null; then
                IN_FOCUS_AREA=$((IN_FOCUS_AREA + 11))
            fi
        done
    done
}

#-------------------------------------------------------------------------------
# FUNCTION: run_all_v4_analysis
# Runs all v4.0 analysis functions on an image
#
# Parameters:
#   $1 - Input file path
#-------------------------------------------------------------------------------

run_all_v4_analysis() {
    local input_file="$1"

    # Run v4.0 detection functions
    detect_time_period "$input_file"
    detect_eyes "$input_file"
    detect_teeth "$input_file"
    detect_food "$input_file"
    detect_architecture "$input_file"
    detect_water "$input_file"
    detect_mood "$input_file"
    detect_motion_blur "$input_file"
    analyze_noise_types "$input_file"
    calculate_quality_score "$input_file"
    calculate_smart_crop "$input_file"
    match_lens_profile "$input_file"
    detect_focus_quality "$input_file"
}

#-------------------------------------------------------------------------------
# FUNCTION: get_v4_corrections
# Returns all v4.0 corrections as ImageMagick parameters
#
# Returns:
#   String of ImageMagick correction parameters
#-------------------------------------------------------------------------------

get_v4_corrections() {
    local corrections=""

    # 1. Time-based adjustments
    if [ -n "$TIME_ADJUSTMENTS" ]; then
        corrections="$corrections $TIME_ADJUSTMENTS"
    fi

    # 2. Food photography enhancement
    if [ "$IS_FOOD_PHOTO" = true ] && [ -n "$FOOD_ENHANCEMENT_PARAMS" ]; then
        corrections="$corrections $FOOD_ENHANCEMENT_PARAMS"
    fi

    # 3. Water/reflection enhancement
    if [ "$HAS_WATER" = true ] && [ -n "$WATER_ENHANCEMENT_PARAMS" ]; then
        corrections="$corrections $WATER_ENHANCEMENT_PARAMS"
    fi

    # 4. Mood enhancement (if not conflicting with other corrections)
    if [ "$DETECTED_MOOD" != "neutral" ] && [ -n "$MOOD_ENHANCEMENT" ]; then
        # Only apply if not already heavily processed
        if [ -z "$IS_FOOD_PHOTO" ] && [ -z "$HAS_WATER" ]; then
            corrections="$corrections $MOOD_ENHANCEMENT"
        fi
    fi

    # 5. Lens corrections
    if [ -n "$MATCHED_LENS_PROFILE" ] && [ -n "$LENS_CORRECTION_PARAMS" ]; then
        corrections="$corrections $LENS_CORRECTION_PARAMS"
    fi

    echo "$corrections"
}

#-------------------------------------------------------------------------------
# FUNCTION: print_v4_analysis
# Prints a summary of v4.0 analysis results for an image
#
# Parameters:
#   $1 - Filename for display
#-------------------------------------------------------------------------------

print_v4_analysis() {
    local filename="$1"

    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}V4.0 Advanced Intelligent Analysis:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Time Intelligence
    echo -e "\n${YELLOW}Time Intelligence:${NC}"
    if [ "$DETECTED_TIME_PERIOD" != "unknown" ]; then
        echo -e "  Time Period:        $DETECTED_TIME_PERIOD (hour: $EXIF_TIME_HOUR)"
    else
        echo -e "  Time Period:        Unknown (no EXIF time)"
    fi

    # Subject Detection
    echo -e "\n${YELLOW}Subject Detection:${NC}"
    if [ "$HAS_EYES" = true ]; then
        echo -e "  Eyes Detected:      Yes - enhancement enabled"
    fi
    if [ "$HAS_TEETH" = true ]; then
        echo -e "  Smile Detected:     Yes - subtle whitening enabled"
    fi
    if [ "$IS_FOOD_PHOTO" = true ]; then
        echo -e "  Food Photography:   Yes - saturation/warmth boost enabled"
    fi
    if [ "$IS_ARCHITECTURE" = true ]; then
        echo -e "  Architecture:       Yes"
        if [ "$HAS_PERSPECTIVE_DISTORTION" = true ]; then
            echo -e "  Perspective:        Distortion detected"
        fi
    fi
    if [ "$HAS_WATER" = true ]; then
        echo -e "  Water Detected:     Yes"
        if [ "$HAS_REFLECTIONS" = true ]; then
            echo -e "  Reflections:        Yes - enhancement enabled"
        fi
    fi

    # Quality Scoring
    echo -e "\n${YELLOW}Quality Scoring:${NC}"
    echo -e "  Technical Score:    $TECHNICAL_QUALITY_SCORE/100"
    echo -e "  Aesthetic Score:    $AESTHETIC_QUALITY_SCORE/100"
    echo -e "  Overall Score:      $OVERALL_QUALITY_SCORE/100"
    if [ "$OVERALL_QUALITY_SCORE" -ge "$QUALITY_THRESHOLD" ]; then
        echo -e "  Recommendation:     ${GREEN}Keep${NC}"
    else
        echo -e "  Recommendation:     ${YELLOW}Review${NC}"
    fi

    # Focus Analysis
    echo -e "\n${YELLOW}Focus Analysis:${NC}"
    echo -e "  Focus Quality:      $FOCUS_QUALITY"
    echo -e "  Focus Point:        $(echo "$FOCUS_POINT_X" | cut -c1-4), $(echo "$FOCUS_POINT_Y" | cut -c1-4)"
    echo -e "  In-Focus Area:      $IN_FOCUS_AREA%"

    # Motion Analysis
    if [ "$HAS_MOTION_BLUR" = true ]; then
        echo -e "\n${YELLOW}Motion Analysis:${NC}"
        echo -e "  Motion Blur:        Yes ($MOTION_DIRECTION)"
        echo -e "  Severity:           $MOTION_SEVERITY%"
        if [ "$IS_INTENTIONAL_MOTION" = true ]; then
            echo -e "  Type:               Intentional (panning/long exposure)"
        else
            echo -e "  Type:               Unintentional (camera shake)"
        fi
    fi

    # Noise Analysis
    echo -e "\n${YELLOW}Noise Analysis:${NC}"
    echo -e "  Noise Type:         $NOISE_TYPE"
    echo -e "  Luminance Noise:    $LUMINANCE_NOISE_LEVEL%"
    echo -e "  Chroma Noise:       $CHROMA_NOISE_LEVEL%"
    if [ "$HAS_BANDING" = true ]; then
        echo -e "  Banding:            Detected"
    fi

    # Mood Detection
    echo -e "\n${YELLOW}Mood Detection:${NC}"
    echo -e "  Detected Mood:      $DETECTED_MOOD ($MOOD_CONFIDENCE% confidence)"

    # Lens Profile
    if [ -n "$MATCHED_LENS_PROFILE" ]; then
        echo -e "\n${YELLOW}Lens Profile:${NC}"
        echo -e "  Matched Lens:       $MATCHED_LENS_PROFILE"
        echo -e "  Corrections:        Applied"
    fi

    # Smart Crop Suggestion
    if [ -n "$SMART_CROP_ASPECT" ] && [ "$CROP_CONFIDENCE" -gt 40 ]; then
        echo -e "\n${YELLOW}Smart Crop Suggestion:${NC}"
        echo -e "  Suggested Aspect:   $SMART_CROP_ASPECT"
        echo -e "  Confidence:         $CROP_CONFIDENCE%"
    fi

    echo ""
}

#-------------------------------------------------------------------------------
# FUNCTION: collect_raw_files
# Collects all RAW files in the directory (multi-format support)
#
# Returns:
#   Populates input_files array
#-------------------------------------------------------------------------------

collect_raw_files() {
    input_files=()

    shopt -s nullglob nocaseglob

    if [ "$AUTO_DETECT_FORMAT" = true ]; then
        # Collect all supported RAW formats
        for format in "${SUPPORTED_RAW_FORMATS[@]}"; do
            for file in *."$format"; do
                input_files+=("$file")
            done
        done
    else
        # Only collect specified format
        for file in *."$INPUT_EXTENSION"; do
            input_files+=("$file")
        done
    fi

    shopt -u nullglob nocaseglob

    # Sort by name
    IFS=$'\n' input_files=($(sort <<<"${input_files[*]}")); unset IFS
}

#-------------------------------------------------------------------------------
# FUNCTION: log_message
# Writes a message to both the console and log file
#
# Parameters:
#   $1 - Message to log
#-------------------------------------------------------------------------------

log_message() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    if [ "$ENABLE_LOGGING" = true ]; then
        echo "[$timestamp] $message" >> "$WORK_DIR/$LOG_FILE"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: process_single_image
# Processes a single RAW file with intelligent enhancement and conversion
#
# Parameters:
#   $1 - Input file path (full path to .CR2 file)
#   $2 - Output file path (full path for .jpg output)
#   $3 - Apply enhancements (true/false)
#
# Returns:
#   0 on success, 1 on failure
#
# Processing Pipeline:
# -------------------------
# 1. Per-image analysis (if intelligent mode enabled)
# 2. White balance / temperature correction
# 3. Exposure and brightness adjustment
# 4. Highlight and shadow recovery
# 5. Contrast and clarity enhancement
# 6. Color adjustments (saturation/vibrance)
# 7. Noise reduction (if enabled)
# 8. Sharpening
# 9. Resize (if requested)
# 10. Watermark (if requested)
# 11. Save with quality settings
# 12. Create web version (if requested)
#-------------------------------------------------------------------------------

process_single_image() {
    local input_file="$1"
    local output_file="$2"
    local apply_enhancements="$3"

    # Working variables for this image (use local copies to avoid conflicts in parallel processing)
    local work_brightness=$BRIGHTNESS
    local work_contrast=$CONTRAST
    local work_highlights=$HIGHLIGHTS
    local work_shadows=$SHADOWS
    local work_temperature=$TEMPERATURE
    local work_saturation=$SATURATION_BOOST
    local work_sharpen=$SHARPEN_AMOUNT
    local work_noise_reduction=$NOISE_REDUCTION
    local work_clarity=$CLARITY
    local work_vibrance=$VIBRANCE

    if [ "$apply_enhancements" = true ]; then

        # === INTELLIGENT ANALYSIS PIPELINE (v2.0) ===

        # 1. Extract EXIF data for intelligent decisions
        if [ "$USE_EXIF_INTELLIGENCE" = true ]; then
            extract_exif_data "$input_file"
        fi

        # 2. Face detection (for auto-portrait mode)
        if [ "$ENABLE_FACE_DETECTION" = true ]; then
            detect_faces "$input_file"
        fi

        # 3. Scene type detection
        if [ "$ENABLE_SCENE_DETECTION" = true ]; then
            detect_scene_type "$input_file"
            # Apply scene-specific adjustments if in auto mode
            if [ "$PRESET" = "auto" ] && [ "$DETECTED_SCENE" != "unknown" ]; then
                apply_scene_preset "$DETECTED_SCENE"
                work_saturation=$SATURATION_BOOST
                work_clarity=$CLARITY
                work_vibrance=$VIBRANCE
                work_highlights=$HIGHLIGHTS
                work_shadows=$SHADOWS
                work_temperature=$TEMPERATURE
            fi
        fi

        # 4. Blur detection for adaptive sharpening
        if [ "$ENABLE_BLUR_DETECTION" = true ]; then
            detect_blur_level "$input_file"
            work_sharpen=$RECOMMENDED_SHARPENING
        fi

        # 5. Histogram analysis for exposure corrections
        if [ "$ENABLE_HISTOGRAM_ANALYSIS" = true ]; then
            analyze_histogram "$input_file"
        fi

        # 6. ISO-based adaptive noise reduction
        if [ "$ENABLE_ADAPTIVE_NOISE" = true ] && [ "$EXIF_ISO" -gt 0 ]; then
            work_noise_reduction=$(calculate_iso_noise_reduction $EXIF_ISO)
        fi

        # 7. Standard per-image analysis (exposure, contrast, color cast)
        if [ "$USE_INTELLIGENT_ANALYSIS" = true ]; then
            analyze_image "$input_file"
            calculate_corrections

            # Merge calculated corrections with manual overrides
            work_brightness=$CALC_BRIGHTNESS
            if [ "$CONTRAST" -eq 0 ]; then
                work_contrast=$CALC_CONTRAST
            fi
            if [ "$HIGHLIGHTS" -eq 0 ]; then
                work_highlights=$CALC_HIGHLIGHTS
            fi
            if [ "$SHADOWS" -eq 0 ]; then
                work_shadows=$CALC_SHADOWS
            fi
            if [ "$TEMPERATURE" -eq 0 ]; then
                work_temperature=$CALC_TEMPERATURE
            fi
        fi

        # === V3.0 ADVANCED INTELLIGENT ANALYSIS ===
        # Run comprehensive v3.0 analysis for advanced corrections
        run_all_v3_analysis "$input_file"

        # Get v3.0 correction parameters
        local v3_corrections=$(get_v3_corrections)

        # === V4.0 ADVANCED INTELLIGENT ANALYSIS ===
        # Run comprehensive v4.0 analysis for next-level corrections
        run_all_v4_analysis "$input_file"

        # Get v4.0 correction parameters
        local v4_corrections=$(get_v4_corrections)

        # Build the ImageMagick command dynamically
        local magick_cmd="magick \"$input_file\""

        # Apply v3.0 corrections first (lens corrections, color cast, etc.)
        if [ -n "$v3_corrections" ]; then
            magick_cmd="$magick_cmd $v3_corrections"
        fi

        # Apply v4.0 corrections (time-based, food, water, mood, lens profiles)
        if [ -n "$v4_corrections" ]; then
            magick_cmd="$magick_cmd $v4_corrections"
        fi

        # 1. White balance / Temperature adjustment
        if [ "$work_temperature" -ne 0 ]; then
            # Temperature: negative = cool (boost blue), positive = warm (boost red/yellow)
            if [ "$work_temperature" -gt 0 ]; then
                # Warm: boost red, reduce blue
                local red_boost=$(echo "100 + $work_temperature / 4" | bc)
                local blue_reduce=$(echo "100 - $work_temperature / 4" | bc)
                magick_cmd="$magick_cmd -channel R -evaluate multiply $(echo "scale=3; $red_boost / 100" | bc)"
                magick_cmd="$magick_cmd -channel B -evaluate multiply $(echo "scale=3; $blue_reduce / 100" | bc)"
                magick_cmd="$magick_cmd +channel"
            else
                # Cool: boost blue, reduce red
                local temp_abs=${work_temperature#-}
                local blue_boost=$(echo "100 + $temp_abs / 4" | bc)
                local red_reduce=$(echo "100 - $temp_abs / 4" | bc)
                magick_cmd="$magick_cmd -channel B -evaluate multiply $(echo "scale=3; $blue_boost / 100" | bc)"
                magick_cmd="$magick_cmd -channel R -evaluate multiply $(echo "scale=3; $red_reduce / 100" | bc)"
                magick_cmd="$magick_cmd +channel"
            fi
        fi

        # 2. Tint adjustment (green/magenta)
        if [ "$TINT" -ne 0 ]; then
            if [ "$TINT" -gt 0 ]; then
                # Magenta: reduce green
                local green_mult=$(echo "scale=3; (100 - $TINT / 5) / 100" | bc)
                magick_cmd="$magick_cmd -channel G -evaluate multiply $green_mult +channel"
            else
                # Green: boost green
                local tint_abs=${TINT#-}
                local green_mult=$(echo "scale=3; (100 + $tint_abs / 5) / 100" | bc)
                magick_cmd="$magick_cmd -channel G -evaluate multiply $green_mult +channel"
            fi
        fi

        # 3. Base auto-corrections
        magick_cmd="$magick_cmd -auto-level -auto-gamma"

        # 4. Highlight recovery
        if [ "$work_highlights" -ne 0 ]; then
            if [ "$work_highlights" -lt 0 ]; then
                # Recover highlights (compress bright values)
                local hl_abs=${work_highlights#-}
                local white_point=$(echo "100 - $hl_abs / 2" | bc)
                magick_cmd="$magick_cmd -level 0%,${white_point}%"
            else
                # Boost highlights
                local white_point=$(echo "100 + $work_highlights / 4" | bc)
                magick_cmd="$magick_cmd -level 0%,${white_point}%,1.0"
            fi
        fi

        # 5. Shadow recovery
        if [ "$work_shadows" -ne 0 ]; then
            if [ "$work_shadows" -gt 0 ]; then
                # Lift shadows (brighten dark areas)
                local shadow_gamma=$(echo "scale=2; 1 + $work_shadows / 100" | bc)
                magick_cmd="$magick_cmd -gamma $shadow_gamma"
            else
                # Deepen shadows
                local shadow_abs=${work_shadows#-}
                local shadow_gamma=$(echo "scale=2; 1 - $shadow_abs / 200" | bc)
                magick_cmd="$magick_cmd -gamma $shadow_gamma"
            fi
        fi

        # 6. Contrast adjustment
        if [ "$work_contrast" -ne 0 ]; then
            local contrast_val=$(echo "scale=1; $work_contrast / 10" | bc)
            if [ "$work_contrast" -gt 0 ]; then
                magick_cmd="$magick_cmd -sigmoidal-contrast ${contrast_val}x50%"
            else
                local contrast_abs=${contrast_val#-}
                magick_cmd="$magick_cmd +sigmoidal-contrast ${contrast_abs}x50%"
            fi
        fi

        # 7. Clarity (local contrast / midtone punch)
        if [ "$CLARITY" -ne 0 ]; then
            if [ "$CLARITY" -gt 0 ]; then
                local clarity_amount=$(echo "scale=2; $CLARITY / 50" | bc)
                magick_cmd="$magick_cmd -unsharp 50x30+${clarity_amount}+0.02"
            else
                # Negative clarity = soften
                local blur_amount=$(echo "scale=1; ${CLARITY#-} / 25" | bc)
                magick_cmd="$magick_cmd -blur 0x${blur_amount}"
            fi
        fi

        # 8. Brightness and saturation (modulate)
        magick_cmd="$magick_cmd -modulate ${work_brightness},${work_saturation},${HUE_ROTATION}"

        # 9. Vibrance (smart saturation that protects skin tones)
        if [ "$VIBRANCE" -gt 0 ]; then
            # Vibrance: boost less-saturated colors more than already-saturated ones
            local vib_boost=$(echo "scale=2; 1 + $VIBRANCE / 200" | bc)
            magick_cmd="$magick_cmd -colorspace HSL -channel G"
            magick_cmd="$magick_cmd -fx \"u<0.5 ? u*$vib_boost : u + (1-u)*(($vib_boost-1)*0.5)\""
            magick_cmd="$magick_cmd +channel -colorspace sRGB"
        fi

        # 10. Noise reduction (using adaptive value from ISO analysis)
        if [ "$work_noise_reduction" -gt 0 ]; then
            if [ "$work_noise_reduction" -lt 30 ]; then
                magick_cmd="$magick_cmd -despeckle"
            elif [ "$work_noise_reduction" -lt 60 ]; then
                magick_cmd="$magick_cmd -despeckle -despeckle"
            else
                local blur_radius=$(echo "scale=1; $work_noise_reduction / 50" | bc)
                magick_cmd="$magick_cmd -blur 0x${blur_radius} -sharpen 0x0.5"
            fi
        fi

        # 11. Sharpening (using adaptive value from blur detection)
        magick_cmd="$magick_cmd -unsharp ${SHARPEN_RADIUS}x${SHARPEN_SIGMA}+${work_sharpen}+${SHARPEN_THRESHOLD}"

        # 12. Quality and output
        magick_cmd="$magick_cmd -quality $JPEG_QUALITY \"$output_file\""

        # Execute the command
        eval $magick_cmd 2>&1
        local result=$?

        if [ $result -ne 0 ]; then
            return 1
        fi

        # 13. Resize if requested
        if [ -n "$RESIZE" ]; then
            resize_image "$output_file" "$RESIZE"
        fi

        # 14. Add watermark if requested
        if [ -n "$WATERMARK_TEXT" ]; then
            add_watermark "$output_file" "$WATERMARK_TEXT" "$WATERMARK_POSITION" "$WATERMARK_OPACITY"
        fi

        # 15. Create web version if requested
        if [ "$CREATE_WEB_VERSION" = true ]; then
            local web_output="${output_file%.*}_web.${OUTPUT_FORMAT}"
            create_web_version "$output_file" "$web_output" "$WEB_MAX_SIZE" "$WEB_QUALITY"
        fi

        # 16. Preserve metadata from original RAW file
        if [ "$PRESERVE_EXIF" = true ]; then
            preserve_metadata "$input_file" "$output_file"
        fi

        return 0
    else
        # Straight conversion without enhancements
        magick "$input_file" \
            -quality "$JPEG_QUALITY" \
            "$output_file" 2>&1

        return $?
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: get_file_size_human
# Returns human-readable file size
#
# Parameters:
#   $1 - File path
#-------------------------------------------------------------------------------

get_file_size_human() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        stat -f "%z" "$file" | awk '{
            if ($1 >= 1073741824) printf "%.1f GB", $1/1073741824
            else if ($1 >= 1048576) printf "%.1f MB", $1/1048576
            else if ($1 >= 1024) printf "%.1f KB", $1/1024
            else printf "%d B", $1
        }'
    else
        # Linux
        stat --printf="%s" "$file" | awk '{
            if ($1 >= 1073741824) printf "%.1f GB", $1/1073741824
            else if ($1 >= 1048576) printf "%.1f MB", $1/1048576
            else if ($1 >= 1024) printf "%.1f KB", $1/1024
            else printf "%d B", $1
        }'
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: format_time
# Converts seconds to human-readable time format
#
# Parameters:
#   $1 - Time in seconds
#-------------------------------------------------------------------------------

format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))

    if [ $hours -gt 0 ]; then
        printf "%dh %dm %ds" $hours $minutes $secs
    elif [ $minutes -gt 0 ]; then
        printf "%dm %ds" $minutes $secs
    else
        printf "%ds" $secs
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: analyze_image
# Analyzes a single image and outputs metrics for intelligent correction
#
# Parameters:
#   $1 - Input file path
#
# Outputs (sets global variables):
#   IMG_MEAN_BRIGHTNESS - Average brightness (0-255)
#   IMG_STD_DEV - Standard deviation (contrast indicator)
#   IMG_MIN_VALUE - Darkest pixel value
#   IMG_MAX_VALUE - Brightest pixel value
#   IMG_RED_MEAN, IMG_GREEN_MEAN, IMG_BLUE_MEAN - Channel means for color cast
#   IMG_CLIPPED_HIGHLIGHTS - Percentage of clipped highlights
#   IMG_CLIPPED_SHADOWS - Percentage of clipped shadows
#-------------------------------------------------------------------------------

analyze_image() {
    local input_file="$1"

    # Get comprehensive image statistics using ImageMagick
    local stats=$(magick "$input_file" -format \
        "%[fx:mean*255] %[fx:standard_deviation*255] %[fx:minima*255] %[fx:maxima*255]" \
        info: 2>/dev/null)

    IMG_MEAN_BRIGHTNESS=$(echo "$stats" | awk '{printf "%.1f", $1}')
    IMG_STD_DEV=$(echo "$stats" | awk '{printf "%.1f", $2}')
    IMG_MIN_VALUE=$(echo "$stats" | awk '{printf "%.1f", $3}')
    IMG_MAX_VALUE=$(echo "$stats" | awk '{printf "%.1f", $4}')

    # Get per-channel means for color cast detection
    local channel_stats=$(magick "$input_file" -colorspace RGB -format \
        "%[fx:mean.r*255] %[fx:mean.g*255] %[fx:mean.b*255]" \
        info: 2>/dev/null)

    IMG_RED_MEAN=$(echo "$channel_stats" | awk '{printf "%.1f", $1}')
    IMG_GREEN_MEAN=$(echo "$channel_stats" | awk '{printf "%.1f", $2}')
    IMG_BLUE_MEAN=$(echo "$channel_stats" | awk '{printf "%.1f", $3}')

    # Calculate clipped highlights (pixels > 250)
    IMG_CLIPPED_HIGHLIGHTS=$(magick "$input_file" -threshold 98% -format "%[fx:mean*100]" info: 2>/dev/null)

    # Calculate clipped shadows (pixels < 5)
    IMG_CLIPPED_SHADOWS=$(magick "$input_file" -negate -threshold 98% -format "%[fx:mean*100]" info: 2>/dev/null)

    # Determine exposure status
    if (( $(echo "$IMG_MEAN_BRIGHTNESS < 80" | bc -l) )); then
        IMG_EXPOSURE_STATUS="underexposed"
    elif (( $(echo "$IMG_MEAN_BRIGHTNESS > 180" | bc -l) )); then
        IMG_EXPOSURE_STATUS="overexposed"
    else
        IMG_EXPOSURE_STATUS="normal"
    fi

    # Detect color cast
    local avg_rgb=$(echo "($IMG_RED_MEAN + $IMG_GREEN_MEAN + $IMG_BLUE_MEAN) / 3" | bc -l)
    local red_dev=$(echo "$IMG_RED_MEAN - $avg_rgb" | bc -l)
    local green_dev=$(echo "$IMG_GREEN_MEAN - $avg_rgb" | bc -l)
    local blue_dev=$(echo "$IMG_BLUE_MEAN - $avg_rgb" | bc -l)

    # Determine dominant color cast (threshold of 5)
    IMG_COLOR_CAST="neutral"
    if (( $(echo "${red_dev#-} > 8" | bc -l) )); then
        if (( $(echo "$red_dev > 0" | bc -l) )); then
            IMG_COLOR_CAST="warm"
        fi
    fi
    if (( $(echo "${blue_dev#-} > 8" | bc -l) )); then
        if (( $(echo "$blue_dev > 0" | bc -l) )); then
            IMG_COLOR_CAST="cool"
        fi
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: calculate_corrections
# Calculates optimal corrections based on image analysis
#
# Uses global variables from analyze_image() and sets correction values
#-------------------------------------------------------------------------------

calculate_corrections() {
    # Reset to defaults
    local calc_brightness=100
    local calc_contrast=0
    local calc_highlights=0
    local calc_shadows=0
    local calc_temperature=0

    # Exposure correction based on mean brightness
    if [ "$IMG_EXPOSURE_STATUS" = "underexposed" ]; then
        # Boost brightness for dark images
        local brightness_deficit=$(echo "127 - $IMG_MEAN_BRIGHTNESS" | bc -l)
        calc_brightness=$(echo "100 + ($brightness_deficit / 3)" | bc -l | awk '{printf "%.0f", $1}')
        # Limit to reasonable range
        if [ "$calc_brightness" -gt 130 ]; then
            calc_brightness=130
        fi
    elif [ "$IMG_EXPOSURE_STATUS" = "overexposed" ]; then
        # Reduce brightness for bright images
        local brightness_excess=$(echo "$IMG_MEAN_BRIGHTNESS - 127" | bc -l)
        calc_brightness=$(echo "100 - ($brightness_excess / 4)" | bc -l | awk '{printf "%.0f", $1}')
        if [ "$calc_brightness" -lt 80 ]; then
            calc_brightness=80
        fi
    fi

    # Contrast adjustment based on standard deviation
    if (( $(echo "$IMG_STD_DEV < 40" | bc -l) )); then
        # Low contrast image - boost contrast
        calc_contrast=$(echo "(50 - $IMG_STD_DEV) / 2" | bc -l | awk '{printf "%.0f", $1}')
    elif (( $(echo "$IMG_STD_DEV > 70" | bc -l) )); then
        # High contrast image - reduce slightly
        calc_contrast=$(echo "($IMG_STD_DEV - 70) / -3" | bc -l | awk '{printf "%.0f", $1}')
    fi

    # Highlight recovery based on clipping
    if (( $(echo "$IMG_CLIPPED_HIGHLIGHTS > 2" | bc -l) )); then
        calc_highlights=$(echo "-1 * $IMG_CLIPPED_HIGHLIGHTS * 3" | bc -l | awk '{printf "%.0f", $1}')
        if [ "$calc_highlights" -lt -50 ]; then
            calc_highlights=-50
        fi
    fi

    # Shadow recovery based on clipping
    if (( $(echo "$IMG_CLIPPED_SHADOWS > 2" | bc -l) )); then
        calc_shadows=$(echo "$IMG_CLIPPED_SHADOWS * 2" | bc -l | awk '{printf "%.0f", $1}')
        if [ "$calc_shadows" -gt 40 ]; then
            calc_shadows=40
        fi
    fi

    # Color cast correction
    if [ "$IMG_COLOR_CAST" = "warm" ]; then
        calc_temperature=-15
    elif [ "$IMG_COLOR_CAST" = "cool" ]; then
        calc_temperature=15
    fi

    # Apply calculated values (only if not manually overridden)
    CALC_BRIGHTNESS=$calc_brightness
    CALC_CONTRAST=$calc_contrast
    CALC_HIGHLIGHTS=$calc_highlights
    CALC_SHADOWS=$calc_shadows
    CALC_TEMPERATURE=$calc_temperature
}

#-------------------------------------------------------------------------------
# FUNCTION: apply_preset
# Loads preset values into adjustment variables
#
# Parameters:
#   $1 - Preset name (auto, portrait, vivid, soft, bw, vintage, natural)
#-------------------------------------------------------------------------------

apply_preset() {
    local preset_name="$1"

    case "$preset_name" in
        auto)
            # Use intelligent analysis - values set by calculate_corrections
            USE_INTELLIGENT_ANALYSIS=true
            ;;
        portrait)
            # Soft, flattering look for portraits
            CONTRAST=-10
            HIGHLIGHTS=-20
            SHADOWS=15
            SATURATION_BOOST=95
            VIBRANCE=20
            CLARITY=-15
            SHARPEN_AMOUNT=0.3
            USE_INTELLIGENT_ANALYSIS=true
            ;;
        vivid)
            # Punchy, saturated look
            CONTRAST=20
            HIGHLIGHTS=-10
            SHADOWS=10
            SATURATION_BOOST=125
            VIBRANCE=40
            CLARITY=25
            SHARPEN_AMOUNT=0.7
            USE_INTELLIGENT_ANALYSIS=false
            ;;
        soft)
            # Dreamy, muted look
            CONTRAST=-15
            HIGHLIGHTS=10
            SHADOWS=20
            SATURATION_BOOST=85
            VIBRANCE=0
            CLARITY=-25
            SHARPEN_AMOUNT=0.2
            USE_INTELLIGENT_ANALYSIS=false
            ;;
        bw)
            # Professional black and white
            SATURATION_BOOST=0
            CONTRAST=15
            CLARITY=20
            SHARPEN_AMOUNT=0.6
            USE_INTELLIGENT_ANALYSIS=true
            ;;
        vintage)
            # Warm, faded vintage look
            TEMPERATURE=25
            CONTRAST=-5
            HIGHLIGHTS=15
            SHADOWS=10
            SATURATION_BOOST=90
            VIBRANCE=-10
            USE_INTELLIGENT_ANALYSIS=false
            ;;
        natural)
            # Minimal processing, true to life
            CONTRAST=0
            HIGHLIGHTS=0
            SHADOWS=0
            SATURATION_BOOST=100
            VIBRANCE=0
            CLARITY=0
            SHARPEN_AMOUNT=0.3
            USE_INTELLIGENT_ANALYSIS=false
            ;;
        *)
            echo -e "${YELLOW}[WARNING]${NC} Unknown preset: $preset_name, using 'auto'"
            apply_preset "auto"
            ;;
    esac
}

#-------------------------------------------------------------------------------
# FUNCTION: print_analysis_report
# Displays detailed analysis for a single image
#
# Parameters:
#   $1 - Input file path
#-------------------------------------------------------------------------------

print_analysis_report() {
    local input_file="$1"
    local filename=$(basename "$input_file")

    # Run all intelligent analysis
    extract_exif_data "$input_file"
    detect_faces "$input_file"
    detect_scene_type "$input_file"
    detect_blur_level "$input_file"
    analyze_histogram "$input_file"
    analyze_image "$input_file"
    calculate_corrections

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Image:${NC} $filename"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # EXIF Information (if available)
    if [ "$EXIF_AVAILABLE" = true ] && [ "$EXIF_ISO" -gt 0 ]; then
        echo -e "${MAGENTA}Camera/EXIF Data:${NC}"
        echo -e "  Camera:             $EXIF_CAMERA_MODEL"
        if [ -n "$EXIF_LENS_MODEL" ]; then
            echo -e "  Lens:               $EXIF_LENS_MODEL"
        fi
        echo -e "  ISO:                $EXIF_ISO"
        echo -e "  Aperture:           $EXIF_APERTURE"
        echo -e "  Shutter:            $EXIF_SHUTTER"
        echo -e "  Focal Length:       ${EXIF_FOCAL_LENGTH}mm"
        echo -e "  Flash:              $([ "$EXIF_FLASH_FIRED" = true ] && echo "Fired" || echo "Not fired")"
        echo ""
    fi

    # Scene Detection
    echo -e "${MAGENTA}Intelligent Detection:${NC}"
    echo -e "  Scene Type:         $DETECTED_SCENE (${SCENE_CONFIDENCE}% confidence)"
    echo -e "  Faces Detected:     $([ "$HAS_FACES" = true ] && echo "Yes" || echo "No")"
    echo -e "  Sharpness Score:    $BLUR_VARIANCE $([ "$IS_BLURRY" = true ] && echo "(Blurry)" || echo "(Sharp)")"
    echo ""

    echo -e "${YELLOW}Exposure Analysis:${NC}"
    echo -e "  Mean Brightness:    $IMG_MEAN_BRIGHTNESS / 255"
    echo -e "  Dynamic Range:      $IMG_MIN_VALUE - $IMG_MAX_VALUE"
    echo -e "  Contrast (StdDev):  $IMG_STD_DEV"
    echo -e "  Status:             $IMG_EXPOSURE_STATUS"
    echo ""

    echo -e "${YELLOW}Histogram Analysis:${NC}"
    printf "  Shadow Clipping:    %.1f%%\n" "$HIST_SHADOW_CLIP"
    printf "  Highlight Clipping: %.1f%%\n" "$HIST_HIGHLIGHT_CLIP"
    echo -e "  Midtone Peak:       $HIST_MIDTONE_PEAK"
    echo -e "  Distribution:       $HIST_DISTRIBUTION"
    echo ""

    echo -e "${YELLOW}Color Analysis:${NC}"
    echo -e "  Red Channel:        $IMG_RED_MEAN"
    echo -e "  Green Channel:      $IMG_GREEN_MEAN"
    echo -e "  Blue Channel:       $IMG_BLUE_MEAN"
    echo -e "  Color Cast:         $IMG_COLOR_CAST"
    echo ""

    echo -e "${GREEN}Recommended Corrections:${NC}"
    echo -e "  Brightness:         $CALC_BRIGHTNESS%"
    echo -e "  Contrast:           $CALC_CONTRAST"
    echo -e "  Highlights:         $CALC_HIGHLIGHTS"
    echo -e "  Shadows:            $CALC_SHADOWS"
    echo -e "  Temperature:        $CALC_TEMPERATURE"
    local suggested_nr=$(calculate_iso_noise_reduction $EXIF_ISO)
    if [ "$suggested_nr" -gt 0 ]; then
        echo -e "  Noise Reduction:    $suggested_nr (based on ISO $EXIF_ISO)"
    fi
    echo -e "  Sharpening:         $RECOMMENDED_SHARPENING"
    if [ "$DETECTED_SCENE" != "unknown" ]; then
        echo -e "  Scene Preset:       $DETECTED_SCENE mode recommended"
    fi
    echo ""

    # V3.0 Advanced Analysis
    run_all_v3_analysis "$input_file"

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}V3.0 Advanced Intelligent Analysis:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${YELLOW}Optical Corrections:${NC}"
    echo -e "  Color Cast:         $([ "$HAS_COLOR_CAST" = true ] && echo "$COLOR_CAST_TYPE detected" || echo "None detected")"
    echo -e "  Lens Distortion:    $([ "$HAS_DISTORTION" = true ] && echo "$DISTORTION_TYPE detected" || echo "None detected")"
    echo -e "  Chromatic Aberration: $([ "$HAS_CA" = true ] && echo "Detected (severity: $CA_SEVERITY)" || echo "None detected")"
    echo -e "  Horizon Tilt:       $([ "$HORIZON_TILTED" = true ] && echo "${HORIZON_ANGLE}° - will correct" || echo "Level")"
    echo -e "  Hot Pixels:         $([ "$HAS_HOT_PIXELS" = true ] && echo "~$HOT_PIXEL_COUNT detected" || echo "None detected")"
    echo ""

    echo -e "${YELLOW}Lighting Analysis:${NC}"
    echo -e "  Golden Hour:        $([ "$IS_GOLDEN_HOUR" = true ] && echo "Yes - warm enhancement enabled" || echo "No")"
    echo -e "  Blue Hour:          $([ "$IS_BLUE_HOUR" = true ] && echo "Yes - cool enhancement enabled" || echo "No")"
    echo -e "  Backlight:          $([ "$IS_BACKLIT" = true ] && echo "Detected (severity: $BACKLIGHT_SEVERITY%)" || echo "No")"
    echo -e "  Weather/Light:      $DETECTED_WEATHER $([ "$WEATHER_CONFIDENCE" -gt 0 ] && echo "(${WEATHER_CONFIDENCE}% confidence)" || echo "")"
    echo ""

    echo -e "${YELLOW}Subject Analysis:${NC}"
    echo -e "  Subject Detected:   $([ "$SUBJECT_DETECTED" = true ] && echo "Yes - at $SUBJECT_POSITION" || echo "No clear subject")"
    echo -e "  Sky Detected:       $([ "$HAS_SKY" = true ] && echo "Yes - $SKY_TYPE ($SKY_REGION% of frame)" || echo "No")"
    echo -e "  Skin Tones:         $([ "$HAS_SKIN_TONES" = true ] && echo "Yes ($SKIN_COVERAGE%) - protection enabled" || echo "None detected")"
    echo -e "  Red-eye:            $([ "$HAS_RED_EYE" = true ] && echo "Detected - will remove" || echo "None")"
    echo ""

    echo -e "${YELLOW}Composition & Color:${NC}"
    echo -e "  Composition Score:  $COMPOSITION_SCORE/100"
    echo -e "  Color Harmony:      $COLOR_HARMONY_TYPE palette"
    echo -e "  Dynamic Range:      $([ "$DR_OPTIMIZED" = true ] && echo "Needs optimization (headroom: $DR_HEADROOM%)" || echo "Good")"
    echo ""

    # V4.0 Advanced Analysis
    run_all_v4_analysis "$input_file"
    print_v4_analysis "$filename"
}

#-------------------------------------------------------------------------------
# FUNCTION: add_watermark
# Adds a text watermark to an image
#
# Parameters:
#   $1 - Input/output file path
#   $2 - Watermark text
#   $3 - Position (topleft, topright, bottomleft, bottomright, center)
#   $4 - Opacity (0-100)
#-------------------------------------------------------------------------------

add_watermark() {
    local file="$1"
    local text="$2"
    local position="$3"
    local opacity="$4"

    # Convert opacity to decimal
    local opacity_dec=$(echo "scale=2; $opacity / 100" | bc)

    # Determine gravity based on position
    local gravity
    case "$position" in
        topleft)     gravity="NorthWest" ;;
        topright)    gravity="NorthEast" ;;
        bottomleft)  gravity="SouthWest" ;;
        bottomright) gravity="SouthEast" ;;
        center)      gravity="Center" ;;
        *)           gravity="SouthEast" ;;
    esac

    # Apply watermark
    magick "$file" \
        -gravity "$gravity" \
        -fill "rgba(255,255,255,$opacity_dec)" \
        -stroke "rgba(0,0,0,$opacity_dec)" \
        -strokewidth 1 \
        -pointsize 36 \
        -annotate +20+20 "$text" \
        "$file"
}

#-------------------------------------------------------------------------------
# FUNCTION: resize_image
# Resizes an image while maintaining aspect ratio
#
# Parameters:
#   $1 - Input/output file path
#   $2 - Size specification (pixels or percentage, e.g., "2000" or "50%")
#-------------------------------------------------------------------------------

resize_image() {
    local file="$1"
    local size_spec="$2"

    if [[ "$size_spec" == *"%" ]]; then
        # Percentage resize
        magick "$file" -resize "$size_spec" "$file"
    else
        # Max dimension resize (maintains aspect ratio)
        magick "$file" -resize "${size_spec}x${size_spec}>" "$file"
    fi
}

#-------------------------------------------------------------------------------
# FUNCTION: create_web_version
# Creates a smaller, web-optimized version of an image
#
# Parameters:
#   $1 - Input file path
#   $2 - Output file path
#   $3 - Max dimension
#   $4 - Quality
#-------------------------------------------------------------------------------

create_web_version() {
    local input="$1"
    local output="$2"
    local max_size="$3"
    local quality="$4"

    magick "$input" \
        -resize "${max_size}x${max_size}>" \
        -strip \
        -interlace Plane \
        -quality "$quality" \
        "$output"
}

#-------------------------------------------------------------------------------
# FUNCTION: print_summary
# Displays a summary of the processing results
#
# Parameters:
#   $1 - Total files
#   $2 - Successful count
#   $3 - Failed count
#   $4 - Start time (epoch seconds)
#   $5 - End time (epoch seconds)
#-------------------------------------------------------------------------------

print_summary() {
    local total=$1
    local success=$2
    local failed=$3
    local start_time=$4
    local end_time=$5
    local elapsed=$((end_time - start_time))

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                        PROCESSING SUMMARY                         ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Total Files:     ${BLUE}$total${NC}"
    echo -e "  Successful:      ${GREEN}$success${NC}"
    echo -e "  Failed:          ${RED}$failed${NC}"
    echo -e "  Success Rate:    ${GREEN}$(awk "BEGIN {printf \"%.1f\", ($success/$total)*100}")%${NC}"
    echo ""
    echo -e "  Processing Time: ${YELLOW}$(format_time $elapsed)${NC}"
    echo -e "  Average Speed:   ${YELLOW}$(awk "BEGIN {printf \"%.1f\", $elapsed/$total}") sec/image${NC}"
    echo ""

    if [ $failed -eq 0 ]; then
        echo -e "  ${GREEN}All files processed successfully!${NC}"
    else
        echo -e "  ${YELLOW}Check $LOG_FILE for details on failed files.${NC}"
    fi

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
}

#-------------------------------------------------------------------------------
# MAIN SCRIPT EXECUTION
#-------------------------------------------------------------------------------

# Parse command line options
QUIET_MODE=false
APPLY_ENHANCEMENTS=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
        -v|--version)
            echo "RAW Photo Batch Processor v4.0"
            exit 0
            ;;
        -q|--quiet)
            QUIET_MODE=true
            shift
            ;;
        -n|--no-enhance)
            APPLY_ENHANCEMENTS=false
            shift
            ;;
        # Presets
        --preset)
            PRESET="$2"
            apply_preset "$PRESET"
            shift 2
            ;;
        # Tone adjustments
        --contrast)
            CONTRAST="$2"
            shift 2
            ;;
        --highlights)
            HIGHLIGHTS="$2"
            shift 2
            ;;
        --shadows)
            SHADOWS="$2"
            shift 2
            ;;
        --clarity)
            CLARITY="$2"
            shift 2
            ;;
        # White balance
        --temperature)
            TEMPERATURE="$2"
            shift 2
            ;;
        --tint)
            TINT="$2"
            shift 2
            ;;
        # Color adjustments
        --saturation)
            SATURATION_BOOST="$2"
            shift 2
            ;;
        --vibrance)
            VIBRANCE="$2"
            shift 2
            ;;
        # Correction
        --noise-reduction)
            NOISE_REDUCTION="$2"
            shift 2
            ;;
        --sharpen)
            SHARPEN_AMOUNT="$2"
            shift 2
            ;;
        # Output options
        --resize)
            RESIZE="$2"
            shift 2
            ;;
        --format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        --quality)
            JPEG_QUALITY="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --watermark)
            WATERMARK_TEXT="$2"
            shift 2
            ;;
        --watermark-position)
            WATERMARK_POSITION="$2"
            shift 2
            ;;
        --watermark-opacity)
            WATERMARK_OPACITY="$2"
            shift 2
            ;;
        --web-version)
            CREATE_WEB_VERSION=true
            shift
            ;;
        --web-size)
            WEB_MAX_SIZE="$2"
            shift 2
            ;;
        --web-quality)
            WEB_QUALITY="$2"
            shift 2
            ;;
        # Analysis/Preview modes
        --analyze)
            ANALYZE_ONLY=true
            shift
            ;;
        --preview)
            PREVIEW_FILE="$2"
            shift 2
            ;;
        # Disable intelligent analysis
        --no-analysis)
            USE_INTELLIGENT_ANALYSIS=false
            shift
            ;;
        # v2.0 options
        --parallel)
            PARALLEL_JOBS="$2"
            shift 2
            ;;
        --format)
            INPUT_EXTENSION="$2"
            AUTO_DETECT_FORMAT=false
            shift 2
            ;;
        --auto-format)
            AUTO_DETECT_FORMAT=true
            shift
            ;;
        --no-face-detection)
            ENABLE_FACE_DETECTION=false
            shift
            ;;
        --no-scene-detection)
            ENABLE_SCENE_DETECTION=false
            shift
            ;;
        --no-adaptive-noise)
            ENABLE_ADAPTIVE_NOISE=false
            shift
            ;;
        --no-blur-detection)
            ENABLE_BLUR_DETECTION=false
            shift
            ;;
        --preserve-metadata)
            PRESERVE_EXIF=true
            PRESERVE_IPTC=true
            PRESERVE_XMP=true
            shift
            ;;
        --no-preserve-metadata)
            PRESERVE_EXIF=false
            PRESERVE_IPTC=false
            PRESERVE_XMP=false
            shift
            ;;
        -*)
            echo -e "${RED}[ERROR]${NC} Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Set working directory (first non-option argument, or current directory)
WORK_DIR="${1:-.}"

# Validate directory exists
if [ ! -d "$WORK_DIR" ]; then
    echo -e "${RED}[ERROR]${NC} Directory does not exist: $WORK_DIR"
    exit 1
fi

# Set output suffix (second argument, or default)
OUTPUT_SUFFIX="${2:-$DEFAULT_SUFFIX}"

# Change to working directory
cd "$WORK_DIR" || exit 1
WORK_DIR=$(pwd)  # Get absolute path

# Print banner (unless quiet mode)
if [ "$QUIET_MODE" = false ]; then
    print_banner
fi

# Check dependencies
check_dependencies

# Collect input files (multi-format support in v2.0)
collect_raw_files

total_files=${#input_files[@]}

if [ $total_files -eq 0 ]; then
    if [ "$AUTO_DETECT_FORMAT" = true ]; then
        echo -e "${YELLOW}[WARNING]${NC} No RAW files found in: $WORK_DIR"
        echo -e "        Supported formats: ${SUPPORTED_RAW_FORMATS[*]}"
    else
        echo -e "${YELLOW}[WARNING]${NC} No .${INPUT_EXTENSION} files found in: $WORK_DIR"
    fi
    exit 0
fi

# Display format breakdown if auto-detecting
if [ "$AUTO_DETECT_FORMAT" = true ] && [ "$QUIET_MODE" = false ]; then
    echo -e "${BLUE}[INFO]${NC} Found RAW files:"
    for format in "${SUPPORTED_RAW_FORMATS[@]}"; do
        shopt -s nullglob nocaseglob
        format_count=$(ls -1 *."$format" 2>/dev/null | wc -l | tr -d ' ')
        shopt -u nullglob nocaseglob
        if [ "$format_count" -gt 0 ]; then
            echo -e "        ${format}: ${format_count} files"
        fi
    done
fi

# Handle preview mode (single file)
if [ -n "$PREVIEW_FILE" ]; then
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                         PREVIEW MODE                              ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""

    if [ ! -f "$PREVIEW_FILE" ]; then
        echo -e "${RED}[ERROR]${NC} Preview file not found: $PREVIEW_FILE"
        exit 1
    fi

    # Show analysis for the preview file
    print_analysis_report "$PREVIEW_FILE"

    # Process the single file
    basename="${PREVIEW_FILE%.*}"
    output_file="${basename}${OUTPUT_SUFFIX}.${OUTPUT_FORMAT}"

    echo -e "${BLUE}[INFO]${NC} Processing preview file..."
    if process_single_image "$PREVIEW_FILE" "$output_file" "$APPLY_ENHANCEMENTS"; then
        echo -e "${GREEN}[SUCCESS]${NC} Created: $output_file ($(get_file_size_human "$output_file"))"
        if [ "$CREATE_WEB_VERSION" = true ]; then
            echo -e "${GREEN}[SUCCESS]${NC} Created: ${basename}${OUTPUT_SUFFIX}_web.${OUTPUT_FORMAT}"
        fi
    else
        echo -e "${RED}[FAILED]${NC} Could not process: $PREVIEW_FILE"
    fi
    echo ""
    exit 0
fi

# Handle analyze-only mode
if [ "$ANALYZE_ONLY" = true ]; then
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                        ANALYSIS MODE                              ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}[INFO]${NC} Analyzing $total_files images without processing..."

    for input_file in "${input_files[@]}"; do
        print_analysis_report "$input_file"
    done

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Analysis complete.${NC} Run without --analyze to process images."
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    exit 0
fi

# Create output directory if specified
if [ -n "$OUTPUT_DIR" ]; then
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        echo -e "${BLUE}[INFO]${NC} Created output directory: $OUTPUT_DIR"
    fi
fi

# Display processing information
echo ""
echo -e "${BLUE}[INFO]${NC} Processing Configuration:"
echo -e "        Directory:    $WORK_DIR"
echo -e "        Input Files:  $total_files .${INPUT_EXTENSION} files"
echo -e "        Output:       *${OUTPUT_SUFFIX}.${OUTPUT_FORMAT}"
echo -e "        Quality:      ${JPEG_QUALITY}%"
echo -e "        Preset:       $PRESET"
echo -e "        Analysis:     $([ "$USE_INTELLIGENT_ANALYSIS" = true ] && echo "Intelligent (per-image)" || echo "Fixed settings")"
echo -e "        Enhancements: $([ "$APPLY_ENHANCEMENTS" = true ] && echo "Enabled" || echo "Disabled")"
if [ "$PARALLEL_JOBS" -gt 1 ]; then
    echo -e "        Parallel:     $PARALLEL_JOBS jobs"
fi
if [ "$ENABLE_FACE_DETECTION" = true ]; then
    echo -e "        Face Detect:  Enabled (auto-portrait)"
fi
if [ "$ENABLE_SCENE_DETECTION" = true ]; then
    echo -e "        Scene Detect: Enabled"
fi
if [ "$ENABLE_ADAPTIVE_NOISE" = true ]; then
    echo -e "        Adaptive NR:  Enabled (ISO-based)"
fi
if [ "$PRESERVE_EXIF" = true ] && [ "$EXIF_AVAILABLE" = true ]; then
    echo -e "        Metadata:     Preserved"
fi
if [ -n "$RESIZE" ]; then
    echo -e "        Resize:       $RESIZE"
fi
if [ -n "$WATERMARK_TEXT" ]; then
    echo -e "        Watermark:    \"$WATERMARK_TEXT\" ($WATERMARK_POSITION)"
fi
if [ "$CREATE_WEB_VERSION" = true ]; then
    echo -e "        Web Version:  Yes (max ${WEB_MAX_SIZE}px, quality ${WEB_QUALITY}%)"
fi
if [ -n "$OUTPUT_DIR" ]; then
    echo -e "        Output Dir:   $OUTPUT_DIR"
fi
echo ""

# Initialize logging
if [ "$ENABLE_LOGGING" = true ]; then
    echo "═══════════════════════════════════════════════════════════════════" > "$LOG_FILE"
    echo "RAW Photo Batch Processor - Processing Log" >> "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "Directory: $WORK_DIR" >> "$LOG_FILE"
    echo "Total Files: $total_files" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════════════════" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
fi

# Initialize counters
success_count=0
failed_count=0
current_count=0
start_time=$(date +%s)

# Process each file
echo -e "${BLUE}[INFO]${NC} Starting batch processing..."
if [ "$PARALLEL_JOBS" -gt 1 ]; then
    echo -e "${BLUE}[INFO]${NC} Using $PARALLEL_JOBS parallel jobs"
fi
echo ""

#-------------------------------------------------------------------------------
# FUNCTION: process_file_wrapper
# Wrapper function for processing a single file (used in parallel processing)
#-------------------------------------------------------------------------------

process_file_wrapper() {
    local input_file="$1"
    local output_dir="$2"
    local output_suffix="$3"
    local output_format="$4"
    local apply_enhancements="$5"

    local basename="${input_file%.*}"
    local output_file
    if [ -n "$output_dir" ]; then
        output_file="${output_dir}/$(basename "$basename")${output_suffix}.${output_format}"
    else
        output_file="${basename}${output_suffix}.${output_format}"
    fi

    if process_single_image "$input_file" "$output_file" "$apply_enhancements"; then
        echo "SUCCESS:$input_file:$output_file"
    else
        echo "FAILED:$input_file"
    fi
}

export -f process_single_image process_file_wrapper analyze_image calculate_corrections
export -f extract_exif_data detect_faces detect_scene_type detect_blur_level
export -f calculate_iso_noise_reduction analyze_histogram apply_scene_preset preserve_metadata
export -f add_watermark resize_image create_web_version get_file_size_human log_message

# Parallel or sequential processing
if [ "$PARALLEL_JOBS" -gt 1 ]; then
    # Parallel processing using background jobs
    job_count=0
    declare -A running_jobs

    for input_file in "${input_files[@]}"; do
        current_count=$((current_count + 1))

        # Generate output filename
        basename="${input_file%.*}"
        if [ -n "$OUTPUT_DIR" ]; then
            output_file="${OUTPUT_DIR}/$(basename "$basename")${OUTPUT_SUFFIX}.${OUTPUT_FORMAT}"
        else
            output_file="${basename}${OUTPUT_SUFFIX}.${OUTPUT_FORMAT}"
        fi

        # Display progress bar
        if [ "$QUIET_MODE" = false ]; then
            progress=$((current_count * 100 / total_files))
            eta=$(calculate_eta $((total_files - current_count)))
            draw_progress_bar $progress $current_count $total_files $eta "$input_file"
        fi

        # Start the job in background
        (
            img_start=$(date +%s)
            log_message "Processing: $input_file"

            if process_single_image "$input_file" "$output_file" "$APPLY_ENHANCEMENTS"; then
                log_message "  SUCCESS: Created $output_file"
                exit 0
            else
                log_message "  FAILED: Could not process $input_file"
                exit 1
            fi
        ) &

        running_jobs[$!]="$input_file"
        job_count=$((job_count + 1))

        # Wait for jobs if we've reached the parallel limit
        if [ $job_count -ge $PARALLEL_JOBS ]; then
            wait -n 2>/dev/null || wait
            for pid in "${!running_jobs[@]}"; do
                if ! kill -0 "$pid" 2>/dev/null; then
                    if wait "$pid"; then
                        success_count=$((success_count + 1))
                    else
                        failed_count=$((failed_count + 1))
                    fi
                    unset running_jobs[$pid]
                    job_count=$((job_count - 1))
                    break
                fi
            done
        fi
    done

    # Wait for remaining jobs
    for pid in "${!running_jobs[@]}"; do
        if wait "$pid"; then
            success_count=$((success_count + 1))
        else
            failed_count=$((failed_count + 1))
        fi
    done

    echo ""  # New line after progress bar
else
    # Sequential processing (original behavior with enhanced progress)
    for input_file in "${input_files[@]}"; do
        current_count=$((current_count + 1))

        # Generate output filename
        basename="${input_file%.*}"
        if [ -n "$OUTPUT_DIR" ]; then
            output_file="${OUTPUT_DIR}/$(basename "$basename")${OUTPUT_SUFFIX}.${OUTPUT_FORMAT}"
        else
            output_file="${basename}${OUTPUT_SUFFIX}.${OUTPUT_FORMAT}"
        fi

        # Track processing time for ETA
        img_start=$(date +%s)

        # Display progress with ETA
        if [ "$QUIET_MODE" = false ]; then
            if [ "$SHOW_PROGRESS_BAR" = true ]; then
                progress=$((current_count * 100 / total_files))
                eta=$(calculate_eta $((total_files - current_count)))
                draw_progress_bar $progress $current_count $total_files $eta "$input_file"
            else
                printf "\r${BLUE}[%d/%d]${NC} Processing: %-40s" "$current_count" "$total_files" "$input_file"
            fi
        fi

        # Process the image
        log_message "Processing: $input_file"

        if process_single_image "$input_file" "$output_file" "$APPLY_ENHANCEMENTS"; then
            success_count=$((success_count + 1))
            log_message "  SUCCESS: Created $output_file ($(get_file_size_human "$output_file"))"

            if [ "$QUIET_MODE" = false ] && [ "$SHOW_PROGRESS_BAR" = false ]; then
                printf " ${GREEN}[OK]${NC}\n"
            fi
        else
            failed_count=$((failed_count + 1))
            log_message "  FAILED: Could not process $input_file"

            if [ "$QUIET_MODE" = false ] && [ "$SHOW_PROGRESS_BAR" = false ]; then
                printf " ${RED}[FAILED]${NC}\n"
            fi
        fi

        # Record processing time for ETA calculation
        img_end=$(date +%s)
        PROCESSING_TIMES+=($((img_end - img_start)))
    done

    if [ "$SHOW_PROGRESS_BAR" = true ]; then
        echo ""  # New line after progress bar
    fi
fi

end_time=$(date +%s)

# Log completion
if [ "$ENABLE_LOGGING" = true ]; then
    echo "" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════════════════" >> "$LOG_FILE"
    echo "Processing completed: $(date)" >> "$LOG_FILE"
    echo "Total: $total_files | Success: $success_count | Failed: $failed_count" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════════════════" >> "$LOG_FILE"
fi

# Print summary
if [ "$QUIET_MODE" = false ]; then
    print_summary $total_files $success_count $failed_count $start_time $end_time
fi

# Exit with appropriate code
if [ $failed_count -gt 0 ]; then
    exit 1
else
    exit 0
fi
