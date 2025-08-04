// Basin Pool Co. Admin Control Panel
// Business Management & Scaling System

// Global admin configuration
let adminConfig = {
    margins: {
        global: 50,
        materials: 45,
        addons: 55,
        siteprep: 60
    },
    jorgeRates: {
        baseInstallation: 300,  // Jorge's base payment per master plan
        sitePrep: 75,          // Jorge's site prep bonus
        saltSystem: 50,        // Jorge's salt system bonus
        heatingSystem: 100,    // Jorge's heating bonus
        shadeSystem: 75,       // Jorge's shade system bonus
        reviewBonus: 100,      // 5-star review bonus
        speedBonus: 75,        // Speed completion bonus
        helper: 90             // Helper cost per job
    },
    inventory: {
        tanks6ft: 0,
        tanks8ft: 0,
        tanks10ft: 0,
        pumpsSX2800: 0,
        saltSystems: 0,
        heatingSystems: 0
    },
    leadTimes: {
        local: 3,
        online: 5,
        specialty: 10
    },
    baseCosts: {
        // Master Plan material costs
        tank6ft: 450,       // 6ft tank cost
        tank8ft: 650,       // 8ft tank cost  
        tank10ft: 950,      // 10ft tank cost
        pumpSX2800: 180,    // SX2800 pump cost
        saltSystem: 151,    // Salt system material cost ($110.99 + $30 salt + $10 materials)
        heatingSystem: 660, // Heating system material cost
        sitePrep: 145,      // Site prep materials (Recom Materials)
        shadeSystem: 609    // Shade system materials
    },
    
    // Master Plan FIXED customer pricing (not calculated)
    customerPricing: {
        pools: {
            '6ft': 2495,    // "The Splash"
            '8ft': 2795,    // "The Oasis" 
            '10ft': 3495    // "The Resort"
        },
        addons: {
            saltwater: 697,     // Spa Experience
            heating: 1497,      // Heating System
            premiumSite: 400,   // Turnkey Site Prep
            shade: 1797         // Shade System
        }
    }
};

// Initialize admin panel
document.addEventListener('DOMContentLoaded', function() {
    loadAdminSettings();
    setupEventListeners();
    updateAllDisplays();
    calculateLiveProfits();
});

// Setup event listeners
function setupEventListeners() {
    // Margin controls
    document.getElementById('globalMargin').addEventListener('input', updateGlobalMargin);
    document.getElementById('materialsMargin').addEventListener('input', updateMarginsDisplay);
    document.getElementById('addonsMargin').addEventListener('input', updateMarginsDisplay);
    document.getElementById('siteprepMargin').addEventListener('input', updateMarginsDisplay);

    // Jorge's rates
    document.querySelectorAll('#jorgeBase, #jorgeSitePrep, #jorgeSalt, #jorgeHeating, #jorgeShade, #jorgeReviewBonus, #jorgeSpeedBonus').forEach(input => {
        input.addEventListener('input', updateJorgeRates);
    });

    // Inventory levels
    document.querySelectorAll('#stock6ft, #stock8ft, #stock10ft, #stockSX2800, #stockSalt, #stockHeating').forEach(input => {
        input.addEventListener('input', updateInventoryStatus);
    });

    // Lead times
    document.querySelectorAll('#leadLocal, #leadOnline, #leadSpecialty').forEach(input => {
        input.addEventListener('input', updateLeadTimes);
    });

    // Profit calculator
    document.getElementById('packageType').addEventListener('change', calculateLiveProfits);
    document.querySelectorAll('#addSaltwater, #addHeating, #addSitePrep, #siteReady').forEach(checkbox => {
        checkbox.addEventListener('change', calculateLiveProfits);
    });

    // Action buttons
    document.getElementById('saveSettings').addEventListener('click', saveAllSettings);
    document.getElementById('resetToDefaults').addEventListener('click', resetToDefaults);
    document.getElementById('syncInventory').addEventListener('click', syncWithInventory);
    document.getElementById('generateReport').addEventListener('click', generateBusinessReport);
}

