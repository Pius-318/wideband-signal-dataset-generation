# RF Signal Spectrogram Dataset Generation Tool

## 📋 Project Overview

This project provides a MATLAB script for generating radio frequency (RF) signal spectrogram datasets for semantic segmentation tasks. The script can generate synthetic signals containing 9 different modulation types (BPSK, QPSK, 8PSK, 16QAM, 64QAM, FM, AM-DSB, AM-SSB, MSK) and automatically generate corresponding spectrograms and multi-class semantic segmentation labels.

## ✨ Key Features

- **Multiple Modulation Types**: Supports 9 common digital and analog modulation types
- **Automatic Label Generation**: Multi-class semantic segmentation label generation based on energy thresholding and morphological processing
- **Parameter Randomization**: Supports random selection of center frequency, symbol rate, signal duration, and start time
- **Spectrogram Generation**: Generates high-quality spectrograms using MATLAB's `pspectrum` function
- **Parameter Recording**: Automatically saves detailed parameters for each signal to CSV files
- **Noise Addition**: Automatically adds complex Gaussian white noise to simulate real-world conditions

## 📁 File Structure

```
datasetOfMatlab/
├── dataset_9_new_1.m          # Main dataset generation script ⭐
├── MyRcos.mat                  # Pulse shaping filter coefficients file ⭐
├── validate_labels.m           # Label validation function (optional)
└── README.md                   # This file
```

**⭐ Marked files are required**

## 🔧 System Requirements

### MATLAB Version
- MATLAB R2018b or higher

### Required MATLAB Toolboxes

1. **Signal Processing Toolbox**
   - `pspectrum()` - Time-frequency analysis
   - `pskmod()` - PSK modulation
   - `qammod()` - QAM modulation
   - `fmmod()` - FM modulation
   - `ammod()` - AM modulation
   - `ssbmod()` - SSB modulation
   - `mskmod()` - MSK modulation
   - `wgn()` - White Gaussian noise generation

2. **Image Processing Toolbox**
   - `ind2rgb()` - Indexed image to RGB conversion
   - `imwrite()` - Image writing
   - `imresize()` - Image resizing
   - `bwareaopen()` - Morphological operations
   - `imfill()` - Filling operations
   - `imclose()` - Closing operations

3. **Statistics and Machine Learning Toolbox**
   - `prctile()` - Percentile calculation

## 🚀 Quick Start

### 1. Preparation

1. Ensure all required files are in the same directory:
   ```
   dataset_9_new_1.m
   MyRcos.mat
   ```

2. Check MATLAB toolbox installation:
   ```matlab
   ver  % View installed toolboxes
   ```

### 2. Configure Output Paths

Before running the script, modify the following paths (lines 58, 509, 749) to your actual paths:

```matlab
% Parameter storage directory
paramDir = 'C:/Users/Pius/Desktop/MyTry/MyTry/MyDataSet/Params/';

% Noisy spectrogram save path
Imagename = sprintf('C:/Users/Pius/Desktop/MyTry/MyTry/MyDataSet/ImageOfSigAndNoise/Signal_%d.jpg', SampleNumIter);

% Label image save path
Labelname = sprintf('C:/Users/Pius/Desktop/MyTry/MyTry/MyDataSet/ImageOfSig/Signal_%d.png', SampleNumIter);
```

### 3. Run the Script

Execute in the MATLAB command window:

```matlab
dataset_9_new_1
```

Or simply double-click the `dataset_9_new_1.m` file to open it in the MATLAB editor, then click the "Run" button.

## ⚙️ Parameter Configuration

### Core Parameters (Lines 23-30)

```matlab
imageSize = [1024 741];              % Spectrogram size [frequency bins, time frames]
sampleRate = 2.4e6;                  % Sampling rate 2.4 MHz
duration = 1.8;                       % Signal duration 1.8 seconds
SampleNum = 50;                       % Number of samples to generate
```

