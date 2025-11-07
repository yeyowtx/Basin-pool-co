# CLAUDE.md - Roof Measurement Tool (MAIN WORKTREE)

## 🎯 **ACTIVE WORKING FILE: /Users/apple/index.html**

**⚠️ THIS IS NOW THE MASTER FILE FOR ALL WORKTREES**
- **Working URL**: http://localhost:8104/index.html
- **File Path**: `/Users/apple/index.html`
- **Status**: Primary development file - synced across all worktrees
- **Backup System**: Active with git commits and timestamped backups

## 🏗️ **Project Overview**
**Purpose**: Professional roof measurement tool for calculating materials and costs  
**Main File**: `index.html` (NOT roof-measurement-tool.html)  
**Tech Stack**: Google Maps API, vanilla JavaScript, HTML/CSS  
**Architecture**: Left sidebar (400px) + map container layout  

## 🔄 **Worktree Synchronization**
All worktrees now use the same master file:
- `/Users/apple/roof-worktree-cards/index.html` → synced from main
- `/Users/apple/roof-worktree-designing-tool/index.html` → synced from main  
- `/Users/apple/roof-worktree-leftpanel/index.html` → synced from main
- `/Users/apple/roof-worktree-maps/index.html` → synced from main

## 🧮 **Material Calculator Features**

### **Current Implementation**
- **Light Spacing**: 6", 12", 18", 24" options
- **Clip Spacing**: 6", 12", 18", 24" options  
- **Wire Buffer**: Percentage input (default 10%)
- **Material Costs**: Lights ($0.75), Wire ($0.18/ft), Clips ($0.25)

### **TARGET FEATURES TO IMPLEMENT**
1. **✓ Check Mark Next to Total Cost**
   - Click to enable reverse margin calculation
   - Input total cost → automatically adjust margin
   - Visual feedback with check mark icon

2. **📖 Guide Icon Next to Measurement Tools**
   - Help icon with base64 image
   - Click to show measurement instructions
   - Tooltip or modal with usage guide

3. **🚫 Remove All Emojis**
   - Replace emoji icons with text or symbols
   - Clean, professional appearance
   - Better accessibility

## 💰 **Business Logic - Material Calculator**

### **Pricing Structure** 
```javascript
const MATERIAL_COSTS = {
    light: 0.75,    // Per light
    wire: 0.18,     // Per foot
    clip: 0.25      // Per clip
};
```

### **Calculation Flow**
1. **Get Measurements**: Total distances from measurement tools
2. **Calculate Quantities**:
   - Lights needed = (total distance × 12) / light spacing
   - Clips needed = (total distance × 12) / clip spacing  
   - Wire length = total distance × (1 + wire buffer %)
3. **Calculate Costs**:
   - Material costs = lights + clips + wire
   - **Final Total = material costs**

## 🛠️ **Development Workflow**

### **Backup Commands**
```bash
# Quick backup before changes
./backup-script.sh "Description of changes"

# Emergency backup
cp index.html .backups/emergency_$(date '+%H%M%S').html

# Git commit
git add index.html && git commit -m "Your changes"
```

### **Testing Setup**
```bash
cd /Users/apple
python3 -m http.server 8104
# Open: http://localhost:8104/index.html
```

### **File Sync Command**
```bash
# Sync main file to all worktrees
./sync-worktrees.sh
```

## 🎨 **CSS Classes - Material Calculator**

```css
.material-calculator {
    /* Calculator container styling */
}

.calculator-config {
    /* Configuration inputs container */
}

.material-items {
    /* Results display container */
}

.result-item {
    /* Individual calculation row */
}

.total-cost-container {
    /* NEW: Container for total cost with check mark */
}

.check-mark-icon {
    /* NEW: Check mark for margin adjustment */
}

.guide-icon {
    /* NEW: Guide icon for measurement tools */
}
```

## 🚨 **Implementation Notes**

### **Check Mark Feature Requirements**
- Add check mark icon (✓) next to total cost
- Click to toggle "reverse calculation mode"
- When active: user inputs desired total → margin adjusts automatically
- Visual state: check mark highlighted when active

### **Guide Icon Requirements**  
- Add guide icon next to "Measurement Tools" title
- Use base64 encoded image or SVG
- Click to show help modal/tooltip
- Content: How to use measurement tools

### **Emoji Removal Requirements**
- Replace 🏠 → "📍" or "Address"
- Replace 📏 → "Tools" or measurement icon
- Replace 🔴/🔵/🟢 → colored text or symbols
- Replace 💡 → "Calculator" or bulb symbol

## 🏆 **CURRENT STATUS: READY FOR DEVELOPMENT**

### **✅ Setup Complete**
- Master file identified: `/Users/apple/index.html`
- Backup system active with git + timestamped copies
- Local server running on port 8104
- All worktrees will be synced to this master file

### **🎯 Next Tasks**
1. Implement check mark next to total cost
2. Add reverse margin calculation logic
3. Create guide icon with help content
4. Remove all emoji characters
5. Test across all worktrees

### **🔧 Technical Notes**
- Keep existing Google Maps integration
- Maintain sidebar layout and measurement tools
- Focus on Material Calculator enhancements only
- Preserve all current functionality

---

*Working File: /Users/apple/index.html*  
*Server: http://localhost:8104/index.html*  
*Last Updated: November 7, 2025*  
*Status: ✅ ACTIVE DEVELOPMENT - Master File for All Worktrees*