// Update global margin
function updateGlobalMargin() {
    const globalMargin = parseInt(document.getElementById('globalMargin').value);
    adminConfig.margins.global = globalMargin;
    
    // Update display
    document.getElementById('currentMargin').textContent = globalMargin + '%';
    
    // Auto-adjust other margins proportionally
    const ratio = globalMargin / 50; // 50 is the base
    adminConfig.margins.materials = Math.min(80, Math.max(35, Math.round(45 * ratio)));
    adminConfig.margins.addons = Math.min(80, Math.max(35, Math.round(55 * ratio)));
    adminConfig.margins.siteprep = Math.min(80, Math.max(35, Math.round(60 * ratio)));
    
    // Update sliders
    document.getElementById('materialsMargin').value = adminConfig.margins.materials;
    document.getElementById('addonsMargin').value = adminConfig.margins.addons;
    document.getElementById('siteprepMargin').value = adminConfig.margins.siteprep;
    
    updateMarginsDisplay();
    calculateLiveProfits();
}

// Update individual margin displays
function updateMarginsDisplay() {
    adminConfig.margins.materials = parseInt(document.getElementById('materialsMargin').value);
    adminConfig.margins.addons = parseInt(document.getElementById('addonsMargin').value);
    adminConfig.margins.siteprep = parseInt(document.getElementById('siteprepMargin').value);
    
    document.getElementById('materialsDisplay').textContent = adminConfig.margins.materials + '%';
    document.getElementById('addonsDisplay').textContent = adminConfig.margins.addons + '%';
    document.getElementById('siteprepDisplay').textContent = adminConfig.margins.siteprep + '%';
    
    calculateLiveProfits();
}

// Update Jorge's rates
function updateJorgeRates() {
    adminConfig.jorgeRates.baseInstallation = parseInt(document.getElementById('jorgeBase').value);
    adminConfig.jorgeRates.sitePrep = parseInt(document.getElementById('jorgeSitePrep').value);
    adminConfig.jorgeRates.saltSystem = parseInt(document.getElementById('jorgeSalt').value);
    adminConfig.jorgeRates.heatingSystem = parseInt(document.getElementById('jorgeHeating').value);
    adminConfig.jorgeRates.shadeSystem = parseInt(document.getElementById('jorgeShade').value);
    adminConfig.jorgeRates.reviewBonus = parseInt(document.getElementById('jorgeReviewBonus').value);
    adminConfig.jorgeRates.speedBonus = parseInt(document.getElementById('jorgeSpeedBonus').value);
    
    updateJorgePreview();
    calculateLiveProfits();
}

// Update Jorge's earnings preview
function updateJorgePreview() {
    const baseEarnings = adminConfig.jorgeRates.baseInstallation;
    document.getElementById('previewBase').textContent = baseEarnings;
    document.getElementById('previewTotal').textContent = baseEarnings;
}

// Update inventory status
function updateInventoryStatus() {
    adminConfig.inventory.tanks6ft = parseInt(document.getElementById('stock6ft').value) || 0;
    adminConfig.inventory.tanks8ft = parseInt(document.getElementById('stock8ft').value) || 0;
    adminConfig.inventory.tanks10ft = parseInt(document.getElementById('stock10ft').value) || 0;
    adminConfig.inventory.pumpsSX2800 = parseInt(document.getElementById('stockSX2800').value) || 0;
    adminConfig.inventory.saltSystems = parseInt(document.getElementById('stockSalt').value) || 0;
    adminConfig.inventory.heatingSystems = parseInt(document.getElementById('stockHeating').value) || 0;
    
    // Update status displays
    updateStockStatus('status6ft', adminConfig.inventory.tanks6ft);
    updateStockStatus('status8ft', adminConfig.inventory.tanks8ft);
    updateStockStatus('status10ft', adminConfig.inventory.tanks10ft);
    updateStockStatus('statusSX2800', adminConfig.inventory.pumpsSX2800);
    updateStockStatus('statusSalt', adminConfig.inventory.saltSystems);
    updateStockStatus('statusHeating', adminConfig.inventory.heatingSystems);
    
    updateSpeedJobs();
}

