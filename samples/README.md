# Sample Images

This directory contains before/after sample images demonstrating the RAW Photo Batch Processor capabilities.

## Required Images

Add the following images to this directory:

### Before & After Comparisons
- `portrait-before.jpg` / `portrait-after.jpg` - Portrait with face detection
- `landscape-before.jpg` / `landscape-after.jpg` - Landscape scene
- `night-before.jpg` / `night-after.jpg` - Night/high ISO photo
- `macro-before.jpg` / `macro-after.jpg` - Macro photography

### Preset Demos
- `wedding-before.jpg` / `wedding-after.jpg` - Wedding preset
- `cinematic-before.jpg` / `cinematic-after.jpg` - Cinematic preset
- `bw-before.jpg` / `bw-after.jpg` - Black & White preset
- `vintage-before.jpg` / `vintage-after.jpg` - Vintage preset

### Feature Demos
- `underexposed-before.jpg` / `underexposed-after.jpg` - Auto exposure correction
- `overexposed-before.jpg` / `overexposed-after.jpg` - Highlight recovery
- `soft-before.jpg` / `soft-after.jpg` - Adaptive sharpening
- `no-watermark.jpg` / `with-watermark.jpg` - Watermark feature

### Batch Processing
- `batch-processing.gif` - Animated GIF of batch processing progress

## Generating Samples

```bash
# Generate a before/after pair
convert photo.CR2 -resize 800x600 samples/portrait-before.jpg
./process_raw_photos.sh photo.CR2 --preset portrait --resize 800x600 --output-dir samples/
mv samples/photo.jpg samples/portrait-after.jpg

# Generate all preset samples from one RAW file
for preset in natural vivid portrait landscape cinematic bw vintage; do
  ./process_raw_photos.sh sample.CR2 --preset $preset --resize 800x600 --output-dir samples/
  mv samples/sample.jpg samples/${preset}-after.jpg
done
```

## Recommended Image Sizes

- Before/After comparisons: 800x600 or 1200x800
- Animated GIFs: 800px width, optimized for web
- Keep file sizes under 500KB for fast README loading
