#!/bin/bash
#===============================================================================
#
#   RAW PHOTO BATCH PROCESSOR
#   Version: 1.0
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
#   Advanced batch processor for Canon RAW (.CR2) files with intelligent
#   per-image analysis, professional presets, and comprehensive editing tools.
#
#   Key Features:
#   - Intelligent per-image analysis and auto-correction
#   - 7 professional presets (auto, portrait, vivid, soft, bw, vintage, natural)
#   - Advanced adjustments (contrast, highlights, shadows, clarity)
#   - White balance control (temperature, tint)
#   - Vibrance and noise reduction
#   - Output options (resize, watermark, web versions)
#   - Preview and analysis modes
#
#   Requirements:
#   - ImageMagick (install via: brew install imagemagick)
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
#
#   Run with --help for full options list.
#
#===============================================================================

#-------------------------------------------------------------------------------
# CONFIGURATION SECTION
# Modify these values to customize the processing behavior
#-------------------------------------------------------------------------------

# Input file extension (case-insensitive matching is handled in the script)
INPUT_EXTENSION="CR2"

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
NC='\033[0m' # No Color (reset)

#-------------------------------------------------------------------------------
# FUNCTION: print_banner
# Displays a welcome banner with script information
#-------------------------------------------------------------------------------

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                    RAW PHOTO BATCH PROCESSOR                      ║"
    echo "║                         Version 1.0                               ║"
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

    # Working variables for this image
    local work_brightness=$BRIGHTNESS
    local work_contrast=$CONTRAST
    local work_highlights=$HIGHLIGHTS
    local work_shadows=$SHADOWS
    local work_temperature=$TEMPERATURE
    local work_saturation=$SATURATION_BOOST

    if [ "$apply_enhancements" = true ]; then

        # Intelligent per-image analysis
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

        # Build the ImageMagick command dynamically
        local magick_cmd="magick \"$input_file\""

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

        # 10. Noise reduction
        if [ "$NOISE_REDUCTION" -gt 0 ]; then
            if [ "$NOISE_REDUCTION" -lt 30 ]; then
                magick_cmd="$magick_cmd -despeckle"
            elif [ "$NOISE_REDUCTION" -lt 60 ]; then
                magick_cmd="$magick_cmd -despeckle -despeckle"
            else
                local blur_radius=$(echo "scale=1; $NOISE_REDUCTION / 50" | bc)
                magick_cmd="$magick_cmd -blur 0x${blur_radius} -sharpen 0x0.5"
            fi
        fi

        # 11. Sharpening
        magick_cmd="$magick_cmd -unsharp ${SHARPEN_RADIUS}x${SHARPEN_SIGMA}+${SHARPEN_AMOUNT}+${SHARPEN_THRESHOLD}"

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

    analyze_image "$input_file"
    calculate_corrections

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Image:${NC} $filename"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Exposure Analysis:${NC}"
    echo -e "  Mean Brightness:    $IMG_MEAN_BRIGHTNESS / 255"
    echo -e "  Dynamic Range:      $IMG_MIN_VALUE - $IMG_MAX_VALUE"
    echo -e "  Contrast (StdDev):  $IMG_STD_DEV"
    echo -e "  Status:             $IMG_EXPOSURE_STATUS"
    echo ""
    echo -e "${YELLOW}Highlight/Shadow Clipping:${NC}"
    printf "  Clipped Highlights: %.1f%%\n" "$IMG_CLIPPED_HIGHLIGHTS"
    printf "  Clipped Shadows:    %.1f%%\n" "$IMG_CLIPPED_SHADOWS"
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
    echo ""
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
            echo "RAW Photo Batch Processor v1.0"
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

# Count input files (case-insensitive for CR2/cr2)
shopt -s nullglob nocaseglob
input_files=(*.${INPUT_EXTENSION})
shopt -u nullglob nocaseglob

total_files=${#input_files[@]}

if [ $total_files -eq 0 ]; then
    echo -e "${YELLOW}[WARNING]${NC} No .${INPUT_EXTENSION} files found in: $WORK_DIR"
    exit 0
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
echo ""

for input_file in "${input_files[@]}"; do
    current_count=$((current_count + 1))

    # Generate output filename
    basename="${input_file%.*}"
    if [ -n "$OUTPUT_DIR" ]; then
        output_file="${OUTPUT_DIR}/$(basename "$basename")${OUTPUT_SUFFIX}.${OUTPUT_FORMAT}"
    else
        output_file="${basename}${OUTPUT_SUFFIX}.${OUTPUT_FORMAT}"
    fi

    # Display progress
    if [ "$QUIET_MODE" = false ]; then
        printf "\r${BLUE}[%d/%d]${NC} Processing: %-40s" "$current_count" "$total_files" "$input_file"
    fi

    # Process the image
    log_message "Processing: $input_file"

    if process_single_image "$input_file" "$output_file" "$APPLY_ENHANCEMENTS"; then
        success_count=$((success_count + 1))
        log_message "  SUCCESS: Created $output_file ($(get_file_size_human "$output_file"))"

        if [ "$QUIET_MODE" = false ]; then
            printf " ${GREEN}[OK]${NC}\n"
        fi
    else
        failed_count=$((failed_count + 1))
        log_message "  FAILED: Could not process $input_file"

        if [ "$QUIET_MODE" = false ]; then
            printf " ${RED}[FAILED]${NC}\n"
        fi
    fi
done

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
