// Basin Pool Co. Inventory Tracker Configuration

const CONFIG = {
    // Firebase Configuration for Real-time Collaboration
    FIREBASE: {
        apiKey: "AIzaSyAxnc2XeHS8DrumOMGKfiD9uP12CYMEogU",
        authDomain: "basin-pool-inventory.firebaseapp.com",
        databaseURL: "https://basin-pool-inventory-default-rtdb.firebaseio.com",
        projectId: "basin-pool-inventory",
        storageBucket: "basin-pool-inventory.firebasestorage.app",
        messagingSenderId: "50367073628",
        appId: "1:50367073628:web:84eb3e794a39073ced37d1"
    },
    
    // Google Sheets API Configuration (Optional backup)
    GOOGLE_SHEETS: {
        API_KEY: 'YOUR_GOOGLE_SHEETS_API_KEY_HERE',
        SHEET_ID: 'YOUR_GOOGLE_SHEET_ID_HERE',
        SHEET_NAME: 'Inventory_Data'
    },
    
    // Auto-save settings
    AUTO_SAVE: {
        ENABLED: true,
        INTERVAL: 30000, // 30 seconds
        LOCAL_STORAGE_KEY: 'basin_pool_inventory'
    },
    
    // Firebase real-time sync settings
    FIREBASE_SYNC: {
        ENABLED: true, // Firebase is the primary collaboration method
        PRESENCE_ENABLED: true, // Show who's online
        OFFLINE_SUPPORT: true // Continue working offline
    },
    
    // Cloud sync settings (Google Sheets backup)
    CLOUD_SYNC: {
        ENABLED: false, // Set to true when API keys are configured
        INTERVAL: 300000, // 5 minutes
        RETRY_ATTEMPTS: 3,
        RETRY_DELAY: 5000 // 5 seconds
    },
    
    // Application settings
    APP: {
        VERSION: '4.0',
        NAME: 'Basin Pool Co. - Inventory Tracker',
        COMPANY: 'Basin Pool Co.'
    },
    
    // Notification settings
    NOTIFICATIONS: {
        SAVE_DURATION: 2000, // 2 seconds
        ERROR_DURATION: 5000, // 5 seconds
        SUCCESS_DURATION: 3000 // 3 seconds
    },
    
    // Export settings
    EXPORT: {
        FILENAME_PREFIX: 'basin_pool_inventory',
        CSV_DELIMITER: ',',
        INCLUDE_TIMESTAMP: true
    },
    
    // Default item structure
    DEFAULT_ITEM: {
        name: '',
        estimatedPrice: 0,
        actualPrice: 0,
        quantity: 0,
        usage: 'pending',
        link: '',
        status: 'pending',
        notes: ''
    },
    
    // Usage types and their colors
    USAGE_TYPES: {
        'one-time': { label: 'One-Time', color: '#e74c3c' },
        'per-job': { label: 'Per Job', color: '#f39c12' },
        'reusable': { label: 'Reusable', color: '#27ae60' },
        'consumable': { label: 'Consumable', color: '#8e44ad' }
    },
    
    // Status types and their colors
    STATUS_TYPES: {
        'pending': { label: 'Pending', color: '#e74c3c' },
        'partial': { label: 'Partial', color: '#f39c12' },
        'verified': { label: 'Verified', color: '#27ae60' }
    },
    
    // Section configurations
    SECTIONS: {
        'cliff': { name: 'Cliff\'s Installation', icon: '=�' },
        'tools': { name: 'One-Time Tools', icon: '='' },
        'tanks': { name: 'Additional Tanks', icon: '<�' },
        'pumps': { name: 'Pump Systems', icon: '�' },
        'salt': { name: 'Salt Water Systems', icon: '<
' },
        'heating': { name: 'Heating Systems', icon: '=%' },
        'hardware': { name: 'Standard Hardware', icon: '=�' }
    }
};

// Validate configuration on load
function validateConfig() {
    const warnings = [];
    
    if (!CONFIG.GOOGLE_SHEETS.API_KEY || CONFIG.GOOGLE_SHEETS.API_KEY === 'YOUR_GOOGLE_SHEETS_API_KEY_HERE') {
        warnings.push('Google Sheets API key not configured. Cloud sync will be disabled.');
        CONFIG.CLOUD_SYNC.ENABLED = false;
    }
    
    if (!CONFIG.GOOGLE_SHEETS.SHEET_ID || CONFIG.GOOGLE_SHEETS.SHEET_ID === 'YOUR_GOOGLE_SHEET_ID_HERE') {
        warnings.push('Google Sheet ID not configured. Cloud sync will be disabled.');
        CONFIG.CLOUD_SYNC.ENABLED = false;
    }
    
    if (warnings.length > 0) {
        console.warn('Configuration warnings:', warnings);
    }
    
    return warnings;
}

// Initialize configuration
document.addEventListener('DOMContentLoaded', function() {
    const warnings = validateConfig();
    if (warnings.length > 0 && window.location.hostname !== 'localhost') {
        // Only show warnings in production
        console.log('Please configure your Google Sheets API credentials in config.js for cloud sync functionality.');
    }
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}