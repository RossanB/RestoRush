Restaurant Rush

PROJECT STORY

Restaurant Rush is a fast-paced restaurant management game developed as a final project for ITE 18. The game puts players in the shoes of a restaurant owner who must manage both the dining area and kitchen simultaneously. Customers arrive with orders, and players must quickly take orders, prepare food using various cooking stations, and serve customers before they lose patience and leave.

The game was designed to challenge players with time management, multitasking, and recipe memorization. As customers arrive in parties of varying sizes, players must efficiently coordinate between the restaurant floor and kitchen to keep everyone satisfied. The game features a dynamic customer system where parties wait for all members to be served before leaving together, adding an extra layer of strategy to order fulfillment.

CONCEPT

Restaurant Rush is a 2D top-down restaurant simulation game that combines elements of time management, cooking simulation, and customer service. Players control a character who moves between two main areas: the restaurant dining room and the kitchen.

Core Gameplay Loop:
1. Customers arrive at tables and wait for the player to take their orders
2. Player takes orders and receives a list of items to prepare
3. Player moves to the kitchen to prepare food using various stations
4. Player must follow recipes to combine ingredients correctly
5. Player returns to serve customers before they lose patience
6. Satisfied customers leave, making room for new ones

Key Features:
- Dual-location gameplay: Seamlessly transition between restaurant and kitchen
- Multiple cooking stations: Fridge, Cabinet, Sink, Cutting Board, Mixer, Oven, and Stove
- Complex recipe system: Combine ingredients in the correct order to create dishes
- Party system: Customers arrive in groups of 1-4 and wait for all members to be served
- Patience system: Customers have limited patience and will leave if orders take too long
- Sound design: Background music and sound effects for immersive gameplay
- State persistence: Game state is saved when transitioning between rooms

Available Dishes:
- Simple items: Donuts, Ice Cream, Sunny Side Up Egg
- Medium complexity: Fries with Drink
- Complex items: Tacos, Pizza, Burgers

DEVELOPMENT STACK

Engine:
- Godot Engine 4.5.1

Programming Language:
- GDScript (Godot's native scripting language)

Key Technologies:
- Godot 4.5 Forward Plus rendering pipeline
- CharacterBody2D for player and customer movement
- Area2D for interaction detection
- AnimatedSprite2D for character animations
- AudioStreamPlayer for sound effects and background music
- Scene management system for room transitions
- Autoload singletons for global state management

Project Structure:
- scripts/: Game logic, customer management, station interactions, recipes
- scenes/: Game scenes (restaurant, kitchen, UI elements, stations)
- assets/: Sprites, audio files, and other game assets
- sfx/: Sound effects for interactions and customer actions

Architecture:
- Singleton pattern for AudioManager, SceneManager, and PlayerDebug
- State machine pattern for customer behavior
- Component-based station system with base class inheritance
- Recipe verification system for cooking mechanics

SETUP INSTRUCTIONS

Requirements:
- Godot Engine 4.5.1 or later
- Windows, macOS, or Linux operating system
- Minimum 2GB RAM
- DirectX 11 / OpenGL 3.3 / Vulkan compatible graphics card

Installation Steps:

1. Download Godot Engine
   - Visit https://godotengine.org/download
   - Download Godot 4.5.1 or later for your operating system
   - Extract the downloaded file to a location of your choice
   - No installation required - Godot runs as a portable executable

2. Open the Project
   - Launch Godot Engine
   - Click the "Import" button in the project manager
   - Navigate to this project folder (resto-rush)
   - Select the project.godot file
   - Click "Import & Edit"

3. Verify Project Settings
   - The project should automatically load with the correct settings
   - Main scene is set to resto.tscn (restaurant scene)
   - Autoload singletons are configured:
     * AudioManager: Handles all audio playback
     * SceneManager: Manages scene transitions and state persistence
     * PlayerDebug: Debug utilities (optional)

4. Run the Game
   - Press F5 or click the "Play" button in the top-right corner
   - The game will start in the restaurant scene
   - Use WASD or Arrow Keys to move
   - Press E to interact with customers and stations

Controls:
- Movement: WASD or Arrow Keys
- Interact: E key
- Debug Position: P key (if PlayerDebug is enabled)

TROUBLESHOOTING

Game won't start:
- Ensure you're using Godot 4.5.1 or later
- Verify that project.godot exists in the project root
- Check that the main scene (resto.tscn) exists and is set correctly
- Look for error messages in the Godot Output panel

No sound or music:
- Verify that audio files exist in the assets/sfx/ folder
- Check Project Settings > Autoload to ensure AudioManager is loaded
- Ensure your system volume is not muted
- Check that audio files are in supported formats (OGG Vorbis recommended)

Customers not spawning:
- Verify that CustomerManager node exists in resto.tscn
- Check that tables are placed in the scene and added to the "tables" group
- Ensure spawn_interval is set correctly in CustomerManager
- Check the Output panel for customer spawning messages

Game crashes or freezes:
- Check system requirements (especially graphics driver compatibility)
- Verify all scene files are properly saved
- Try running the game in debug mode to see error messages
- Ensure all required assets are present in the project

Performance issues:
- Close other applications to free up system resources
- Lower graphics settings in Godot project settings if needed
- Check that you're using a compatible graphics API (Vulkan/OpenGL)

PROJECT INFORMATION

Project Name: Restaurant Rush
Version: 1.0
Developed for: ITE 108 Final Project
Engine: Godot 4.5.1
License: Educational/Personal Use

For questions or issues, refer to the project documentation or contact the development team.
