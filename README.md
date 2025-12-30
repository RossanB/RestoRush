Restaurant Rush - Installation Guide

Requirements:
- Godot Engine 4.5.1 or later
- Windows, macOS, or Linux

Installation Steps:

1. Download Godot Engine
   - Visit https://godotengine.org/download
   - Download Godot 4.5.1 or later for your operating system
   - Extract and run Godot

2. Open the Project
   - Launch Godot Engine
   - Click Import button
   - Navigate to this project folder
   - Select project.godot
   - Click Import and Edit

3. Run the Game
   - Press F5 or click the Play button in the top-right
   - The game will start in the restaurant scene

Troubleshooting:

Game won't start:
- Make sure you're using Godot 4.5.1 or later
- Check that project.godot is in the project root
- Verify the main scene is set correctly (should be resto.tscn)

No sound/music:
- Check that audio files are in the sfx folder
- Verify AudioManager is loaded (check Project then Project Settings then Autoload)

Customers not spawning:
- Check that CustomerManager node exists in resto.tscn
- Verify tables are placed and in the tables group