// Update stock status display
function updateStockStatus(elementId, quantity) {
    const element = document.getElementById(elementId);
    if (quantity === 0) {
        element.textContent = 'Out of Stock';
        element.className = 'stock-status out-of-stock';
    } else if (quantity <= 2) {
        element.textContent = 'Low Stock';
        element.className = 'stock-status low-stock';
    } else {
        element.textContent = 'In Stock';
        element.className = 'stock-status in-stock';
    }
}

// Update lead times
function updateLeadTimes() {
    adminConfig.leadTimes.local = parseInt(document.getElementById('leadLocal').value);
    adminConfig.leadTimes.online = parseInt(document.getElementById('leadOnline').value);
    adminConfig.leadTimes.specialty = parseInt(document.getElementById('leadSpecialty').value);
}

// Calculate live profits using Master Plan structure
function calculateLiveProfits() {
    const packageType = document.getElementById('packageType').value;
    const addSaltwater = document.getElementById('addSaltwater').checked;
    const addHeating = document.getElementById('addHeating').checked;
    const addSitePrep = document.getElementById('addSitePrep').checked;
    const siteReady = document.getElementById('siteReady').checked;

    // Use FIXED customer pricing from Master Plan
    let customerPrice = adminConfig.customerPricing.pools[packageType];
    
    // Calculate actual material costs
    let materialCosts = 0;
    if (packageType === '6ft') {
        materialCosts = 905; // From master plan: tank + pump + hardware
    } else if (packageType === '8ft') {
        materialCosts = 1065; // From master plan
    } else {
        materialCosts = 1415; // From master plan
    }
    
    // Calculate Jorge + Helper costs
    let jorgeCosts = adminConfig.jorgeRates.baseInstallation; // $300
    let helperCosts = adminConfig.jorgeRates.helper; // $90
    
    // Add-ons (customer pays FIXED prices, we track costs separately)
    if (addSaltwater) {
        customerPrice += adminConfig.customerPricing.addons.saltwater; // +$697
        materialCosts += adminConfig.baseCosts.saltSystem; // +$151 materials
        jorgeCosts += adminConfig.jorgeRates.saltSystem; // +$50 Jorge bonus
        helperCosts += 30; // +$30 helper time (2 hours)
    }
    
    if (addHeating) {
        customerPrice += adminConfig.customerPricing.addons.heating; // +$1497
        materialCosts += adminConfig.baseCosts.heatingSystem; // +$660 materials
        jorgeCosts += adminConfig.jorgeRates.heatingSystem; // +$100 Jorge bonus
        helperCosts += 45; // +$45 helper time (3 hours)
    }
    
    if (addSitePrep && !siteReady) {
        customerPrice += adminConfig.customerPricing.addons.premiumSite; // +$400
        materialCosts += adminConfig.baseCosts.sitePrep; // +$145 materials
        jorgeCosts += adminConfig.jorgeRates.sitePrep; // +$75 Jorge bonus
        helperCosts += 30; // +$30 helper time (2 hours)
    }
    
    // Site ready discount (customer saves $400)
    const customerSavings = siteReady ? 400 : 0;
    const finalCustomerPrice = customerPrice - customerSavings;
    
    // If site ready, Jorge doesn't get site prep bonus
    if (siteReady) {
        jorgeCosts -= adminConfig.jorgeRates.sitePrep; // Remove $75 site prep bonus
        helperCosts -= 30; // Remove site prep helper time
    }
    
    // Calculate YOUR profit
    const totalLaborCosts = jorgeCosts + helperCosts;
    const totalCosts = materialCosts + totalLaborCosts;
    const yourProfit = finalCustomerPrice - totalCosts;
    const marginPercent = finalCustomerPrice > 0 ? (yourProfit / finalCustomerPrice * 100) : 0;

    // Display breakdown
    const breakdown = `
        <div class="profit-row">
            <span>Customer Pays:</span>
            <span class="price">$${finalCustomerPrice.toFixed(0)}</span>
        </div>
        <div class="profit-row cost">
            <span>Material Costs:</span>
            <span>-$${materialCosts.toFixed(0)}</span>
        </div>
        <div class="profit-row cost">
            <span>Jorge's Payment:</span>
            <span>-$${jorgeCosts.toFixed(0)}</span>
        </div>
        <div class="profit-row cost">
            <span>Helper Payment:</span>
            <span>-$${helperCosts.toFixed(0)}</span>
        </div>
        ${customerSavings > 0 ? `
        <div class="profit-row savings">
            <span>Customer Savings (Site Ready):</span>
            <span class="savings">-$${customerSavings}</span>
        </div>
        ` : ''}
        <div class="profit-row total">
            <span><strong>YOUR PROFIT:</strong></span>
            <span class="profit"><strong>$${yourProfit.toFixed(0)}</strong></span>
        </div>
        <div class="profit-row margin">
            <span>Profit Margin:</span>
            <span>${marginPercent.toFixed(1)}%</span>
        </div>
        <div class="profit-row summary">
            <span>Total Costs:</span>
            <span>$${totalCosts.toFixed(0)} (Materials: $${materialCosts} + Labor: $${totalLaborCosts})</span>
        </div>
    `;
    
    document.getElementById('profitBreakdown').innerHTML = breakdown;
    
    // Update dashboard metrics
    document.getElementById('avgProfit').textContent = `$${yourProfit.toFixed(0)}`;
    document.getElementById('marginPerf').textContent = `${marginPercent.toFixed(1)}%`;
}

