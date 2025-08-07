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
    
    // Check if Firebase is available
    if (CONFIG.FIREBASE_SYNC.ENABLED && window.database) {
        initializeFirebase();
    } else {
        // Fallback to local storage
        loadFromLocalStorage();
        startAutoSave();
    }
    
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
        dataRef = Firebase.ref(database, 'inventory');
        presenceRef = Firebase.ref(database, 'presence');
        
        // Set up real-time data listener
        Firebase.onValue(dataRef, (snapshot) => {
            if (snapshot.exists()) {
                const firebaseData = snapshot.val();
                if (firebaseData.lastUpdated > lastUpdateTimestamp) {
                    lastUpdateTimestamp = firebaseData.lastUpdated;
                    // Merge Firebase data with default template to ensure new sections exist
                    inventoryData = mergeWithDefaultData(firebaseData.data);
                    renderAllSections();
                    updateSummary();
                    loadProjectNotes();
                    showSaveIndicator('Synced from cloud');
                }
            } else {
                // Firebase is empty, save default data to it
                console.log('Firebase is empty, initializing with default data');
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
        
        // Set up presence system
        if (CONFIG.FIREBASE_SYNC.PRESENCE_ENABLED) {
            setupPresence();
        }
        
        // Handle connection state
        const connectedRef = Firebase.ref(database, '.info/connected');
        Firebase.onValue(connectedRef, (snapshot) => {
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
    
    const userPresenceRef = Firebase.ref(database, `presence/${currentUser.id}`);
    
    // Set user as online
    Firebase.set(userPresenceRef, {
        ...currentUser,
        online: true,
        lastSeen: Firebase.serverTimestamp()
    });
    
    // Remove user when they disconnect
    Firebase.onDisconnect(userPresenceRef).remove();
    
    // Listen for presence changes
    Firebase.onValue(presenceRef, (snapshot) => {
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
        { name: 'Filter Balls', actualPrice: 24.79, quantity: 1, usage: 'per-job', location: 'online', link: '', status: 'purchased', notes: 'MAQIHAN 50PCS Pool Filter Balls - Replaces 100 lbs pool filter sand, reusable filtration media' },
        { name: 'Water Transfer Pump', actualPrice: 49.99, quantity: 1, usage: 'per-job', location: 'online', link: '', status: 'purchased', notes: 'VEVOR Water Transfer Removal Pump - 360 GPH utility pump with hose for water transfer operations' },
        { name: 'Sand Filter Pump', actualPrice: 230.90, quantity: 1, usage: 'per-job', location: 'online', link: '', status: 'purchased', notes: 'INTEX 26641EG Krystal Clear Sand Filter - 4,400 GPH pool pump system, open box condition' },
        { name: 'Propane Heater', actualPrice: 299.99, quantity: 1, usage: 'per-job', location: 'online', link: '', status: 'purchased', notes: 'Outdoor Propane Tankless Water Heater - 120,000 BTU instant heater, 5.3 gallon capacity' },
        
        // 🛒 HOME DEPOT - ELECTRICAL ($98.98)
        { name: '2-Gang FSC Box', actualPrice: 8.74, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Cantex 1/2 in. 2-Gang FSC Box' },
        { name: '4-Gang Deep Box', actualPrice: 18.88, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Commercial Electric 4-Gang Extra Deep Box' },
        { name: 'Plastic Anchors', actualPrice: 9.91, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Triple Grip Plastic Anchors (15-pack)' },
        { name: '1-Gang PVC Boxes', actualPrice: 6.60, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Carlon 1-Gang PVC Boxes (2)' },
        { name: 'Box Covers', actualPrice: 4.88, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Carlon Box Covers (2)' },
        { name: 'Liquid-Tight Conduit', actualPrice: 44.99, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'HYDROMAXX 50ft Liquid-Tight Conduit' },
        { name: 'Conduit Clamps', actualPrice: 4.98, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Carlon Conduit Clamps (25-pack)' },
        
        // 🛒 TSC MIDLAND - TANK ($599)
        { name: 'Stock Tank (8ft)', actualPrice: 599.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '8ft CountyLine Stock Tank - 8 foot diameter galvanized, 2 foot depth, ~700 gallons. CALL AHEAD FOR AVAILABILITY' },
        
        // 🛒 HOME DEPOT - PLUMBING HARDWARE ($150)
        { name: 'Bulkhead Fittings', actualPrice: 60.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x Bulkhead Tank Fittings (2") - Through-wall penetrations with gaskets' },
        { name: 'PVC Pipe & Fittings', actualPrice: 40.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'PVC Pipe & Fittings Kit - 1.5" main line (10 feet), 1/2" heater line (20 feet), elbows, tees, couplers, cement' },
        { name: 'Check Valves', actualPrice: 30.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x Check Valves (1.5" & 1/2")' },
        { name: 'Gate Valves', actualPrice: 24.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x Gate Valves (1.5" & 1/2")' },
        { name: 'Tank Drain Valve', actualPrice: 20.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Tank Drain Valve Kit' },
        { name: 'Hose Clamps & Adapters', actualPrice: 25.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Hose Clamps & Adapters' },
        { name: 'Teflon & Sealant', actualPrice: 15.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Teflon Tape & Sealant' },
        
        // 🛒 HOME DEPOT - DECK MATERIALS ($675)
        { name: 'Concrete Pier Blocks', actualPrice: 108.00, quantity: 9, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '9x Concrete Pier Blocks' },
        { name: 'PT Posts', actualPrice: 54.00, quantity: 3, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '3x 4x4x8\' PT Posts' },
        { name: 'PT Boards 8ft', actualPrice: 34.00, quantity: 4, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '4x 2x6x8\' PT Boards' },
        { name: 'PT Boards 12ft', actualPrice: 28.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x 2x6x12\' PT Boards' },
        { name: 'PT Deck Boards', actualPrice: 240.00, quantity: 20, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '20x 5/4"x6"x8\' PT Deck Boards' },
        { name: 'Stair Stringers', actualPrice: 90.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x 3-Step Stair Stringers' },
        { name: 'Joist Hangers', actualPrice: 30.00, quantity: 12, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '12x 2x6 Joist Hangers' },
        { name: 'Stringer Connectors', actualPrice: 16.00, quantity: 2, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '2x Stair Stringer Connectors' },
        { name: 'TimberLOK Screws', actualPrice: 35.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'TimberLOK 4" Screws (1 box)' },
        { name: 'Deck Screws', actualPrice: 25.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Exterior Deck Screws (5 lbs)' },
        { name: 'Joist Hanger Nails', actualPrice: 15.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Joist Hanger Nails (1 box)' },
        
        // 🛒 RECOM MATERIALS - PICKUP ($150)
        { name: 'Caliche Base', actualPrice: 45.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '1 Yard Caliche Base' },
        { name: 'Pea Gravel', actualPrice: 80.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: '1 Yard Pea Gravel' },
        { name: 'Landscape Fabric', actualPrice: 25.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Landscape Fabric (45 sq ft)' },
        
        // 🛒 HOME DEPOT - LANDSCAPE EDGING ($113)
        { name: 'Landscape Edging', actualPrice: 113.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Colmet 8 ft. x 4 in. 14-Gauge Brown Steel Landscape Edging (5-Pack) - Home Depot' },
        
        // 🛒 MISCELLANEOUS SUPPLIES ($100)
        { name: 'Extra Fittings', actualPrice: 40.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Extra Fittings & Adapters' },
        { name: 'Safety Equipment', actualPrice: 25.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Safety Equipment' },
        { name: 'Installation Tools', actualPrice: 35.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Installation Tools/Consumables' },
        
        // 🛒 LABOR
        { name: 'Installation Labor', actualPrice: 750.00, quantity: 1, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Complete Installation Labor' }
    ];

    // One-Time Tools (template with $0 prices)
    inventoryData.tools = [
        // Tank Installation Tools
        { name: 'Hole Saw Set (1.5", 2", 3")', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Tank fittings' },
        { name: 'Cordless Drill (if needed)', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'both', link: '', status: 'pending', notes: 'May already have' },
        { name: 'Step Bit Set', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Clean holes' },
        { name: 'Level (4ft)', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Tank leveling' },
        { name: 'Socket Set & Wrenches', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'both', link: '', status: 'pending', notes: 'Pump assembly' },
        { name: 'Shop Vacuum (wet/dry)', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Cleanup' },
        
        // Professional Excavation & Site Prep Tools
        { name: 'Mini Excavator Rental (per day)', actualPrice: 0, quantity: 0, usage: 'per-job', location: 'local', link: '', status: 'pending', notes: 'Large pad excavation' },
        { name: 'Trenching Shovel', actualPrice: 0, quantity: 0, usage: 'one-time', location: 'local', link: '', status: 'pending', notes: 'Hand excavation' },
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
    
    inventoryData.cliff.forEach((item, index) => {
        const category = categorizeItem(item);
        categories[category].push({ ...item, originalIndex: index });
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
                <input type="text" class="item-name-input" value="${item.name}" onchange="updateItemField('cliff', ${item.originalIndex}, 'name', this.value)">
            </td>
            <td>
                <input type="number" class="price-input" value="${item.actualPrice || 0}" step="0.01" min="0" onchange="updateItemField('cliff', ${item.originalIndex}, 'actualPrice', parseFloat(this.value))">
            </td>
            <td>
                <input type="number" class="qty-input" value="${item.quantity || 1}" min="0" onchange="updateItemField('cliff', ${item.originalIndex}, 'quantity', parseInt(this.value))">
            </td>
            <td>
                <select class="usage-select" onchange="updateItemField('cliff', ${item.originalIndex}, 'usage', this.value)">
                    ${Object.keys(CONFIG.USAGE_TYPES).map(usage => 
                        `<option value="${usage}" ${item.usage === usage ? 'selected' : ''}>${CONFIG.USAGE_TYPES[usage].label}</option>`
                    ).join('')}
                </select>
            </td>
            <td>
                <select class="location-select" onchange="updateItemField('cliff', ${item.originalIndex}, 'location', this.value)">
                    ${Object.keys(CONFIG.LOCATION_TYPES).map(location => 
                        `<option value="${location}" ${item.location === location ? 'selected' : ''}>${CONFIG.LOCATION_TYPES[location].label}</option>`
                    ).join('')}
                </select>
            </td>
            <td>
                <input type="url" class="link-input" value="${item.link || ''}" placeholder="Supplier URL" onchange="updateItemField('cliff', ${item.originalIndex}, 'link', this.value)">
            </td>
            <td>
                <button class="status ${item.status}" onclick="cycleStatus(this)" data-section="cliff" data-index="${item.originalIndex}">
                    ${CONFIG.STATUS_TYPES[item.status]?.label || item.status}
                </button>
                ${item.status !== 'purchased' ? `<button class="quick-purchase-btn" onclick="openQuickPurchase('cliff', ${item.originalIndex})" title="Quick Purchase">🛒</button>` : ''}
            </td>
            <td>
                <textarea class="notes-input" placeholder="Notes, supplier info, etc." onchange="updateItemField('cliff', ${item.originalIndex}, 'notes', this.value)">${item.notes || ''}</textarea>
                <button class="delete-item-btn" onclick="deleteItem('cliff', ${item.originalIndex})" title="Delete Item">🗑️</button>
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
        inventoryData[section][index][field] = value;
        console.log('Data updated:', inventoryData[section][index]); // Debug
        
        // Re-render accordion sections to update categories and totals
        renderAccordionSections();
        updateSummary();
        
        // Force immediate save
        forceSave();
        
    } else {
        console.error('Could not update field - invalid section or index:', section, index);
    }
}

// Force immediate save (both Firebase and localStorage)
function forceSave() {
    console.log('Force saving data...'); // Debug
    
    // Always save to localStorage as backup
    saveToLocalStorage();
    
    // Also try Firebase if available
    if (isFirebaseReady && dataRef) {
        console.log('Saving to Firebase...'); // Debug
        saveToFirebase();
    } else {
        console.log('Firebase not ready, localStorage only'); // Debug
    }
    
    showSaveIndicator('Saved');
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
        row.innerHTML = `
            <td data-label="Item">
                <input type="text" class="item-name-input" data-section="${section}" data-index="${index}" data-field="name" 
                       value="${item.name}" placeholder="Item name..." style="font-weight: bold; border: 1px solid #e1e8ed; padding: 6px; border-radius: 4px; width: 100%; background: #fafbfc;">
            </td>
            <td data-label="Price">
                <input type="number" class="price-input" data-section="${section}" data-index="${index}" data-field="actualPrice" 
                       value="${item.actualPrice || ''}" placeholder="$" step="0.01">
            </td>
            <td data-label="Qty">
                <input type="number" class="qty-input" data-section="${section}" data-index="${index}" data-field="quantity" 
                       value="${item.quantity}" min="0">
            </td>
            <td data-label="Usage">
                <select class="usage-select" data-section="${section}" data-index="${index}" data-field="usage" style="padding: 6px; border: 1px solid #e1e8ed; border-radius: 4px; font-size: 0.85em;">
                    <option value="one-time" ${item.usage === 'one-time' ? 'selected' : ''}>One-Time</option>
                    <option value="per-job" ${item.usage === 'per-job' ? 'selected' : ''}>Per Job</option>
                    <option value="reusable" ${item.usage === 'reusable' ? 'selected' : ''}>Reusable</option>
                    <option value="consumable" ${item.usage === 'consumable' ? 'selected' : ''}>Consumable</option>
                </select>
            </td>
            <td data-label="Location">
                <select class="location-select" data-section="${section}" data-index="${index}" data-field="location">
                    <option value="online" ${item.location === 'online' ? 'selected' : ''}>Online</option>
                    <option value="local" ${item.location === 'local' ? 'selected' : ''}>Local Midland TX</option>
                    <option value="both" ${item.location === 'both' ? 'selected' : ''}>Both</option>
                </select>
                <span class="location-badge ${item.location}">
                    ${item.location === 'online' ? 'Online' : item.location === 'local' ? 'Local TX' : 'Both'}
                </span>
            </td>
            <td data-label="Supplier Link">
                <input type="url" class="link-input" data-section="${section}" data-index="${index}" data-field="link" 
                       value="${item.link}" placeholder="Supplier link...">
            </td>
            <td data-label="Status">
                <span class="status ${item.status}" data-section="${section}" data-index="${index}">${CONFIG.STATUS_TYPES[item.status]?.label || item.status}</span>
                ${item.status === 'pending' || item.status === 'ordered' ? 
                    `<button class="quick-purchase-btn" onclick="openQuickPurchase('${section}', ${index})" title="Quick Purchase (${section}[${index}]: ${item.name})">💳</button>` : 
                    ''}
                ${item.receiptPhoto ? 
                    `<button class="view-receipt-btn" onclick="viewReceipt('${section}', ${index})" title="View Receipt">📷</button>` : 
                    ''}
            </td>
            <td data-label="Notes">
                <input type="text" class="notes-input" data-section="${section}" data-index="${index}" data-field="notes" 
                       value="${item.notes}" placeholder="Notes...">
                <button class="delete-item-btn" onclick="deleteItem('${section}', ${index})" title="Delete item">🗑️</button>
            </td>
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
    
    // Re-render accordion sections
    renderAccordionSections();
    
    scheduleAutoSave();
    updateSummary();
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
    
    // Site Prep
    if (notes.includes('caliche') || notes.includes('gravel') || notes.includes('landscape') ||
        notes.includes('fabric') || name.includes('caliche') || name.includes('gravel')) {
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
                
                // Calculate costs - actualPrice is already the total cost for the quantity specified
                const actualPrice = item.actualPrice || 0;
                // Don't multiply by quantity - actualPrice already includes the total cost
                const totalPrice = actualPrice;
                
                if (section === 'cliff') {
                    cliffTotal += totalPrice;
                } else if (item.usage === 'one-time') {
                    oneTimeTotal += totalPrice;
                } else {
                    perJobTotal += totalPrice;
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
    if (CONFIG.AUTO_SAVE.ENABLED) {
        setInterval(() => {
            if (isFirebaseReady && dataRef) {
                saveToFirebase();
            } else {
                saveToLocalStorage();
            }
        }, CONFIG.AUTO_SAVE.INTERVAL);
    }
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
        
        Firebase.set(dataRef, dataToSave).then(() => {
            console.log('Data saved to Firebase');
            showSaveIndicator('Synced to cloud');
        }).catch((error) => {
            console.error('Firebase save error:', error);
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
        if (saved) {
            const parsedData = JSON.parse(saved);
            // Merge saved data with current data, preserving structure
            Object.keys(inventoryData).forEach(key => {
                if (parsedData[key] !== undefined) {
                    inventoryData[key] = parsedData[key];
                }
            });
            
            // Load project notes
            if (parsedData.projectNotes) {
                const notesElement = document.getElementById('projectNotes');
                if (notesElement) {
                    notesElement.value = parsedData.projectNotes;
                }
            }
        }
    } catch (error) {
        console.error('Failed to load from localStorage:', error);
    }
}

// Cloud sync functionality
function startCloudSync() {
    if (CONFIG.CLOUD_SYNC.ENABLED) {
        setInterval(() => {
            syncToCloud();
        }, CONFIG.CLOUD_SYNC.INTERVAL);
    }
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
        
        // Update summary and save
        updateSummary();
        scheduleAutoSave();
        
        showNotification(`"${itemName}" deleted`, 'success');
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