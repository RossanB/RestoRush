HOW TO CONVERT MP3 FILES TO OGG FOR WEB EXPORT

MP3 files can cause crashes in Godot web exports. OGG Vorbis is the recommended format.

METHOD 1: USING AUDACITY (FREE, RECOMMENDED)

1. Download Audacity: https://www.audacityteam.org/download/
2. Install and open Audacity
3. For each MP3 file:
   - File > Open > Select your MP3 file
   - File > Export > Export as OGG
   - Choose location and save
   - Replace the .mp3 file with the .ogg file in your sfx folder
4. Update file names in Godot project

METHOD 2: ONLINE CONVERTER (QUICKEST)

1. Go to: https://convertio.co/mp3-ogg/ or https://cloudconvert.com/mp3-to-ogg
2. Upload your MP3 file
3. Convert to OGG
4. Download the converted file
5. Replace the .mp3 file in your sfx folder with the .ogg file
6. Rename to match (remove .mp3, add .ogg)

METHOD 3: FFMPEG (COMMAND LINE)

If you have FFMPEG installed:
ffmpeg -i "input.mp3" -c:a libvorbis "output.ogg"

FILES TO CONVERT:

All files in sfx/ folder:
- 1 Hour of Nintendo Cooking Music .mp3 → .ogg
- FRIDGE OPEN.mp3 → .ogg
- FRIDGE CLOSE.mp3 → .ogg
- kitchen cupboard open.mp3 → .ogg
- kitchen cupboard close.mp3 → .ogg
- cutting board.mp3 → .ogg
- mixer.mp3 → .ogg
- OVEN.mp3 → .ogg
- FRYING.mp3 → .ogg
- FAUCET.mp3 → .ogg
- bell-ring-390294.mp3 → .ogg
- MONEY.mp3 → .ogg
- angry-grunt-103204.mp3 → .ogg
- hmph-338183.mp3 → .ogg
- pencil-writing-on-paper-84424.mp3 → .ogg

AFTER CONVERTING:

1. Replace all .mp3 files with .ogg versions in sfx/ folder
2. Update audio_manager.gd file paths (already done - code now tries .ogg first)
3. Re-export your game
4. Test the web build

TEMPORARY FIX (DISABLE BACKGROUND MUSIC):

If you want to test without converting, you can temporarily disable background music by commenting out the play_background_music() call in _ready().

