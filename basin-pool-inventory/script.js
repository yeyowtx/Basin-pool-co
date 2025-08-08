// Basin Pool Co. Inventory Tracker - Real-time Collaborative Edition

// Global state management
let inventoryData = {
    cliff: [],
    tools: [],
    tanks: [],
    pumps: [],
    salt: [],
    heating: [],
    siteprep: [],
    hardware: [],
    projectNotes: '',
    roiTracking: {
        totalRevenue: 0,
        jobsCompleted: 0,
        revenueHistory: []
    }
};

// Firebase and collaboration variables
let database = null;
let currentUser = null;
let isFirebaseReady = false;
let dataRef = null;
let presenceRef = null;
let connectionStatus = 'connecting';

// Auto-save timer
let autoSaveTimer = null;
let cloudSyncTimer = null;
let lastUpdateTimestamp = 0;

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    generateUserId();
    initializeData();
    
    // Always render the initial data first
    renderAllSections();
    updateSummary();
    
    // Wait for Firebase to be ready then initialize
    setTimeout(() => {
        console.log('Firebase check:', CONFIG.FIREBASE_SYNC.ENABLED, window.database, window.Firebase);
        if (CONFIG.FIREBASE_SYNC.ENABLED && window.database && window.Firebase) {
            console.log('Starting Firebase initialization...');
            initializeFirebase();
        } else {
            console.log('Firebase not available, using localStorage fallback');
            // Fallback to local storage
            loadFromLocalStorage();
            startAutoSave();
        }
    }, 1000); // Give Firebase modules time to load
    
    setupEventListeners();
    showConnectionStatus();
    
    if (CONFIG.CLOUD_SYNC.ENABLED) {
        startCloudSync();
    }
});

// Generate unique user ID
function generateUserId() {
    currentUser = {
        id: 'user_' + Math.random().toString(36).substr(2, 9),
        name: 'User ' + Math.floor(Math.random() * 1000),
        color: getRandomColor(),
        joinedAt: Date.now()
    };
}

function getRandomColor() {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD', '#98D8C8'];
    return colors[Math.floor(Math.random() * colors.length)];
}

// Initialize Firebase real-time database
function initializeFirebase() {
    try {
        database = window.database;
        dataRef = window.Firebase.ref(database, 'inventory');
        presenceRef = window.Firebase.ref(database, 'presence');
        
        // Set up real-time data listener
        window.Firebase.onValue(dataRef, (snapshot) => {
            if (snapshot.exists()) {
                const firebaseData = snapshot.val();
                if (firebaseData.lastUpdated > lastUpdateTimestamp) {
                    lastUpdateTimestamp = firebaseData.lastUpdated;
                    // Merge Firebase data with default template to ensure new sections exist
                    inventoryData = mergeWithDefaultData(firebaseData.data);
                    // CRITICAL FIX: Add purchased tools to merged data
                    addNewToolsToInventory();
                    renderAllSections();
                    updateSummary();
                    loadProjectNotes();
                    // Save back to Firebase with new tools included
                    saveToFirebase();
                    showSaveIndicator('Synced from cloud');
                }
            } else {
                // Firebase is empty, save default data to it
                console.log('Firebase is empty, initializing with default data');
                addNewToolsToInventory();
                saveToFirebase();
                renderAllSections();
                updateSummary();
            }
        }, (error) => {
            console.error('Firebase read error:', error);
            connectionStatus = 'disconnected';
            showConnectionStatus();
            // Fallback to local storage
            loadFromLocalStorage();
        });
        
        // Tools will be added when Firebase data loads/syncs
        console.log('Firebase initialization complete - tools will be added during data sync');
        
        // Set up presence system
        if (CONFIG.FIREBASE_SYNC.PRESENCE_ENABLED) {
            setupPresence();
        }
        
        // Handle connection state
        const connectedRef = window.Firebase.ref(database, '.info/connected');
        window.Firebase.onValue(connectedRef, (snapshot) => {
            if (snapshot.val() === true) {
                connectionStatus = 'connected';
                isFirebaseReady = true;
                console.log('Firebase connected');
            } else {
                connectionStatus = 'disconnected';
                console.log('Firebase disconnected');
            }
            showConnectionStatus();
        });
        
        console.log('Firebase real-time collaboration initialized');
        
    } catch (error) {
        console.error('Firebase initialization failed:', error);
        connectionStatus = 'disconnected';
        showConnectionStatus();
        // Fallback to local storage
        loadFromLocalStorage();
        startAutoSave();
    }
}

// Set up user presence tracking
function setupPresence() {
    if (!presenceRef || !currentUser) return;
    
    const userPresenceRef = window.Firebase.ref(database, `presence/${currentUser.id}`);
    
    // Set user as online
    window.Firebase.set(userPresenceRef, {
        ...currentUser,
        online: true,
        lastSeen: window.Firebase.serverTimestamp()
    });
    
    // Remove user when they disconnect
    window.Firebase.onDisconnect(userPresenceRef).remove();
    
    // Listen for presence changes
    window.Firebase.onValue(presenceRef, (snapshot) => {
        updatePresenceDisplay(snapshot.val());
    });
}

// Update presence display
function updatePresenceDisplay(presenceData) {
    const presenceContainer = document.getElementById('userPresence');
    const presenceUsers = document.getElementById('presenceUsers');
    
    if (!presenceData || !presenceContainer || !presenceUsers) return;
    
    const onlineUsers = Object.values(presenceData).filter(user => user.online);
    
    if (onlineUsers.length > 0) {
        presenceContainer.style.display = 'flex';
        presenceUsers.innerHTML = onlineUsers.map(user => 
            `<span class="presence-user" style="background-color: ${user.color}20; border-color: ${user.color};">${user.name}</span>`
        ).join('');
    } else {
        presenceContainer.style.display = 'none';
    }
}

