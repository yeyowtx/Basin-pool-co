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

## 🏆 **CURRENT STATUS: ENHANCED & OPTIMIZED**

### **✅ Recently Completed Features (Nov 6, 2025)**
- **Wire Configuration Overhaul**: Clean tabbed interface (Configuration/Inventory)
- **Product SKU Integration**: Real SKU numbers for easy ordering (29551120, 29551500, etc.)
- **SPT-1 Wire System**: Complete dual-wire system with connectors and pricing
- **Inventory Tracking**: C9 spools (1000ft) and SPT-1 wire (100ft increments) management
- **Labor Complexity Simplification**: "How difficult is this project?" with real examples
- **Mounting Clips Revolution**: Measurement-based calculation with configurable spacing
- **Clean UI Design**: Removed emojis, simplified interfaces, professional appearance
- **Accurate Calculations**: Clips now calculate as (distance × 12) ÷ spacing

### **🧮 Current Material Calculator Features**
- **LED Color Mixing**: Professional color selection with percentage splits
- **C9 Wire System**: 1000ft spool tracking with 15% buffer configuration
- **SPT-1 Wire System**: Extension wire with male/female plugs and splitters
- **Mounting Clips**: Automatic calculation based on spacing (default 18")
- **Crew-Based Labor**: Configurable crews with complexity multipliers (1x-3x)
- **Sales Intelligence**: Target/minimum margin system for negotiations
- **Inventory Management**: Real-time stock tracking with SKU references
- **Real-time Updates**: All changes instantly update calculations

### **🛠️ Technical Architecture**
```javascript
projectConfig = {
    // LED Configuration
    ledColor1: 'warm-white',
    ledColor2: null,
    colorSplit: 100,
    lightSpacing: 12,
    
    // Wire Systems
    wireBuffer: 15,
    clipSpacing: 18,
    spt1WireNeeded: 0,
    spt1MalePlugs: 0,
    spt1FemalePlugs: 0,
    spt1Splitters: 0,
    
    // Inventory Tracking
    c9SpoolInventory: 0,
    spt1WireInventory: 0,
    
    // Labor & Pricing
    complexityMultiplier: 1.0,
    crewCount: 1,
    crewRate: 1.50,
    currentMargin: 35,
    marginFloor: 35,
    marginCeiling: 65,
    
    // Hardware Selection
    selectedClips: ['c9-circle'],
    includeTakedown: false
};
```

### **📊 Calculation Logic**
```javascript
// Accurate measurement-based calculations
lightsNeeded = Math.ceil((totalDist * 12) / lightSpacing);
clipsNeeded = Math.ceil((totalDist * 12) / clipSpacing);
wireNeeded = Math.ceil(totalDist * (1 + wireBuffer / 100));
spoolsNeeded = Math.ceil(wireNeeded / 1000);

// Labor with complexity
laborCost = totalDist * crewRate * crewCount * complexityMultiplier;
```

### **🎯 Ready for Production Use**
- **Professional Sales Tool**: Clean interface for client presentations
- **Accurate Material Estimates**: Measurement-driven calculations
- **Inventory Management**: Track stock levels with real SKUs
- **Flexible Pricing**: Margin sliders for negotiation
- **Hardware Expertise**: Real product catalogs and specifications
- **VA Training Ready**: Simple, intuitive interface design

### **🔄 Recent Bug Fixes**
- ✅ Fixed clip calculations to be measurement-based (not manual entry)
- ✅ Removed duplicate functions causing conflicts
- ✅ Simplified wire configuration UI for better usability
- ✅ Added automatic inventory adjustment functions
- ✅ Enhanced labor complexity with real-world examples

---

*Worktree: Main - Material Calculator Enhanced*  
*Last Updated: November 6, 2025*  
*Status: ✅ OPTIMIZED - Production Ready with Enhanced Calculations*