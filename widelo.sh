#!/bin/bash

# Sprawdzenie i utworzenie katalogów, jeśli nie istnieją
for dir in mp3 mp4 srt; do
    if [ ! -d "$dir" ]; then
        echo "Creating directory: $dir"
        mkdir "$dir"
    fi
done

# Usunięcie istniejącego pliku title.txt, jeśli istnieje
rm -f title.txt

# Sprawdzenie, czy w url.txt jest link do playlisty i jego przetworzenie
if grep -q "list" url.txt; then
    echo "Playlist link found. Extracting individual video links..."
    # Tymczasowy plik dla linków z playlisty
    playlist_file="playlist_url.txt"
    
    # Pobieranie linków z playlisty do playlist_url.txt
    grep "list" url.txt | while read -r playlist_url; do
        yt-dlp --dump-single-json "$playlist_url" 2>/dev/null | grep -oP '"webpage_url": "\K[^"]*' | grep -v "list" >> "$playlist_file"
    done
    
    # Usuwanie linków do playlist z url.txt
    sed -i '/list/d' url.txt
    
    # Łączenie url.txt i playlist_url.txt
    cat "$playlist_file" >> url.txt
    rm "$playlist_file"
    
    echo "Updated url.txt with individual video links from playlist."
fi

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
    
    # Pobranie tytułu filmu
    title=$(yt-dlp --get-title "$url")
    
    # Zapisanie tytułu do pliku title.txt
    echo "$count $title" >> title.txt
    
    # Wykonanie komendy yt-dlp z odpowiednimi parametrami
    yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4" --output "mp4/$count.%(ext)s" "$url"
    
    echo "Processed link $count of $total_links"
    
    # Konwersja MP4 do MP3 używając ffmpeg
    ffmpeg -i "mp4/$count.mp4" -vn -acodec libmp3lame -q:a 2 "mp3/$count.mp3"
    
    echo "Converted $count.mp4 to $count.mp3"
    echo "Executing Python script for transcription on $count.mp3, please wait..."    
    # Wykonanie skryptu Python na pliku MP3
    python3 widelo.py "mp3/$count.mp3"
    
done

# Print the total number of processed links
echo "Processed, converted, and analyzed $total_links files."
echo "Titles saved in title.txt"