// Initialize default inventory data
function initializeData() {
    // Complete Project Shopping List - Cliff's Pool + Deck ($3,116.67 Total)
    inventoryData.cliff = [
        // ✅ ALREADY PURCHASED - EBAY ($599.43) - Pool System Components
        { name: 'Filter Balls', actualPrice: 24.79, quantity: 1, usage: 'per-job', location: 'online', link: '', status: 'purchased', notes: 'MAQIHAN 50PCS Pool Filter Balls // Replaces 100 lbs pool filter sand for filtration system' },
        { name: 'Water Transfer Pump', actualPrice: 49.99, quantity: 1, usage: 'per-job', location: 'online', link: '', status: 'purchased', notes: 'VEVOR Water Transfer Removal Pump 360 GPH // Water transfer operations and tank filling' },
        { name: 'Sand Filter Pump', actualPrice: 230.90, quantity: 1, usage: 'per-job', location: 'online', link: '', status: 'purchased', notes: 'INTEX 26641EG Krystal Clear Sand Filter 4,400 GPH // Main pool pump and filtration system' },
        { name: 'Propane Heater', actualPrice: 299.99, quantity: 1, usage: 'per-job', location: 'online', link: '', status: 'purchased', notes: 'Outdoor Propane Tankless Water Heater 120,000 BTU 5.3 gallon // Pool water heating system' },
        
        // 🛒 HOME DEPOT - ELECTRICAL ($98.98)
        { name: '2-Gang FSC Box', actualPrice: 8.74, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Cantex 1/2 in. 2-Gang FSC Box // Electrical junction box for pump and heater connections' },
        { name: '4-Gang Deep Box', actualPrice: 18.88, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Commercial Electric 4-Gang Extra Deep Box // Main electrical distribution box' },
        { name: 'Plastic Anchors', actualPrice: 9.91, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Triple Grip Plastic Anchors 15-pack // Securing electrical boxes to concrete/masonry' },
        { name: '1-Gang PVC Boxes', actualPrice: 6.60, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Carlon 1-Gang PVC Boxes (2) // Individual component electrical enclosures' },
        { name: 'Box Covers', actualPrice: 4.88, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Carlon Box Covers (2) // Weather protection for electrical boxes' },
        { name: 'Liquid-Tight Conduit', actualPrice: 44.99, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'HYDROMAXX 50ft Liquid-Tight Conduit // Waterproof electrical wire protection' },
        { name: 'Conduit Clamps', actualPrice: 4.98, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Carlon Conduit Clamps 25-pack // Securing conduit to surfaces' },
        
        // 🛒 TSC MIDLAND - TANK ($599)
        { name: 'Stock Tank (8ft)', actualPrice: 599.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'CountyLine 8ft Stock Tank Galvanized 2ft Depth 700 Gallon // Main pool container structure' },
        
        // 🛒 HOME DEPOT - PLUMBING HARDWARE ($150)
        { name: 'Bulkhead Fittings', actualPrice: 60.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x Bulkhead Tank Fittings 2 inch with gaskets // Through-wall water connections' },
        { name: 'PVC Pipe & Fittings', actualPrice: 40.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'PVC Pipe & Fittings Kit 1.5 inch main 1/2 inch heater lines with elbows tees couplers cement // Pool plumbing system' },
        { name: 'Check Valves', actualPrice: 30.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x Check Valves 1.5 inch and 1/2 inch // Prevent water backflow' },
        { name: 'Gate Valves', actualPrice: 24.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x Gate Valves 1.5 inch and 1/2 inch // Water flow control' },
        { name: 'Tank Drain Valve', actualPrice: 20.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Tank Drain Valve Kit // Pool draining and maintenance' },
        { name: 'Hose Clamps & Adapters', actualPrice: 25.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Hose Clamps & Adapters Assortment // Secure hose connections' },
        { name: 'Teflon & Sealant', actualPrice: 15.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Teflon Tape & Pipe Sealant // Thread sealing and waterproofing' },
        
        // 🛒 HOME DEPOT - DECK MATERIALS ($675)
        { name: 'Concrete Pier Blocks', actualPrice: 108.00, quantity: 9, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '9x Concrete Pier Blocks // Deck foundation support' },
        { name: 'PT Posts', actualPrice: 54.00, quantity: 3, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '3x 4x4x8 ft Pressure Treated Posts // Vertical deck support structure' },
        { name: 'PT Boards 8ft', actualPrice: 34.00, quantity: 4, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '4x 2x6x8 ft Pressure Treated Boards // Deck frame construction' },
        { name: 'PT Boards 12ft', actualPrice: 28.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x 2x6x12 ft Pressure Treated Boards // Extended deck frame spans' },
        { name: 'PT Deck Boards', actualPrice: 240.00, quantity: 20, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '20x 5/4 inch x 6 inch x 8 ft Pressure Treated Deck Boards // Deck surface planking' },
        { name: 'Stair Stringers', actualPrice: 90.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x 3-Step Stair Stringers // Deck access stairs structure' },
        { name: 'Joist Hangers', actualPrice: 30.00, quantity: 12, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '12x 2x6 Joist Hangers // Connect joists to beam structure' },
        { name: 'Stringer Connectors', actualPrice: 16.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x Stair Stringer Connectors // Attach stairs to deck frame' },
        { name: 'TimberLOK Screws', actualPrice: 35.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'TimberLOK 4 inch Screws 1 box // Heavy-duty structural connections' },
        { name: 'Deck Screws', actualPrice: 25.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Exterior Deck Screws 5 lbs // Attach deck boards to frame' },
        { name: 'Joist Hanger Nails', actualPrice: 15.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Joist Hanger Nails 1 box // Secure joist hangers to wood' },
        
        // 🛒 RECOM MATERIALS - PICKUP ($150)
        { name: 'Caliche Base', actualPrice: 45.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '1 Yard Caliche Base // Foundation base material for tank leveling' },
        { name: 'Pea Gravel', actualPrice: 80.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '1 Yard Pea Gravel // Drainage layer under tank foundation' },
        { name: 'Landscape Fabric', actualPrice: 25.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Landscape Fabric 45 sq ft // Weed barrier under gravel base' },
        
        // 🛒 HOME DEPOT - LANDSCAPE EDGING ($113)
        { name: 'Landscape Edging', actualPrice: 113.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Colmet 8 ft x 4 in 14-Gauge Brown Steel Landscape Edging 5-Pack // Pool perimeter edging and landscaping' },
        
        // 🛒 PURCHASED TOOLS - HOME DEPOT ($134)
        { name: 'Dewalt 66" Landscape Rake', actualPrice: 53.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'DEWALT 66 inch Landscape Rake DXPGR66 // Site leveling and debris removal' },
        { name: 'Husky 8"x8" Steel Tamper', actualPrice: 39.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'HUSKY 8x8 inch Steel Tamper // Base compaction and soil preparation' },
        { name: '250ft Mason Line', actualPrice: 5.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: '250 ft Mason Line String // Layout and leveling guide lines' },
        { name: '44in Digging Shovel', actualPrice: 10.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: '44 inch Digging Shovel // Excavation and trenching work' },
        { name: 'Metal Stakes', actualPrice: 7.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'Metal Survey Stakes // Site marking and layout reference points' },
        { name: 'Marking Spray Paint', actualPrice: 10.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'Marking Spray Paint // Site boundary and utility marking' },
        
        // 🛒 PURCHASED TOOLS - HARBOR FREIGHT ($30)
        { name: 'Drain Spade 46in Shovel', actualPrice: 15.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'Harbor Freight 46 inch Drain Spade Shovel // Narrow trench digging and drainage work' },
        { name: 'Square Point Shovel', actualPrice: 15.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'Harbor Freight Square Point Shovel // General excavation and soil moving' },
        
        // 🛒 MISCELLANEOUS SUPPLIES ($100)
        { name: 'Extra Fittings', actualPrice: 40.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Miscellaneous Extra Fittings & Adapters // Backup plumbing connections' },
        { name: 'Safety Equipment', actualPrice: 25.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Safety Equipment Kit // Work site safety compliance' },
        { name: 'Installation Tools', actualPrice: 35.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Installation Tools & Consumables // Project-specific tools and supplies' },
        
        // 🛒 LABOR
        { name: 'Installation Labor', actualPrice: 750.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Complete Installation Labor // Full pool system installation service' }
    ];

    // One-Time Tools (template with $0 prices)
    inventoryData.tools = [
        // Tank Installation Tools
        { name: 'Hole Saw Set (1.5", 2", 3")', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Hole Saw Set 1.5 2 3 inch // Tank bulkhead fitting installation' },
        { name: 'Cordless Drill (if needed)', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'both', link: '', status: 'pending', notes: 'Cordless Drill // Drilling holes and driving screws' },
        { name: 'Step Bit Set', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Step Bit Set // Clean precise holes in metal' },
        { name: 'Level (4ft)', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: '4 ft Level // Tank and deck leveling' },
        { name: 'Socket Set & Wrenches', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'both', link: '', status: 'pending', notes: 'Socket Set & Wrenches // Pump and hardware assembly' },
        { name: 'Shop Vacuum (wet/dry)', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Shop Vacuum Wet/Dry // Site cleanup and debris removal' },
        
        // Professional Excavation & Site Prep Tools
        { name: 'Mini Excavator Rental (per day)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Mini Excavator Rental per day // Large pad excavation projects' },
        { name: 'Trenching Shovel', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Trenching Shovel // Hand excavation and trenching work' },
        { name: 'Mattock/Pick', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Hard soil breaking' },
        { name: 'Hand Tamper (steel)', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Caliche compaction' },
        { name: 'Plate Compactor Rental', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Professional compaction' },
        { name: 'Transit Level (for leveling)', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Precise pad leveling' },
        { name: 'Measuring Tape (100ft)', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Pad layout' },
        { name: 'String Line & Stakes', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Layout marking' },
        { name: 'Chalk Line', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Precise marking' },
        { name: 'Wheelbarrow', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Material transport' },
        { name: 'Rubber Mallet', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Paver installation' },
        { name: 'Circular Saw', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Edging cuts' }
    ];

    // Additional Tanks (template with $0 prices)
    inventoryData.tanks = [
        { name: '6ft CountyLine (390 gal)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Singles/couples' },
        { name: '8ft CountyLine (700 gal)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Most popular' },
        { name: '10ft Behlen (1,117 gal)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Premium families' }
    ];

    // Additional Pump Systems (template with $0 prices)
    inventoryData.pumps = [
        { name: 'Intex SX2800 (additional)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'online', link: '', status: 'pending', notes: '6ft & 8ft tanks' },
        { name: 'Intex SX3000 (for 10ft)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'online', link: '', status: 'pending', notes: '10ft tanks only' },
        { name: 'Filter Balls 4.6lbs (bulk)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'online', link: '', status: 'pending', notes: 'SX2800 pumps' },
        { name: 'Filter Balls 6lbs (10ft)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'online', link: '', status: 'pending', notes: 'SX3000 pumps' }
    ];

    // Salt Water Systems (template with $0 prices)
    inventoryData.salt = [
        { name: 'Intex QS200 (additional)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'online', link: '', status: 'pending', notes: '$697 upsell' },
        { name: 'Pool Salt (50 lb bags)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Local bulk pricing' }
    ];

    // Heating Systems (template with $0 prices)
    inventoryData.heating = [
        { name: 'FOGATTI Heaters (extra)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'online', link: '', status: 'pending', notes: '$1,497 upsell' },
        { name: 'Gas Line Kits (bulk)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Propane connections' },
        { name: 'Mounting Kits (bulk)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'both', link: '', status: 'pending', notes: 'Brackets, bolts' },
        { name: 'Temp Controllers (bulk)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'online', link: '', status: 'pending', notes: 'Digital displays' }
    ];

    // Site Preparation & Premium Pad Installation (template with $0 prices)
    inventoryData.siteprep = [
        // Excavation & Leveling
        { name: 'Excavation & Leveling (6ft = 8x8)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '8ft x 8ft pad area' },
        { name: 'Excavation & Leveling (8ft = 10x10)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '10ft x 10ft pad area' },
        { name: 'Excavation & Leveling (10ft = 12x12)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '12ft x 12ft pad area' },
        
        // Foundation Materials
        { name: 'Caliche Base (per cubic yard)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Hand compacted solid foundation' },
        { name: 'Landscape Fabric (100ft roll)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Full coverage weed prevention' },
        
        // Professional Edging
        { name: 'Pressure Treated Edging 2x8', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Professional border definition' },
        { name: 'Pressure Treated Stakes', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Secure edging installation' },
        { name: 'Construction Screws (3.5")', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Edging assembly' },
        
        // Premium Finishing
        { name: '12"x12"x1.5" Pavers (per sq ft)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Premium 2ft border finish' },
        { name: '3/4" Limestone (per cubic yard)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Drainage & aesthetics backfill' },
        
        // Future-Proofed Trenching
        { name: 'Trenching for Water Lines', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Pool pump water lines' },
        { name: 'Trenching for Gas Lines', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Water heater gas & water' },
        { name: '12V Lighting Conduit Run', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '12V lighting infrastructure' },
        { name: 'Audio Conduit Run', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Outdoor audio preparation' },
        
        // Optional Add-ons
        { name: 'French Drain System', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Custom drainage (quote separately)' },
        { name: 'Drain Pipe (4" perforated)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'French drain installation' },
        { name: 'Drain Gravel (per cubic yard)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'French drain surround' }
    ];

    // Standard Hardware (template with $0 prices)
    inventoryData.hardware = [
        { name: 'Pool Skimmers', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'both', link: '', status: 'pending', notes: 'Surface cleaning' },
        { name: 'Return Jet Fittings', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '1.5 inch' },
        { name: 'Suction Fittings', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Main drains' },
        { name: 'Pool Hoses (25ft pairs)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'both', link: '', status: 'pending', notes: '1.5 inch diameter' }
    ];
}

// Merge Firebase data with default template to ensure new sections exist
function mergeWithDefaultData(firebaseData) {
    // Create fresh template data without affecting global inventoryData
    const templateData = getDefaultInventoryData();
    
    // Start with template data to ensure all sections exist
    const mergedData = JSON.parse(JSON.stringify(templateData));
    
    // Merge Firebase data, preserving any existing user data
    if (firebaseData) {
        Object.keys(firebaseData).forEach(section => {
            if (section === 'projectNotes' || section === 'roiTracking') {
                // Preserve user-specific data
                mergedData[section] = firebaseData[section];
            } else if (Array.isArray(firebaseData[section]) && Array.isArray(mergedData[section])) {
                // For array sections, merge existing user data with template
                // Keep user data if it exists, otherwise use template
                if (firebaseData[section].length > 0) {
                    mergedData[section] = firebaseData[section];
                }
                // If Firebase data doesn't have a section that exists in template, keep template
            }
        });
    }
    
    console.log('Merged data with new sections:', Object.keys(mergedData));
    return mergedData;
}

// Get default inventory data without affecting global state
function getDefaultInventoryData() {
    // Use existing initializeData to get template, but preserve global state
    const savedData = JSON.parse(JSON.stringify(inventoryData));
    initializeData();
    const templateData = JSON.parse(JSON.stringify(inventoryData));
    inventoryData = savedData; // Restore global state
    
    return templateData;
}

// Setup event listeners
function setupEventListeners() {
    // Project notes
    const projectNotes = document.getElementById('projectNotes');
    if (projectNotes) {
        projectNotes.addEventListener('input', function() {
            inventoryData.projectNotes = this.value;
            scheduleAutoSave();
        });
    }

    // Revenue tracking
    const revenueInput = document.getElementById('revenueInput');
    if (revenueInput) {
        revenueInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                addRevenue();
            }
        });
        
        revenueInput.addEventListener('blur', function() {
            if (this.value) {
                addRevenue();
            }
        });
    }

    // Status click handlers
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('status')) {
            cycleStatus(e.target);
        }
    });

    // Input change handlers
    document.addEventListener('input', function(e) {
        if (e.target.matches('.price-input, .qty-input, .link-input, .notes-input, .location-select, .item-name-input, .usage-select')) {
            scheduleAutoSave();
            updateSummary();
        }
    });
}

// Render all inventory sections
function renderAllSections() {
    // Render legacy sections (hidden)
    renderSection('cliff', inventoryData.cliff, 'cliffTable');
    renderSection('tools', inventoryData.tools, 'toolsTable');
    renderSection('tanks', inventoryData.tanks, 'tanksTable');
    renderSection('pumps', inventoryData.pumps, 'pumpsTable');
    renderSection('salt', inventoryData.salt, 'saltTable');
    renderSection('heating', inventoryData.heating, 'heatingTable');
    renderSection('siteprep', inventoryData.siteprep, 'siteprepTable');
    renderSection('hardware', inventoryData.hardware, 'hardwareTable');
    
    // Render accordion sections
    renderAccordionSections();
}

// Toggle accordion sections
function toggleAccordion(sectionId) {
    const content = document.getElementById(sectionId);
    const arrowId = 'arrow-' + sectionId.replace('-section', '');
    const arrow = document.getElementById(arrowId);
    
    
    if (content && arrow) {
        if (content.classList.contains('collapsed')) {
            content.classList.remove('collapsed');
            content.classList.add('expanded');
            arrow.classList.add('expanded');
        } else {
            content.classList.remove('expanded');
            content.classList.add('collapsed');
            arrow.classList.remove('expanded');
        }
    } else {
    }
}

// Render accordion sections with categorized items
function renderAccordionSections() {
    if (!inventoryData.cliff) return;
    
    // Group items by category
    const categories = {
        pool: [],
        electrical: [],
        plumbing: [],
        deck: [],
        siteprep: [],
        labor: []
    };
    
    // Add items from cliff section
    inventoryData.cliff.forEach((item, index) => {
        const category = categorizeItem(item);
        categories[category].push({ ...item, originalIndex: index, section: 'cliff' });
    });
    
    // Add items from siteprep section
    inventoryData.siteprep.forEach((item, index) => {
        const category = categorizeItem(item);
        categories[category].push({ ...item, originalIndex: index, section: 'siteprep' });
    });
    
    // Render each category
    Object.keys(categories).forEach(category => {
        const tableId = category + 'Table';
        renderCategorySection(tableId, categories[category]);
        updateCategoryStats(category, categories[category]);
    });
}

// Render items in a category section
function renderCategorySection(tableId, items) {
    const tbody = document.getElementById(tableId);
    if (!tbody) return;
    
    tbody.innerHTML = '';
    
    items.forEach((item) => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>
                <input type="text" class="item-name-input" value="${item.name}" onchange="updateItemField('${item.section || 'cliff'}', ${item.originalIndex}, 'name', this.value)">
            </td>
            <td>
                <input type="number" class="price-input" value="${item.actualPrice || 0}" step="0.01" min="0" 
                       onchange="updateItemField('${item.section || 'cliff'}', ${item.originalIndex}, 'actualPrice', parseFloat(this.value))"
                       title="${isItemTaxable(item) ? 'Taxable item - 8.25% TX tax will be added automatically' : 'Non-taxable item (labor/materials exempt in TX)'}">
            </td>
            <td>
                <input type="number" class="qty-input" value="${item.quantity || 1}" min="0" onchange="updateItemField('${item.section || 'cliff'}', ${item.originalIndex}, 'quantity', parseInt(this.value))">
            </td>
            <td>
                <select class="usage-select" onchange="updateItemField('${item.section || 'cliff'}', ${item.originalIndex}, 'usage', this.value)">
                    ${Object.keys(CONFIG.USAGE_TYPES).map(usage => 
                        `<option value="${usage}" ${item.usage === usage ? 'selected' : ''}>${CONFIG.USAGE_TYPES[usage].label}</option>`
                    ).join('')}
                </select>
            </td>
            <td>
                <select class="location-select" onchange="updateItemField('${item.section || 'cliff'}', ${item.originalIndex}, 'location', this.value)">
                    ${Object.keys(CONFIG.LOCATION_TYPES).map(location => 
                        `<option value="${location}" ${item.location === location ? 'selected' : ''}>${CONFIG.LOCATION_TYPES[location].label}</option>`
                    ).join('')}
                </select>
            </td>
            <td>
                <input type="url" class="link-input" value="${item.link || ''}" placeholder="Supplier URL" onchange="updateItemField('${item.section || 'cliff'}', ${item.originalIndex}, 'link', this.value)">
            </td>
            <td>
                <button class="status ${item.status}" onclick="cycleStatus(this)" data-section="${item.section || 'cliff'}" data-index="${item.originalIndex}">
                    ${CONFIG.STATUS_TYPES[item.status]?.label || item.status}
                </button>
                ${item.status !== 'purchased' ? `<button class="quick-purchase-btn" onclick="openQuickPurchase('${item.section || 'cliff'}', ${item.originalIndex})" title="Quick Purchase">🛒</button>` : ''}
            </td>
            <td>
                <textarea class="notes-input" placeholder="Notes, supplier info, etc." onchange="updateItemField('${item.section || 'cliff'}', ${item.originalIndex}, 'notes', this.value)">${item.notes || ''}</textarea>
                <button class="delete-item-btn" onclick="deleteItem('${item.section || 'cliff'}', ${item.originalIndex})" title="Delete Item">🗑️</button>
            </td>
        `;
        tbody.appendChild(row);
    });
}

// Update category statistics
function updateCategoryStats(category, items) {
    const count = items.length;
    const total = items.reduce((sum, item) => sum + (item.actualPrice || 0), 0);
    
    const countElement = document.getElementById(`count-${category}`);
    const totalElement = document.getElementById(`total-${category}`);
    
    if (countElement) {
        countElement.textContent = `${count} item${count !== 1 ? 's' : ''}`;
    }
    
    if (totalElement) {
        totalElement.textContent = `$${total.toFixed(2)}`;
    }
}

// Add new item to specific category
function addCategoryItem(category) {
    const newItem = {
        name: 'New Item',
        actualPrice: 0,
        quantity: 1,
        usage: 'per-job',
        location: 'local',
        link: '',
        status: 'pending',
        notes: `New ${category} item - please edit`
    };
    
    inventoryData.cliff.push(newItem);
    renderAccordionSections();
    updateSummary();
    scheduleAutoSave();
}

// Update individual item field
function updateItemField(section, index, field, value) {
    console.log('updateItemField called:', { section, index, field, value }); // Debug
    
    if (inventoryData[section] && inventoryData[section][index]) {
        // If updating price, automatically calculate tax-inclusive price
        if (field === 'actualPrice' && value > 0) {
            const item = inventoryData[section][index];
            const retailPrice = parseFloat(value);
            
            // Calculate tax-inclusive price if item is taxable
            const finalPrice = calculateTaxablePrice(retailPrice, item);
            
            if (finalPrice !== retailPrice) {
                console.log(`Applied ${(CONFIG.TAX.RATE * 100).toFixed(2)}% tax: $${retailPrice.toFixed(2)} → $${finalPrice.toFixed(2)}`);
                inventoryData[section][index][field] = finalPrice;
            } else {
                inventoryData[section][index][field] = retailPrice;
            }
        } else {
            inventoryData[section][index][field] = value;
        }
        
        console.log('Data updated:', inventoryData[section][index]); // Debug
        
        // Re-render accordion sections to update categories and totals (throttled)
        throttledRender();
        
        // Force immediate save
        forceSave();
        
    } else {
        console.error('Could not update field - invalid section or index:', section, index);
    }
}

// Force immediate save (both Firebase and localStorage)
function forceSave() {
    console.log('Force saving data...'); 
    console.log('Firebase ready:', isFirebaseReady, 'DataRef exists:', !!dataRef);
    
    // Always save to localStorage as backup
    saveToLocalStorage();
    
    // Always try Firebase if available - prioritize cloud save
    if (isFirebaseReady && dataRef) {
        console.log('Saving to Firebase...');
        saveToFirebase();
        showSaveIndicator('☁️ Saved to cloud');
    } else {
        console.log('Firebase not ready, localStorage only');
        showSaveIndicator('💾 Saved locally');
    }
}

// Manually add new purchased tools to inventory
function addNewToolsToInventory() {
    console.log('Adding new purchased tools to site prep...');
    
    const newTools = [
        { name: 'Dewalt 66" Landscape Rake', actualPrice: 53.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'DEWALT 66 inch Landscape Rake DXPGR66 // Site leveling and debris removal' },
        { name: 'Husky 8"x8" Steel Tamper', actualPrice: 39.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'HUSKY 8x8 inch Steel Tamper // Base compaction and soil preparation' },
        { name: '250ft Mason Line', actualPrice: 5.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: '250 ft Mason Line String // Layout and leveling guide lines' },
        { name: '44in Digging Shovel', actualPrice: 10.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: '44 inch Digging Shovel // Excavation and trenching work' },
        { name: 'Metal Stakes', actualPrice: 7.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'Metal Survey Stakes // Site marking and layout reference points' },
        { name: 'Marking Spray Paint', actualPrice: 10.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'Marking Spray Paint // Site boundary and utility marking' },
        { name: 'Drain Spade 46in Shovel', actualPrice: 15.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'Harbor Freight 46 inch Drain Spade Shovel // Narrow trench digging and drainage work' },
        { name: 'Square Point Shovel', actualPrice: 15.00, quantity: 1, usage: 'one-time', location: 'owned', link: '', status: 'verified', notes: 'Harbor Freight Square Point Shovel // General excavation and soil moving' }
    ];
    
    // Check if tools already exist, if not add them
    newTools.forEach(newTool => {
        const exists = inventoryData.siteprep.some(item => item.name === newTool.name);
        if (!exists) {
            console.log(`Adding ${newTool.name} to site prep`);
            inventoryData.siteprep.push(newTool);
        } else {
            console.log(`${newTool.name} already exists in site prep`);
        }
    });
}

// Texas Sales Tax Calculation Functions
function isItemTaxable(item) {
    if (!CONFIG.TAX.ENABLED) return false;
    
    // Check if usage type is non-taxable
    if (CONFIG.TAX.NON_TAXABLE_USAGE.includes(item.usage)) {
        return false;
    }
    
    // Check if item name or notes contain non-taxable keywords
    const itemText = `${item.name} ${item.notes}`.toLowerCase();
    const isExempt = CONFIG.TAX.NON_TAXABLE_KEYWORDS.some(keyword => 
        itemText.includes(keyword.toLowerCase())
    );
    
    return !isExempt;
}

function calculateTaxablePrice(retailPrice, item) {
    if (!isItemTaxable(item)) {
        return retailPrice;
    }
    
    const taxAmount = retailPrice * CONFIG.TAX.RATE;
    return retailPrice + taxAmount;
}

function getTaxAmount(retailPrice, item) {
    if (!isItemTaxable(item)) {
        return 0;
    }
    
    return retailPrice * CONFIG.TAX.RATE;
}

function formatPriceWithTax(retailPrice, item) {
    const finalPrice = calculateTaxablePrice(retailPrice, item);
    const taxAmount = getTaxAmount(retailPrice, item);
    
    if (taxAmount > 0) {
        return `$${finalPrice.toFixed(2)} (inc. $${taxAmount.toFixed(2)} tax)`;
    } else {
        return `$${finalPrice.toFixed(2)} (no tax)`;
    }
}

// Test function - call from browser console: testSave()
function testSave() {
    console.log('=== TESTING SAVE SYSTEM ===');
    console.log('Current inventoryData.cliff length:', inventoryData.cliff?.length);
    console.log('Firebase ready:', isFirebaseReady);
    console.log('DataRef exists:', !!dataRef);
    console.log('LocalStorage key:', CONFIG.AUTO_SAVE.LOCAL_STORAGE_KEY);
    
    // Test localStorage
    console.log('Testing localStorage save...');
    forceSave();
    
    // Check what's in localStorage
    setTimeout(() => {
        const saved = localStorage.getItem(CONFIG.AUTO_SAVE.LOCAL_STORAGE_KEY);
        console.log('Data in localStorage:', saved ? 'EXISTS' : 'MISSING');
        if (saved) {
            const parsed = JSON.parse(saved);
            console.log('Saved cliff items count:', parsed.cliff?.length);
        }
    }, 1000);
}


// Render a specific inventory section
function renderSection(section, items, tableId) {
    const tbody = document.getElementById(tableId);
    if (!tbody) return;

    tbody.innerHTML = '';
    
    items.forEach((item, index) => {
        // Ensure location field exists with default value
        if (!item.location) {
            item.location = 'both';
        }
        
        const row = document.createElement('tr');
        row.classList.add('collapsed'); // Start collapsed on mobile
        row.innerHTML = `
            <!-- Mobile Item Header (Always Visible) -->
            <div class="mobile-item-header" onclick="toggleMobileItem(this)">
                <div class="mobile-item-title">
                    <input type="text" class="item-name-input mobile-item-name" data-section="${section}" data-index="${index}" data-field="name" 
                           value="${item.name}" placeholder="Item name..." onclick="event.stopPropagation()">
                    <span class="mobile-toggle-icon">▼</span>
                </div>
                <div class="mobile-item-summary">
                    <span class="status ${item.status}" data-section="${section}" data-index="${index}">${CONFIG.STATUS_TYPES[item.status]?.label || item.status}</span>
                    <span class="mobile-price">$${(item.actualPrice || 0).toFixed(2)}</span>
                </div>
            </div>
            
            <!-- Mobile Item Details (Collapsible) -->
            <div class="mobile-item-details">
                <td data-label="Item" style="display:none;">
                    <input type="text" class="item-name-input" data-section="${section}" data-index="${index}" data-field="name" 
                           value="${item.name}" placeholder="Item name..." style="font-weight: bold; border: 1px solid #e1e8ed; padding: 6px; border-radius: 4px; width: 100%; background: #fafbfc;">
                </td>
                <div class="mobile-field-group">
                    <div class="mobile-field">
                        <label>Price:</label>
                        <input type="number" class="price-input" data-section="${section}" data-index="${index}" data-field="actualPrice" 
                               value="${item.actualPrice || ''}" placeholder="$" step="0.01">
                    </div>
                    <div class="mobile-field">
                        <label>Qty:</label>
                        <input type="number" class="qty-input" data-section="${section}" data-index="${index}" data-field="quantity" 
                               value="${item.quantity}" min="0">
                    </div>
                </div>
                <div class="mobile-field-group">
                    <div class="mobile-field">
                        <label>Usage:</label>
                        <select class="usage-select" data-section="${section}" data-index="${index}" data-field="usage">
                            <option value="one-time" ${item.usage === 'one-time' ? 'selected' : ''}>One-Time</option>
                            <option value="per-job" ${item.usage === 'per-job' ? 'selected' : ''}>Per Job</option>
                            <option value="reusable" ${item.usage === 'reusable' ? 'selected' : ''}>Reusable</option>
                            <option value="consumable" ${item.usage === 'consumable' ? 'selected' : ''}>Consumable</option>
                        </select>
                    </div>
                    <div class="mobile-field">
                        <label>Location:</label>
                        <select class="location-select" data-section="${section}" data-index="${index}" data-field="location">
                            <option value="online" ${item.location === 'online' ? 'selected' : ''}>Online</option>
                            <option value="local" ${item.location === 'local' ? 'selected' : ''}>Local Midland TX</option>
                            <option value="both" ${item.location === 'both' ? 'selected' : ''}>Both</option>
                        </select>
                    </div>
                </div>
                <div class="mobile-field">
                    <label>Supplier Link:</label>
                    <input type="url" class="link-input" data-section="${section}" data-index="${index}" data-field="link" 
                           value="${item.link}" placeholder="Supplier link...">
                </div>
                <div class="mobile-field">
                    <label>Notes:</label>
                    <input type="text" class="notes-input" data-section="${section}" data-index="${index}" data-field="notes" 
                           value="${item.notes}" placeholder="Notes...">
                </div>
                <div class="mobile-actions">
                    ${item.status === 'pending' || item.status === 'ordered' ? 
                        `<button class="quick-purchase-btn" onclick="openQuickPurchase('${section}', ${index})" title="Quick Purchase">💳 Purchase</button>` : 
                        ''}
                    ${item.receiptPhoto ? 
                        `<button class="view-receipt-btn" onclick="viewReceipt('${section}', ${index})" title="View Receipt">📷 Receipt</button>` : 
                        ''}
                    <button class="delete-item-btn" onclick="deleteItem('${section}', ${index})" title="Delete item">🗑️ Delete</button>
                </div>
            </div>
        `;
        tbody.appendChild(row);
    });

    // Add event listeners for inputs and selects
    tbody.querySelectorAll('input, select').forEach(input => {
        input.addEventListener('input', function() {
            const section = this.dataset.section;
            const index = parseInt(this.dataset.index);
            const field = this.dataset.field;
            const value = this.type === 'number' ? parseFloat(this.value) || 0 : this.value;
            
            inventoryData[section][index][field] = value;
            
            // Update location badge when location changes
            if (field === 'location') {
                const badge = this.parentNode.querySelector('.location-badge');
                if (badge) {
                    badge.className = `location-badge ${value}`;
                    badge.textContent = value === 'online' ? 'Online' : value === 'local' ? 'Local TX' : 'Both';
                }
            }
            
            scheduleAutoSave();
            updateSummary();
        });
        
        input.addEventListener('change', function() {
            // Trigger change for selects as well
            if (this.tagName === 'SELECT') {
                this.dispatchEvent(new Event('input'));
            }
        });
    });
}

// Cycle through status options when clicked
function cycleStatus(statusElement) {
    const statuses = ['pending', 'ordered', 'purchased', 'partial', 'verified'];
    
    // Determine current status by checking all possible classes
    let currentStatus = 'pending';
    for (const status of statuses) {
        if (statusElement.classList.contains(status)) {
            currentStatus = status;
            break;
        }
    }
    
    const currentIndex = statuses.indexOf(currentStatus);
    const nextStatus = statuses[(currentIndex + 1) % statuses.length];
    
    // Update visual - handle both old 'status' class and new 'item-status' class
    if (statusElement.classList.contains('status')) {
        statusElement.className = `status ${nextStatus}`;
    } else {
        statusElement.className = `item-status ${nextStatus}`;
    }
    statusElement.textContent = CONFIG.STATUS_TYPES[nextStatus].label;
    
    // Update data
    const section = statusElement.dataset.section;
    const index = parseInt(statusElement.dataset.index);
    inventoryData[section][index].status = nextStatus;
    
    // Re-render accordion sections (throttled)
    throttledRender();
    scheduleAutoSave();
}

// Categorize items by type
function categorizeItem(item) {
    const notes = item.notes.toLowerCase();
    const name = item.name.toLowerCase();
    
    // Pool System (tanks, pumps, filters, heaters)
    if (notes.includes('stock tank') || notes.includes('filter') || notes.includes('pump') || 
        notes.includes('heater') || notes.includes('water transfer') || name.includes('tank') ||
        name.includes('filter') || name.includes('pump') || name.includes('heater')) {
        return 'pool';
    }
    
    // Electrical
    if (notes.includes('gang') || notes.includes('box') || notes.includes('conduit') || 
        notes.includes('clamp') || notes.includes('anchor') || notes.includes('electrical') ||
        name.includes('electrical') || name.includes('conduit') || name.includes('box')) {
        return 'electrical';
    }
    
    // Plumbing
    if (notes.includes('bulkhead') || notes.includes('pvc') || notes.includes('valve') || 
        notes.includes('teflon') || notes.includes('hose') || notes.includes('fitting') ||
        name.includes('valve') || name.includes('pvc') || name.includes('fitting')) {
        return 'plumbing';
    }
    
    // Deck/Structure
    if (notes.includes('pt ') || notes.includes('deck') || notes.includes('joist') || 
        notes.includes('stair') || notes.includes('pier') || notes.includes('screw') ||
        notes.includes('lumber') || notes.includes('board') || name.includes('deck') ||
        name.includes('pt ') || name.includes('stair') || name.includes('pier')) {
        return 'deck';
    }
    
    // Site Prep (includes tools and materials)
    if (notes.includes('caliche') || notes.includes('gravel') || notes.includes('landscape') ||
        notes.includes('fabric') || notes.includes('home depot') || notes.includes('harbor freight') ||
        notes.includes('site leveling') || notes.includes('compaction') || notes.includes('layout') ||
        notes.includes('marking') || notes.includes('excavation') || notes.includes('digging') ||
        name.includes('caliche') || name.includes('gravel') || name.includes('landscape') ||
        name.includes('rake') || name.includes('tamper') || name.includes('shovel') ||
        name.includes('mason') || name.includes('stakes') || name.includes('spray') ||
        name.includes('dewalt') || name.includes('husky') || name.includes('drain spade')) {
        return 'siteprep';
    }
    
    // Labor
    if (notes.includes('labor') || notes.includes('installation') || name.includes('labor')) {
        return 'labor';
    }
    
    // Default to pool system for uncategorized items
    return 'pool';
}

// Update summary calculations
function updateSummary() {
    let totalItems = 0;
    let verifiedItems = 0;
    let pendingItems = 0;
    let partialItems = 0;
    let oneTimeTotal = 0;
    let perJobTotal = 0;
    let cliffTotal = 0;

    // Calculate totals for all sections
    Object.keys(inventoryData).forEach(section => {
        if (Array.isArray(inventoryData[section])) {
            inventoryData[section].forEach(item => {
                totalItems++;
                
                // Count by status
                if (item.status === 'verified') verifiedItems++;
                else if (item.status === 'partial') partialItems++;
                else pendingItems++;
                
                // Only count actual purchases (verified items) in financial calculations
                if (item.status === 'verified') {
                    const actualPrice = item.actualPrice || 0;
                    const totalPrice = actualPrice;
                    
                    if (section === 'cliff') {
                        cliffTotal += totalPrice;
                    } else if (item.usage === 'one-time') {
                        oneTimeTotal += totalPrice;
                    } else {
                        perJobTotal += totalPrice;
                    }
                }
            });
        }
    });

    // ROI Calculations
    const initialInvestment = cliffTotal + oneTimeTotal; // First install + tools
    const totalDeposit = oneTimeTotal + perJobTotal + cliffTotal;
    const totalRevenue = inventoryData.roiTracking?.totalRevenue || 0;
    const netProfit = totalRevenue - initialInvestment;
    const roiPercentage = initialInvestment > 0 ? ((netProfit / initialInvestment) * 100) : 0;
    
    // ROI Status Messages
    let roiStatus = 'Break-even pending';
    if (roiPercentage > 0) {
        roiStatus = `Profit: ${formatCurrency(netProfit)}`;
    } else if (roiPercentage === 0 && totalRevenue > 0) {
        roiStatus = 'Break-even achieved!';
    } else if (totalRevenue > 0) {
        const remaining = initialInvestment - totalRevenue;
        roiStatus = `Need ${formatCurrency(remaining)} more`;
    }

    // Update summary cards
    updateElement('totalItems', totalItems);
    updateElement('verifiedItems', verifiedItems);
    updateElement('initialInvestment', formatCurrency(initialInvestment));
    updateElement('oneTimeTotal', formatCurrency(oneTimeTotal));
    updateElement('perJobTotal', formatCurrency(perJobTotal));
    updateElement('totalRevenue', formatCurrency(totalRevenue));
    updateElement('roiPercentage', roiPercentage.toFixed(1) + '%');
    updateElement('roiStatus', roiStatus);
    updateElement('totalDeposit', formatCurrency(totalDeposit));

    // Update detailed summaries
    updateElement('cliff-total', formatCurrency(cliffTotal));
    updateElement('depositOneTime', formatCurrency(oneTimeTotal));
    updateElement('depositPerJob', formatCurrency(perJobTotal));
    updateElement('depositCliff', formatCurrency(cliffTotal));
    updateElement('depositTotal', formatCurrency(totalDeposit));
    
    // Update ROI summary section
    updateElement('roiCliffTotal', formatCurrency(cliffTotal));
    updateElement('roiToolsTotal', formatCurrency(oneTimeTotal));
    updateElement('roiInitialTotal', formatCurrency(initialInvestment));
    updateElement('roiRevenueTotal', formatCurrency(totalRevenue));
    updateElement('roiJobsCount', inventoryData.roiTracking?.jobsCompleted || 0);
    updateElement('roiCurrentPercent', roiPercentage.toFixed(1) + '%');
    
    // Update ROI status text with more detailed info
    let detailedStatus = 'Enter job revenue to track your return on investment';
    if (totalRevenue > 0) {
        if (roiPercentage > 0) {
            detailedStatus = `🎉 Profitable! You've earned ${formatCurrency(netProfit)} profit on your ${formatCurrency(initialInvestment)} investment.`;
        } else if (roiPercentage === 0) {
            detailedStatus = `🎯 Break-even achieved! You've recovered your initial investment of ${formatCurrency(initialInvestment)}.`;
        } else {
            const remaining = initialInvestment - totalRevenue;
            detailedStatus = `📈 ${formatCurrency(remaining)} more revenue needed to break even on your ${formatCurrency(initialInvestment)} investment.`;
        }
    }
    updateElement('roiStatusText', detailedStatus);
    
    // Update inventory status
    updateElement('verifiedCount', verifiedItems);
    updateElement('totalCount', totalItems);
    updateElement('pendingCount', pendingItems);
    updateElement('partialCount', partialItems);
}

// Helper function to update element content
function updateElement(id, content) {
    const element = document.getElementById(id);
    if (element) {
        element.textContent = content;
    }
}

// Format currency
function formatCurrency(amount) {
    return '$' + amount.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
}

// Auto-save functionality
function scheduleAutoSave() {
    if (autoSaveTimer) {
        clearTimeout(autoSaveTimer);
    }
    
    autoSaveTimer = setTimeout(() => {
        if (isFirebaseReady && dataRef) {
            saveToFirebase();
        } else {
            saveToLocalStorage();
        }
        showSaveIndicator();
    }, 1000); // Save 1 second after last change
}

function startAutoSave() {
    // Auto-save is now handled by scheduleAutoSave() on changes only
    // No more automatic interval saving to reduce sync frequency
    console.log('Auto-save initialized - will save on changes only');
}

// Firebase save function
function saveToFirebase() {
    if (!isFirebaseReady || !dataRef) {
        saveToLocalStorage();
        return;
    }
    
    try {
        const dataToSave = {
            data: inventoryData,
            lastUpdated: Date.now(),
            lastUpdatedBy: currentUser.id,
            version: CONFIG.APP.VERSION
        };
        
        lastUpdateTimestamp = dataToSave.lastUpdated;
        
        window.Firebase.set(dataRef, dataToSave).then(() => {
            console.log('✅ Data saved to Firebase successfully');
            showSaveIndicator('☁️ Synced to cloud');
        }).catch((error) => {
            console.error('❌ Firebase save error:', error);
            showNotification('Failed to sync to cloud', 'error');
            // Fallback to local storage
            saveToLocalStorage();
        });
    } catch (error) {
        console.error('Failed to save to Firebase:', error);
        saveToLocalStorage();
    }
}

// Local storage functions (fallback)
function saveToLocalStorage() {
    try {
        const dataToSave = {
            ...inventoryData,
            lastSaved: new Date().toISOString()
        };
        console.log('Saving to localStorage:', CONFIG.AUTO_SAVE.LOCAL_STORAGE_KEY); // Debug
        localStorage.setItem(CONFIG.AUTO_SAVE.LOCAL_STORAGE_KEY, JSON.stringify(dataToSave));
        console.log('Successfully saved to localStorage'); // Debug
        showSaveIndicator('Saved locally');
    } catch (error) {
        console.error('Failed to save to localStorage:', error);
        showNotification('Save failed!', 'error');
    }
}

function loadFromLocalStorage() {
    try {
        const saved = localStorage.getItem(CONFIG.AUTO_SAVE.LOCAL_STORAGE_KEY);
        console.log('Loading from localStorage...', saved ? 'DATA FOUND' : 'NO DATA'); // Debug
        
        if (saved) {
            const parsedData = JSON.parse(saved);
            console.log('Parsed data cliff length:', parsedData.cliff?.length); // Debug
            
            // Merge saved data with current data, preserving structure
            Object.keys(inventoryData).forEach(key => {
                if (parsedData[key] !== undefined) {
                    inventoryData[key] = parsedData[key];
                }
            });
            
            console.log('After loading - inventoryData.cliff length:', inventoryData.cliff?.length); // Debug
            
            // Load project notes
            if (parsedData.projectNotes) {
                const notesElement = document.getElementById('projectNotes');
                if (notesElement) {
                    notesElement.value = parsedData.projectNotes;
                }
            }
            
            // CRITICAL FIX: Re-render after loading data!
            renderAllSections();
            updateSummary();
            console.log('Data loaded and re-rendered!'); // Debug
        }
    } catch (error) {
        console.error('Failed to load from localStorage:', error);
    }
}

// Cloud sync functionality
function startCloudSync() {
    // Cloud sync is now manual only - click the "☁️ Sync" button to sync
    // No more automatic background syncing to reduce server calls
    console.log('Cloud sync disabled - use manual sync button');
}

async function syncToCloud() {
    if (!CONFIG.CLOUD_SYNC.ENABLED) {
        showNotification('Cloud sync is not configured', 'error');
        return;
    }

    try {
        showNotification('Syncing to cloud...', 'info');
        
        // Prepare data for Google Sheets
        const sheetData = prepareDataForSheets();
        
        // Send to Google Sheets API
        await updateGoogleSheet(sheetData);
        
        showNotification('Successfully synced to cloud', 'success');
    } catch (error) {
        console.error('Cloud sync failed:', error);
        showNotification('Cloud sync failed: ' + error.message, 'error');
    }
}

function prepareDataForSheets() {
    const rows = [['Section', 'Item', 'Price', 'Quantity', 'Usage', 'Location', 'Status', 'Link', 'Notes', 'Total Cost']];
    
    Object.keys(inventoryData).forEach(section => {
        if (Array.isArray(inventoryData[section])) {
            inventoryData[section].forEach(item => {
                const actualPrice = item.actualPrice || 0;
                const totalCost = actualPrice * (item.quantity || 0);
                
                rows.push([
                    section,
                    item.name,
                    item.actualPrice || '',
                    item.quantity,
                    item.usage,
                    item.location || 'both',
                    item.status,
                    item.link || '',
                    item.notes || '',
                    totalCost
                ]);
            });
        }
    });
    
    return rows;
}

async function updateGoogleSheet(data) {
    const url = `https://sheets.googleapis.com/v4/spreadsheets/${CONFIG.GOOGLE_SHEETS.SHEET_ID}/values/${CONFIG.GOOGLE_SHEETS.SHEET_NAME}?key=${CONFIG.GOOGLE_SHEETS.API_KEY}`;
    
    const response = await fetch(url, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            values: data
        })
    });
    
    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return response.json();
}

// Export functions
function exportData() {
    const dataToExport = {
        ...inventoryData,
        exportedAt: new Date().toISOString(),
        version: CONFIG.APP.VERSION
    };
    
    const blob = new Blob([JSON.stringify(dataToExport, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    
    const timestamp = CONFIG.EXPORT.INCLUDE_TIMESTAMP ? '_' + new Date().toISOString().slice(0, 19).replace(/:/g, '-') : '';
    a.href = url;
    a.download = `${CONFIG.EXPORT.FILENAME_PREFIX}${timestamp}.json`;
    
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    showNotification('Data exported successfully', 'success');
}

function importData(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    const reader = new FileReader();
    reader.onload = function(e) {
        try {
            const importedData = JSON.parse(e.target.result);
            
            // Validate and merge data
            Object.keys(inventoryData).forEach(key => {
                if (importedData[key] !== undefined) {
                    inventoryData[key] = importedData[key];
                }
            });
            
            // Re-render everything
            renderAllSections();
            updateSummary();
            saveToLocalStorage();
            
            showNotification('Data imported successfully', 'success');
        } catch (error) {
            console.error('Import failed:', error);
            showNotification('Import failed: Invalid file format', 'error');
        }
    };
    reader.readAsText(file);
}

function exportToCSV() {
    const headers = ['Section', 'Item', 'Price', 'Quantity', 'Usage', 'Location', 'Status', 'Link', 'Notes', 'Total Cost'];
    const rows = [headers];
    
    Object.keys(inventoryData).forEach(section => {
        if (Array.isArray(inventoryData[section])) {
            inventoryData[section].forEach(item => {
                const actualPrice = item.actualPrice || 0;
                const totalCost = actualPrice * (item.quantity || 0);
                
                rows.push([
                    section,
                    item.name,
                    item.actualPrice || '',
                    item.quantity,
                    item.usage,
                    item.location || 'both',
                    item.status,
                    item.link || '',
                    item.notes || '',
                    totalCost
                ]);
            });
        }
    });
    
    const csvContent = rows.map(row => 
        row.map(field => `"${String(field).replace(/"/g, '""')}"`).join(CONFIG.EXPORT.CSV_DELIMITER)
    ).join('\n');
    
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    
    const timestamp = CONFIG.EXPORT.INCLUDE_TIMESTAMP ? '_' + new Date().toISOString().slice(0, 19).replace(/:/g, '-') : '';
    a.href = url;
    a.download = `${CONFIG.EXPORT.FILENAME_PREFIX}${timestamp}.csv`;
    
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    showNotification('CSV exported successfully', 'success');
}

function printReport() {
    window.print();
}

function clearAllData() {
    if (confirm('Are you sure you want to clear all data? This action cannot be undone.')) {
        localStorage.removeItem(CONFIG.AUTO_SAVE.LOCAL_STORAGE_KEY);
        
        // Clear all inventory data completely
        inventoryData.cliff = [];
        inventoryData.tools = [];
        inventoryData.tanks = [];
        inventoryData.pumps = [];
        inventoryData.salt = [];
        inventoryData.heating = [];
        inventoryData.siteprep = [];
        inventoryData.hardware = [];
        inventoryData.projectNotes = '';
        
        // Clear ROI tracking
        inventoryData.roiTracking = {
            totalRevenue: 0,
            jobsCompleted: 0,
            revenueHistory: []
        };
        
        renderAllSections();
        updateSummary();
        
        // Clear project notes
        const notesElement = document.getElementById('projectNotes');
        if (notesElement) {
            notesElement.value = '';
        }
        
        // Clear revenue input
        const revenueInput = document.getElementById('revenueInput');
        if (revenueInput) {
            revenueInput.value = '';
        }
        
        scheduleAutoSave();
        showNotification('All data cleared - starting fresh!', 'success');
    }
}

// Connection status display
function showConnectionStatus() {
    let statusElement = document.getElementById('connectionStatus');
    
    if (!statusElement) {
        statusElement = document.createElement('div');
        statusElement.id = 'connectionStatus';
        statusElement.className = 'connection-status';
        document.body.appendChild(statusElement);
    }
    
    statusElement.className = `connection-status ${connectionStatus}`;
    
    const statusText = {
        'connected': '🟢 Connected',
        'disconnected': '🔴 Offline',
        'connecting': '🟡 Connecting...',
        'reconnecting': '🟡 Reconnecting...'
    };
    
    statusElement.textContent = statusText[connectionStatus] || '⚪ Unknown';
    
    // Auto-hide connected status after 3 seconds
    if (connectionStatus === 'connected') {
        setTimeout(() => {
            if (statusElement && connectionStatus === 'connected') {
                statusElement.style.display = 'none';
            }
        }, 3000);
    } else {
        statusElement.style.display = 'block';
    }
}

// Load project notes into UI
function loadProjectNotes() {
    const notesElement = document.getElementById('projectNotes');
    if (notesElement && inventoryData.projectNotes) {
        notesElement.value = inventoryData.projectNotes;
    }
}

// Revenue tracking functions
function addRevenue() {
    const revenueInput = document.getElementById('revenueInput');
    const amount = parseFloat(revenueInput.value);
    
    if (!amount || amount <= 0) {
        showNotification('Please enter a valid revenue amount', 'error');
        return;
    }
    
    // Initialize ROI tracking if it doesn't exist
    if (!inventoryData.roiTracking) {
        inventoryData.roiTracking = {
            totalRevenue: 0,
            jobsCompleted: 0,
            revenueHistory: []
        };
    }
    
    // Add to tracking
    inventoryData.roiTracking.totalRevenue += amount;
    inventoryData.roiTracking.jobsCompleted++;
    inventoryData.roiTracking.revenueHistory.push({
        amount: amount,
        date: new Date().toISOString(),
        jobNumber: inventoryData.roiTracking.jobsCompleted
    });
    
    // Clear input and update
    revenueInput.value = '';
    updateSummary();
    scheduleAutoSave();
    
    showNotification(`Revenue added: ${formatCurrency(amount)} (Job #${inventoryData.roiTracking.jobsCompleted})`, 'success');
}

function resetROI() {
    if (confirm('Reset all revenue tracking? This will clear your ROI progress but keep inventory data.')) {
        inventoryData.roiTracking = {
            totalRevenue: 0,
            jobsCompleted: 0,
            revenueHistory: []
        };
        updateSummary();
        scheduleAutoSave();
        showNotification('ROI tracking reset', 'success');
    }
}

// Dynamic item management functions
function addNewItem(section) {
    if (!inventoryData[section]) {
        console.error(`Section ${section} does not exist`);
        return;
    }
    
    // Create new item from template
    const newItem = { ...CONFIG.DEFAULT_ITEM };
    
    // Set default usage based on section
    if (section === 'tools') {
        newItem.usage = 'one-time';
    } else if (section === 'cliff') {
        newItem.usage = 'per-job';
    } else {
        newItem.usage = 'per-job';
    }
    
    // Add to inventory data
    inventoryData[section].push(newItem);
    
    // Re-render the section
    const tableMap = {
        'cliff': 'cliffTable',
        'tools': 'toolsTable', 
        'tanks': 'tanksTable',
        'pumps': 'pumpsTable',
        'salt': 'saltTable',
        'heating': 'heatingTable',
        'siteprep': 'siteprepTable',
        'hardware': 'hardwareTable'
    };
    
    renderSection(section, inventoryData[section], tableMap[section]);
    
    // CRITICAL: Also re-render accordion sections to update UI
    renderAccordionSections();
    
    // Update summary and save
    updateSummary();
    scheduleAutoSave();
    
    // Focus on the name field of the new item
    setTimeout(() => {
        const newIndex = inventoryData[section].length - 1;
        const nameField = document.querySelector(`input[data-section="${section}"][data-index="${newIndex}"][data-field="name"]`);
        if (nameField) {
            nameField.focus();
            nameField.select();
        }
    }, 100);
    
    showNotification(`New item added to ${section}`, 'success');
}

function deleteItem(section, index) {
    if (!inventoryData[section] || !inventoryData[section][index]) {
        console.error(`Item at ${section}[${index}] does not exist`);
        return;
    }
    
    const item = inventoryData[section][index];
    const itemName = item.name || 'Unnamed item';
    
    // Confirmation dialog
    if (confirm(`Delete "${itemName}"?\n\nThis action cannot be undone.`)) {
        // Remove item from array
        inventoryData[section].splice(index, 1);
        
        // Re-render the section
        const tableMap = {
            'cliff': 'cliffTable',
            'tools': 'toolsTable', 
            'tanks': 'tanksTable',
            'pumps': 'pumpsTable',
            'salt': 'saltTable',
            'heating': 'heatingTable',
            'siteprep': 'siteprepTable',
            'hardware': 'hardwareTable'
        };
        
        renderSection(section, inventoryData[section], tableMap[section]);
        
        // CRITICAL: Also re-render accordion sections to update UI
        renderAccordionSections();
        
        // Update summary and save
        updateSummary();
        scheduleAutoSave();
        
        showNotification(`"${itemName}" deleted`, 'success');
    }
}

// Toggle mobile item details
function toggleMobileItem(headerElement) {
    const row = headerElement.closest('tr');
    const isCollapsed = row.classList.contains('collapsed');
    const toggleIcon = headerElement.querySelector('.mobile-toggle-icon');
    
    if (isCollapsed) {
        row.classList.remove('collapsed');
        toggleIcon.textContent = '▲';
    } else {
        row.classList.add('collapsed');
        toggleIcon.textContent = '▼';
    }
}

// Notification system
function showSaveIndicator(message = '✓ Auto-saved') {
    const indicator = document.getElementById('saveIndicator');
    if (indicator) {
        indicator.textContent = message;
        indicator.classList.add('show');
        setTimeout(() => {
            indicator.classList.remove('show');
        }, CONFIG.NOTIFICATIONS.SAVE_DURATION);
    }
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    // Style the notification
    Object.assign(notification.style, {
        position: 'fixed',
        top: '20px',
        right: '20px',
        padding: '12px 20px',
        borderRadius: '5px',
        color: 'white',
        fontWeight: 'bold',
        zIndex: '10000',
        transform: 'translateX(100%)',
        transition: 'transform 0.3s ease',
        maxWidth: '300px'
    });
    
    // Set background color based on type
    const colors = {
        success: '#27ae60',
        error: '#e74c3c',
        info: '#3498db',
        warning: '#f39c12'
    };
    notification.style.backgroundColor = colors[type] || colors.info;
    
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Auto remove
    const duration = type === 'error' ? CONFIG.NOTIFICATIONS.ERROR_DURATION : CONFIG.NOTIFICATIONS.SUCCESS_DURATION;
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, duration);
}

// Quick Purchase Modal Functions
let currentPurchaseItem = null;

function openQuickPurchase(section, index) {
    // Convert index to number to ensure proper array access
    const numIndex = parseInt(index);
    currentPurchaseItem = { section, index: numIndex };
    
    console.log('openQuickPurchase:', { section, index, numIndex, arrayLength: inventoryData[section]?.length });
    
    if (!inventoryData[section] || !inventoryData[section][numIndex]) {
        console.error('Invalid section or index:', { section, numIndex, availableIndices: inventoryData[section]?.length });
        showNotification('Error: Invalid item selected', 'error');
        return;
    }
    
    const item = inventoryData[section][numIndex];
    console.log('Selected item:', item);
    
    document.getElementById('purchaseItemName').textContent = item.name;
    document.getElementById('purchasePrice').value = item.actualPrice || '';
    document.getElementById('purchaseNotes').value = item.notes || '';
    document.getElementById('photoPreview').innerHTML = '';
    
    document.getElementById('quickPurchaseModal').style.display = 'flex';
    document.body.style.overflow = 'hidden'; // Prevent background scrolling
}

function closeQuickPurchase() {
    document.getElementById('quickPurchaseModal').style.display = 'none';
    document.body.style.overflow = 'auto';
    currentPurchaseItem = null;
}

function triggerCamera() {
    console.log('Triggering camera');
    const photoInput = document.getElementById('receiptPhoto');
    if (photoInput) {
        console.log('Photo input found, triggering click');
        photoInput.click();
    } else {
        console.error('Photo input not found when triggering camera');
        showNotification('Camera not available', 'error');
    }
}

// Handle photo selection - Ensure this runs after DOM is fully loaded
function initializePhotoHandler() {
    const photoInput = document.getElementById('receiptPhoto');
    if (photoInput) {
        console.log('Photo input found, adding event listener');
        photoInput.addEventListener('change', function(e) {
            console.log('Photo input changed, file count:', e.target.files.length);
            if (e.target.files.length > 0) {
                handlePhotoSelection(e.target.files[0]);
            }
        });
    } else {
        console.warn('Photo input not found');
    }
}

// Initialize photo handler when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM loaded, initializing photo handler');
    initializePhotoHandler();
});

function handlePhotoSelection(file) {
    if (!file) {
        console.log('No file selected');
        return;
    }
    
    console.log('Handling photo selection:', { name: file.name, size: file.size, type: file.type });
    
    // Check if file is an image
    if (!file.type.startsWith('image/')) {
        console.error('Selected file is not an image:', file.type);
        showNotification('Please select an image file', 'error');
        return;
    }
    
    const reader = new FileReader();
    reader.onload = function(e) {
        console.log('Photo loaded successfully');
        const preview = document.getElementById('photoPreview');
        if (preview) {
            preview.innerHTML = `
                <div class="photo-preview-container">
                    <img src="${e.target.result}" alt="Receipt Preview" class="preview-image">
                    <button type="button" onclick="clearPhoto()" class="clear-photo-btn">&times;</button>
                </div>
            `;
            console.log('Photo preview updated');
        } else {
            console.error('Photo preview element not found');
        }
    };
    
    reader.onerror = function(e) {
        console.error('Error reading file:', e);
        showNotification('Error reading photo file', 'error');
    };
    
    reader.readAsDataURL(file);
}

function clearPhoto() {
    console.log('Clearing photo');
    const preview = document.getElementById('photoPreview');
    const input = document.getElementById('receiptPhoto');
    
    if (preview) {
        preview.innerHTML = '';
        console.log('Photo preview cleared');
    } else {
        console.error('Photo preview element not found');
    }
    
    if (input) {
        input.value = '';
        console.log('Photo input cleared');
    } else {
        console.error('Photo input element not found');
    }
}

function completePurchase() {
    if (!currentPurchaseItem) {
        console.error('No current purchase item');
        return;
    }
    
    const { section, index } = currentPurchaseItem;
    console.log('completePurchase:', { section, index });
    
    if (!inventoryData[section] || !inventoryData[section][index]) {
        console.error('Invalid purchase item:', { section, index });
        showNotification('Error: Invalid item for purchase', 'error');
        return;
    }
    
    const price = parseFloat(document.getElementById('purchasePrice').value) || 0;
    const notes = document.getElementById('purchaseNotes').value;
    const photoFile = document.getElementById('receiptPhoto').files[0];
    
    console.log('Purchase data:', { price, notes, hasPhoto: !!photoFile });
    
    // Update item data
    inventoryData[section][index].actualPrice = price;
    inventoryData[section][index].status = 'purchased';
    inventoryData[section][index].notes = notes;
    inventoryData[section][index].purchaseDate = new Date().toISOString();
    
    // Store photo as base64 for now (in production, you'd upload to Firebase Storage)
    if (photoFile) {
        const reader = new FileReader();
        reader.onload = function(e) {
            inventoryData[section][index].receiptPhoto = e.target.result;
            console.log('Photo stored for item:', inventoryData[section][index].name);
            finalizePurchase();
        };
        reader.readAsDataURL(photoFile);
    } else {
        finalizePurchase();
    }
}

function finalizePurchase() {
    // Re-render the section to show updated data
    renderSection(currentPurchaseItem.section, CONFIG.SECTIONS[currentPurchaseItem.section]);
    updateSummary();
    scheduleAutoSave();
    
    // Show success notification
    showNotification(`Purchase completed! Item marked as purchased.`, 'success');
    
    closeQuickPurchase();
}

function viewReceipt(section, index) {
    const numIndex = parseInt(index);
    console.log('viewReceipt:', { section, index, numIndex });
    
    if (!inventoryData[section] || !inventoryData[section][numIndex]) {
        console.error('Invalid receipt view request:', { section, numIndex });
        return;
    }
    
    const item = inventoryData[section][numIndex];
    if (!item.receiptPhoto) {
        console.log('No receipt photo for item:', item.name);
        return;
    }
    
    document.getElementById('receiptImageContainer').innerHTML = `
        <img src="${item.receiptPhoto}" alt="Receipt for ${item.name}" class="receipt-image">
        <div class="receipt-details">
            <p><strong>Item:</strong> ${item.name}</p>
            <p><strong>Price:</strong> $${item.actualPrice?.toFixed(2) || 'N/A'}</p>
            <p><strong>Purchase Date:</strong> ${item.purchaseDate ? new Date(item.purchaseDate).toLocaleDateString() : 'N/A'}</p>
        </div>
    `;
    
    document.getElementById('receiptModal').style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

function closeReceiptModal() {
    document.getElementById('receiptModal').style.display = 'none';
    document.body.style.overflow = 'auto';
}

// Debug function to help troubleshoot index issues
function debugInventoryStructure() {
    console.log('=== INVENTORY DEBUG ===');
    Object.keys(inventoryData).forEach(section => {
        if (Array.isArray(inventoryData[section])) {
            console.log(`Section: ${section} (${inventoryData[section].length} items)`);
            inventoryData[section].forEach((item, index) => {
                console.log(`  [${index}] ${item.name} - Status: ${item.status}`);
            });
        }
    });
    console.log('=== END DEBUG ===');
}

// Add debug function to global scope for console access
window.debugInventory = debugInventoryStructure;

// ===========================
// RECEIPT SCANNER FUNCTIONALITY
// ===========================

// Global scanner state
let cameraStream = null;
let currentCamera = 'environment';
let capturedImageData = null;
let extractedReceiptData = null;

// UI render throttling
let renderThrottle = null;
let lastRenderTime = 0;
const RENDER_THROTTLE_MS = 500; // Only allow renders every 500ms

// Throttled render function to prevent excessive refreshing
function throttledRender() {
    const now = Date.now();
    
    if (renderThrottle) {
        clearTimeout(renderThrottle);
    }
    
    const timeSinceLastRender = now - lastRenderTime;
    
    if (timeSinceLastRender >= RENDER_THROTTLE_MS) {
        // Render immediately if enough time has passed
        lastRenderTime = now;
        renderAccordionSections();
        updateSummary();
    } else {
        // Schedule render for later
        const delay = RENDER_THROTTLE_MS - timeSinceLastRender;
        renderThrottle = setTimeout(() => {
            lastRenderTime = Date.now();
            renderAccordionSections();
            updateSummary();
        }, delay);
    }
}

// Open receipt scanner modal
function openReceiptScanner() {
    if (!CONFIG.RECEIPT_SCANNER.ENABLED) {
        showNotification('Receipt scanner is disabled in configuration', 'error');
        return;
    }
    
    document.getElementById('receiptScannerModal').style.display = 'flex';
    document.body.style.overflow = 'hidden';
    
    // Reset scanner state
    resetScannerState();
    
    // Initialize camera
    initializeCamera();
}

// Close receipt scanner modal
function closeReceiptScanner() {
    document.getElementById('receiptScannerModal').style.display = 'none';
    document.body.style.overflow = 'auto';
    
    // Stop camera stream
    if (cameraStream) {
        cameraStream.getTracks().forEach(track => track.stop());
        cameraStream = null;
    }
}

// Reset scanner to initial state
function resetScannerState() {
    document.getElementById('cameraPreview').style.display = 'block';
    document.getElementById('capturedImage').style.display = 'none';
    document.getElementById('processingIndicator').style.display = 'none';
    document.getElementById('ocrResults').style.display = 'none';
    capturedImageData = null;
    extractedReceiptData = null;
}

// Initialize camera access
async function initializeCamera() {
    try {
        const constraints = {
            video: {
                ...CONFIG.RECEIPT_SCANNER.CAMERA.VIDEO_CONSTRAINTS,
                facingMode: currentCamera
            }
        };
        
        cameraStream = await navigator.mediaDevices.getUserMedia(constraints);
        const video = document.getElementById('cameraVideo');
        video.srcObject = cameraStream;
        
        console.log('Camera initialized successfully');
        showNotification('Camera ready - position receipt in frame', 'success');
        
    } catch (error) {
        console.error('Camera access error:', error);
        showNotification('Camera access denied. Please allow camera permissions.', 'error');
    }
}

// Toggle between front and back camera
async function toggleCamera() {
    if (cameraStream) {
        cameraStream.getTracks().forEach(track => track.stop());
    }
    
    currentCamera = currentCamera === 'environment' ? 'user' : 'environment';
    await initializeCamera();
}

// Enhanced receipt capture with image processing for better OCR
function captureReceipt() {
    const video = document.getElementById('cameraVideo');
    const canvas = document.createElement('canvas');
    const context = canvas.getContext('2d');
    
    // Wait for auto-focus if configured
    const autoFocusDelay = CONFIG.RECEIPT_SCANNER.CAMERA.RECEIPT_CAPTURE?.AUTO_FOCUS_DELAY || 0;
    if (autoFocusDelay > 0) {
        showNotification('📷 Focusing...', 'info');
        setTimeout(() => performCapture(), autoFocusDelay);
    } else {
        performCapture();
    }
    
    function performCapture() {
        // Set canvas dimensions to match video with high resolution
        const maxWidth = 2048; // High res for better OCR
        const aspectRatio = video.videoHeight / video.videoWidth;
        
        canvas.width = Math.min(video.videoWidth, maxWidth);
        canvas.height = canvas.width * aspectRatio;
        
        // Enable image smoothing for better quality
        context.imageSmoothingEnabled = true;
        context.imageSmoothingQuality = 'high';
        
        // Draw current frame to canvas
        context.drawImage(video, 0, 0, canvas.width, canvas.height);
        
        // Apply image enhancements for better OCR
        const receiptConfig = CONFIG.RECEIPT_SCANNER.CAMERA.RECEIPT_CAPTURE;
        if (receiptConfig?.BRIGHTNESS_ADJUSTMENT || receiptConfig?.CONTRAST_ENHANCEMENT) {
            enhanceImageForOCR(context, canvas.width, canvas.height, receiptConfig);
        }
        
        // Convert to base64 with high quality for OCR
        const quality = CONFIG.RECEIPT_SCANNER.CAMERA.PHOTO_QUALITY || 0.92;
        capturedImageData = canvas.toDataURL('image/jpeg', quality);
        
        // Show captured image
        document.getElementById('cameraPreview').style.display = 'none';
        document.getElementById('capturedImage').style.display = 'block';
        document.getElementById('receiptImage').src = capturedImageData;
        
        // Stop camera stream
        if (cameraStream) {
            cameraStream.getTracks().forEach(track => track.stop());
            cameraStream = null;
        }
        
        showNotification('📄 Receipt captured! Ready to process.', 'success');
    }
}

// Image enhancement function for better OCR results
function enhanceImageForOCR(context, width, height, config) {
    if (!config.CONTRAST_ENHANCEMENT && !config.BRIGHTNESS_ADJUSTMENT) {
        return; // No enhancements needed
    }
    
    try {
        const imageData = context.getImageData(0, 0, width, height);
        const data = imageData.data;
        
        const brightness = config.BRIGHTNESS_ADJUSTMENT || 0;
        const contrast = config.CONTRAST_ENHANCEMENT ? 1.2 : 1; // 20% contrast boost
        
        // Apply brightness and contrast adjustments
        for (let i = 0; i < data.length; i += 4) {
            // Red, Green, Blue channels (skip Alpha)
            for (let j = 0; j < 3; j++) {
                let pixel = data[i + j];
                
                // Apply contrast
                pixel = ((pixel - 128) * contrast) + 128;
                
                // Apply brightness
                pixel = pixel + (brightness * 255);
                
                // Clamp to valid range
                data[i + j] = Math.max(0, Math.min(255, pixel));
            }
        }
        
        // Put the enhanced image data back
        context.putImageData(imageData, 0, 0);
        
        console.log('Applied OCR image enhancements:', { brightness, contrast });
    } catch (error) {
        console.warn('Failed to enhance image for OCR:', error);
        // Continue without enhancement
    }
}

// Retake photo
function retakePhoto() {
    resetScannerState();
    initializeCamera();
}

// Process receipt with OCR
async function processReceipt() {
    if (!capturedImageData) {
        showNotification('No image captured to process', 'error');
        return;
    }
    
    // Show processing indicator
    document.getElementById('capturedImage').style.display = 'none';
    document.getElementById('processingIndicator').style.display = 'block';
    
    try {
        // Use real Veryfi API if configured, otherwise fall back to mock
        let ocrResults;
        const apiConfig = CONFIG.RECEIPT_SCANNER.OCR_API;
        
        if (apiConfig.API_KEY && apiConfig.API_KEY !== 'your_veryfi_api_key_here') {
            console.log('Using Veryfi API for OCR processing...');
            ocrResults = await callVeryfiAPI(capturedImageData);
        } else {
            console.log('Using mock OCR for demo (configure Veryfi API keys for production)');
            ocrResults = await mockOCRProcessing(capturedImageData);
        }
        
        if (ocrResults && ((ocrResults.line_items && ocrResults.line_items.length > 0) || ocrResults.vendor)) {
            extractedReceiptData = ocrResults;
            displayOCRResults(ocrResults);
        } else {
            throw new Error('No items found on receipt');
        }
        
    } catch (error) {
        console.error('OCR processing error:', error);
        showNotification('Failed to process receipt: ' + error.message, 'error');
        
        // Return to captured image view
        document.getElementById('processingIndicator').style.display = 'none';
        document.getElementById('capturedImage').style.display = 'block';
    }
}

// Mock OCR processing for demo (replace with real Veryfi API call)
async function mockOCRProcessing(imageData) {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Mock response with typical Home Depot items
    return {
        vendor: {
            name: "The Home Depot",
            address: "123 Main St, Midland, TX 79701"
        },
        date: new Date().toISOString().split('T')[0],
        total: 127.45,
        tax: 9.68,
        line_items: [
            {
                description: "2x4x8 Pressure Treated Lumber",
                sku: "HD123456",
                quantity: 6,
                unit_price: 8.97,
                total: 53.82
            },
            {
                description: "Quikrete Concrete Mix 80lb",
                sku: "HD789012", 
                quantity: 4,
                unit_price: 4.48,
                total: 17.92
            },
            {
                description: "Deck Screws 2.5\" Box",
                sku: "HD345678",
                quantity: 2,
                unit_price: 12.97,
                total: 25.94
            }
        ]
    };
}

// Real Veryfi OCR API call (requires API keys)
async function callVeryfiAPI(imageData) {
    const apiConfig = CONFIG.RECEIPT_SCANNER.OCR_API;
    
    if (!apiConfig.API_KEY || apiConfig.API_KEY === 'your_veryfi_api_key_here') {
        throw new Error('Veryfi API key not configured');
    }
    
    try {
        // Validate image data format
        if (!imageData || !imageData.startsWith('data:image/')) {
            throw new Error('Invalid image data format');
        }
        
        // Convert base64 to blob with proper error handling
        const base64Response = await fetch(imageData);
        if (!base64Response.ok) {
            throw new Error('Failed to process image data');
        }
        
        const blob = await base64Response.blob();
        
        // Validate blob size (Veryfi has file size limits)
        const maxSize = 10 * 1024 * 1024; // 10MB limit
        if (blob.size > maxSize) {
            throw new Error('Image file too large. Please use a smaller image.');
        }
        
        if (blob.size === 0) {
            throw new Error('Image file is empty');
        }
        
        // Create form data
        const formData = new FormData();
        formData.append('file', blob, 'receipt.jpg');
        
        // Add enhanced processing parameters
        if (apiConfig.AUTO_ROTATE) {
            formData.append('auto_rotate', 'true');
        }
        if (apiConfig.BOOST_MODE) {
            formData.append('boost_mode', 'true');
        }
        if (apiConfig.CATEGORIES && Array.isArray(apiConfig.CATEGORIES)) {
            formData.append('categories', apiConfig.CATEGORIES.join(','));
        }
        
        // Add additional processing options for better accuracy
        formData.append('auto_delete', apiConfig.AUTO_DELETE ? 'true' : 'false');
        formData.append('external_id', `basin-pool-${Date.now()}`);
        
        // Generate proper authentication signature
        const timestamp = Math.floor(Date.now() / 1000).toString();
        
        // Call Veryfi API with enhanced authentication and timeout
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), apiConfig.TIMEOUT || 30000);
        
        const apiResponse = await fetch(apiConfig.BASE_URL, {
            method: 'POST',
            headers: {
                'CLIENT-ID': apiConfig.CLIENT_ID,
                'AUTHORIZATION': `apikey ${apiConfig.USERNAME}:${apiConfig.API_KEY}`,
                'X-Veryfi-Request-Timestamp': timestamp,
                'Accept': 'application/json',
                'User-Agent': 'Basin-Pool-Inventory/1.0'
            },
            body: formData,
            signal: controller.signal
        });
        
        clearTimeout(timeoutId);
        
        // Enhanced error handling
        if (!apiResponse.ok) {
            const contentType = apiResponse.headers.get('content-type');
            let errorMessage;
            
            if (contentType && contentType.includes('application/json')) {
                const errorData = await apiResponse.json();
                errorMessage = errorData.error || errorData.message || `HTTP ${apiResponse.status}`;
            } else {
                errorMessage = await apiResponse.text();
            }
            
            // Handle specific error cases
            switch (apiResponse.status) {
                case 401:
                    throw new Error('Authentication failed. Please check API credentials.');
                case 402:
                    throw new Error('Insufficient credits. Please check your Veryfi account.');
                case 413:
                    throw new Error('Image file too large. Please use a smaller image.');
                case 429:
                    throw new Error('API rate limit exceeded. Please try again later.');
                default:
                    throw new Error(`API error (${apiResponse.status}): ${errorMessage}`);
            }
        }
        
        const veryfiData = await apiResponse.json();
        
        // Validate API response structure
        if (!veryfiData || typeof veryfiData !== 'object') {
            throw new Error('Invalid API response format');
        }
        
        // Enhanced data conversion with validation
        const processedData = {
            vendor: {
                name: (veryfiData.vendor?.name || 'Unknown Store').trim(),
                address: (veryfiData.vendor?.address || '').trim()
            },
            date: veryfiData.date || new Date().toISOString().split('T')[0],
            total: parseFloat(veryfiData.total) || 0,
            tax: parseFloat(veryfiData.tax) || 0,
            subtotal: parseFloat(veryfiData.subtotal) || 0,
            line_items: []
        };
        
        // Process line items with enhanced validation
        if (veryfiData.line_items && Array.isArray(veryfiData.line_items)) {
            processedData.line_items = veryfiData.line_items
                .filter(item => item && (item.description || item.name)) // Filter out invalid items
                .map(item => {
                    const quantity = Math.max(1, parseInt(item.quantity) || 1);
                    const total = parseFloat(item.total) || 0;
                    const unitPrice = parseFloat(item.unit_price) || (total / quantity);
                    
                    return {
                        description: (item.description || item.name || 'Unknown Item').trim(),
                        sku: (item.sku || item.upc || '').trim() || null,
                        quantity: quantity,
                        unit_price: Math.round(unitPrice * 100) / 100, // Round to 2 decimals
                        total: Math.round(total * 100) / 100,
                        category: (item.category || '').trim() || null
                    };
                })
                .filter(item => item.total > 0); // Only include items with valid totals
        }
        
        // Validate that we got useful data
        if (processedData.line_items.length === 0 && processedData.total === 0) {
            throw new Error('No valid items or total found on receipt');
        }
        
        console.log('Veryfi OCR processing successful:', {
            vendor: processedData.vendor.name,
            items: processedData.line_items.length,
            total: processedData.total
        });
        
        return processedData;
        
    } catch (error) {
        console.error('Veryfi API call failed:', error);
        
        // Handle timeout errors specifically
        if (error.name === 'AbortError') {
            throw new Error('Request timed out. Please try again with a clearer image.');
        }
        
        // Re-throw with enhanced error context
        throw new Error(`OCR processing failed: ${error.message}`);
    }
}

// Display OCR results
function displayOCRResults(ocrData) {
    document.getElementById('processingIndicator').style.display = 'none';
    document.getElementById('ocrResults').style.display = 'block';
    
    const extractedItemsDiv = document.getElementById('extractedItems');
    extractedItemsDiv.innerHTML = '';
    
    // Show store and date info
    const storeInfo = document.createElement('div');
    storeInfo.className = 'store-info';
    storeInfo.innerHTML = `
        <h4>📍 ${ocrData.vendor?.name || 'Unknown Store'}</h4>
        <p>📅 ${ocrData.date || 'Unknown Date'}</p>
        <p>💰 Total: $${ocrData.total?.toFixed(2) || '0.00'} (Tax: $${ocrData.tax?.toFixed(2) || '0.00'})</p>
    `;
    extractedItemsDiv.appendChild(storeInfo);
    
    // Display each line item
    if (ocrData.line_items && ocrData.line_items.length > 0) {
        ocrData.line_items.forEach((item, index) => {
            const itemDiv = document.createElement('div');
            itemDiv.className = 'extracted-item';
            itemDiv.innerHTML = `
                <div class="item-info">
                    <div class="item-name">${item.description || 'Unknown Item'}</div>
                    <div class="item-details">
                        SKU: ${item.sku || 'N/A'} | Qty: ${item.quantity || 1} | Unit: $${(item.unit_price || 0).toFixed(2)}
                    </div>
                </div>
                <div class="item-price">$${(item.total || 0).toFixed(2)}</div>
            `;
            extractedItemsDiv.appendChild(itemDiv);
        });
    }
    
    showNotification(`Extracted ${ocrData.line_items?.length || 0} items from receipt`, 'success');
}

// Add extracted items to inventory
function addExtractedItems() {
    if (!extractedReceiptData || !extractedReceiptData.line_items) {
        showNotification('No extracted data to add', 'error');
        return;
    }
    
    let itemsAdded = 0;
    const targetSection = 'siteprep'; // Default section for scanned items
    
    extractedReceiptData.line_items.forEach(item => {
        const newItem = {
            name: item.description || 'Scanned Item',
            actualPrice: item.total || 0,
            quantity: item.quantity || 1,
            usage: 'consumable',
            location: 'local',
            link: '',
            status: 'purchased',
            notes: `${item.description || 'Unknown product'} // Scanned from receipt${item.sku ? ` (SKU: ${item.sku})` : ''}`
        };
        
        // Add to target section
        if (!inventoryData[targetSection]) {
            inventoryData[targetSection] = [];
        }
        inventoryData[targetSection].push(newItem);
        itemsAdded++;
    });
    
    // Update UI and save
    renderAccordionSections();
    updateSummary();
    forceSave();
    
    showNotification(`Added ${itemsAdded} items to ${targetSection} inventory`, 'success');
    closeReceiptScanner();
}

// Reset scanner for new receipt
function resetScanner() {
    resetScannerState();
    initializeCamera();
}

// ===========================
// PRODUCT LOOKUP & VERIFICATION
// ===========================

// Verify extracted items with Home Depot API
async function verifyExtractedItems(extractedData) {
    const config = CONFIG.RECEIPT_SCANNER.PRODUCT_LOOKUP;
    
    if (!config.ENABLED || !config.HOME_DEPOT_API_KEY || config.HOME_DEPOT_API_KEY === 'your_bigbox_api_key_here') {
        console.log('Product lookup disabled or API key not configured');
        return extractedData; // Return original data unchanged
    }
    
    console.log('Verifying products with Home Depot API...');
    
    try {
        const verifiedItems = await Promise.all(
            extractedData.line_items.map(async (item) => {
                try {
                    const productInfo = await lookupProduct(item.sku || item.description);
                    return enhanceItemWithProductData(item, productInfo);
                } catch (error) {
                    console.warn(`Could not verify product: ${item.description}`, error);
                    return item; // Return original item if lookup fails
                }
            })
        );
        
        return {
            ...extractedData,
            line_items: verifiedItems
        };
        
    } catch (error) {
        console.error('Product verification failed:', error);
        return extractedData; // Return original data if verification fails
    }
}

// Lookup individual product with BigBox API
async function lookupProduct(skuOrDescription) {
    const config = CONFIG.RECEIPT_SCANNER.PRODUCT_LOOKUP;
    
    const params = new URLSearchParams({
        api_key: config.HOME_DEPOT_API_KEY,
        type: 'search',
        search_term: skuOrDescription,
        max_page: 1
    });
    
    const response = await fetch(`${config.BASE_URL}?${params}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    });
    
    if (!response.ok) {
        throw new Error(`BigBox API error: ${response.status}`);
    }
    
    const data = await response.json();
    
    if (data.search_results && data.search_results.length > 0) {
        return data.search_results[0]; // Return first match
    }
    
    throw new Error('No product found');
}

// Enhance item with verified product data
function enhanceItemWithProductData(originalItem, productData) {
    const config = CONFIG.RECEIPT_SCANNER.PRODUCT_LOOKUP;
    
    // Check price difference if verification is enabled
    let priceVerification = null;
    if (config.VERIFY_PRICES && productData.price?.value) {
        const storePriceCents = productData.price.value * 100;
        const receiptPriceCents = originalItem.unit_price * 100;
        const difference = Math.abs(storePriceCents - receiptPriceCents) / storePriceCents;
        
        if (difference > config.PRICE_TOLERANCE) {
            priceVerification = {
                status: 'warning',
                message: `Price difference detected: Receipt $${originalItem.unit_price.toFixed(2)} vs Store $${productData.price.value.toFixed(2)}`,
                receipt_price: originalItem.unit_price,
                store_price: productData.price.value,
                difference_percent: (difference * 100).toFixed(1)
            };
        } else {
            priceVerification = {
                status: 'verified',
                message: 'Price verified'
            };
        }
    }
    
    return {
        ...originalItem,
        // Enhanced product information
        verified_name: productData.title || originalItem.description,
        brand: productData.brand || null,
        model: productData.model || null,
        verified_sku: productData.asin || productData.item_id || originalItem.sku,
        product_url: productData.link || null,
        availability: productData.availability || null,
        price_verification: priceVerification,
        // Metadata
        verification_status: 'verified',
        verification_confidence: productData.position <= 3 ? 'high' : 'medium' // First 3 results are high confidence
    };
}