### Signal Parameter Ranges

```matlab
% Center frequency set (Hz)
CenterFreqSet = [3e6 8e6 11e6 16e6 22e6 26e6];

% Symbol rate set (sps)
SymbolRateSet = [1.2e3 2.4e3 4.8e3 9.6e3 19.2e3];

% Signal duration set (seconds)
SymbolDurationSet = [0.01 0.03 0.05 0.08 0.1 0.12 0.2];

% Start time set (seconds)
SymbolStartTime = [0.1 0.3 0.5 0.8 1.0 1.2 1.5];
```

### STFT Parameters

```matlab
TimeResolution = 0.01;                % Time resolution 0.01 seconds
% Frequency resolution = sampleRate / imageSize(1) ≈ 2.34 kHz/pixel
```

### Label Generation Parameters (Lines 552-555)

```matlab
energyThreshold = 0.1;                % Energy threshold
boundaryExpansion = 3;                % Boundary expansion pixels
minRegionSize = 2;                    % Minimum region size
adaptiveThreshold = true;             % Enable adaptive thresholding
```

### Pulse Shaping Filter Parameters

```matlab
rolloff = 0.35;                       % Roll-off factor (for all digital modulation types)
```

## 📊 Supported Modulation Types

| Class ID | Modulation Type | Description | Bandwidth Formula |
|----------|----------------|-------------|-------------------|
| 1 | BPSK | Binary Phase Shift Keying | `symbolRate × (1 + rolloff)` |
| 2 | QPSK | Quadrature Phase Shift Keying | `symbolRate × (1 + rolloff)` |
| 3 | 8PSK | 8-Phase Shift Keying | `symbolRate × (1 + rolloff)` |
| 4 | 16QAM | 16-Quadrature Amplitude Modulation | `symbolRate × (1 + rolloff)` |
| 5 | 64QAM | 64-Quadrature Amplitude Modulation | `symbolRate × (1 + rolloff)` |
| 6 | FM | Frequency Modulation | `2 × (fDev + symbolRate/2)` |
| 7 | AM-DSB | Double Sideband Amplitude Modulation | `2 × symbolRate` |
| 8 | AM-SSB | Single Sideband Amplitude Modulation | `symbolRate` |
| 9 | MSK | Minimum Shift Keying | `symbolRate × 1.5` |

**Note**: In the label matrix, `0` represents background (no signal), and `1-9` represent the corresponding modulation type class IDs.

## 📤 Output File Description

### 1. Spectrogram Images (with Noise)

- **Path**: `ImageOfSigAndNoise/Signal_*.jpg`
- **Format**: JPEG color image
- **Size**: 512×512 pixels
- **Content**: Spectrogram with noise, using `hot` colormap

### 2. Semantic Segmentation Labels

- **Path**: `ImageOfSig/Signal_*.png`
- **Format**: PNG grayscale image
- **Size**: 512×512 pixels
- **Pixel Values**:
  - `0`: Background (no signal)
  - `1-9`: Corresponding modulation type class IDs

### 3. Signal Parameter CSV Files

- **Path**: `Params/Signal_*.csv`
- **Format**: CSV table
- **Fields**:
  - `Type`: Modulation type (string)
  - `Start`: Start time (seconds)
  - `Duration`: Signal duration (seconds)
  - `Freq`: Center frequency (Hz)
  - `Rate`: Symbol rate (sps)
  - `Bandwidth`: Signal bandwidth (Hz)
  - `SampleID`: Sample ID

## 🔍 Label Generation Algorithm

The script uses a hybrid annotation method based on energy thresholding to generate semantic segmentation labels:

1. **Theoretical Region Calculation**: Calculate theoretical time-frequency regions based on signal parameters (center frequency, bandwidth, start time, duration)
2. **Energy Threshold Detection**: Expand search range around theoretical regions and use adaptive energy thresholding to detect actual signal regions
3. **Morphological Processing**: Remove small noise regions, fill holes, and connect adjacent regions
4. **Hybrid Annotation Strategy**:
   - If energy detection succeeds, use detection results
   - If energy detection fails, fall back to theoretical regions (with reduced range)
