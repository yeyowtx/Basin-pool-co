// Basin Pool Co. Inventory Tracker - Real-time Collaborative Edition

// Global state management
let inventoryData = {
    cliff: [],
    tools: [],
    tanks: [],
    pumps: [],
    salt: [],
    heating: [],
    hardware: [],
    projectNotes: ''
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
    
    // Check if Firebase is available
    if (CONFIG.FIREBASE_SYNC.ENABLED && window.database) {
        initializeFirebase();
    } else {
        // Fallback to local storage
        loadFromLocalStorage();
        startAutoSave();
    }
    
    setupEventListeners();
    renderAllSections();
    updateSummary();
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
                    inventoryData = firebaseData.data;
                    renderAllSections();
                    updateSummary();
                    loadProjectNotes();
                    showSaveIndicator('Synced from cloud');
                }
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
    // Cliff's Installation - Lean Startup Materials
    inventoryData.cliff = [
        { name: '8ft CountyLine Tank (700 gal)', estimatedPrice: 600, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Cliff\'s installation' },
        { name: 'Intex SX2800 Sand Filter Pump', estimatedPrice: 225, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: '2-day shipping' },
        { name: 'Filter Balls 4.6lbs', estimatedPrice: 40, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'REVICOAR brand' },
        { name: 'Intex QS200 Salt System', estimatedPrice: 110.99, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Spa experience' },
        { name: 'Pool Salt (50 lb bag)', estimatedPrice: 30, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Local supplier' },
        { name: 'FOGATTI Heater (120k BTU)', estimatedPrice: 500, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'B0CS9M5BFM model' },
        { name: 'Pool Skimmer', estimatedPrice: 15, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Surface cleaning' },
        { name: 'Return Jet Fitting', estimatedPrice: 12, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: '1.5 inch' },
        { name: 'Suction Fitting', estimatedPrice: 18, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Main drain' },
        { name: 'PVC Fittings & Pipe', estimatedPrice: 25, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Elbows, unions' },
        { name: 'Pool Hoses (25ft x2)', estimatedPrice: 60, actualPrice: 0, quantity: 2, usage: 'per-job', link: '', status: 'pending', notes: '1.5 inch diameter' },
        { name: 'GFCI Outlet & Box', estimatedPrice: 40, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Outdoor rated' },
        { name: 'Gas Line Kit', estimatedPrice: 25, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Propane connection' },
        { name: 'Heater Mounting Kit', estimatedPrice: 20, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Brackets, bolts' },
        { name: 'Temp Controller', estimatedPrice: 35, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Digital display' },
        { name: 'Test Strips', estimatedPrice: 15, actualPrice: 0, quantity: 1, usage: 'consumable', link: '', status: 'pending', notes: '50 count' },
        { name: 'Chlorine Tablets (starter)', estimatedPrice: 20, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: '2-week supply' },
        { name: 'Chlorine Dispenser', estimatedPrice: 12, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Floating tablet' },
        { name: 'Pool Thermometer', estimatedPrice: 8, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Floating digital' },
        { name: 'Vacuum Head & Hose', estimatedPrice: 35, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Manual cleaning' },
        { name: 'Pool Ladder', estimatedPrice: 60, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Tank specific' }
    ];

    // One-Time Tools
    inventoryData.tools = [
        { name: 'Hole Saw Set (1.5", 2", 3")', estimatedPrice: 45, actualPrice: 0, quantity: 1, usage: 'one-time', link: '', status: 'pending', notes: 'Tank fittings' },
        { name: 'Cordless Drill (if needed)', estimatedPrice: 120, actualPrice: 0, quantity: 0, usage: 'one-time', link: '', status: 'pending', notes: 'May already have' },
        { name: 'Step Bit Set', estimatedPrice: 25, actualPrice: 0, quantity: 1, usage: 'one-time', link: '', status: 'pending', notes: 'Clean holes' },
        { name: 'Level (4ft)', estimatedPrice: 35, actualPrice: 0, quantity: 1, usage: 'one-time', link: '', status: 'pending', notes: 'Tank leveling' },
        { name: 'Socket Set & Wrenches', estimatedPrice: 45, actualPrice: 0, quantity: 1, usage: 'one-time', link: '', status: 'pending', notes: 'Pump assembly' },
        { name: 'Shop Vacuum (wet/dry)', estimatedPrice: 80, actualPrice: 0, quantity: 1, usage: 'one-time', link: '', status: 'pending', notes: 'Cleanup' }
    ];

    // Additional Tanks
    inventoryData.tanks = [
        { name: '6ft CountyLine (390 gal)', estimatedPrice: 450, actualPrice: 0, quantity: 2, usage: 'per-job', link: '', status: 'pending', notes: 'Singles/couples' },
        { name: '8ft CountyLine (700 gal)', estimatedPrice: 600, actualPrice: 0, quantity: 2, usage: 'per-job', link: '', status: 'pending', notes: 'Most popular' },
        { name: '10ft Behlen (1,117 gal)', estimatedPrice: 875, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'Premium families' }
    ];

    // Additional Pump Systems
    inventoryData.pumps = [
        { name: 'Intex SX2800 (additional)', estimatedPrice: 225, actualPrice: 0, quantity: 4, usage: 'per-job', link: '', status: 'pending', notes: '6ft & 8ft tanks' },
        { name: 'Intex SX3000 (for 10ft)', estimatedPrice: 250, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: '10ft tanks only' },
        { name: 'Filter Balls 4.6lbs (bulk)', estimatedPrice: 40, actualPrice: 0, quantity: 4, usage: 'per-job', link: '', status: 'pending', notes: 'SX2800 pumps' },
        { name: 'Filter Balls 6lbs (10ft)', estimatedPrice: 50, actualPrice: 0, quantity: 1, usage: 'per-job', link: '', status: 'pending', notes: 'SX3000 pumps' }
    ];

    // Salt Water Systems
    inventoryData.salt = [
        { name: 'Intex QS200 (additional)', estimatedPrice: 110.99, actualPrice: 0, quantity: 3, usage: 'per-job', link: '', status: 'pending', notes: '$697 upsell' },
        { name: 'Pool Salt (50 lb bags)', estimatedPrice: 30, actualPrice: 0, quantity: 5, usage: 'per-job', link: '', status: 'pending', notes: 'Local bulk pricing' }
    ];

    // Heating Systems
    inventoryData.heating = [
        { name: 'FOGATTI Heaters (extra)', estimatedPrice: 500, actualPrice: 0, quantity: 2, usage: 'per-job', link: '', status: 'pending', notes: '$1,497 upsell' },
        { name: 'Gas Line Kits (bulk)', estimatedPrice: 25, actualPrice: 0, quantity: 5, usage: 'per-job', link: '', status: 'pending', notes: 'Propane connections' },
        { name: 'Mounting Kits (bulk)', estimatedPrice: 20, actualPrice: 0, quantity: 5, usage: 'per-job', link: '', status: 'pending', notes: 'Brackets, bolts' },
        { name: 'Temp Controllers (bulk)', estimatedPrice: 35, actualPrice: 0, quantity: 5, usage: 'per-job', link: '', status: 'pending', notes: 'Digital displays' }
    ];

    // Standard Hardware
    inventoryData.hardware = [
        { name: 'Pool Skimmers', estimatedPrice: 15, actualPrice: 0, quantity: 5, usage: 'per-job', link: '', status: 'pending', notes: 'Surface cleaning' },
        { name: 'Return Jet Fittings', estimatedPrice: 12, actualPrice: 0, quantity: 5, usage: 'per-job', link: '', status: 'pending', notes: '1.5 inch' },
        { name: 'Suction Fittings', estimatedPrice: 18, actualPrice: 0, quantity: 5, usage: 'per-job', link: '', status: 'pending', notes: 'Main drains' },
        { name: 'Pool Hoses (25ft pairs)', estimatedPrice: 60, actualPrice: 0, quantity: 5, usage: 'per-job', link: '', status: 'pending', notes: '1.5 inch diameter' }
    ];
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

    // Status click handlers
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('status')) {
            cycleStatus(e.target);
        }
    });

    // Input change handlers
    document.addEventListener('input', function(e) {
        if (e.target.matches('.price-input, .qty-input, .link-input, .notes-input')) {
            scheduleAutoSave();
            updateSummary();
        }
    });
}

// Render all inventory sections
function renderAllSections() {
    renderSection('cliff', inventoryData.cliff, 'cliffTable');
    renderSection('tools', inventoryData.tools, 'toolsTable');
    renderSection('tanks', inventoryData.tanks, 'tanksTable');
    renderSection('pumps', inventoryData.pumps, 'pumpsTable');
    renderSection('salt', inventoryData.salt, 'saltTable');
    renderSection('heating', inventoryData.heating, 'heatingTable');
    renderSection('hardware', inventoryData.hardware, 'hardwareTable');
}

// Render a specific inventory section
function renderSection(section, items, tableId) {
    const tbody = document.getElementById(tableId);
    if (!tbody) return;

    tbody.innerHTML = '';
    
    items.forEach((item, index) => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td data-label="Item"><strong>${item.name}</strong></td>
            <td data-label="Est. Price">$${item.estimatedPrice}</td>
            <td data-label="Actual">
                <input type="number" class="price-input" data-section="${section}" data-index="${index}" data-field="actualPrice" 
                       value="${item.actualPrice || ''}" placeholder="$" step="0.01">
            </td>
            <td data-label="Qty">
                <input type="number" class="qty-input" data-section="${section}" data-index="${index}" data-field="quantity" 
                       value="${item.quantity}" min="0">
            </td>
            <td data-label="Usage">
                <span class="usage-type ${item.usage}">${CONFIG.USAGE_TYPES[item.usage]?.label || item.usage}</span>
            </td>
            <td data-label="Link">
                <input type="url" class="link-input" data-section="${section}" data-index="${index}" data-field="link" 
                       value="${item.link}" placeholder="Supplier link...">
            </td>
            <td data-label="Status">
                <span class="status ${item.status}" data-section="${section}" data-index="${index}">${CONFIG.STATUS_TYPES[item.status]?.label || item.status}</span>
            </td>
            <td data-label="Notes">
                <input type="text" class="notes-input" data-section="${section}" data-index="${index}" data-field="notes" 
                       value="${item.notes}" placeholder="Notes...">
            </td>
        `;
        tbody.appendChild(row);
    });

    // Add event listeners for the new inputs
    tbody.querySelectorAll('input').forEach(input => {
        input.addEventListener('input', function() {
            const section = this.dataset.section;
            const index = parseInt(this.dataset.index);
            const field = this.dataset.field;
            const value = this.type === 'number' ? parseFloat(this.value) || 0 : this.value;
            
            inventoryData[section][index][field] = value;
            scheduleAutoSave();
            updateSummary();
        });
    });
}

// Cycle through status options when clicked
function cycleStatus(statusElement) {
    const statuses = ['pending', 'partial', 'verified'];
    const currentStatus = statusElement.classList.contains('pending') ? 'pending' : 
                         statusElement.classList.contains('partial') ? 'partial' : 'verified';
    const currentIndex = statuses.indexOf(currentStatus);
    const nextStatus = statuses[(currentIndex + 1) % statuses.length];
    
    // Update visual
    statusElement.className = `status ${nextStatus}`;
    statusElement.textContent = CONFIG.STATUS_TYPES[nextStatus].label;
    
    // Update data
    const section = statusElement.dataset.section;
    const index = parseInt(statusElement.dataset.index);
    inventoryData[section][index].status = nextStatus;
    
    scheduleAutoSave();
    updateSummary();
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
                
                // Calculate costs
                const actualPrice = item.actualPrice || item.estimatedPrice;
                const totalPrice = actualPrice * (item.quantity || 0);
                
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

    const totalDeposit = oneTimeTotal + perJobTotal + cliffTotal;

    // Update summary cards
    updateElement('totalItems', totalItems);
    updateElement('verifiedItems', verifiedItems);
    updateElement('oneTimeTotal', formatCurrency(oneTimeTotal));
    updateElement('perJobTotal', formatCurrency(perJobTotal));
    updateElement('cliffMaterials', formatCurrency(cliffTotal));
    updateElement('totalDeposit', formatCurrency(totalDeposit));

    // Update detailed summaries
    updateElement('cliff-total', formatCurrency(cliffTotal));
    updateElement('depositOneTime', formatCurrency(oneTimeTotal));
    updateElement('depositPerJob', formatCurrency(perJobTotal));
    updateElement('depositCliff', formatCurrency(cliffTotal));
    updateElement('depositTotal', formatCurrency(totalDeposit));
    
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
        localStorage.setItem(CONFIG.AUTO_SAVE.LOCAL_STORAGE_KEY, JSON.stringify(dataToSave));
    } catch (error) {
        console.error('Failed to save to localStorage:', error);
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
    const rows = [['Section', 'Item', 'Estimated Price', 'Actual Price', 'Quantity', 'Usage', 'Status', 'Link', 'Notes', 'Total Cost']];
    
    Object.keys(inventoryData).forEach(section => {
        if (Array.isArray(inventoryData[section])) {
            inventoryData[section].forEach(item => {
                const actualPrice = item.actualPrice || item.estimatedPrice;
                const totalCost = actualPrice * (item.quantity || 0);
                
                rows.push([
                    section,
                    item.name,
                    item.estimatedPrice,
                    item.actualPrice || '',
                    item.quantity,
                    item.usage,
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
    const headers = ['Section', 'Item', 'Estimated Price', 'Actual Price', 'Quantity', 'Usage', 'Status', 'Link', 'Notes', 'Total Cost'];
    const rows = [headers];
    
    Object.keys(inventoryData).forEach(section => {
        if (Array.isArray(inventoryData[section])) {
            inventoryData[section].forEach(item => {
                const actualPrice = item.actualPrice || item.estimatedPrice;
                const totalCost = actualPrice * (item.quantity || 0);
                
                rows.push([
                    section,
                    item.name,
                    item.estimatedPrice,
                    item.actualPrice || '',
                    item.quantity,
                    item.usage,
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
        initializeData();
        renderAllSections();
        updateSummary();
        
        // Clear project notes
        const notesElement = document.getElementById('projectNotes');
        if (notesElement) {
            notesElement.value = '';
        }
        
        showNotification('All data cleared', 'success');
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