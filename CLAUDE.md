# CLAUDE.md - Roof Measurement Tool (CARDS WORKTREE)

## 🎯 **WORKTREE FOCUS: Material Calculator ONLY**

**⚠️ CRITICAL: Focus ONLY on the Material Calculator section (Stories, Difficulty, Profit Margin, Crew Count, spacing inputs, wire buffer). DO NOT modify sidebar, maps, or measurement tools.**

## 🏗️ **Project Overview**
**Purpose**: Professional roof measurement tool for calculating materials and costs  
**Main File**: `index.html` (NOT roof-measurement-tool.html)  
**Tech Stack**: Google Maps API, vanilla JavaScript, HTML/CSS  
**Architecture**: Left sidebar (400px) + map container layout  

## 🧮 **Material Calculator Section - YOUR FOCUS AREA**

### **Configuration Inputs**
- **Stories Dropdown**: 1, 2, 3+ story options with multipliers
  - 1 Story: 1.0x multiplier
  - 2 Story: 1.3x multiplier  
  - 3+ Story: 1.6x multiplier

- **Difficulty Dropdown**: Impact on labor costs
  - Easy: 0.8x multiplier (simple rooflines)
  - Medium: 1.0x multiplier (standard complexity)
  - Hard: 1.3x multiplier (complex rooflines)
  - Extreme: 1.6x multiplier (very complex rooflines)

- **Profit Margin Input**: Percentage field (default 35%)
  - Applied to total material + labor costs
  - Configurable by user for different job types

- **Crew Count Dropdown**: 1-4 crews
  - Affects labor calculation speed
  - More crews = higher total labor cost

### **Spacing Configuration**
- **Light Spacing**: Distance between LED lights (inches)
  - Affects total number of lights needed
  - Typical values: 6", 8", 12"

- **Clip Spacing**: Distance between mounting clips (inches)  
  - Affects total number of clips needed
  - Typical values: 12", 18", 24"

- **Wire Buffer**: Extra wire percentage for installation
  - Accounts for routing, connections, waste
  - Typical values: 10-20%

## 💰 **Business Logic - Material Calculator**

### **Pricing Structure** 
```javascript
const basePricing = {
    ledLight: 0.85,    // Per light
    wire: 0.18,        // Per foot
    clip: 0.32,        // Per clip
    laborRate: 1.50    // Per foot base rate
};

const complexityMultipliers = {
    stories: { 1: 1.0, 2: 1.3, 3: 1.6 },
    difficulty: { easy: 0.8, medium: 1.0, hard: 1.3, extreme: 1.6 }
};
```

### **Calculation Flow**
1. **Get Measurements**: Total distances from measurement tools
2. **Calculate Quantities**:
   - Lights needed = (total distance × 12) / light spacing
   - Clips needed = (total distance × 12) / clip spacing  
   - Wire length = total distance × (1 + wire buffer %)
3. **Apply Multipliers**:
   - Story multiplier affects labor cost
   - Difficulty multiplier affects labor cost
   - Crew count multiplies labor cost
4. **Calculate Totals**:
   - Material costs = lights + clips + wire
   - Labor cost = distance × labor rate × story × difficulty × crews
   - Subtotal = materials + labor
   - Profit = subtotal × profit margin %
   - **Final Total = subtotal + profit**

### **Real-time Updates**
- Calculator updates automatically when:
  - User changes any dropdown/input value
  - New measurements are added
  - Measurements are deleted or modified

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

.item-row {
    /* Individual calculation row */
}

.item-label, .item-value {
    /* Label and value styling */
}

.total-row {
    /* Final total styling */
}
```

## 🚫 **DO NOT MODIFY**

### **Areas Outside Your Scope**
- **Sidebar Layout**: Width, positioning, overall structure
- **Property Address Section**: Address input and Load Property button
- **Measurement Tools**: Perimeter, Ridge, Ground buttons
- **Distance Results**: Measurement display sections
- **Map Container**: Google Maps integration and controls
- **Zoom Tools**: Custom zoom controls and area selection

### **Files to Avoid**
- Any Google Maps JavaScript code
- Measurement tool event handlers
- Address search functionality
- Zoom control implementations

## 🧭 **Development Guidelines**

### **Code Standards**
- Maintain existing CSS class naming conventions
- Keep material calculator responsive within sidebar
- Use vanilla JavaScript (no frameworks)
- Follow existing color scheme and typography

### **State Management**
```javascript
// Key variables for material calculator
let totalDistance = 0;
let currentConfig = {
    stories: 1,
    difficulty: 'medium',
    profitMargin: 35,
    crewCount: 1,
    lightSpacing: 12,
    clipSpacing: 18,
    wireBuffer: 15
};
```

### **Testing Your Changes**
```bash
cd /Users/apple/roof-worktree-cards
python3 -m http.server 8080
# Open: http://localhost:8080/index.html
```

### **Testing Checklist**
- [ ] All dropdown values update calculations correctly
- [ ] Profit margin input accepts valid percentages
- [ ] Wire buffer percentage applies correctly
- [ ] Real-time updates work when measurements change
- [ ] Final totals calculate accurately
- [ ] Calculator stays within sidebar bounds
- [ ] No interference with measurement or map functionality

## 🚨 **Important Notes**

### **Scope Limitations** 
- **ONLY modify** the Material Calculator section
- **DO NOT touch** any Google Maps code
- **DO NOT modify** measurement tools or sidebar layout
- **DO NOT change** address search or zoom functionality

### **Integration Points**
- Calculator receives total distance from measurement system
- Updates happen via `updateMaterialEstimate()` function
- Configuration changes trigger automatic recalculation

---

*Worktree: Cards (Material Calculator Focus)*  
*Last Updated: November 2, 2025*