5. **Post-processing Optimization**: Remove isolated pixels

## 🛠️ Advanced Usage

### Modify Number of Generated Samples

```matlab
SampleNum = 100;  % Modify line 30 to generate 100 samples
```

### Modify Spectrogram Resolution

```matlab
imageSize = [2048 1482];  % Modify line 23 to increase resolution
```

### Enable Label Validation

Uncomment line 756:

```matlab
validate_labels(activatedSignals, Signal, sampleRate, SymbolRateSet);
```

### Customize Noise Power

Modify line 496 to add noise with different power levels:

```matlab
% Current: 0 dBW
Noise = wgn(1,length(Signal),0,'complex');

% Modified to: -5 dBW
Noise = wgn(1,length(Signal),-5,'complex');
```

## ⚠️ Common Issues

### 1. Cannot Find `MyRcos.mat` File

**Error Message**:
```
Error using load
Unable to read file 'MyRcos.mat'
```

**Solution**:
- Ensure `MyRcos.mat` file is in the same directory as the script
- Check if the file path is correct

### 2. Undefined Function Error

**Error Message**:
```
Undefined function 'pspectrum' for input arguments of type 'double'
```

**Solution**:
- Install MATLAB Signal Processing Toolbox
- Check if toolboxes are properly installed using the `ver` command

### 3. Output Directory Permission Issues

**Error Message**:
```
Error using mkdir
Access is denied
```

**Solution**:
- Check write permissions for the output path
- Modify the path in the script to a directory with write permissions
- Ensure the directory path format is correct (Windows uses `/` or `\`)

### 4. Out of Memory

**Error Message**:
```
Out of memory
```

**Solution**:
- Reduce the value of `SampleNum`
- Lower the resolution of `imageSize`
- Generate the dataset in batches

### 5. Label Generation Failure

**Warning Message**:
```
Warning: Energy detection failed for signal XXX, using theoretical region
```

**Possible Causes**:
- Signal energy too low
- Noise too high
- Unreasonable parameter settings

**Solution**:
- Adjust `energyThreshold` parameter (lower the threshold)
- Increase `boundaryExpansion` value
- Check if signal parameters are reasonable

## 📈 Dataset Statistics

According to the default configuration (`SampleNum=50`), the generated dataset contains:

- **Total Samples**: 50
- **Spectrogram Size**: 1024×741 (original), 512×512 (output)
- **Time Resolution**: 0.01 seconds/frame
- **Frequency Resolution**: ≈2.34 kHz/pixel
- **Number of Modulation Types**: 9
- **Each Sample Contains**: 1 randomly selected modulation type signal

## 📝 Important Notes

1. **Path Configuration**: Be sure to modify the output paths in the script (lines 58, 509, 749) before running
2. **Randomness**: Each run generates a different dataset (uses random number generator)
3. **Computation Time**: Generating 50 samples takes approximately a few minutes (depends on computer performance)
4. **Storage Space**: Each sample occupies approximately a few MB of space; ensure sufficient disk space
5. **Label Quality**: Label generation depends on energy thresholding; for low SNR signals, parameter adjustment may be necessary

## 🔄 Version History

- **v1.0** (Current Version)
  - Support for 9 modulation types
  - Automatic label generation
  - Parameter recording functionality
  - Adaptive threshold detection

## 📄 License

This project is for academic research use only.

## 👥 Contributing

For questions or suggestions, please submit an Issue or Pull Request.

## 📧 Contact

For technical questions, please contact through:
- Submit a GitHub Issue
- Send email to project maintainer

---

**Last Updated**: February 2026

**MATLAB Version Requirement**: R2018b or higher
