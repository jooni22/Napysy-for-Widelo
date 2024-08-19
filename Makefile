SHELL := /bin/bash

.PHONY: install check_dependencies install_python_deps install_system_deps install_mpv transcribe test test_all clean rename

install: check_dependencies install_python_deps
	@echo "Setting execute permissions for widelo.sh..."
	@chmod +x widelo.sh
	@if ! env | grep -q DEEPGRAM_API_KEY; then \
		echo "DEEPGRAM_API_KEY environment variable not found."; \
		echo "Please set it using one of the following methods:"; \
		echo "1. For temporary use: export DEEPGRAM_API_KEY='your_api_key_here'"; \
		echo "2. For persistent use, add the above line to your ~/.bashrc or ~/.bash_profile"; \
		echo "Then, run 'source ~/.bashrc' or restart your terminal."; \
		exit 1; \
	fi

check_dependencies:
	@echo "Checking system dependencies..."
	@which yt-dlp > /dev/null 2>&1 || { echo "yt-dlp not found. Installing..."; $(MAKE) install_system_deps; }
	@which ffmpeg > /dev/null 2>&1 || { echo "ffmpeg not found. Installing..."; $(MAKE) install_system_deps; }
	@if ! which mpv > /dev/null 2>&1; then \
		if [ -x "./mpv" ] && ./mpv --version > /dev/null 2>&1; then \
			echo "Using local mpv binary."; \
			echo "export PATH=$$PATH:$$(pwd)" >> ~/.bashrc; \
			source ~/.bashrc; \
			echo "Added local mpv to PATH."; \
		else \
			echo "mpv not found or not working. Attempting to install..."; \
			$(MAKE) install_mpv; \
		fi \
	fi

install_python_deps:
	@echo "Installing Python dependencies..."
	pip install -r requirements.txt --break-system-packages

install_system_deps:
	@if [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y yt-dlp ffmpeg; \
	elif [ -f /etc/arch-release ]; then \
		sudo pacman -Syu --noconfirm yt-dlp ffmpeg; \
	elif [ -f /etc/fedora-release ]; then \
		sudo dnf install -y yt-dlp ffmpeg; \
	else \
		echo "Unsupported system. Please install yt-dlp and ffmpeg manually."; \
		exit 1; \
	fi

install_mpv:
	@echo "Attempting to install mpv..."
	@if [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y mpv; \
	elif [ -f /etc/arch-release ]; then \
		sudo pacman -Syu --noconfirm mpv; \
	elif [ -f /etc/fedora-release ]; then \
		sudo dnf install -y mpv; \
	else \
		echo "Unsupported system. Please install mpv manually."; \
		exit 1; \
	fi

transcribe:
	@echo "Do you want to clean the folders before transcribing? [y/N]"
	@read -r response; \
	if [[ $$response =~ ^[Yy]$$ ]]; then \
		$(MAKE) clean; \
	fi
	@echo "Running widelo.sh..."
	./widelo.sh

test:
	@echo "Testing with first video and subtitle..."
	@if [ -f mp4/1.mp4 ] && [ -f srt/1.srt ]; then \
		mpv mp4/1.mp4 --sub-file=srt/1.srt; \
	else \
		echo "Error: mp4/1.mp4 or srt/1.srt not found."; \
	fi

test_all:
	@echo "Testing all videos with subtitles..."
	@count=$$(ls -1 mp4/*.mp4 2>/dev/null | wc -l); \
	if [ $$count -eq 0 ]; then \
		echo "No MP4 files found in mp4/ directory."; \
	else \
		for i in $$(seq 1 $$count); do \
			if [ -f mp4/$$i.mp4 ] && [ -f srt/$$i.srt ]; then \
				echo "Playing video $$i of $$count"; \
				mpv mp4/$$i.mp4 --sub-file=srt/$$i.srt; \
			else \
				echo "Error: mp4/$$i.mp4 or srt/$$i.srt not found."; \
			fi \
		done \
	fi

clean:
	@echo "This will delete all files in mp4, mp3, and srt folders. Are you sure? [y/N]"
	@read -r response; \
	if [[ $$response =~ ^[Yy]$$ ]]; then \
		rm -rf mp4/* mp3/* srt/*; \
		echo "Folders cleaned."; \
	else \
		echo "Operation cancelled."; \
	fi

rename:
	@echo "Renaming files based on titles..."
	@if [ ! -f title.txt ]; then \
		echo "Error: title.txt not found."; \
		exit 1; \
	fi
	@while IFS= read -r line; do \
		number=$$(echo "$$line" | cut -d' ' -f1); \
		title=$$(echo "$$line" | cut -d' ' -f2-); \
		sanitized_title=$$(echo "$$title" | \
			sed 'y/ĄĆĘŁŃÓŚŹŻąćęłńóśźż/ACELNOSZZacelnoszz/' | \
			tr -cd '[:alnum:][:space:],.' | \
			tr '[:space:],.' '_' | \
			tr -s '_' | \
			tr '[:upper:]' '[:lower:]' | \
			sed 's/_*$$//'); \
		if [ -f "mp4/$$number.mp4" ]; then \
			mv "mp4/$$number.mp4" "mp4/$$sanitized_title.mp4"; \
			echo "Renamed mp4/$$number.mp4 to mp4/$$sanitized_title.mp4"; \
		fi; \
		if [ -f "srt/$$number.srt" ]; then \
			mv "srt/$$number.srt" "srt/$$sanitized_title.srt"; \
			echo "Renamed srt/$$number.srt to srt/$$sanitized_title.srt"; \
		fi; \
		if [ -f "mp3/$$number.mp3" ]; then \
			mv "mp3/$$number.mp3" "mp3/$$sanitized_title.mp3"; \
			echo "Renamed mp3/$$number.mp3 to mp3/$$sanitized_title.mp3"; \
		fi; \
	done < title.txt
	@echo "Renaming complete."