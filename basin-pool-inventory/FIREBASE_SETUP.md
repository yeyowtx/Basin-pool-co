# 🔥 Firebase Setup for Real-time Collaboration

## Quick Setup (5 minutes)

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it `basin-pool-inventory`
4. Disable Google Analytics (not needed)
5. Click "Create project"

### Step 2: Set Up Realtime Database
1. In your Firebase project, click "Realtime Database" in the sidebar
2. Click "Create Database"
3. **Choose "Start in test mode"** (for quick setup)
4. Select your preferred location (closest to you)
5. Click "Done"

### Step 3: Get Your Configuration
1. In Firebase Console, click the gear icon → "Project settings"
2. Scroll down to "Your apps" section
3. Click the `</>` icon to add a web app
4. Name it "Basin Pool Inventory"
5. **Don't** check "Firebase Hosting"
6. Click "Register app"
7. **Copy the config object** (looks like this):

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyBqRjKs8ux4V3fU-Zi6L_EXAMPLE_KEY",
  authDomain: "basin-pool-inventory.firebaseapp.com",
  databaseURL: "https://basin-pool-inventory-default-rtdb.firebaseio.com/",
  projectId: "basin-pool-inventory",
  storageBucket: "basin-pool-inventory.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890example"
};
```

### Step 4: Update Your App
1. Open `config.js` in your project
2. Replace the `FIREBASE` section with your actual config:

```javascript
FIREBASE: {
    apiKey: "your_actual_api_key_here",
    authDomain: "your-project.firebaseapp.com",
    databaseURL: "https://your-project-default-rtdb.firebaseio.com/",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789012",
    appId: "1:123456789012:web:abcdef1234567890example"
},
```

3. Save the file

### Step 5: Test It Works
1. Open `index.html` in your browser
2. You should see "🟢 Connected" in the top right
3. Open the same page in another browser tab
4. Make changes in one tab - they should appear instantly in the other!

## 🚀 Deploy to Netlify (2 minutes)

### Option A: Drag & Drop
1. Go to [Netlify](https://netlify.com)
2. Drag your entire project folder to Netlify
3. Get your URL and share with team!

### Option B: GitHub Integration
1. Commit your changes to GitHub
2. Connect Netlify to your GitHub repo
3. Auto-deploy on every change

## 🔒 Security Rules (Production)

Once you've tested everything works, update your Firebase Realtime Database rules:

1. Go to Firebase Console → Realtime Database → Rules
2. Replace with these rules:

```json
{
  "rules": {
    "inventory": {
      ".read": true,
      ".write": true
    },
    "presence": {
      ".read": true,
      ".write": true,
      "$uid": {
        ".validate": "newData.hasChildren(['id', 'name', 'online'])"
      }
    }
  }
}
```

3. Click "Publish"

## ✅ What You Get

✅ **Real-time collaboration** - Multiple people can edit simultaneously  
✅ **Live presence indicators** - See who's online  
✅ **Automatic sync** - Changes appear instantly on all devices  
✅ **Offline support** - Works even when internet is down  
✅ **Conflict resolution** - Handles simultaneous edits gracefully  
✅ **Mobile-friendly** - Works on phones, tablets, laptops  

## 🔧 Troubleshooting

**"🔴 Offline" status:**
- Check your Firebase config is correct
- Verify database URL ends with your project name
- Ensure Realtime Database is created (not Firestore)

**Changes not syncing:**
- Check browser console for errors
- Verify database rules allow read/write
- Try refreshing the page

**Can't see other users:**
- Presence might be disabled in config.js
- Check `FIREBASE_SYNC.PRESENCE_ENABLED: true`

## 🎯 You're Done!

Your team can now collaborate in real-time on the inventory tracker. Just share the URL and everyone will see live updates!