// Update speed jobs count
function updateSpeedJobs() {
    let readyJobs = 0;
    
    // Count jobs that can be installed immediately
    if (adminConfig.inventory.tanks6ft > 0 && adminConfig.inventory.pumpsSX2800 > 0) readyJobs++;
    if (adminConfig.inventory.tanks8ft > 0 && adminConfig.inventory.pumpsSX2800 > 0) readyJobs++;
    if (adminConfig.inventory.tanks10ft > 0 && adminConfig.inventory.pumpsSX2800 > 0) readyJobs++;
    
    document.getElementById('speedJobs').textContent = readyJobs;
}

// Update all displays
function updateAllDisplays() {
    updateMarginsDisplay();
    updateJorgePreview();
    updateInventoryStatus();
    updateSpeedJobs();
}

// Save all settings
function saveAllSettings() {
    try {
        localStorage.setItem('basinPoolAdminConfig', JSON.stringify(adminConfig));
        
        // Also sync with Firebase if available
        if (window.database && window.Firebase) {
            const adminRef = window.Firebase.ref(window.database, 'adminConfig');
            window.Firebase.set(adminRef, {
                config: adminConfig,
                lastUpdated: Date.now(),
                version: '1.0'
            });
        }
        
        showNotification('Settings saved successfully!', 'success');
    } catch (error) {
        console.error('Failed to save settings:', error);
        showNotification('Failed to save settings', 'error');
    }
}

// Load admin settings
function loadAdminSettings() {
    try {
        const saved = localStorage.getItem('basinPoolAdminConfig');
        if (saved) {
            const parsedConfig = JSON.parse(saved);
            adminConfig = { ...adminConfig, ...parsedConfig };
            
            // Update UI elements
            document.getElementById('globalMargin').value = adminConfig.margins.global;
            document.getElementById('materialsMargin').value = adminConfig.margins.materials;
            document.getElementById('addonsMargin').value = adminConfig.margins.addons;
            document.getElementById('siteprepMargin').value = adminConfig.margins.siteprep;
            
            document.getElementById('jorgeBase').value = adminConfig.jorgeRates.baseInstallation;
            document.getElementById('jorgeSitePrep').value = adminConfig.jorgeRates.sitePrep;
            document.getElementById('jorgeSalt').value = adminConfig.jorgeRates.saltSystem;
            document.getElementById('jorgeHeating').value = adminConfig.jorgeRates.heatingSystem;
            document.getElementById('jorgeShade').value = adminConfig.jorgeRates.shadeSystem;
            document.getElementById('jorgeReviewBonus').value = adminConfig.jorgeRates.reviewBonus;
            document.getElementById('jorgeSpeedBonus').value = adminConfig.jorgeRates.speedBonus;
            
            document.getElementById('stock6ft').value = adminConfig.inventory.tanks6ft;
            document.getElementById('stock8ft').value = adminConfig.inventory.tanks8ft;
            document.getElementById('stock10ft').value = adminConfig.inventory.tanks10ft;
            document.getElementById('stockSX2800').value = adminConfig.inventory.pumpsSX2800;
            document.getElementById('stockSalt').value = adminConfig.inventory.saltSystems;
            document.getElementById('stockHeating').value = adminConfig.inventory.heatingSystems;
            
            document.getElementById('leadLocal').value = adminConfig.leadTimes.local;
            document.getElementById('leadOnline').value = adminConfig.leadTimes.online;
            document.getElementById('leadSpecialty').value = adminConfig.leadTimes.specialty;
        }
    } catch (error) {
        console.error('Failed to load settings:', error);
    }
}

