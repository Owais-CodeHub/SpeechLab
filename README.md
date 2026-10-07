# Moving Average Speech Lab in MATLAB

A simple interactive MATLAB GUI for demonstrating the practical use of **Moving Average Filters** for speech denoising and signal smoothing.

The tool is designed for teaching **Signals and Systems** concepts in the context of real-world signal processing applications.

<p align="center">
  <img src="images/gui.png" alt="Moving Average Speech Lab GUI" width="900">
</p>

---

## Overview

The **Moving Average Speech Lab** provides an interactive way to understand how a moving average filter operates on a real one-dimensional signal.

Instead of studying the filter only through equations, users can:

- record their own voice,
- visualize the speech waveform,
- add Gaussian noise,
- listen to the noisy speech,
- apply a moving average filter,
- change the filter window size,
- compare simple and weighted moving averages,
- visualize the filtered output,
- and listen to the resulting signal.

The tool directly connects the mathematical concepts of

\[
x[n] \rightarrow h[n] \rightarrow y[n]
\]

with a practical speech-processing experiment.

---

# Learning Objective

The main objective of this tool is to demonstrate how a **Moving Average Filter** can reduce rapid fluctuations and noise in a discrete-time signal.

Students can investigate the relationship between:

- input signal \(x[n]\),
- noise signal \(w[n]\),
- noisy signal,
- filter impulse response \(h[n]\),
- moving-average window size,
- filtered output \(y[n]\),
- and the trade-off between smoothing and signal distortion.

---

# Signal Processing Workflow

The experiment follows four simple steps:

### STEP 1 — Voice Input

Record a short speech signal directly using the computer microphone or load an existing audio file.

The recorded speech represents the original input signal:

\[
x[n]
\]

---

### STEP 2 — Add Gaussian Noise

Artificial Gaussian noise is added to the original speech signal.

\[
x_{\text{noisy}}[n] = x[n] + w[n]
\]

where

- \(x[n]\) = original speech signal
- \(w[n]\) = Gaussian noise
- \(x_{\text{noisy}}[n]\) = noisy speech signal

The noise level can be controlled using the **Signal-to-Noise Ratio (SNR)**.

Users can listen to:

- the original voice,
- the generated noise,
- and the noisy voice.

---

### STEP 3 — Apply Moving Average Filter

A moving average filter is applied to the noisy speech signal.

For a \(W\)-point simple moving average filter:

\[
y[n]
=
\frac{1}{W}
\sum_{k=0}^{W-1}
x_{\text{noisy}}[n-k]
\]

For example, a 3-point moving average is

\[
y[n]
=
\frac{x[n]+x[n-1]+x[n-2]}{3}
\]

The corresponding impulse response is

\[
h[n]
=
\left[
\frac{1}{3},
\frac{1}{3},
\frac{1}{3}
\right]
\]

and the system can also be represented as

\[
y[n]=x[n]*h[n]
\]

---

# Weighted Moving Average

The GUI also provides a **Weighted Moving Average** option.

Unlike the simple moving average, all samples do not contribute equally.

For example,

\[
y[n]
=
0.5x[n]
+
0.3x[n-1]
+
0.2x[n-2]
\]

with

\[
h[n]
=
[0.5,\;0.3,\;0.2]
\]

Here, the more recent samples receive greater importance.

This allows students to compare:

| Filter | Main Idea |
|---|---|
| Simple Moving Average | Equal weight for all samples |
| Weighted Moving Average | Different importance for different samples |

---

# STEP 4 — Compare the Signals

The GUI displays the complete processing pipeline:

1. **Original Voice Signal**
2. **Gaussian Noise**
3. **Noisy Voice Signal**
4. **Filtered Voice Signal**

Users can independently play the original, noisy, and filtered signals.

This makes it possible to both **see** and **hear** the effect of the moving average filter.

---

# GUI Features

The MATLAB interface includes:

- Microphone-based voice recording
- Audio-file loading
- Original speech waveform visualization
- Gaussian noise generation
- Adjustable SNR
- Noise waveform visualization
- Noisy speech visualization
- Audio playback
- Moving-average window selection
- Window sizes from 3 to 10 samples
- Simple Moving Average
- Weighted Moving Average
- Filter coefficient display
- Filtered waveform visualization
- Same-length causal filtering
- Reset and replay controls
- Signals-and-systems interpretation using \(x[n]\), \(h[n]\), and \(y[n]\)

---

# GUI Preview

Only one screenshot is required for the repository.

Create the following folder:

```text
images/
