// Basin Pool Co. Inventory Tracker Configuration

const CONFIG = {
    // Firebase Configuration for Real-time Collaboration
    FIREBASE: {
        apiKey: "AIzaSyAxnc2XeHS8DrumOMGKfiD9uP12CYMEogU",
        authDomain: "basin-pool-inventory.firebaseapp.com",
        databaseURL: "https://basin-pool-inventory-default-rtdb.firebaseio.com",
        projectId: "basin-pool-inventory",
        storageBucket: "basin-pool-inventory.firebasestorage.app",
        messagingSenderId: "503670730628",
        appId: "1:503670730628:web:84eb3e794a39073ced37d1"
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
    
    // Texas Sales Tax Settings
    TAX: {
        RATE: 0.0825, // 8.25% Texas sales tax
        ENABLED: true,
        // Items exempt from sales tax in Texas
        NON_TAXABLE_KEYWORDS: [
            'labor', 'installation', 'service', 'caliche', 'gravel', 'sand',
            'excavation', 'leveling'
        ],
        // Force non-taxable for specific usage types
        NON_TAXABLE_USAGE: ['labor-service']
    },
    
    // Receipt Scanner & OCR Settings
    RECEIPT_SCANNER: {
        ENABLED: true,
        // Veryfi OCR API Configuration
        OCR_API: {
            CLIENT_ID: 'vrfy_basin_pool_co_client_id_placeholder', // Replace with your Client ID
            USERNAME: 'basin_pool_co_username_placeholder',          // Replace with your Username  
            API_KEY: 'your_veryfi_api_key_here',                     // Replace with your API Key
            BASE_URL: 'https://api.veryfi.com/api/v8/partner/documents/',
            TIMEOUT: 30000, // 30 seconds
            // Production settings
            AUTO_DELETE: false,    // Keep processed documents 
            AUTO_ROTATE: true,     // Auto-rotate receipt images
            BOOST_MODE: true,      // Enhanced accuracy mode
            CATEGORIES: ['office supplies', 'hardware', 'materials'] // Receipt categorization
        },
        
        // Home Depot Product Lookup
        PRODUCT_LOOKUP: {
            ENABLED: false, // Enable after getting BigBox API key
            // BigBox API for Home Depot  
            HOME_DEPOT_API_KEY: 'your_bigbox_api_key_here', // Replace with your BigBox API key
            BASE_URL: 'https://api.bigboxapi.com/request',
            TIMEOUT: 10000, // 10 seconds
            // Product lookup settings
            VERIFY_PRICES: true,        // Cross-check receipt prices with store prices
            AUTO_CORRECT: false,        // Don't auto-correct, just flag differences
            PRICE_TOLERANCE: 0.05       // 5% tolerance for price differences
        },
        
        // Camera Settings
        CAMERA: {
            PREFERRED_CAMERA: 'environment', // 'environment' for back camera, 'user' for front
            VIDEO_CONSTRAINTS: {
                width: { ideal: 1920, max: 1920 },
                height: { ideal: 1080, max: 1080 },
                facingMode: 'environment'
            },
            PHOTO_QUALITY: 0.9 // JPEG quality 0-1
        }
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
        actualPrice: 0,
        quantity: 0,
        usage: 'pending',
        location: 'both',
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
        'pending': { label: '📋 Need to Order', color: '#e74c3c' },
        'ordered': { label: '🛒 Ordered', color: '#f39c12' },
        'purchased': { label: '✅ Purchased', color: '#27ae60' },
        'partial': { label: '⚠️ Partial', color: '#8e44ad' },
        'verified': { label: '✓ Verified', color: '#2c3e50' }
    },
    
    // Location types and their colors
    LOCATION_TYPES: {
        'online': { label: 'Online', color: '#3498db', description: 'Order online (Amazon, eBay, etc.)' },
        'local': { label: 'Local Midland TX', color: '#e67e22', description: 'Available locally within 60-mile radius of Midland, TX' },
        'both': { label: 'Both Options', color: '#9b59b6', description: 'Available both online and locally' }
    },
    
    // Section configurations
    SECTIONS: {
        'cliff': { name: 'Cliff Installation', icon: 'rocket' },
        'tools': { name: 'One-Time Tools', icon: 'wrench' },
        'tanks': { name: 'Additional Tanks', icon: 'pool' },
        'pumps': { name: 'Pump Systems', icon: 'gear' },
        'salt': { name: 'Salt Water Systems', icon: 'wave' },
        'heating': { name: 'Heating Systems', icon: 'fire' },
        'siteprep': { name: 'Site Preparation & Pad Installation', icon: 'construction' },
        'hardware': { name: 'Standard Hardware', icon: 'tools' }
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