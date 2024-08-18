#!/bin/bash

# Wczytanie linków do tablicy
mapfile -t links < url.txt

# Liczba linków
total_links=${#links[@]}

# Przetwarzanie każdego URL-a
for ((i=0; i<${#links[@]}; i++))
do
    # Numer bieżącego linku (indeksowanie od 1)
    count=$((i+1))
    
    # Pobranie URL-a z tablicy
    url="${links[i]}"
    
    # Wykonanie komendy yt-dlp z odpowiednimi parametrami
    yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4" --output "mp4/$count.%(ext)s" "$url"
    
    echo "Processed link $count of $total_links"
    
    # Konwersja MP4 do MP3 używając ffmpeg
    ffmpeg -i "mp4/$count.mp4" -vn -acodec libmp3lame -q:a 2 "mp3/$count.mp3"
    
    echo "Converted $count.mp4 to $count.mp3"
    echo "Executed Python script for transcription on $count.mp3, please wait..."    
    # Wykonanie skryptu Python na pliku MP3
    python3 widelo.py "mp3/$count.mp3"
    
done

# Print the total number of processed links
echo "Processed, converted, and analyzed $total_links files."