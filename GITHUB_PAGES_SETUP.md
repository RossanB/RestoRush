GITHUB PAGES DEPLOYMENT - STEP BY STEP

Your web_build folder is ready! Follow these steps:

STEP 1: Commit and Push to GitHub

If you already have a GitHub repository:
1. Open terminal/command prompt in your project folder
2. Run these commands:
   git add .
   git commit -m "Add web build for GitHub Pages"
   git push

If you DON'T have a GitHub repository yet:
1. Go to https://github.com and sign in
2. Click the "+" icon in top right → "New repository"
3. Name it: resto-rush (or any name you prefer)
4. Make it Public (required for free GitHub Pages)
5. DO NOT check "Initialize with README" (you already have files)
6. Click "Create repository"
7. GitHub will show you commands - run these in your project folder:
   git remote add origin https://github.com/YOUR_USERNAME/resto-rush.git
   git branch -M main
   git push -u origin main

STEP 2: Enable GitHub Pages

1. Go to your GitHub repository page (github.com/YOUR_USERNAME/resto-rush)
2. Click the "Settings" tab (top right of repository page)
3. Scroll down to "Pages" in the left sidebar
4. Under "Source", select "Deploy from a branch"
5. Select:
   - Branch: main
   - Folder: /web_build
6. Click "Save"
7. Wait 1-2 minutes for GitHub to build your site

STEP 3: Access Your Game

Your game will be live at:
https://YOUR_USERNAME.github.io/resto-rush/

Note: It may take a few minutes for the site to be available after enabling Pages.

TROUBLESHOOTING

If the page shows 404:
- Wait 2-3 more minutes (GitHub needs time to build)
- Check that you selected the correct folder (/web_build)
- Verify index.html exists in web_build folder

If game doesn't load:
- Open browser console (F12) to check for errors
- Make sure all files (.pck, .js, .wasm) are in web_build folder
- Try a different browser (Chrome/Firefox recommended)

If you need to update the game:
- Export again from Godot
- Copy new files to web_build folder
- Run: git add web_build/ && git commit -m "Update web build" && git push
- GitHub Pages will automatically update in 1-2 minutes

