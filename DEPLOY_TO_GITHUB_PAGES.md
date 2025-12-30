QUICK DEPLOYMENT GUIDE - GITHUB PAGES

Your exported files are ready:
- Restaurant Rush.html
- Restaurant Rush.pck
- Restaurant Rush.js
- Restaurant Rush.wasm
- Other supporting files

OPTION 1: EASIEST - Create Separate Web Build Branch

Step 1: Create a web_build folder
- Create a new folder called "web_build" in your project
- Copy all exported files into it:
  * Restaurant Rush.html
  * Restaurant Rush.pck
  * Restaurant Rush.js
  * Restaurant Rush.wasm
  * Restaurant Rush.png
  * Restaurant Rush.icon.png
  * Restaurant Rush.apple-touch-icon.png
  * Restaurant Rush.audio.position.worklet.js
  * Restaurant Rush.audio.worklet.js

Step 2: Push to GitHub
- If you haven't pushed your repo yet:
  git add .
  git commit -m "Add web export"
  git remote add origin https://github.com/YOUR_USERNAME/resto-rush.git
  git push -u origin main

Step 3: Enable GitHub Pages
- Go to your GitHub repository on github.com
- Click "Settings" tab
- Scroll down to "Pages" section
- Under "Source", select "Deploy from a branch"
- Select branch: "main"
- Select folder: "/web_build" (or "/" if files are in root)
- Click "Save"
- Wait 1-2 minutes for deployment

Step 4: Access Your Game
- Your game will be live at:
  https://YOUR_USERNAME.github.io/resto-rush/
- Or if using web_build folder:
  https://YOUR_USERNAME.github.io/resto-rush/web_build/

OPTION 2: QUICKEST - Netlify Drag & Drop

1. Go to https://netlify.com
2. Sign up/login (free)
3. Drag your exported HTML file and all related files into Netlify
4. Your game is live instantly!

OPTION 3: ITCH.IO (Best for Games)

1. Go to https://itch.io
2. Create account
3. Click "Create new project"
4. Upload all exported files
5. Set project type to "HTML"
6. Add description and screenshots
7. Publish

RECOMMENDED: Use Option 1 (GitHub Pages) for school projects