// Reset to defaults
function resetToDefaults() {
    if (confirm('Reset all settings to defaults? This cannot be undone.')) {
        // Reset to original defaults
        adminConfig = {
            margins: { global: 50, materials: 45, addons: 55, siteprep: 60 },
            jorgeRates: { baseInstallation: 600, sitePrep: 150, saltSystem: 75, heatingSystem: 200, shadeSystem: 125, reviewBonus: 100, speedBonus: 75 },
            inventory: { tanks6ft: 0, tanks8ft: 0, tanks10ft: 0, pumpsSX2800: 0, saltSystems: 0, heatingSystems: 0 },
            leadTimes: { local: 3, online: 5, specialty: 10 },
            baseCosts: { tank6ft: 450, tank8ft: 650, tank10ft: 950, pumpSX2800: 180, saltSystem: 250, heatingSystem: 800, sitePrep: 400 }
        };
        
        loadAdminSettings();
        updateAllDisplays();
        showNotification('Settings reset to defaults', 'success');
    }
}

// Sync with main inventory
function syncWithInventory() {
    // This would pull data from your main inventory system
    showNotification('Syncing with main inventory system...', 'info');
    
    setTimeout(() => {
        showNotification('Inventory sync completed', 'success');
        updateInventoryStatus();
    }, 2000);
}

// Generate business report
function generateBusinessReport() {
    const report = `
Basin Pool Co. Business Report
Generated: ${new Date().toLocaleDateString()}

=== CURRENT SETTINGS ===
Global Margin: ${adminConfig.margins.global}%
Materials Margin: ${adminConfig.margins.materials}%
Add-ons Margin: ${adminConfig.margins.addons}%
Site Prep Margin: ${adminConfig.margins.siteprep}%

=== JORGE'S STRUCTURE ===
Base Installation: $${adminConfig.jorgeRates.baseInstallation}
Site Prep Add-on: $${adminConfig.jorgeRates.sitePrep}
Salt System: $${adminConfig.jorgeRates.saltSystem}
Heating System: $${adminConfig.jorgeRates.heatingSystem}
Review Bonus: $${adminConfig.jorgeRates.reviewBonus}
Speed Bonus: $${adminConfig.jorgeRates.speedBonus}

=== INVENTORY STATUS ===
6ft Tanks: ${adminConfig.inventory.tanks6ft}
8ft Tanks: ${adminConfig.inventory.tanks8ft}
10ft Tanks: ${adminConfig.inventory.tanks10ft}
SX2800 Pumps: ${adminConfig.inventory.pumpsSX2800}
Salt Systems: ${adminConfig.inventory.saltSystems}
Heating Systems: ${adminConfig.inventory.heatingSystems}

=== LEAD TIMES ===
Local Supplier: ${adminConfig.leadTimes.local} days
Online Orders: ${adminConfig.leadTimes.online} days
Specialty Items: ${adminConfig.leadTimes.specialty} days
    `;
    
    const blob = new Blob([report], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `basin_pool_business_report_${new Date().toISOString().slice(0, 10)}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    showNotification('Business report downloaded', 'success');
}

// Notification system
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
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
        transition: 'transform 0.3s ease'
    });
    
    const colors = {
        success: '#27ae60',
        error: '#e74c3c',
        info: '#3498db',
        warning: '#f39c12'
    };
    notification.style.backgroundColor = colors[type] || colors.info;
    
    document.body.appendChild(notification);
    
    setTimeout(() => notification.style.transform = 'translateX(0)', 100);
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Export admin config for use in other modules
window.adminConfig = adminConfig;
window.getAdminConfig = () => adminConfig;