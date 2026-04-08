#!/bin/bash
# Auto-push local progress to GitHub Gist for phone sync
# Run this after studying on the Mac

GIST_ID="2a6db13fca5e1c86f14a394fe8f1ac32"
PROGRESS_FILE="/tmp/grammar-progress-export.json"

# Export from Chrome/Safari localStorage requires manual export
# For now, this pushes whatever is in progress-sync.json
echo "To sync: open the app → Sync tab → Export → save file"
echo "Then run: gh gist edit $GIST_ID -f progress.json < /path/to/exported-file.json"
