from deepgram import Deepgram
from deepgram_captions import DeepgramConverter, srt
import asyncio
import os
import sys

# Initialize Deepgram client
DEEPGRAM_API_KEY = os.environ.get('DEEPGRAM_API_KEY')
if not DEEPGRAM_API_KEY:
    print("Error: DEEPGRAM_API_KEY environment variable is not set.")
    print("Please set it using: export DEEPGRAM_API_KEY='your_api_key_here'")
    sys.exit(1)

dg_client = Deepgram(DEEPGRAM_API_KEY)

async def transcribe_audio(file_path):
    with open(file_path, 'rb') as audio:
        source = {'buffer': audio, 'mimetype': 'audio/mp3'}
        response = await dg_client.transcription.prerecorded(source, {
            'punctuate': True,
            'utterances': True,
         #   'diarize': True,
            'smart_format': True,
            'language': 'pl', 
            'model': 'nova-2',
            #'nova-2', 'whisper-tiny', 'whisper-base', 'whisper-small', 'whisper-medium', 'whisper-large'
        })
    return response

async def mp3_to_srt(input_file):
    try:
        # Create 'srt' directory if it doesn't exist
        os.makedirs('srt', exist_ok=True)
        
        # Generate output file path
        base_name = os.path.basename(input_file)
        name_without_ext = os.path.splitext(base_name)[0]
        output_file = os.path.join('srt', f"{name_without_ext}.srt")
        
        transcription = await transcribe_audio(input_file)
        
        # Use Deepgram Captions library to create SRT
        dg_converter = DeepgramConverter(transcription)
        srt_content = srt(dg_converter, line_length=8)  # Set maximum 8 words per line
        
        with open(output_file, 'w', encoding='utf-8') as srt_file:
            srt_file.write(srt_content)
        print(f"SRT file created successfully: {output_file}")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

# Dodaj nową funkcję do zapisywania tytułu
def save_title(count, title):
    with open('title.txt', 'a', encoding='utf-8') as f:
        f.write(f"{count} {title}\n")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <path_to_mp3_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    asyncio.run(mp3_to_srt(input_file))

# Example usage:
# python wiedlo.py mp3/1.mp3