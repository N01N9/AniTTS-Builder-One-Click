# AniTTS-Builder One Click

## About

- Summary
  
  This program processes anime videos and subtitles to create Text-to-Speech (TTS) datasets. It extracts and cleans the audio by removing background noise, then slices it into smaller segments. Finally, the program clusters the audio by speaker for easy organization, streamlining the creation of speaker-specific TTS datasets.

  This program operates based on the models from Audio-separator and Speechbrain.

- Developer
  - N01N9

## Installation

This project is developed for a Windows environment. FFmpeg must be installed. Please install CUDA 12.X + CUDNN 9.X versions. 

Just download [AniTTS-Builder-One-Click](https://github.com/N01N9/AniTTS-Builder-One-Click/archive/refs/heads/main.zip) and unzip it. Then, run the batch file.

## Usage

To run this program, you will need an .mp4 file of an anime featuring the character with the voice you desire, as well as a .ass subtitle file that is synced with the .mp4 file. To gather sufficient data, you will need at least one season of anime (approximately 12 episodes, 20 minutes each).

1. Run main.bat. Then, the Gradio web UI will open.

2. Follow the steps in order based on the description in the web UI.

## Precautions

- This program is more likely to function correctly with larger datasets. Therefore, if the animation dataset is insufficient or if you are attempting to extract the voice of a character with limited data, the reliability of the program cannot be guaranteed.

## References

- (https://github.com/nomadkaraoke/python-audio-separator)
- (https://github.com/speechbrain/speechbrain)
- (https://github.com/N01N9/AniTTS-Builder-No-UI)
- (https://github.com/N01N9/AniTTS-Builder-webUI)
