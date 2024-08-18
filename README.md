# YouTube Video Transcription Project

This project downloads YouTube videos, converts them to MP3, and generates transcriptions using the Deepgram API.

## Prerequisites

- Python 3.7+
- Make
- Git (for cloning the repository)
- Deepgram API key set as an environment variable

## Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd <repository-name>
   ```

2. Set up your Deepgram API key as an environment variable:
   ```
   export DEEPGRAM_API_KEY='your_api_key_here'
   ```
   You may want to add this line to your `~/.bashrc` or `~/.bash_profile` for persistence.

3. Install the project dependencies:
   ```
   make install
   ```
   This will install Python dependencies and check for system dependencies (yt-dlp, ffmpeg, mpv).

## Configuration

1. Create a file named `url.txt` in the project root directory.
2. Add YouTube video URLs to `url.txt`, one per line.

## Usage

1. To download videos, convert to MP3, and generate transcriptions:
   ```
   make transcribe
   ```
   This will process all URLs in `url.txt`.

2. To test playback of the first video with subtitles:
   ```
   make test
   ```

3. To test playback of all downloaded videos with subtitles:
   ```
   make test_all
   ```

4. To clean up downloaded files and transcriptions:
   ```
   make clean
   ```

## Output

- Downloaded MP4 videos will be stored in the `mp4/` directory.
- Converted MP3 files will be stored in the `mp3/` directory.
- Generated SRT subtitle files will be stored in the `srt/` directory.

## Note

Ensure you have the right to download and use materials from YouTube. This tool is intended for personal use and should be used in compliance with YouTube's terms of service.